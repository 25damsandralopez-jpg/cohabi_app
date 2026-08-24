-- ============================================================
-- COHABI - FLUJO E2E OWNER <-> TENANT
-- Ejecutar una vez en Supabase SQL Editor.
-- Es idempotente sobre el esquema actual.
-- ============================================================

create extension if not exists pgcrypto;

-- ============================================================
-- APPLICATIONS
-- ============================================================

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid()
);

alter table public.applications
  add column if not exists tenant_id uuid references public.tenant_profiles(user_id) on delete cascade;

alter table public.applications
  add column if not exists property_id uuid references public.properties(id) on delete cascade;

alter table public.applications
  add column if not exists room_id uuid references public.rooms(id) on delete cascade;

alter table public.applications
  add column if not exists status text not null default 'pending';

alter table public.applications
  add column if not exists visit_scheduled_at timestamptz;

alter table public.applications
  add column if not exists created_at timestamptz not null default now();

alter table public.applications
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_applications_tenant_id
on public.applications(tenant_id);

create index if not exists idx_applications_property_id
on public.applications(property_id);

create index if not exists idx_applications_room_id
on public.applications(room_id);

create index if not exists idx_applications_status
on public.applications(status);

-- Evita duplicar interés para la misma habitación durante el MVP.
create unique index if not exists applications_tenant_room_unique
on public.applications(tenant_id, room_id);

-- ============================================================
-- VISIT SLOTS
-- ============================================================

