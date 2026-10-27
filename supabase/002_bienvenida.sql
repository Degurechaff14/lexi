-- Lexi: datos de la bienvenida (nivel de experiencia y guía elegida).
-- Pegar en Supabase > SQL Editor > New query > Run. Se puede ejecutar más de una vez.
alter table public.profiles
  add column if not exists nivel text check (nivel in ('practicante','junior','experimentado','abogado')),
  add column if not exists guia text check (guia in ('valeria','mateo')),
  add column if not exists onboarded boolean not null default false;
