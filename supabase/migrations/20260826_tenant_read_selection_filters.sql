-- ============================================================
-- COHABI - MATCHING TENANT / FILTROS DE SELECCIÓN DEL PISO
-- Permite al tenant usar los criterios del owner para calcular compatibilidad
-- solo en propiedades publicadas.
-- ============================================================

alter table public.property_selection_filters enable row level security;

drop policy if exists tenant_read_published_property_selection_filters
on public.property_selection_filters;

create policy tenant_read_published_property_selection_filters
on public.property_selection_filters
for select
to authenticated
using (
  exists (
    select 1
    from public.properties p
    where p.id = property_selection_filters.property_id
      and p.status = 'published'
  )
  and exists (
    select 1
    from public.tenant_profiles tp
    where tp.user_id = auth.uid()
  )
);
