-- ============================================================
-- PrimazIA — Migration 002: Row Level Security (RLS)
-- ============================================================

-- Helper function: get current user role
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: check if current user is admin+
CREATE OR REPLACE FUNCTION is_admin_or_above()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() IN ('super_admin', 'admin')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: check if current user is pastor+
CREATE OR REPLACE FUNCTION is_pastor_or_above()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() IN ('super_admin', 'admin', 'pastor')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: check if current user is coordinator+
CREATE OR REPLACE FUNCTION is_coordinator_or_above()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() IN ('super_admin', 'admin', 'pastor', 'coordinator')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: check if current user is financial admin
CREATE OR REPLACE FUNCTION is_financial()
RETURNS BOOLEAN AS $$
  SELECT get_my_role() IN ('super_admin', 'financial_admin')
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE church_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE ministries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ministry_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE children_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE children_guardians ENABLE ROW LEVEL SECURITY;
ALTER TABLE children_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE children_lesson_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE children_feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE pastoral_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE pastoral_appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_minutes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE meeting_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROFILES
-- ============================================================

-- Users can view all active profiles (needed for dropdowns etc)
CREATE POLICY "profiles_select_authenticated"
  ON profiles FOR SELECT
  TO authenticated
  USING (is_active = true OR auth.uid() = id);

-- Users can update only their own non-sensitive fields
CREATE POLICY "profiles_update_self"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Cannot change own role
    AND role = (SELECT role FROM profiles WHERE id = auth.uid())
  );

-- Admins can update any profile (including role)
CREATE POLICY "profiles_update_admin"
  ON profiles FOR UPDATE
  TO authenticated
  USING (is_admin_or_above());

-- ============================================================
-- ROLE REQUESTS
-- ============================================================

CREATE POLICY "role_requests_select"
  ON role_requests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin_or_above());

CREATE POLICY "role_requests_insert"
  ON role_requests FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "role_requests_update_admin"
  ON role_requests FOR UPDATE
  TO authenticated
  USING (is_admin_or_above());

-- ============================================================
-- CHURCH SETTINGS
-- ============================================================

CREATE POLICY "settings_select_all"
  ON church_settings FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "settings_modify_admin"
  ON church_settings FOR ALL
  TO authenticated
  USING (is_admin_or_above())
  WITH CHECK (is_admin_or_above());

-- ============================================================
-- NOTICES
-- ============================================================

-- Public notices visible to all
CREATE POLICY "notices_select_public"
  ON notices FOR SELECT
  TO anon, authenticated
  USING (is_active = true AND is_public = true);

-- Authenticated users see all active notices
CREATE POLICY "notices_select_auth"
  ON notices FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "notices_manage_admin"
  ON notices FOR ALL
  TO authenticated
  USING (is_admin_or_above())
  WITH CHECK (is_admin_or_above());

-- ============================================================
-- MEMBERS
-- ============================================================

CREATE POLICY "members_select_staff"
  ON members FOR SELECT
  TO authenticated
  USING (is_pastor_or_above() AND deleted_at IS NULL);

CREATE POLICY "members_modify_admin"
  ON members FOR ALL
  TO authenticated
  USING (is_admin_or_above())
  WITH CHECK (is_admin_or_above());

-- ============================================================
-- VISITORS
-- ============================================================

CREATE POLICY "visitors_select_staff"
  ON visitors FOR SELECT
  TO authenticated
  USING (is_pastor_or_above() AND deleted_at IS NULL);

CREATE POLICY "visitors_insert_staff"
  ON visitors FOR INSERT
  TO authenticated
  WITH CHECK (is_pastor_or_above());

CREATE POLICY "visitors_update_staff"
  ON visitors FOR UPDATE
  TO authenticated
  USING (is_pastor_or_above());

-- ============================================================
-- EVENTS
-- ============================================================

-- Public events visible to all
CREATE POLICY "events_select_public"
  ON events FOR SELECT
  TO anon, authenticated
  USING (status = 'published' AND is_public = true AND deleted_at IS NULL);

-- Authenticated users see all non-deleted
CREATE POLICY "events_select_auth"
  ON events FOR SELECT
  TO authenticated
  USING (deleted_at IS NULL);

CREATE POLICY "events_manage_admin"
  ON events FOR ALL
  TO authenticated
  USING (is_admin_or_above())
  WITH CHECK (is_admin_or_above());

-- ============================================================
-- EVENT REGISTRATIONS
-- ============================================================

CREATE POLICY "event_reg_select_own"
  ON event_registrations FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin_or_above());

