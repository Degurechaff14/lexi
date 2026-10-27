-- Lexi: tablas y reglas de acceso para las cuentas.
-- Pegar completo en Supabase > SQL Editor > New query > Run.

-- Perfil público mínimo: solo el nombre de usuario.
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  username text unique not null check (char_length(btrim(username)) between 3 and 30 and username !~ '[<>]'),
  nivel text check (nivel in ('practicante','junior','experimentado','abogado')),
  guia text check (guia in ('valeria','mateo')),
  onboarded boolean not null default false,
  created_at timestamptz not null default now()
);

-- Datos de cada usuario (expedientes, notas y días inhábiles) en un solo documento.
create table if not exists public.user_data (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Cada persona solo puede leer y escribir lo suyo.
alter table public.profiles enable row level security;
alter table public.user_data enable row level security;

drop policy if exists "perfil propio: leer" on public.profiles;
create policy "perfil propio: leer" on public.profiles
  for select using (auth.uid() = id);
drop policy if exists "perfil propio: editar" on public.profiles;
create policy "perfil propio: editar" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "datos propios: leer" on public.user_data;
create policy "datos propios: leer" on public.user_data
  for select using (auth.uid() = user_id);
drop policy if exists "datos propios: crear" on public.user_data;
create policy "datos propios: crear" on public.user_data
  for insert with check (auth.uid() = user_id);
drop policy if exists "datos propios: editar" on public.user_data;
create policy "datos propios: editar" on public.user_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "datos propios: borrar" on public.user_data;
create policy "datos propios: borrar" on public.user_data
  for delete using (auth.uid() = user_id);

-- Crea el perfil al registrarse. Con correo usa el nombre elegido;
-- con Google genera uno a partir del correo.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  base text;
  uname text;
begin
  uname := lower(coalesce(new.raw_user_meta_data->>'username', ''));
  if uname !~ '^[a-z0-9_]{3,20}$' then
    base := left(regexp_replace(lower(split_part(new.email, '@', 1)), '[^a-z0-9_]', '', 'g'), 13);
    if length(base) < 3 then base := 'usuario'; end if;
    uname := base || '_' || substr(replace(new.id::text, '-', ''), 1, 6);
  end if;
  insert into public.profiles (id, username) values (new.id, uname);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Permite comprobar si un nombre de usuario está libre antes de registrarse.
create or replace function public.username_available(u text)
returns boolean language sql security definer set search_path = public stable as $$
  select not exists (select 1 from public.profiles where username = lower(u));
$$;
grant execute on function public.username_available(text) to anon, authenticated;

-- Después de este archivo, ejecutar también 002_bienvenida.sql y 003_configuracion.sql.
