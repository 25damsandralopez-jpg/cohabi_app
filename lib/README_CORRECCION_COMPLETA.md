# Cohabi — corrección integral owner + tenant

Esta versión alinea el código Flutter con un único contrato SQL.

## Ejecutar primero

En Supabase > SQL Editor, ejecuta completo:

`supabase/migrations/20260824_cohabi_canonical_schema.sql`

El script es de migración/adaptación: añade columnas que falten y no borra los datos existentes.

## Cambios principales

- Corrige `record NEW has no field updated_at` añadiendo `updated_at` a todas las tablas que usan el trigger.
- `PropertyFeaturesScreen` ahora guarda `tenant_type`, `features`, `services` y `other_services`.
- `RoomPhotosScreen` evita duplicados de metadatos y publica el piso al completar la última habitación.
- Añade tablas/campos requeridos por tenant: selección, favoritos, solicitudes y slots de visita.
- Añade RPCs de cambio de modo, activación de perfiles y flujo de solicitudes/visitas.
- Añade RLS coherente para tenant/owner.
- Añade Storage privado `property-photos` y políticas.
- Activa Solicitudes y Visitas en el menú owner.
- Añade pantallas y servicios owner para revisar, proponer visita, aceptar y rechazar.

## Test punta a punta

1. Owner crea piso y todas sus habitaciones.
2. Al terminar la última habitación, `properties.status` pasa a `published`.
3. Tenant entra en Selección y ve habitaciones `Disponible`.
4. Tenant pulsa `Me interesa` -> `applications.status = pending`.
5. Owner > Solicitudes ve al candidato.
6. Owner marca revisar o propone visita.
7. Tenant > Solicitudes elige un slot.
8. La solicitud pasa a `visit_confirmed`.
9. Owner acepta -> `accepted`; la habitación pasa a `Ocupada` y las demás solicitudes abiertas de esa habitación pasan a `rejected`.

## Consultas de comprobación

```sql
select id,name,status,owner_id from public.properties order by created_at desc;
select id,property_id,room_number,status,monthly_price from public.rooms order by created_at desc;
select id,tenant_id,property_id,room_id,status,visit_scheduled_at from public.applications order by created_at desc;
select * from public.application_visit_slots order by scheduled_at;
```