CREATE POLICY "event_reg_insert_self"
  ON event_registrations FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "event_reg_update_admin"
  ON event_registrations FOR UPDATE
  TO authenticated
  USING (is_admin_or_above());

-- ============================================================
-- COURSES
-- ============================================================

CREATE POLICY "courses_select_public"
  ON courses FOR SELECT
  TO anon, authenticated
  USING (status = 'published' AND is_public = true AND deleted_at IS NULL);

CREATE POLICY "courses_select_auth"
  ON courses FOR SELECT
  TO authenticated
  USING (deleted_at IS NULL);

CREATE POLICY "courses_manage_admin"
  ON courses FOR ALL
  TO authenticated
  USING (is_admin_or_above())
  WITH CHECK (is_admin_or_above());

-- Lessons: only enrolled and active users can view
CREATE POLICY "lessons_select_enrolled"
  ON course_lessons FOR SELECT
  TO authenticated
  USING (
    is_free = true
    OR is_admin_or_above()
    OR EXISTS (
      SELECT 1 FROM course_enrollments
      WHERE course_id = course_lessons.course_id
        AND user_id = auth.uid()
        AND status IN ('active', 'in_progress', 'completed')
    )
  );

CREATE POLICY "enrollments_select_own"
  ON course_enrollments FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin_or_above());

CREATE POLICY "enrollments_insert_self"
  ON course_enrollments FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "enrollments_update_admin"
  ON course_enrollments FOR UPDATE
  TO authenticated
  USING (is_admin_or_above());

-- ============================================================
-- CHILDREN — Reforçado
-- ============================================================

-- Coordinator+ sees all
CREATE POLICY "children_classes_select_staff"
  ON children_classes FOR SELECT
  TO authenticated
  USING (is_coordinator_or_above() OR teacher_id = auth.uid());

CREATE POLICY "children_classes_manage_coord"
  ON children_classes FOR ALL
  TO authenticated
  USING (is_coordinator_or_above())
  WITH CHECK (is_coordinator_or_above());

-- Children: guardian sees only own children; staff sees all
CREATE POLICY "children_select_guardian"
  ON children FOR SELECT
  TO authenticated
  USING (
    deleted_at IS NULL
    AND (
      is_coordinator_or_above()
      OR EXISTS (SELECT 1 FROM children_guardians WHERE child_id = children.id AND profile_id = auth.uid())
      OR (
        get_my_role() = 'teacher'
        AND class_id IN (SELECT id FROM children_classes WHERE teacher_id = auth.uid())
      )
    )
  );

CREATE POLICY "children_manage_coord"
  ON children FOR ALL
  TO authenticated
  USING (is_coordinator_or_above())
  WITH CHECK (is_coordinator_or_above());

-- Guardians: visible to coordinator+
CREATE POLICY "children_guardians_select"
  ON children_guardians FOR SELECT
  TO authenticated
  USING (
    profile_id = auth.uid()
    OR is_coordinator_or_above()
  );

CREATE POLICY "children_guardians_manage_coord"
  ON children_guardians FOR ALL
  TO authenticated
  USING (is_coordinator_or_above())
  WITH CHECK (is_coordinator_or_above());

-- Attendance: teacher of class can record
CREATE POLICY "attendance_select"
  ON children_attendance FOR SELECT
  TO authenticated
  USING (
    is_coordinator_or_above()
    OR recorded_by = auth.uid()
    OR EXISTS (SELECT 1 FROM children_guardians WHERE child_id = children_attendance.child_id AND profile_id = auth.uid())
  );

CREATE POLICY "attendance_insert_teacher"
  ON children_attendance FOR INSERT
  TO authenticated
  WITH CHECK (
    is_coordinator_or_above()
    OR (
      get_my_role() = 'teacher'
      AND class_id IN (SELECT id FROM children_classes WHERE teacher_id = auth.uid())
    )
  );

-- Feedbacks: visibility controlled by field
CREATE POLICY "feedbacks_select"
  ON children_feedbacks FOR SELECT
  TO authenticated
  USING (
    is_coordinator_or_above()
    OR teacher_id = auth.uid()
    OR (
      visibility IN ('guardians', 'all_staff')
      AND EXISTS (SELECT 1 FROM children_guardians WHERE child_id = children_feedbacks.child_id AND profile_id = auth.uid())
    )
    OR (visibility = 'all_staff' AND get_my_role() IN ('teacher', 'coordinator', 'pastor', 'admin', 'super_admin'))
  );

CREATE POLICY "feedbacks_insert_teacher"
  ON children_feedbacks FOR INSERT
  TO authenticated
  WITH CHECK (
    teacher_id = auth.uid()
    AND (
      get_my_role() IN ('teacher', 'coordinator', 'super_admin', 'admin', 'pastor')
    )
  );

