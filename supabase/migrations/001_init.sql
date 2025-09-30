-- Assets table
create table public.asset (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id),
  filename text not null,
  mime text not null,
  size int not null,
  storage_path text not null unique,
  sha256 text,
  status text not null check (status in ('draft', 'uploading', 'ready', 'corrupt')),
  version int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Asset shares
create table public.asset_share (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.asset(id) on delete cascade,
  to_user uuid not null references auth.users(id) on delete cascade,
  can_download boolean not null default true,
  unique(asset_id, to_user)
);

-- Upload tickets
create table public.upload_ticket (
  asset_id uuid primary key references public.asset(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  nonce text not null unique,
  mime text not null,
  size int not null,
  storage_path text not null,
  expires_at timestamptz not null,
  used boolean not null default false
);

-- Download audit
create table public.download_audit (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.asset(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  at timestamptz not null default now()
);

-- Enable RLS
alter table public.asset enable row level security;
alter table public.asset_share enable row level security;
alter table public.upload_ticket enable row level security;
alter table public.download_audit enable row level security;

-- Policies
create policy "owner can CRUD own assets"
on public.asset for all to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "shared users can read"
on public.asset for select to authenticated
using (
  owner_id = auth.uid()
  or exists(select 1 from public.asset_share s where s.asset_id = asset.id and s.to_user = auth.uid())
);

create policy "owner manages shares"
on public.asset_share for all to authenticated
using (exists(select 1 from public.asset a where a.id = asset_share.asset_id and a.owner_id = auth.uid()))
with check (exists(select 1 from public.asset a where a.id = asset_share.asset_id and a.owner_id = auth.uid()));

create policy "owner manages ticket"
on public.upload_ticket for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());
