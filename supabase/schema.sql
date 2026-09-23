-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query)

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  classifications text[] default '{}',   -- subset of GF, GFI, DF
  stores text[] default '{}',            -- subset of Coles, Woolworths, Aldi, Other
  links jsonb default '{}',              -- { "Coles": "https://...", ... }
  image text,                            -- URL (see README re: uploaded images)
  rating smallint default 0,
  added_by text,
  updated_at timestamptz not null default now()
);

-- Keep updated_at current on every edit
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_products_updated_at on products;
create trigger trg_products_updated_at
  before update on products
  for each row execute function set_updated_at();

-- Row Level Security
alter table products enable row level security;

-- MVP policy: anyone with the anon key can read/write.
-- This matches a "shared link" trust model (like the Claude artifact version) —
-- fine for a small trusted group, but anyone with your Supabase URL + anon key
-- can add/edit/delete. See README for how to lock this down further.
create policy "public read" on products
  for select using (true);

create policy "public insert" on products
  for insert with check (true);

create policy "public update" on products
  for update using (true);

create policy "public delete" on products
  for delete using (true);

-- Enable realtime so all connected browsers see changes live
alter publication supabase_realtime add table products;
