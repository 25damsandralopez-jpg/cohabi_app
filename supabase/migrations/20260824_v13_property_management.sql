-- ============================================================
-- COHABI V13 - GESTIÓN AVANZADA DEL PISO
-- Dashboard por propiedad, avisos y filtros de selección
-- Ejecutar después de la migración V12.
-- ============================================================

create extension if not exists pgcrypto;

create table if not exists public.property_announcements (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete cascade,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists property_announcements_property_created
  on public.property_announcements(property_id, created_at desc);

create table if not exists public.property_selection_filters (
  property_id uuid primary key references public.properties(id) on delete cascade,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  min_age int,
  max_age int,
  min_stay_months int,
  min_monthly_income numeric(10,2),
  non_smokers_only boolean not null default false,
  no_pets boolean not null default false,
  income_verifiable boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint property_selection_filters_age_check
    check (min_age is null or max_age is null or min_age <= max_age)
);

alter table public.property_announcements enable row level security;
alter table public.property_selection_filters enable row level security;

-- Owner: avisos de sus propiedades.
drop policy if exists owner_manage_property_announcements on public.property_announcements;
create policy owner_manage_property_announcements
on public.property_announcements
for all to authenticated
using (
  owner_id = auth.uid()
  and exists (
    select 1 from public.properties p
    where p.id = property_announcements.property_id
      and p.owner_id = auth.uid()
  )
)
with check (
  owner_id = auth.uid()
  and exists (
    select 1 from public.properties p
    where p.id = property_announcements.property_id
      and p.owner_id = auth.uid()
  )
);

-- Tenant: puede leer avisos solo de un piso en el que tiene reserva/estancia.
drop policy if exists tenant_read_current_property_announcements on public.property_announcements;
create policy tenant_read_current_property_announcements
on public.property_announcements
for select to authenticated
using (
  exists (
    select 1 from public.tenancies t
    where t.property_id = property_announcements.property_id
      and t.tenant_id = auth.uid()
      and t.status in ('reserved','active','ending')
  )
);

-- Filtros: solo owner del piso.
drop policy if exists owner_manage_property_selection_filters on public.property_selection_filters;
create policy owner_manage_property_selection_filters
on public.property_selection_filters
for all to authenticated
using (
  owner_id = auth.uid()
  and exists (
    select 1 from public.properties p
    where p.id = property_selection_filters.property_id
      and p.owner_id = auth.uid()
  )
)
with check (
  owner_id = auth.uid()
  and exists (
    select 1 from public.properties p
    where p.id = property_selection_filters.property_id
      and p.owner_id = auth.uid()
  )
);

-- Trigger updated_at solo para la tabla que sí tiene la columna.
drop trigger if exists set_updated_at on public.property_selection_filters;
create trigger set_updated_at
before update on public.property_selection_filters
for each row execute function public.set_updated_at();

-- Permite al owner crear notificaciones para tenants vinculados a sus propiedades.
-- Esto hace que un aviso del piso también aparezca en la campana del tenant.
drop policy if exists owner_insert_tenant_notifications on public.notifications;
create policy owner_insert_tenant_notifications
on public.notifications
for insert to authenticated
with check (
  exists (
    select 1
    from public.tenancies t
    join public.properties p on p.id = t.property_id
    where t.tenant_id = notifications.user_id
      and p.owner_id = auth.uid()
      and t.status in ('reserved','active','ending')
      and (
        notifications.entity_type <> 'property'
        or notifications.entity_id is null
        or notifications.entity_id = t.property_id
      )
  )
);
