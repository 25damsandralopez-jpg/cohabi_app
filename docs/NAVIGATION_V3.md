# Navegación multimodo Cohabi

## Tenant
- Inicio
- Selección
- Solicitudes
- Mi Casa
- Cuenta

Color activo: purple.

## Owner
- Inicio
- Propiedades
- Solicitudes
- Visitas
- Cuenta

Color activo: turquoise.

## Regla
`profiles.active_mode` decide qué menú se muestra en `AccountScreen`.

Los permisos reales siguen dependiendo de la existencia de `tenant_profiles` y `owner_profiles`.

Las pantallas de formulario o wizard (registro, activar perfil, fotos, habitaciones, etc.) no llevan bottom navigation para no mezclar navegación global con un flujo que debe completarse o cancelarse.

## Archivos
- `lib/core/widgets/tenant_bottom_navigation.dart`
- `lib/core/widgets/owner_bottom_navigation.dart`
- `lib/core/navigation/tenant_navigation.dart`
- `lib/core/navigation/owner_navigation.dart`
- `lib/screens/tenant_home_screen.dart`
- `lib/screens/properties_dashboard_screen.dart`
- `lib/screens/account_screen.dart`
