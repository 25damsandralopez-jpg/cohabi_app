# Cohabi v13 — Gestión avanzada del piso

Esta actualización parte de la v12 estable con el hotfix de `owner_applications`.

## Qué añade

### Owner → Pisos
- Las tarjetas dejan de mostrar métricas falsas.
- Inquilinos, ingresos, incidencias, entradas y salidas se cargan desde Supabase.
- Al tocar un piso se abre un dashboard real de la propiedad.

### Dashboard de un piso
- Foto principal y número de fotos.
- Habitaciones y estado.
- Inquilinos/reservas.
- Próximas entradas y salidas.
- Ingresos mensuales y ocupación.
- Pagos cobrados y pendientes.
- Marcar un pago como cobrado.
- Gastos registrados.
- Incidencias abiertas.
- Mensajes/avisos para todos los inquilinos.
- Filtro de selección por piso.
- Datos básicos del inmueble.

### Tenant → Mi Casa
- Nueva sección de avisos enviados por el propietario.

## SQL obligatorio

Antes de probar las nuevas pantallas ejecuta en Supabase:

`supabase/migrations/20260824_v13_property_management.sql`

Crea:
- `property_announcements`
- `property_selection_filters`
- RLS de owner/tenant
- permiso para notificaciones de avisos

## Instalación

Opción recomendada:
1. Descomprime el ZIP en la raíz del proyecto Cohabi.
2. Ejecuta `INSTALAR_V13.bat`.
3. Ejecuta el SQL v13 en Supabase.
4. Si `flutter analyze` no muestra `error`, ejecuta la app.

El instalador no borra tu proyecto. Solo copia/reemplaza los archivos incluidos en este parche.
