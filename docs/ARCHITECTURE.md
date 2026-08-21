
# Cohabi — Arquitectura y reglas técnicas

Este documento define las reglas comunes que deben seguir las partes de Propietario e Inquilino para desarrollar Cohabi en paralelo sin romper la estructura compartida.

## 1. Principios base

- Supabase es la fuente de verdad para Auth, Base de Datos y Storage.
- `auth.users.id` es el ID maestro de cada usuario.
- Todos los IDs son UUID.
- Roles permitidos:
  - `owner`
  - `tenant`
- Todas las columnas SQL usan `snake_case`.
- Todas las tablas accesibles desde Flutter deben tener RLS.
- Nunca usar `service_role` dentro de Flutter.
- Una entidad real = una tabla.
- No duplicar datos si ya pueden obtenerse mediante relaciones.
- Todo cambio de base de datos debe hacerse mediante migraciones SQL.

---

# 2. Arquitectura general

```text
auth.users
    │
    └── trigger handle_new_user()
            │
            ▼
        profiles
       /        \
owner_profiles  tenant_profiles
      │              │
      ▼              │
 properties          │
      │               │
      ▼               │
    rooms             │
      │               │
      └──────┬────────┘
             ▼
        applications
             │
        ┌────┴────┐
        ▼         ▼
      visits    matches
        │
        ▼
     tenancies
        │
   ┌────┼─────────────┐
   ▼    ▼             ▼
incidents documents reviews
        │
  notifications
