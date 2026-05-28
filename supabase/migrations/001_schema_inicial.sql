-- ============================================================
-- PrimazIA — Migration 001: Schema Inicial
-- Execute no SQL Editor do Supabase
-- ============================================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE user_role AS ENUM (
  'super_admin',
  'admin',
  'financial_admin',
  'pastor',
  'coordinator',
  'teacher',
  'guardian',
  'member',
  'student',
  'visitor'
);

CREATE TYPE request_status AS ENUM (
  'pending', 'approved', 'rejected', 'cancelled'
);

CREATE TYPE event_status AS ENUM (
  'draft', 'published', 'full', 'cancelled', 'finished'
);

CREATE TYPE registration_status AS ENUM (
  'registered', 'confirmed', 'paid', 'present', 'absent', 'cancelled'
);

CREATE TYPE course_status AS ENUM (
  'draft', 'published', 'archived'
);

CREATE TYPE enrollment_status AS ENUM (
  'pending', 'active', 'in_progress', 'completed', 'blocked', 'cancelled'
);

CREATE TYPE transaction_type AS ENUM ('income', 'expense');

CREATE TYPE transaction_status AS ENUM (
  'active', 'cancelled', 'archived'
);

CREATE TYPE appointment_status AS ENUM (
  'requested', 'confirmed', 'done', 'rescheduled', 'cancelled'
);

CREATE TYPE child_feedback_visibility AS ENUM ('private', 'guardians', 'all_staff');

CREATE TYPE notice_type AS ENUM ('general', 'urgent', 'pastoral', 'event');

-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================

CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  email         TEXT NOT NULL,
  phone         TEXT,
  avatar_url    TEXT,
  role          user_role NOT NULL DEFAULT 'member',
  is_active     BOOLEAN NOT NULL DEFAULT true,
  approved_by   UUID REFERENCES profiles(id),
  approved_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

-- Index
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_active ON profiles(is_active);

-- ============================================================
-- ROLE UPGRADE REQUESTS
-- ============================================================

