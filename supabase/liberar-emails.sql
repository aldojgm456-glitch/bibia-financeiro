-- Rode UMA vez no SQL Editor do Supabase.
-- Depois disso, "Primeiro acesso" no app cria a conta sozinho para os e-mails desta lista.

create table if not exists public.emails_liberados (
  email text primary key
);
alter table public.emails_liberados enable row level security;  -- sem policies: ninguém acessa pela API

insert into public.emails_liberados (email) values ('aldojgm456@gmail.com')
on conflict do nothing;

create or replace function public.checa_email_liberado()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.emails_liberados where lower(email) = lower(new.email)) then
    raise exception 'Este e-mail nao foi liberado';
  end if;
  return new;
end $$;

drop trigger if exists bloqueia_email_nao_liberado on auth.users;
create trigger bloqueia_email_nao_liberado
  before insert on auth.users
  for each row execute function public.checa_email_liberado();

-- Para liberar mais gente depois:
--   insert into public.emails_liberados values ('outra@pessoa.com');
-- Para liberar para qualquer um (cada pessoa só vê os próprios dados via RLS):
--   drop trigger bloqueia_email_nao_liberado on auth.users;
