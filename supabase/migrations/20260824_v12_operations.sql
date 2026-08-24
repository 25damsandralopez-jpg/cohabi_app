-- ============================================================
-- COHABI V12 - OPERACIONES DE ESTANCIA
-- Tenancies, pagos, incidencias, notificaciones y gastos
-- Idempotente sobre v9/v10/v11
-- ============================================================

create extension if not exists pgcrypto;

-- -------------------------
-- APPLICATIONS: notas owner
-- -------------------------
alter table if exists public.applications
  add column if not exists owner_notes text,
  add column if not exists owner_favorite boolean not null default false;

-- -------------------------
-- TENANCIES
-- -------------------------
create table if not exists public.tenancies (
  id uuid primary key default gen_random_uuid(),
  application_id uuid unique references public.applications(id) on delete set null,
  tenant_id uuid not null references public.profiles(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  room_id uuid not null references public.rooms(id) on delete restrict,
  start_date date,
  end_date date,
  monthly_rent numeric(10,2) not null default 0,
  deposit numeric(10,2) not null default 0,
  status text not null default 'reserved' check (status in ('reserved','active','ending','completed','cancelled')),
  check_in_at timestamptz,
  check_out_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists tenancies_owner_lookup on public.tenancies(property_id, status);
create index if not exists tenancies_tenant_lookup on public.tenancies(tenant_id, status);
create unique index if not exists tenancies_one_live_room
  on public.tenancies(room_id)
  where status in ('reserved','active','ending');

-- -------------------------
-- PAYMENTS
-- -------------------------
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  tenancy_id uuid not null references public.tenancies(id) on delete cascade,
  tenant_id uuid not null references public.profiles(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  room_id uuid not null references public.rooms(id) on delete restrict,
  concept text not null default 'Alquiler',
  amount numeric(10,2) not null,
  due_date date not null,
  paid_at timestamptz,
  status text not null default 'pending' check (status in ('pending','paid','partial','late','cancelled')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists payments_tenancy_due on public.payments(tenancy_id, due_date desc);
create index if not exists payments_property_due on public.payments(property_id, due_date desc);

-- -------------------------
-- INCIDENTS
-- -------------------------
create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  tenancy_id uuid references public.tenancies(id) on delete set null,
  property_id uuid not null references public.properties(id) on delete cascade,
  room_id uuid references public.rooms(id) on delete set null,
  tenant_id uuid references public.profiles(id) on delete set null,
  created_by uuid not null references public.profiles(id) on delete cascade,
  category text not null default 'Otros',
  title text not null,
  description text,
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  status text not null default 'new' check (status in ('new','reviewing','in_progress','resolved','closed')),
  owner_notes text,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists incidents_property_status on public.incidents(property_id, status, created_at desc);
create index if not exists incidents_tenant_status on public.incidents(tenant_id, status, created_at desc);

-- -------------------------
-- NOTIFICATIONS
-- -------------------------
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null default 'info',
  title text not null,
  body text,
  entity_type text,
  entity_id uuid,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_unread on public.notifications(user_id, is_read, created_at desc);

-- -------------------------
-- PROPERTY EXPENSES
-- -------------------------
create table if not exists public.property_expenses (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete cascade,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  category text not null,
  concept text,
  amount numeric(10,2) not null,
  expense_date date not null default current_date,
  recurring boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists property_expenses_owner_date on public.property_expenses(owner_id, expense_date desc);

-- -------------------------
-- FAVORITOS TENANT
-- -------------------------
create table if not exists public.tenant_favorites (
  tenant_id uuid not null references public.profiles(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (tenant_id, property_id)
);

-- -------------------------
-- updated_at triggers
-- -------------------------
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

do $$
declare
  t text;
begin
  foreach t in array array['tenancies','payments','incidents','property_expenses']
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

-- -------------------------
-- RLS
-- -------------------------
alter table public.tenancies enable row level security;
alter table public.payments enable row level security;
alter table public.incidents enable row level security;
alter table public.notifications enable row level security;
alter table public.property_expenses enable row level security;
alter table public.tenant_favorites enable row level security;

-- TENANCIES
drop policy if exists tenant_read_own_tenancies on public.tenancies;
create policy tenant_read_own_tenancies on public.tenancies
for select to authenticated
using (tenant_id = auth.uid());

drop policy if exists owner_manage_own_tenancies on public.tenancies;
create policy owner_manage_own_tenancies on public.tenancies
for all to authenticated
using (exists(select 1 from public.properties p where p.id = tenancies.property_id and p.owner_id = auth.uid()))
with check (exists(select 1 from public.properties p where p.id = tenancies.property_id and p.owner_id = auth.uid()));

-- PAYMENTS
drop policy if exists tenant_read_own_payments on public.payments;
create policy tenant_read_own_payments on public.payments
for select to authenticated using (tenant_id = auth.uid());

drop policy if exists owner_manage_property_payments on public.payments;
create policy owner_manage_property_payments on public.payments
for all to authenticated
using (exists(select 1 from public.properties p where p.id = payments.property_id and p.owner_id = auth.uid()))
with check (exists(select 1 from public.properties p where p.id = payments.property_id and p.owner_id = auth.uid()));

-- INCIDENTS
drop policy if exists tenant_read_own_incidents on public.incidents;
create policy tenant_read_own_incidents on public.incidents
for select to authenticated using (tenant_id = auth.uid() or created_by = auth.uid());

drop policy if exists tenant_create_own_incidents on public.incidents;
create policy tenant_create_own_incidents on public.incidents
for insert to authenticated
with check (
  created_by = auth.uid()
  and tenant_id = auth.uid()
  and exists (
    select 1 from public.tenancies t
    where t.id = incidents.tenancy_id
      and t.tenant_id = auth.uid()
      and t.property_id = incidents.property_id
      and t.status in ('reserved','active','ending')
  )
);

drop policy if exists owner_manage_property_incidents on public.incidents;
create policy owner_manage_property_incidents on public.incidents
for all to authenticated
using (exists(select 1 from public.properties p where p.id = incidents.property_id and p.owner_id = auth.uid()))
with check (exists(select 1 from public.properties p where p.id = incidents.property_id and p.owner_id = auth.uid()));

-- NOTIFICATIONS
drop policy if exists user_read_own_notifications on public.notifications;
create policy user_read_own_notifications on public.notifications
for select to authenticated using (user_id = auth.uid());

drop policy if exists user_update_own_notifications on public.notifications;
create policy user_update_own_notifications on public.notifications
for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- EXPENSES
drop policy if exists owner_manage_own_expenses on public.property_expenses;
create policy owner_manage_own_expenses on public.property_expenses
for all to authenticated
using (owner_id = auth.uid())
with check (
  owner_id = auth.uid()
  and exists(select 1 from public.properties p where p.id = property_expenses.property_id and p.owner_id = auth.uid())
);

-- FAVORITES
drop policy if exists tenant_manage_own_favorites on public.tenant_favorites;
create policy tenant_manage_own_favorites on public.tenant_favorites
for all to authenticated
using (tenant_id = auth.uid())
with check (tenant_id = auth.uid());

-- -------------------------
-- OWNER ACCEPT -> TENANCY
-- -------------------------
create or replace function public.owner_accept_application_v12(target_application_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  a public.applications%rowtype;
  r public.rooms%rowtype;
  v_tenancy_id uuid;
  tenant_name text;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into a from public.applications where id = target_application_id for update;
  if not found then raise exception 'Application not found'; end if;

  if not exists (
    select 1 from public.properties p
    where p.id = a.property_id and p.owner_id = auth.uid()
  ) then
    raise exception 'Not allowed';
  end if;

  select * into r from public.rooms where id = a.room_id for update;
  if not found then raise exception 'Room not found'; end if;

  update public.applications
  set status = 'accepted', updated_at = now()
  where id = a.id;

  update public.applications
  set status = 'rejected', updated_at = now()
  where room_id = a.room_id
    and id <> a.id
    and status not in ('accepted','rejected','withdrawn');

  -- Se mantiene 'Ocupada' por compatibilidad con el esquema actual.
  update public.rooms set status = 'Ocupada', updated_at = now() where id = a.room_id;

  insert into public.tenancies(
    application_id, tenant_id, property_id, room_id,
    start_date, monthly_rent, deposit, status
  ) values (
    a.id, a.tenant_id, a.property_id, a.room_id,
    r.available_from, coalesce(r.monthly_price,0), coalesce(r.deposit,0), 'reserved'
  )
  on conflict (application_id) do update
    set monthly_rent = excluded.monthly_rent,
        deposit = excluded.deposit,
        updated_at = now()
  returning id into v_tenancy_id;

  select trim(coalesce(first_name,'') || ' ' || coalesce(last_name,''))
    into tenant_name from public.profiles where id = a.tenant_id;

  insert into public.payments(tenancy_id, tenant_id, property_id, room_id, concept, amount, due_date, status)
  select v_tenancy_id, a.tenant_id, a.property_id, a.room_id, 'Primer alquiler', coalesce(r.monthly_price,0), coalesce(r.available_from,current_date), 'pending'
  where not exists (select 1 from public.payments p where p.tenancy_id = v_tenancy_id and p.concept = 'Primer alquiler');

  insert into public.notifications(user_id, type, title, body, entity_type, entity_id)
  values (
    a.tenant_id,
    'application_accepted',
    '¡Tu solicitud ha sido aceptada!',
    'El propietario ha aceptado tu solicitud. Ya puedes consultar Mi Casa.',
    'tenancy',
    v_tenancy_id
  );

  return v_tenancy_id;
end;
$$;

grant execute on function public.owner_accept_application_v12(uuid) to authenticated;

-- -------------------------
-- CHECK-IN OWNER
-- -------------------------
create or replace function public.owner_confirm_check_in(target_tenancy_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  t public.tenancies%rowtype;
begin
  select * into t from public.tenancies where id = target_tenancy_id for update;
  if not found then raise exception 'Tenancy not found'; end if;
  if not exists(select 1 from public.properties p where p.id=t.property_id and p.owner_id=auth.uid()) then
    raise exception 'Not allowed';
  end if;

  update public.tenancies
  set status='active', check_in_at=now(), start_date=coalesce(start_date,current_date), updated_at=now()
  where id=t.id;

  update public.rooms set status='Ocupada', updated_at=now() where id=t.room_id;

  insert into public.notifications(user_id,type,title,body,entity_type,entity_id)
  values(t.tenant_id,'check_in','Entrada confirmada','Tu estancia ya figura como activa en Cohabi.','tenancy',t.id);
end;
$$;

grant execute on function public.owner_confirm_check_in(uuid) to authenticated;

-- -------------------------
-- CHECK-OUT OWNER
-- -------------------------
create or replace function public.owner_confirm_check_out(target_tenancy_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  t public.tenancies%rowtype;
begin
  select * into t from public.tenancies where id = target_tenancy_id for update;
  if not found then raise exception 'Tenancy not found'; end if;
  if not exists(select 1 from public.properties p where p.id=t.property_id and p.owner_id=auth.uid()) then
    raise exception 'Not allowed';
  end if;

  update public.tenancies
  set status='completed', check_out_at=now(), end_date=coalesce(end_date,current_date), updated_at=now()
  where id=t.id;

  update public.rooms set status='Disponible', updated_at=now() where id=t.room_id;

  insert into public.notifications(user_id,type,title,body,entity_type,entity_id)
  values(t.tenant_id,'check_out','Estancia finalizada','La salida ha sido confirmada y la estancia queda en el histórico.','tenancy',t.id);
end;
$$;

grant execute on function public.owner_confirm_check_out(uuid) to authenticated;

-- -------------------------
-- MARK NOTIFICATION READ
-- -------------------------
create or replace function public.mark_all_notifications_read()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.notifications set is_read=true where user_id=auth.uid() and is_read=false;
$$;

grant execute on function public.mark_all_notifications_read() to authenticated;
