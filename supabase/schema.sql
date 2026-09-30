-- SoCreate Tradeshow Lead Capture schema.
-- Run once in the Supabase dashboard: SQL Editor > New query > paste > Run.
-- Safe to re-run.

create table if not exists public.customer_leads (
  lead_id       uuid        primary key default gen_random_uuid(),
  first_name    text        not null check (length(btrim(first_name)) > 0),
  last_name     text        not null check (length(btrim(last_name)) > 0),
  company_name  text        null,
  email_address text        not null
                check (email_address ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  employee_name text        not null check (length(btrim(employee_name)) > 0),
  date_created  timestamptz not null default now()
);

create index if not exists customer_leads_employee_date_idx
  on public.customer_leads (employee_name, date_created);

-- The app ships the anon key, so ids and timestamps are set by the database
-- and text is normalized no matter what the client sends.
create or replace function public.customer_leads_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.lead_id       := gen_random_uuid();
  new.date_created  := now();
  new.first_name    := btrim(new.first_name);
  new.last_name     := btrim(new.last_name);
  new.company_name  := nullif(btrim(new.company_name), '');
  new.email_address := lower(btrim(new.email_address));
  new.employee_name := btrim(new.employee_name);
  return new;
end;
$$;

drop trigger if exists customer_leads_before_insert on public.customer_leads;
create trigger customer_leads_before_insert
  before insert on public.customer_leads
  for each row execute function public.customer_leads_before_insert();

-- Anonymous clients may add leads and nothing else. Reading, editing and
-- deleting rows is only possible from the Supabase dashboard.
alter table public.customer_leads enable row level security;

revoke all on public.customer_leads from anon, authenticated;
grant insert on public.customer_leads to anon, authenticated;

drop policy if exists "App can add leads" on public.customer_leads;
create policy "App can add leads"
  on public.customer_leads
  for insert
  to anon, authenticated
  with check (true);

-- Counts for one employee. day_start/day_end are the phone's local midnight
-- boundaries so "today" follows the show's time zone.
create or replace function public.employee_stats(
  p_employee_name text,
  p_day_start     timestamptz,
  p_day_end       timestamptz
)
returns table (today_count bigint, show_total bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select
    count(*) filter (
      where date_created >= p_day_start and date_created < p_day_end
    ) as today_count,
    count(*) as show_total
  from public.customer_leads
  where employee_name = btrim(p_employee_name);
$$;

-- Every employee's show total, highest first. Returns names and counts only.
create or replace function public.leaderboard()
returns table (employee_rank bigint, employee_name text, lead_count bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select
    rank() over (order by count(*) desc) as employee_rank,
    employee_name,
    count(*) as lead_count
  from public.customer_leads
  group by employee_name
  order by lead_count desc, employee_name;
$$;

revoke all on function public.employee_stats(text, timestamptz, timestamptz) from public;
revoke all on function public.leaderboard() from public;
grant execute on function public.employee_stats(text, timestamptz, timestamptz) to anon, authenticated;
grant execute on function public.leaderboard() to anon, authenticated;