-- ============================================================
-- PASTORAL SCHEDULE
-- ============================================================

-- Availability: pastor manages own; admin+ sees all
CREATE POLICY "availability_select"
  ON pastoral_availability FOR SELECT
  TO authenticated
  USING (pastor_id = auth.uid() OR is_admin_or_above());

CREATE POLICY "availability_manage"
  ON pastoral_availability FOR ALL
  TO authenticated
  USING (pastor_id = auth.uid() OR is_admin_or_above())
  WITH CHECK (pastor_id = auth.uid() OR is_admin_or_above());

-- Appointments
CREATE POLICY "appointments_select"
  ON pastoral_appointments FOR SELECT
  TO authenticated
  USING (
    requester_id = auth.uid()
    OR pastor_id = auth.uid()
    OR is_admin_or_above()
  );

CREATE POLICY "appointments_insert"
  ON pastoral_appointments FOR INSERT
  TO authenticated
  WITH CHECK (requester_id = auth.uid() OR is_admin_or_above());

CREATE POLICY "appointments_update"
  ON pastoral_appointments FOR UPDATE
  TO authenticated
  USING (pastor_id = auth.uid() OR is_admin_or_above());

-- ============================================================
-- MEETING MINUTES — Atas Pastorais
-- ============================================================

-- Non-confidential: all staff can read
-- Confidential: only pastor+, or explicitly granted access
CREATE POLICY "minutes_select"
  ON meeting_minutes FOR SELECT
  TO authenticated
  USING (
    deleted_at IS NULL
    AND (
      is_confidential = false AND is_pastor_or_above()
      OR is_pastor_or_above() -- pastors see all
      OR EXISTS (SELECT 1 FROM meeting_access WHERE meeting_id = meeting_minutes.id AND profile_id = auth.uid())
    )
  );

CREATE POLICY "minutes_manage_pastor"
  ON meeting_minutes FOR ALL
  TO authenticated
  USING (is_pastor_or_above())
  WITH CHECK (is_pastor_or_above());

CREATE POLICY "meeting_tasks_select"
  ON meeting_tasks FOR SELECT
  TO authenticated
  USING (
    is_pastor_or_above()
    OR assigned_to = auth.uid()
  );

CREATE POLICY "meeting_tasks_manage"
  ON meeting_tasks FOR ALL
  TO authenticated
  USING (is_pastor_or_above())
  WITH CHECK (is_pastor_or_above());

-- ============================================================
-- FINANCIAL — Altamente restrito
-- ============================================================

CREATE POLICY "financial_cat_select"
  ON financial_categories FOR SELECT
  TO authenticated
  USING (is_financial() OR is_admin_or_above());

CREATE POLICY "financial_cat_manage"
  ON financial_categories FOR ALL
  TO authenticated
  USING (is_financial())
  WITH CHECK (is_financial());

CREATE POLICY "transactions_select"
  ON financial_transactions FOR SELECT
  TO authenticated
  USING (
    is_financial()
    OR (is_admin_or_above() AND (SELECT (value->>'financial_visible_to_admin')::boolean FROM church_settings WHERE key = 'modules_config'))
  );

CREATE POLICY "transactions_insert"
  ON financial_transactions FOR INSERT
  TO authenticated
  WITH CHECK (is_financial());

CREATE POLICY "transactions_update"
  ON financial_transactions FOR UPDATE
  TO authenticated
  USING (is_financial())
  WITH CHECK (is_financial() AND status != 'cancelled');

-- ============================================================
-- FILES
-- ============================================================

CREATE POLICY "files_select"
  ON files FOR SELECT
  TO authenticated
  USING (
    is_public = true
    OR uploaded_by = auth.uid()
    OR is_admin_or_above()
    OR (
      bucket = 'courses'
      AND EXISTS (
        SELECT 1 FROM course_enrollments
        WHERE course_id = files.related_id::uuid
          AND user_id = auth.uid()
          AND status IN ('active','in_progress','completed')
      )
    )
  );

CREATE POLICY "files_insert"
  ON files FOR INSERT
  TO authenticated
  WITH CHECK (uploaded_by = auth.uid());

-- ============================================================
-- AUDIT LOGS — Append-only for all, read for admins
-- ============================================================

CREATE POLICY "audit_insert_all"
  ON audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "audit_select_admin"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (is_admin_or_above() OR user_id = auth.uid());

-- Prevent delete/update of audit logs
-- (no DELETE or UPDATE policy = denied)
