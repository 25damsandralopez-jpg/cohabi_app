# Cohabi — Arquitectura y reglas técnicas

Este documento define la arquitectura compartida de Cohabi para que las partes de Propietario e Inquilino puedan desarrollarse en paralelo sin duplicar entidades ni romper permisos.

## 1. Principios base

- Supabase es la fuente de verdad para Auth, Base de Datos y Storage.
- `auth.users.id` es el UUID maestro de cada usuario.
- Todos los IDs principales son UUID.
- Una misma cuenta puede tener capacidades de **inquilino**, **propietario** o ambas.
- `profiles.active_mode` indica únicamente qué experiencia está usando el usuario ahora: `tenant` u `owner`.
- Los permisos/capacidades se determinan por la existencia de `tenant_profiles` y `owner_profiles`, no por `active_mode`.
- Todas las columnas SQL usan `snake_case`.
- Dart usa `camelCase`.
- Todas las tablas accesibles desde Flutter deben tener RLS.
- Nunca usar `service_role` o claves secretas dentro de Flutter.
- Una entidad real = una tabla compartida.
- No duplicar datos si ya pueden obtenerse mediante relaciones.
- Todo cambio de base de datos compartido debe guardarse como migración SQL.

## 2. Cuenta multimodo

```text
auth.users
    │
    ▼
 profiles
    │
    ├───────────────┐
    ▼               ▼
tenant_profiles  owner_profiles
```

`profiles` contiene los datos comunes y `active_mode`.

Ejemplos válidos:

```text
Solo inquilino:
tenant_profiles ✅
owner_profiles  ❌
active_mode = tenant

Solo propietario:
tenant_profiles ❌
owner_profiles  ✅
active_mode = owner

Cuenta híbrida:
tenant_profiles ✅
owner_profiles  ✅
active_mode = tenant | owner
```

### Regla crítica

`active_mode` **no concede permisos**. Solo controla la interfaz/navegación activa.

- Existe `tenant_profiles` → puede utilizar funciones de inquilino.
- Existe `owner_profiles` → puede utilizar funciones de propietario.

## 3. Registro

Flutter registra una única identidad en Supabase Auth y envía el tipo inicial mediante metadata:

```dart
data: {
  'account_type': 'tenant', // o owner
  ...
}
```

El trigger `handle_new_user()` crea:

```text
account_type = tenant
→ profiles(active_mode = tenant)
→ tenant_profiles

account_type = owner
→ profiles(active_mode = owner)
→ owner_profiles
```

Flutter no debe hacer inserts manuales en `profiles`, `tenant_profiles` u `owner_profiles` durante el alta inicial.

## 4. Cambio de modo

Funciones RPC compartidas:

- `switch_active_mode(target_mode)`
- `enable_owner_profile(profile_data)`
- `enable_tenant_profile(profile_data)`

Flujo tenant → owner:

```text
¿Existe owner_profiles?
├── Sí → switch_active_mode('owner')
└── No → formulario owner
         → enable_owner_profile(...)
         → active_mode = owner
```

Flujo owner → tenant:

```text
¿Existe tenant_profiles?
├── Sí → switch_active_mode('tenant')
└── No → formulario tenant
         → enable_tenant_profile(...)
         → active_mode = tenant
```

Nunca crear una segunda cuenta Auth para cambiar de modo.

## 5. Entidades principales

```text
auth.users
    │
    ▼
profiles
 ├───────────────┐
 ▼               ▼
tenant_profiles  owner_profiles
                     │
                     ▼
                 properties
                     │
                     ▼
                   rooms
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
   property_photos          applications
                                  │
                          ┌───────┴───────┐
                          ▼               ▼
                       visits           matches
                          │
                          ▼
                       tenancies
                          │
                 ┌────────┼────────┐
                 ▼        ▼        ▼
             incidents documents reviews
                          │
                     notifications
```

Tablas futuras como `applications`, `matches`, `visits`, `tenancies`, `contracts`, `documents`, `incidents`, `notifications` y `reviews` deben ser compartidas por ambos modos.

## 6. Propiedades

`properties.owner_id` usa directamente el UUID del usuario propietario.

Estados permitidos:

```text
draft
published
archived
```

- Al crear una propiedad: `draft`.
- Al terminar el wizard: `published`.
- Los tenants solo leen propiedades `published`.

