-- Cohabi: cuenta multimodo definitiva (tenant / owner)
-- Requiere las tablas profiles, tenant_profiles y owner_profiles existentes.

alter table public.profiles
add column if not exists active_mode text;

alter table public.profiles
drop constraint if exists profiles_active_mode_check;

alter table public.profiles
add constraint profiles_active_mode_check
check (active_mode in ('tenant', 'owner'));

alter table public.profiles
drop constraint if exists profiles_role_check;

alter table public.profiles
drop column if exists role;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  initial_mode text;
begin
  initial_mode :=
    case
      when new.raw_user_meta_data ->> 'account_type' = 'owner' then 'owner'
      else 'tenant'
    end;

  insert into public.profiles (
    id,
    first_name,
    last_name,
    phone,
    active_mode
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', ''),
    new.raw_user_meta_data ->> 'phone',
    initial_mode
  );

  if initial_mode = 'owner' then
    insert into public.owner_profiles (
      user_id,
      owner_type,
      company_name,
      document_number,
      city,
      province,
      language
    )
    values (
      new.id,
      new.raw_user_meta_data ->> 'owner_type',
      nullif(new.raw_user_meta_data ->> 'company_name', ''),
      new.raw_user_meta_data ->> 'document_number',
      new.raw_user_meta_data ->> 'city',
      new.raw_user_meta_data ->> 'province',
      coalesce(new.raw_user_meta_data ->> 'language', 'Español')
    );
  end if;

  if initial_mode = 'tenant' then
    insert into public.tenant_profiles (
      user_id,
      birth_date,
      gender,
      nationality,
      nationality_code,
      language,
      search_city,
      accommodation_type,
      entry_date,
      stay_duration,
      max_monthly_budget,
      search_zone,
      room_size,
      smoker,
      has_pet,
      occupation,
      monthly_income,
      has_guarantor,
      share_room,
      desired_environment
    )
    values (
      new.id,
      case
        when nullif(new.raw_user_meta_data ->> 'birth_date', '') is not null
        then to_date(new.raw_user_meta_data ->> 'birth_date', 'DD/MM/YYYY')
        else null
      end,
      new.raw_user_meta_data ->> 'gender',
      new.raw_user_meta_data ->> 'nationality',
      new.raw_user_meta_data ->> 'nationality_code',
      coalesce(new.raw_user_meta_data ->> 'language', 'Español'),
      new.raw_user_meta_data ->> 'search_city',
      new.raw_user_meta_data ->> 'accommodation_type',
      case
        when nullif(new.raw_user_meta_data ->> 'entry_date', '') is not null
          and new.raw_user_meta_data ->> 'entry_date' <> 'Selecciona una fecha'
        then to_date(new.raw_user_meta_data ->> 'entry_date', 'DD/MM/YYYY')
        else null
      end,
      new.raw_user_meta_data ->> 'stay_duration',
      case
        when nullif(new.raw_user_meta_data ->> 'max_monthly_budget', '') is not null
        then (new.raw_user_meta_data ->> 'max_monthly_budget')::numeric
        else null
      end,
      new.raw_user_meta_data ->> 'search_zone',
      new.raw_user_meta_data ->> 'room_size',
      new.raw_user_meta_data ->> 'smoker',
      new.raw_user_meta_data ->> 'has_pet',
      new.raw_user_meta_data ->> 'occupation',
      new.raw_user_meta_data ->> 'monthly_income',
      new.raw_user_meta_data ->> 'has_guarantor',
      new.raw_user_meta_data ->> 'share_room',
      new.raw_user_meta_data ->> 'desired_environment'
    );
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.switch_active_mode(target_mode text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if target_mode not in ('tenant', 'owner') then
    raise exception 'Invalid mode';
  end if;

  if target_mode = 'tenant'
     and not exists (
       select 1 from public.tenant_profiles where user_id = auth.uid()
     ) then
    raise exception 'Tenant profile does not exist';
  end if;

  if target_mode = 'owner'
     and not exists (
       select 1 from public.owner_profiles where user_id = auth.uid()
     ) then
    raise exception 'Owner profile does not exist';
  end if;

  update public.profiles
  set active_mode = target_mode
  where id = auth.uid();
end;
$$;

create or replace function public.enable_owner_profile(profile_data jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  owner_type_value text;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  owner_type_value := profile_data ->> 'owner_type';

  if owner_type_value not in ('Particular', 'Empresa', 'Agencia inmobiliaria') then
    raise exception 'Invalid owner type';
  end if;

  insert into public.owner_profiles (
    user_id,
    owner_type,
    company_name,
    document_number,
    city,
    province,
    language
  )
  values (
    auth.uid(),
    owner_type_value,
    nullif(profile_data ->> 'company_name', ''),
    nullif(profile_data ->> 'document_number', ''),
    nullif(profile_data ->> 'city', ''),
    nullif(profile_data ->> 'province', ''),
    coalesce(nullif(profile_data ->> 'language', ''), 'Español')
  )
  on conflict (user_id) do update set
    owner_type = excluded.owner_type,
    company_name = excluded.company_name,
    document_number = excluded.document_number,
    city = excluded.city,
    province = excluded.province,
    language = excluded.language;

  update public.profiles
  set active_mode = 'owner'
  where id = auth.uid();
end;
$$;

create or replace function public.enable_tenant_profile(profile_data jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.tenant_profiles (
    user_id,
    birth_date,
    gender,
    nationality,
    nationality_code,
    language,
    search_city,
    accommodation_type,
    entry_date,
    stay_duration,
    max_monthly_budget,
    search_zone,
    room_size,
    smoker,
    has_pet,
    occupation,
    monthly_income,
    has_guarantor,
    share_room,
    desired_environment
  )
  values (
    auth.uid(),
    case
      when nullif(profile_data ->> 'birth_date', '') is not null
      then to_date(profile_data ->> 'birth_date', 'DD/MM/YYYY')
      else null
    end,
    profile_data ->> 'gender',
    profile_data ->> 'nationality',
    profile_data ->> 'nationality_code',
    coalesce(nullif(profile_data ->> 'language', ''), 'Español'),
    profile_data ->> 'search_city',
    profile_data ->> 'accommodation_type',
    case
      when nullif(profile_data ->> 'entry_date', '') is not null
        and profile_data ->> 'entry_date' <> 'Selecciona una fecha'
      then to_date(profile_data ->> 'entry_date', 'DD/MM/YYYY')
      else null
    end,
    profile_data ->> 'stay_duration',
    case
      when nullif(profile_data ->> 'max_monthly_budget', '') is not null
      then (profile_data ->> 'max_monthly_budget')::numeric
      else null
    end,
    profile_data ->> 'search_zone',
    profile_data ->> 'room_size',
    profile_data ->> 'smoker',
    profile_data ->> 'has_pet',
    profile_data ->> 'occupation',
    profile_data ->> 'monthly_income',
    profile_data ->> 'has_guarantor',
    profile_data ->> 'share_room',
    profile_data ->> 'desired_environment'
  )
  on conflict (user_id) do update set
    birth_date = excluded.birth_date,
    gender = excluded.gender,
    nationality = excluded.nationality,
    nationality_code = excluded.nationality_code,
    language = excluded.language,
    search_city = excluded.search_city,
    accommodation_type = excluded.accommodation_type,
    entry_date = excluded.entry_date,
    stay_duration = excluded.stay_duration,
    max_monthly_budget = excluded.max_monthly_budget,
    search_zone = excluded.search_zone,
    room_size = excluded.room_size,
    smoker = excluded.smoker,
    has_pet = excluded.has_pet,
    occupation = excluded.occupation,
    monthly_income = excluded.monthly_income,
    has_guarantor = excluded.has_guarantor,
    share_room = excluded.share_room,
    desired_environment = excluded.desired_environment;

  update public.profiles
  set active_mode = 'tenant'
  where id = auth.uid();
end;
$$;

revoke all on function public.switch_active_mode(text) from public;
revoke all on function public.enable_owner_profile(jsonb) from public;
revoke all on function public.enable_tenant_profile(jsonb) from public;

grant execute on function public.switch_active_mode(text) to authenticated;
grant execute on function public.enable_owner_profile(jsonb) to authenticated;
grant execute on function public.enable_tenant_profile(jsonb) to authenticated;