CREATE TABLE role_requests (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  current_role     user_role NOT NULL,
  requested_role   user_role NOT NULL,
  justification    TEXT NOT NULL,
  status           request_status NOT NULL DEFAULT 'pending',
  reviewed_by      UUID REFERENCES profiles(id),
  review_note      TEXT,
  reviewed_at      TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_role_requests_user ON role_requests(user_id);
CREATE INDEX idx_role_requests_status ON role_requests(status);

-- ============================================================
-- CHURCH SETTINGS
-- ============================================================

CREATE TABLE church_settings (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key           TEXT NOT NULL UNIQUE,
  value         JSONB NOT NULL DEFAULT '{}',
  updated_by    UUID REFERENCES profiles(id),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Default settings
INSERT INTO church_settings (key, value) VALUES
  ('church_info', '{"name":"Igreja Batista Central","address":"","whatsapp":"","email":"","vision":"","mission":"","values":"","logo_url":""}'),
  ('service_schedule', '[]'),
  ('modules_config', '{"financial_visible_to_pastor":false,"enable_public_registration":true}');

-- ============================================================
-- NOTICES / AVISOS
-- ============================================================

CREATE TABLE notices (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        notice_type NOT NULL DEFAULT 'general',
  is_active   BOOLEAN NOT NULL DEFAULT true,
  is_public   BOOLEAN NOT NULL DEFAULT false,
  created_by  UUID NOT NULL REFERENCES profiles(id),
  updated_by  UUID REFERENCES profiles(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at  TIMESTAMPTZ
);

CREATE INDEX idx_notices_active ON notices(is_active);
CREATE INDEX idx_notices_created_at ON notices(created_at DESC);

-- ============================================================
-- MEMBERS
-- ============================================================

CREATE TABLE members (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id    UUID REFERENCES profiles(id) ON DELETE SET NULL,
  full_name     TEXT NOT NULL,
  email         TEXT,
  phone         TEXT,
  birth_date    DATE,
  gender        TEXT CHECK (gender IN ('M', 'F', 'other', 'not_informed')),
  ministry      TEXT,
  status        TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'transferred', 'deceased')),
  notes         TEXT,
  created_by    UUID REFERENCES profiles(id),
  updated_by    UUID REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX idx_members_profile ON members(profile_id);
CREATE INDEX idx_members_status ON members(status);
CREATE INDEX idx_members_ministry ON members(ministry);

-- ============================================================
-- VISITORS
-- ============================================================

CREATE TABLE visitors (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name       TEXT NOT NULL,
  visit_date      DATE NOT NULL,
  service_type    TEXT NOT NULL,
  gender          TEXT CHECK (gender IN ('M', 'F', 'other', 'not_informed')),
  age             INT,
  age_range       TEXT,
  neighborhood    TEXT,
  city            TEXT,
  phone           TEXT,
  how_found       TEXT,
  wants_contact   BOOLEAN NOT NULL DEFAULT false,
  is_recurring    BOOLEAN NOT NULL DEFAULT false,
  first_visit_id  UUID REFERENCES visitors(id),
  pastoral_notes  TEXT,
  consent_contact BOOLEAN NOT NULL DEFAULT false,
  status          TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  registered_by   UUID NOT NULL REFERENCES profiles(id),
  updated_by      UUID REFERENCES profiles(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_visitors_visit_date ON visitors(visit_date DESC);
CREATE INDEX idx_visitors_status ON visitors(status);
CREATE INDEX idx_visitors_registered_by ON visitors(registered_by);

-- ============================================================
-- EVENTS
-- ============================================================

CREATE TABLE events (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title         TEXT NOT NULL,
  description   TEXT,
  event_date    DATE NOT NULL,
  start_time    TIME,
  end_time      TIME,
  location      TEXT,
  max_spots     INT DEFAULT 0, -- 0 = unlimited
  price         NUMERIC(10,2) DEFAULT 0,
  is_free       BOOLEAN NOT NULL DEFAULT true,
  status        event_status NOT NULL DEFAULT 'draft',
  is_public     BOOLEAN NOT NULL DEFAULT false,
  image_url     TEXT,
  created_by    UUID NOT NULL REFERENCES profiles(id),
  updated_by    UUID REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ
);

CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_date ON events(event_date DESC);

CREATE TABLE event_registrations (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id     UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status       registration_status NOT NULL DEFAULT 'registered',
  payment_ref  TEXT,
  checked_in   BOOLEAN DEFAULT false,
  checked_in_at TIMESTAMPTZ,
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_reg_event ON event_registrations(event_id);
CREATE INDEX idx_event_reg_user ON event_registrations(user_id);

-- ============================================================
-- COURSES
-- ============================================================

CREATE TABLE courses (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title         TEXT NOT NULL,
  description   TEXT,
  instructor    TEXT,
  workload      TEXT,
  status        course_status NOT NULL DEFAULT 'draft',
  is_public     BOOLEAN NOT NULL DEFAULT false,
  thumbnail_url TEXT,
  created_by    UUID NOT NULL REFERENCES profiles(id),
  updated_by    UUID REFERENCES profiles(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE course_modules (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT,
  order_num   INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE course_lessons (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  module_id   UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT,
  video_url   TEXT,
  duration    TEXT,
  order_num   INT NOT NULL DEFAULT 0,
  is_free     BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE course_enrollments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status          enrollment_status NOT NULL DEFAULT 'pending',
  payment_ref     TEXT,
  enrolled_by     UUID REFERENCES profiles(id),
  progress_pct    INT DEFAULT 0,
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(course_id, user_id)
);

CREATE TABLE lesson_progress (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id   UUID NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  completed   BOOLEAN NOT NULL DEFAULT false,
  watched_at  TIMESTAMPTZ,
  UNIQUE(lesson_id, user_id)
);

-- ============================================================
-- MINISTRIES
-- ============================================================

CREATE TABLE ministries (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  description TEXT,
  leader_id   UUID REFERENCES profiles(id),
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ministry_members (
  ministry_id UUID NOT NULL REFERENCES ministries(id) ON DELETE CASCADE,
  member_id   UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  role        TEXT DEFAULT 'member',
  joined_at   DATE,
  PRIMARY KEY(ministry_id, member_id)
);

-- ============================================================
-- CHILDREN (MINISTÉRIO INFANTIL)
-- ============================================================

CREATE TABLE children_classes (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name         TEXT NOT NULL,
  age_range    TEXT,
  teacher_id   UUID REFERENCES profiles(id),
  is_active    BOOLEAN NOT NULL DEFAULT true,
  created_by   UUID REFERENCES profiles(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE children (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name        TEXT NOT NULL,
  birth_date       DATE,
  class_id         UUID REFERENCES children_classes(id),
  gender           TEXT CHECK (gender IN ('M', 'F', 'other')),
  allergies        TEXT,
  special_needs    TEXT,
  consent_given    BOOLEAN NOT NULL DEFAULT false,
  consent_date     TIMESTAMPTZ,
  consent_by       UUID REFERENCES profiles(id),
  status           TEXT NOT NULL DEFAULT 'active',
  created_by       UUID NOT NULL REFERENCES profiles(id),
  updated_by       UUID REFERENCES profiles(id),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMPTZ
);

CREATE TABLE children_guardians (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id     UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  profile_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  relationship TEXT NOT NULL DEFAULT 'guardian',
  is_primary   BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(child_id, profile_id)
);

CREATE TABLE children_attendance (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id   UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  class_id   UUID NOT NULL REFERENCES children_classes(id),
  date       DATE NOT NULL,
  present    BOOLEAN NOT NULL DEFAULT false,
  recorded_by UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE children_lesson_reports (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  class_id       UUID NOT NULL REFERENCES children_classes(id),
  lesson_date    DATE NOT NULL,
  theme          TEXT,
  activity       TEXT,
  general_notes  TEXT,
  teacher_id     UUID NOT NULL REFERENCES profiles(id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE children_feedbacks (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id       UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  report_id      UUID REFERENCES children_lesson_reports(id),
  behavior       TEXT CHECK (behavior IN ('excellent', 'good', 'regular', 'needs_attention')),
  text           TEXT NOT NULL,
  private_notes  TEXT,
  visibility     child_feedback_visibility NOT NULL DEFAULT 'private',
  teacher_id     UUID NOT NULL REFERENCES profiles(id),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_children_class ON children(class_id);
CREATE INDEX idx_children_guardians_profile ON children_guardians(profile_id);
CREATE INDEX idx_children_feedbacks_child ON children_feedbacks(child_id);
CREATE INDEX idx_children_attendance_child ON children_attendance(child_id, date);

-- ============================================================
-- PASTORAL SCHEDULE
-- ============================================================

CREATE TABLE pastoral_availability (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pastor_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  time_slots  TEXT[] NOT NULL DEFAULT '{}',
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(pastor_id, date)
);

CREATE TABLE pastoral_appointments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pastor_id       UUID NOT NULL REFERENCES profiles(id),
  requester_id    UUID NOT NULL REFERENCES profiles(id),
  date            DATE NOT NULL,
  time_slot       TEXT NOT NULL,
  reason          TEXT NOT NULL,
  private_notes   TEXT,
  public_notes    TEXT,
  status          appointment_status NOT NULL DEFAULT 'requested',
  reviewed_by     UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_appointments_pastor ON pastoral_appointments(pastor_id);
CREATE INDEX idx_appointments_date ON pastoral_appointments(date);
CREATE INDEX idx_appointments_status ON pastoral_appointments(status);

-- ============================================================
-- MEETING MINUTES / ATAS PASTORAIS
-- ============================================================

CREATE TABLE meeting_minutes (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title            TEXT NOT NULL,
  meeting_date     DATE NOT NULL,
  participants     TEXT,
  agenda           TEXT,
  content          TEXT,
  decisions        TEXT,
  is_confidential  BOOLEAN NOT NULL DEFAULT false,
  file_url         TEXT,
  created_by       UUID NOT NULL REFERENCES profiles(id),
  updated_by       UUID REFERENCES profiles(id),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMPTZ
);

CREATE TABLE meeting_access (
  meeting_id  UUID NOT NULL REFERENCES meeting_minutes(id) ON DELETE CASCADE,
  profile_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  granted_by  UUID REFERENCES profiles(id),
  granted_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(meeting_id, profile_id)
);

CREATE TABLE meeting_tasks (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meeting_id   UUID NOT NULL REFERENCES meeting_minutes(id) ON DELETE CASCADE,
  description  TEXT NOT NULL,
  assigned_to  UUID REFERENCES profiles(id),
  due_date     DATE,
  status       TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','in_progress','done','cancelled')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_minutes_date ON meeting_minutes(meeting_date DESC);
CREATE INDEX idx_minutes_confidential ON meeting_minutes(is_confidential);

-- ============================================================
-- FINANCIAL
-- ============================================================

CREATE TABLE financial_categories (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  type        transaction_type NOT NULL,
  description TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_by  UUID REFERENCES profiles(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Default categories
INSERT INTO financial_categories (name, type) VALUES
  ('Dízimos',       'income'),
  ('Ofertas',       'income'),
  ('Inscrições',    'income'),
  ('Doações',       'income'),
  ('Outros',        'income'),
  ('Administrativo','expense'),
  ('Ministerial',   'expense'),
  ('Operacional',   'expense'),
  ('Evento',        'expense'),
  ('Manutenção',    'expense'),
  ('Outros',        'expense');

CREATE TABLE financial_transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type            transaction_type NOT NULL,
  category_id     UUID REFERENCES financial_categories(id),
  description     TEXT NOT NULL,
  amount          NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  transaction_date DATE NOT NULL,
  payment_method  TEXT,
  reference_num   TEXT,
  file_url        TEXT,
  notes           TEXT,
  status          transaction_status NOT NULL DEFAULT 'active',
  created_by      UUID NOT NULL REFERENCES profiles(id),
  updated_by      UUID REFERENCES profiles(id),
  cancelled_by    UUID REFERENCES profiles(id),
  cancelled_at    TIMESTAMPTZ,
  cancel_reason   TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_date ON financial_transactions(transaction_date DESC);
CREATE INDEX idx_transactions_type ON financial_transactions(type);
CREATE INDEX idx_transactions_status ON financial_transactions(status);
CREATE INDEX idx_transactions_category ON financial_transactions(category_id);

-- ============================================================
-- FILES
-- ============================================================

CREATE TABLE files (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  bucket      TEXT NOT NULL,
  path        TEXT NOT NULL,
  filename    TEXT NOT NULL,
  mime_type   TEXT,
  size_bytes  BIGINT,
  related_id  UUID,
  related_type TEXT,
  is_public   BOOLEAN NOT NULL DEFAULT false,
  uploaded_by UUID NOT NULL REFERENCES profiles(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_files_related ON files(related_id, related_type);

-- ============================================================
-- AUDIT LOGS
-- ============================================================

CREATE TABLE audit_logs (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action       TEXT NOT NULL,
  module       TEXT NOT NULL,
  record_id    UUID,
  record_type  TEXT,
  old_data     JSONB,
  new_data     JSONB,
  ip_address   INET,
  user_agent   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_module ON audit_logs(module);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'profiles','role_requests','notices','members','visitors',
    'events','event_registrations','courses','course_lessons',
    'course_enrollments','children_classes','children','children_lesson_reports',
    'children_feedbacks','pastoral_availability','pastoral_appointments',
    'meeting_minutes','meeting_tasks','financial_transactions','ministries'
  ]) LOOP
    EXECUTE format('
      CREATE TRIGGER trg_%s_updated_at
      BEFORE UPDATE ON %s
      FOR EACH ROW EXECUTE FUNCTION set_updated_at()', t, t);
  END LOOP;
END $$;

-- ============================================================
-- PROFILE AUTO-CREATE on auth.users insert
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.email,
    'member'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
