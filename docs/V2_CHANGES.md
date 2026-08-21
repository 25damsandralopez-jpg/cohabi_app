# Cohabi Refactor v2

## Cambios principales

- `AccountScreen` dividido en widgets reutilizables.
- `EnableOwnerProfileScreen` y `EnableTenantProfileScreen` reducidos y conectados a `AccountService`.
- Corregido `LoginScreen`: usa `active_mode` en lugar de la columna eliminada `role`.
- Añadidos widgets de cuenta:
  - `AccountProfileCard`
  - `ActiveModeCard`
  - `ChangeModeCard`
  - `AccountProfilesCard`
  - `AccountSettingsCard`
- Se mantiene la arquitectura multimodo:
  - `active_mode` decide la interfaz activa.
  - `tenant_profiles` habilita capacidades tenant.
  - `owner_profiles` habilita capacidades owner.

## Pendiente para v3

- Refactor completo de `OwnerRegisterScreen`.
- Refactor completo de `TenantRegisterScreen`.
- Unificar el wizard de propiedades.
- Extraer navegación de dashboards/homes.
