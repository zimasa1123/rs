-- RS Nexus — shared state table for Supabase (multi-user, real-time sync)
-- Run this in Supabase → SQL Editor. Pairs with CLOUD.url/anonKey in the app (src/11-cloud.js / index.html).
--
-- This is the pragmatic "shared JSON document" backend: the whole CRM dataset lives in one row and is kept
-- in sync in real time. It's the fastest path to genuinely shared, multi-user data with the current app.
-- rsnexus-schema.sql has the fully normalized per-table design for a later migration to per-record queries
-- and fine-grained, role/branch-aware Row Level Security.

create table if not exists rsnexus_state (
  id         text primary key default 'main',
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

alter table rsnexus_state enable row level security;

-- Any signed-in user (all your teammates, once they have an account) can read and write the shared dataset.
-- This matches the app's current client-side role/permission checks. For stricter server-side enforcement,
-- move to the per-table schema in rsnexus-schema.sql and scope policies by role/branch there instead.
create policy "authenticated read" on rsnexus_state
  for select using (auth.role() = 'authenticated');

create policy "authenticated write" on rsnexus_state
  for insert with check (auth.role() = 'authenticated');

create policy "authenticated update" on rsnexus_state
  for update using (auth.role() = 'authenticated');

-- Enable real-time change broadcasts so every open browser tab updates live.
alter publication supabase_realtime add table rsnexus_state;
