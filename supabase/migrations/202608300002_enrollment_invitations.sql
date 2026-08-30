create type public.child_sex as enum ('girl', 'boy', 'not_specified');
create type public.invitation_status as enum ('pending', 'sent', 'failed');

alter table public.children
  add column sex public.child_sex not null default 'not_specified',
  add column notes text,
  add column medical_notes text,
  add column emergency_contact_name text,
  add column emergency_contact_phone text;

create table public.enrollment_invitations (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  email text not null,
  full_name text not null,
  role public.app_role not null,
  relationship text,
  invited_by uuid references public.profiles(id) on delete set null,
  status public.invitation_status not null default 'pending',
  error_message text,
  created_at timestamptz not null default now(),
  sent_at timestamptz
);

alter table public.enrollment_invitations enable row level security;

create policy "Members can read center enrollment invitations"
on public.enrollment_invitations for select
to authenticated
using (public.is_center_member(center_id));

create index enrollment_invitations_center_id_idx
  on public.enrollment_invitations(center_id);

create index enrollment_invitations_child_id_idx
  on public.enrollment_invitations(child_id);
