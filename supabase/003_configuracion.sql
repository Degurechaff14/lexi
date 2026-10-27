-- Lexi: nombres de usuario libres, mensajes al equipo y eliminación de cuenta.
-- Pegar completo en Supabase > SQL Editor > New query > Run. Se puede ejecutar más de una vez.

-- 1. Nombres de usuario con mayúsculas, espacios y tildes (3 a 30 caracteres).
alter table public.profiles drop constraint if exists profiles_username_check;
alter table public.profiles add constraint profiles_username_check
  check (char_length(btrim(username)) between 3 and 30 and username !~ '[<>]');
-- "Arles Red" y "arles red" cuentan como el mismo nombre.
create unique index if not exists profiles_username_lower_idx on public.profiles (lower(username));

create or replace function public.username_available(u text)
returns boolean language sql security definer set search_path = public stable as $$
  select not exists (
    select 1 from public.profiles
    where lower(username) = lower(btrim(u)) and id is distinct from auth.uid()
  );
$$;
grant execute on function public.username_available(text) to anon, authenticated;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  base text;
  uname text;
begin
  uname := regexp_replace(btrim(coalesce(new.raw_user_meta_data->>'username', '')), '\s+', ' ', 'g');
  if char_length(uname) not between 3 and 30 or uname ~ '[<>]'
     or exists (select 1 from public.profiles where lower(username) = lower(uname)) then
    base := left(regexp_replace(lower(split_part(new.email, '@', 1)), '[^a-z0-9_]', '', 'g'), 20);
    if length(base) < 3 then base := 'usuario'; end if;
    uname := base || '_' || substr(replace(new.id::text, '-', ''), 1, 6);
  end if;
  insert into public.profiles (id, username) values (new.id, uname);
  return new;
end;
$$;

-- 2. Mensajes que los usuarios envían desde Lexi. Solo los lee la administración (panel de Supabase).
create table if not exists public.mensajes (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  email text,
  asunto text not null check (char_length(asunto) between 1 and 120),
  mensaje text not null check (char_length(mensaje) between 1 and 2000),
  created_at timestamptz not null default now()
);
alter table public.mensajes enable row level security;
drop policy if exists "mensajes: enviar" on public.mensajes;
create policy "mensajes: enviar" on public.mensajes
  for insert to authenticated with check (auth.uid() = user_id);

-- 3. Eliminar la propia cuenta (borra también perfil, datos y mensajes).
create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then
    raise exception 'No has iniciado sesión';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- Recarga la lista de funciones y tablas para que la web las vea al instante.
notify pgrst, 'reload schema';