create table if not exists public.application_visit_slots (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.applications(id) on delete cascade,
  scheduled_at timestamptz not null,
  status text not null default 'available',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.application_visit_slots
  add column if not exists application_id uuid references public.applications(id) on delete cascade;

alter table public.application_visit_slots
  add column if not exists scheduled_at timestamptz;

alter table public.application_visit_slots
  add column if not exists status text not null default 'available';

alter table public.application_visit_slots
  add column if not exists created_at timestamptz not null default now();

alter table public.application_visit_slots
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_visit_slots_application_id
on public.application_visit_slots(application_id);

create index if not exists idx_visit_slots_scheduled_at
on public.application_visit_slots(scheduled_at);

-- ============================================================
-- UPDATED_AT
-- ============================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_applications_updated_at on public.applications;
create trigger set_applications_updated_at
before update on public.applications
for each row execute function public.set_updated_at();

drop trigger if exists set_application_visit_slots_updated_at on public.application_visit_slots;
create trigger set_application_visit_slots_updated_at
before update on public.application_visit_slots
for each row execute function public.set_updated_at();

-- ============================================================
-- RLS BASE: PROPERTIES / ROOMS / PHOTOS
-- ============================================================

alter table public.properties enable row level security;
alter table public.rooms enable row level security;
alter table public.property_photos enable row level security;
alter table public.applications enable row level security;
alter table public.application_visit_slots enable row level security;

-- OWNER: properties

drop policy if exists owner_read_own_properties on public.properties;
create policy owner_read_own_properties
on public.properties for select to authenticated
using (owner_id = auth.uid());

drop policy if exists owner_create_property on public.properties;
create policy owner_create_property
on public.properties for insert to authenticated
with check (
  owner_id = auth.uid()
  and exists (
    select 1 from public.owner_profiles op
    where op.user_id = auth.uid()
  )
);

drop policy if exists owner_update_property on public.properties;
create policy owner_update_property
on public.properties for update to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

drop policy if exists owner_delete_property on public.properties;
create policy owner_delete_property
on public.properties for delete to authenticated
using (owner_id = auth.uid());

-- TENANT: published properties

drop policy if exists tenant_read_published_properties on public.properties;
create policy tenant_read_published_properties
on public.properties for select to authenticated
using (
  status = 'published'
  and exists (
    select 1 from public.tenant_profiles tp
    where tp.user_id = auth.uid()
  )
);

-- OWNER: rooms

drop policy if exists owner_manage_rooms on public.rooms;
create policy owner_manage_rooms
on public.rooms for all to authenticated
using (
  exists (
    select 1 from public.properties p
    where p.id = rooms.property_id
      and p.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.properties p
    where p.id = rooms.property_id
      and p.owner_id = auth.uid()
  )
);

-- TENANT: available rooms from published properties

drop policy if exists tenant_read_published_rooms on public.rooms;
create policy tenant_read_published_rooms
on public.rooms for select to authenticated
using (
  status = 'Disponible'
  and exists (
    select 1 from public.properties p
    where p.id = rooms.property_id
      and p.status = 'published'
  )
  and exists (
    select 1 from public.tenant_profiles tp
    where tp.user_id = auth.uid()
  )
);

-- OWNER: photo metadata

drop policy if exists owner_read_photo_records on public.property_photos;
create policy owner_read_photo_records
on public.property_photos for select to authenticated
using (owner_id = auth.uid());

drop policy if exists owner_create_photo_records on public.property_photos;
create policy owner_create_photo_records
on public.property_photos for insert to authenticated
with check (
  owner_id = auth.uid()
  and exists (
    select 1 from public.properties p
    where p.id = property_photos.property_id
      and p.owner_id = auth.uid()
  )
);

drop policy if exists owner_delete_photo_records on public.property_photos;
create policy owner_delete_photo_records
on public.property_photos for delete to authenticated
using (owner_id = auth.uid());

-- TENANT: photo metadata of published properties

drop policy if exists tenant_read_published_property_photos on public.property_photos;
create policy tenant_read_published_property_photos
on public.property_photos for select to authenticated
using (
  exists (
    select 1 from public.properties p
    where p.id = property_photos.property_id
      and p.status = 'published'
  )
  and exists (
    select 1 from public.tenant_profiles tp
    where tp.user_id = auth.uid()
  )
);

-- ============================================================
-- APPLICATION RLS
-- ============================================================

-- Tenant can see own applications.
drop policy if exists tenant_read_own_applications on public.applications;
create policy tenant_read_own_applications
on public.applications for select to authenticated
using (tenant_id = auth.uid());

-- Tenant can create an application only for an available room
-- belonging to a published property.
drop policy if exists tenant_create_application on public.applications;
create policy tenant_create_application
on public.applications for insert to authenticated
with check (
  tenant_id = auth.uid()
  and exists (
    select 1
    from public.rooms r
    join public.properties p on p.id = r.property_id
    where r.id = applications.room_id
      and p.id = applications.property_id
      and r.status = 'Disponible'
      and p.status = 'published'
  )
  and exists (
    select 1 from public.tenant_profiles tp
    where tp.user_id = auth.uid()
  )
);

-- Tenant may only withdraw its own open application directly.
drop policy if exists tenant_update_own_applications on public.applications;
create policy tenant_update_own_applications
on public.applications for update to authenticated
using (tenant_id = auth.uid())
with check (tenant_id = auth.uid());

-- Owner can see/update applications for properties they own.
drop policy if exists owner_read_property_applications on public.applications;
create policy owner_read_property_applications
on public.applications for select to authenticated
using (
  exists (
    select 1 from public.properties p
    where p.id = applications.property_id
      and p.owner_id = auth.uid()
  )
);

drop policy if exists owner_update_property_applications on public.applications;
create policy owner_update_property_applications
on public.applications for update to authenticated
using (
  exists (
    select 1 from public.properties p
    where p.id = applications.property_id
      and p.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.properties p
    where p.id = applications.property_id
      and p.owner_id = auth.uid()
  )
);

-- ============================================================
-- VISIT SLOT RLS
-- ============================================================

drop policy if exists tenant_read_visit_slots on public.application_visit_slots;
create policy tenant_read_visit_slots
on public.application_visit_slots for select to authenticated
using (
  exists (
    select 1 from public.applications a
    where a.id = application_visit_slots.application_id
      and a.tenant_id = auth.uid()
  )
);

drop policy if exists owner_manage_visit_slots on public.application_visit_slots;
create policy owner_manage_visit_slots
on public.application_visit_slots for all to authenticated
using (
  exists (
    select 1
    from public.applications a
    join public.properties p on p.id = a.property_id
    where a.id = application_visit_slots.application_id
      and p.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.applications a
    join public.properties p on p.id = a.property_id
    where a.id = application_visit_slots.application_id
      and p.owner_id = auth.uid()
  )
);

-- ============================================================
-- OWNER FEED RPC
-- Avoids opening profiles RLS to arbitrary owners.
-- ============================================================

create or replace function public.owner_application_feed()
returns table (
  application_id uuid,
  tenant_id uuid,
  tenant_name text,
  property_id uuid,
  property_name text,
  city text,
  room_id uuid,
  room_number integer,
  monthly_price numeric,
  status text,
  created_at timestamptz,
  visit_scheduled_at timestamptz
)
language sql
security definer
set search_path = ''
as $$
  select
    a.id,
    a.tenant_id,
    trim(concat_ws(' ', pr.first_name, pr.last_name)) as tenant_name,
    p.id,
    p.name,
    p.city,
    r.id,
    r.room_number,
    r.monthly_price,
    a.status,
    a.created_at,
    a.visit_scheduled_at
  from public.applications a
  join public.properties p on p.id = a.property_id
  join public.rooms r on r.id = a.room_id
  left join public.profiles pr on pr.id = a.tenant_id
  where p.owner_id = auth.uid()
  order by a.created_at desc;
$$;

-- ============================================================
-- OWNER ACTION RPCs
-- ============================================================

create or replace function public.owner_mark_application_under_review(
  target_application_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  update public.applications a
  set status = 'under_review'
  where a.id = target_application_id
    and a.status = 'pending'
    and exists (
      select 1 from public.properties p
      where p.id = a.property_id
        and p.owner_id = auth.uid()
    );

  if not found then
    raise exception 'Application not found or invalid state';
  end if;
end;
$$;

create or replace function public.owner_propose_visit(
  target_application_id uuid,
  proposed_slots text[]
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  slot_text text;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if coalesce(array_length(proposed_slots, 1), 0) = 0 then
    raise exception 'At least one visit slot is required';
  end if;

  if not exists (
    select 1
    from public.applications a
    join public.properties p on p.id = a.property_id
    where a.id = target_application_id
      and p.owner_id = auth.uid()
      and a.status in ('pending', 'under_review', 'visit_proposed')
  ) then
    raise exception 'Application not found or invalid state';
  end if;

  delete from public.application_visit_slots
  where application_id = target_application_id;

  foreach slot_text in array proposed_slots
  loop
    insert into public.application_visit_slots (
      application_id,
      scheduled_at,
      status
    ) values (
      target_application_id,
      slot_text::timestamptz,
      'available'
    );
  end loop;

  update public.applications
  set status = 'visit_proposed',
      visit_scheduled_at = null
  where id = target_application_id;
end;
$$;

create or replace function public.owner_reject_application(
  target_application_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  update public.applications a
  set status = 'rejected'
  where a.id = target_application_id
    and a.status in ('pending', 'under_review', 'visit_proposed', 'visit_confirmed')
    and exists (
      select 1 from public.properties p
      where p.id = a.property_id
        and p.owner_id = auth.uid()
    );

  if not found then
    raise exception 'Application not found or invalid state';
  end if;
end;
$$;

create or replace function public.owner_accept_application(
  target_application_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_room_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select a.room_id
  into target_room_id
  from public.applications a
  join public.properties p on p.id = a.property_id
  where a.id = target_application_id
    and p.owner_id = auth.uid()
    and a.status in ('visit_confirmed', 'under_review');

  if target_room_id is null then
    raise exception 'Application not found or invalid state';
  end if;

  update public.applications
  set status = 'accepted'
  where id = target_application_id;

  update public.rooms
  set status = 'Ocupada'
  where id = target_room_id;

  update public.applications
  set status = 'rejected'
  where room_id = target_room_id
    and id <> target_application_id
    and status in ('pending', 'under_review', 'visit_proposed', 'visit_confirmed');
end;
$$;

-- ============================================================
-- TENANT VISIT RPCs
-- ============================================================

create or replace function public.tenant_confirm_visit(
  target_slot_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_application_id uuid;
  target_time timestamptz;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select s.application_id, s.scheduled_at
  into target_application_id, target_time
  from public.application_visit_slots s
  join public.applications a on a.id = s.application_id
  where s.id = target_slot_id
    and s.status = 'available'
    and a.tenant_id = auth.uid()
    and a.status = 'visit_proposed';

  if target_application_id is null then
    raise exception 'Visit slot not found or invalid state';
  end if;

  update public.application_visit_slots
  set status = case when id = target_slot_id then 'selected' else 'cancelled' end
  where application_id = target_application_id;

  update public.applications
  set status = 'visit_confirmed',
      visit_scheduled_at = target_time
  where id = target_application_id;
end;
$$;

create or replace function public.tenant_decline_visit(
  target_application_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  update public.applications
  set status = 'visit_declined',
      visit_scheduled_at = null
  where id = target_application_id
    and tenant_id = auth.uid()
    and status = 'visit_proposed';

  if not found then
    raise exception 'Application not found or invalid state';
  end if;

  update public.application_visit_slots
  set status = 'cancelled'
  where application_id = target_application_id;
end;
$$;

-- ============================================================
-- GRANTS
-- ============================================================

revoke all on function public.owner_application_feed() from public;
revoke all on function public.owner_mark_application_under_review(uuid) from public;
revoke all on function public.owner_propose_visit(uuid, text[]) from public;
revoke all on function public.owner_reject_application(uuid) from public;
revoke all on function public.owner_accept_application(uuid) from public;
revoke all on function public.tenant_confirm_visit(uuid) from public;
revoke all on function public.tenant_decline_visit(uuid) from public;

grant execute on function public.owner_application_feed() to authenticated;
grant execute on function public.owner_mark_application_under_review(uuid) to authenticated;
grant execute on function public.owner_propose_visit(uuid, text[]) to authenticated;
grant execute on function public.owner_reject_application(uuid) to authenticated;
grant execute on function public.owner_accept_application(uuid) to authenticated;
grant execute on function public.tenant_confirm_visit(uuid) to authenticated;
grant execute on function public.tenant_decline_visit(uuid) to authenticated;

-- ============================================================
-- STORAGE READ FOR AUTHENTICATED USERS (MVP PROPERTY PHOTOS)
-- ============================================================

-- Allows signed URLs for published property photos during the MVP test.
drop policy if exists "authenticated_read_property_photos" on storage.objects;
create policy "authenticated_read_property_photos"
on storage.objects for select
to authenticated
using (bucket_id = 'property-photos');

-- ============================================================
-- QUICK CHECK
-- ============================================================

-- select id, tenant_id, property_id, room_id, status, visit_scheduled_at
-- from public.applications
-- order by created_at desc;