## 7. RLS

RLS es obligatorio.

### Perfil común

El usuario puede leer su propio `profiles`.

### Capacidad tenant

Las políticas tenant deben comprobar la existencia de:

```sql
exists (
  select 1
  from public.tenant_profiles
  where user_id = auth.uid()
)
```

No comprobar `active_mode = 'tenant'` para conceder acceso.

### Capacidad owner

Las políticas owner deben comprobar la propiedad del recurso y, cuando corresponda, la existencia de `owner_profiles`.

Ejemplo conceptual:

```sql
owner_id = auth.uid()
and exists (
  select 1
  from public.owner_profiles
  where user_id = auth.uid()
)
```

## 8. Storage

Bucket de fotografías: `property-photos`.

Ruta recomendada:

```text
<owner_id>/<property_id>/<tipo>/<archivo>
```

La existencia de un registro en `property_photos` no concede por sí sola acceso al objeto de Storage. Las policies de `storage.objects` también deben permitir la lectura/escritura adecuada.

Nunca hacer público el bucket únicamente para evitar escribir políticas.

## 9. Convenciones de código Flutter

### Estructura recomendada

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_radius.dart
│   │   ├── app_spacing.dart
│   │   └── app_text_styles.dart
│   ├── widgets/
│   │   ├── cohabi_card.dart
│   │   ├── cohabi_primary_button.dart
│   │   ├── cohabi_text_field.dart
│   │   ├── cohabi_dropdown.dart
│   │   ├── cohabi_checkbox_card.dart
│   │   ├── cohabi_snackbar.dart
│   │   ├── cohabi_step_indicator.dart
│   │   ├── cohabi_section_header.dart
│   │   └── cohabi_bottom_navigation.dart
│   └── services/
│       ├── auth_service.dart
│       └── profile_service.dart
├── features/
│   ├── account/
│   │   ├── models/
│   │   └── services/
│   └── properties/
│       └── widgets/
└── screens/              # transición: pantallas actuales
```

Las pantallas actuales pueden seguir en `lib/screens/` mientras se refactorizan gradualmente. No mover todo de golpe si genera cientos de cambios de imports.

### Regla de reutilización

Si un bloque visual aparece en tres pantallas, convertirlo en widget compartido.

Ejemplos compartidos:

- botón principal Cohabi,
- cards,
- text fields,
- dropdowns,
- snackbar,
- step indicator,
- bottom navigation.

## 10. Servicios

Las pantallas no deberían concentrar toda la lógica de Supabase.

Servicios base:

- `AuthService`: login, signup, logout.
- `ProfileService`: acceso a perfiles.
- `AccountService`: carga de cuenta multimodo, cambio de modo y activación de perfiles.

A medida que crezca el proyecto se crearán servicios por feature, por ejemplo:

```text
PropertyService
ApplicationService
VisitService
TenancyService
NotificationService
```

## 11. Wizard de propiedades

Las pantallas de creación de propiedad forman un único flujo conceptual:

```text
PropertyRegister
→ PropertyFeatures
→ PropertyPhotos
→ PropertyRooms
→ RoomFeatures
→ RoomPhotos
→ PropertyCompleted
```

Deben reutilizar componentes comunes para:

- indicador de paso,
- botón continuar,
- cards de subida de fotos,
- cards de consejos.

No duplicar `_buildStepIndicator`, `_buildContinueButton`, `_buildPhotoCard` o `_buildTipsBox` en cada pantalla.

## 12. Git y coordinación

- Cambios de DB compartidos → `supabase/migrations`.
- No cambiar nombres de columnas/tablas sin coordinar ambas partes.
- `main` debe representar una versión estable.
- Trabajar en ramas feature y fusionar mediante PR.
- Antes de fusionar: ejecutar formatter, analyzer y pruebas disponibles.

## 13. Reglas que no se deben romper

1. Una cuenta Auth por persona.
2. Un usuario puede tener ambos perfiles.
3. `active_mode` no es autorización.
4. Nunca `service_role` en Flutter.
5. RLS siempre activo en datos sensibles.
6. Una entidad compartida no se duplica por modo.
7. No copiar widgets comunes a múltiples pantallas.
8. No mezclar credenciales o secretos en Git.
9. No hacer cambios de esquema directamente en producción sin migración.
