-- =============================================================
-- Supabase setup para "De la Conversación a la Coordinación"
-- Ejecutar UNA SOLA VEZ en SQL Editor de Supabase.
-- =============================================================

-- Tabla de respuestas anónimas
create table if not exists public.responses (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  priorities      text[] not null,
  other_priority  text,
  role            text not null,
  engagement      text not null,
  horizon         text not null,
  norm            text not null
);

-- RLS: solo permitir INSERT anónimo, nunca SELECT individual
alter table public.responses enable row level security;

drop policy if exists "anon_insert" on public.responses;
create policy "anon_insert" on public.responses
  for insert to anon
  with check (
    array_length(priorities, 1) between 1 and 3
  );

-- Función pública para obtener contador y agregados
-- (mantiene anonimato: no expone filas individuales)
create or replace function public.get_stats()
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object(
    'count',       (select count(*) from responses),
    'priorities',  (select json_object_agg(p, c) from (
                      select unnest(priorities) p, count(*) c
                      from responses group by 1) t),
    'role',        (select json_object_agg(role, c)
                      from (select role, count(*) c
                            from responses group by 1) t),
    'engagement',  (select json_object_agg(engagement, c)
                      from (select engagement, count(*) c
                            from responses group by 1) t),
    'horizon',     (select json_object_agg(horizon, c)
                      from (select horizon, count(*) c
                            from responses group by 1) t),
    'norm',        (select json_object_agg(norm, c)
                      from (select norm, count(*) c
                            from responses group by 1) t)
  );
$$;

grant execute on function public.get_stats() to anon;
