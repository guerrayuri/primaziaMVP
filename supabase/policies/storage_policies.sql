-- ============================================================
-- PrimazIA — Storage Bucket Policies
-- Execute após criar os buckets no Supabase Storage
-- ============================================================

-- 1. Criar buckets (faça isso no painel Storage do Supabase ou use este SQL)
-- INSERT INTO storage.buckets (id, name, public) VALUES
--   ('public',          'public',          true),
--   ('courses',         'courses',         false),
--   ('finance',         'finance',         false),
--   ('meeting-minutes', 'meeting-minutes', false),
--   ('children',        'children',        false),
--   ('admin',           'admin',           false);

-- ============================================================
-- BUCKET: public (logos, imagens públicas)
-- ============================================================

CREATE POLICY "public_bucket_read_all"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'public');

CREATE POLICY "public_bucket_write_admin"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'public'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin')
  );

CREATE POLICY "public_bucket_delete_admin"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'public'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin')
  );

-- ============================================================
-- BUCKET: courses (materiais de cursos)
-- ============================================================

CREATE POLICY "courses_bucket_read_enrolled"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'courses'
    AND (
      (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin', 'pastor')
      OR EXISTS (
        SELECT 1 FROM course_enrollments ce
        JOIN courses c ON c.id = ce.course_id
        WHERE ce.user_id = auth.uid()
          AND ce.status IN ('active', 'in_progress', 'completed')
          AND storage.foldername(name)[1] = c.id::text
      )
    )
  );

CREATE POLICY "courses_bucket_write_admin"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'courses'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin', 'pastor')
  );

-- ============================================================
-- BUCKET: finance (comprovantes financeiros)
-- ============================================================

CREATE POLICY "finance_bucket_read_financial"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'finance'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'financial_admin')
  );

CREATE POLICY "finance_bucket_write_financial"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'finance'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'financial_admin')
  );

-- ============================================================
-- BUCKET: meeting-minutes (arquivos de atas)
-- ============================================================

CREATE POLICY "minutes_bucket_read_pastor"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'meeting-minutes'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin', 'pastor')
  );

CREATE POLICY "minutes_bucket_write_pastor"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'meeting-minutes'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin', 'pastor')
  );

-- ============================================================
-- BUCKET: children (arquivos do ministério infantil)
-- ============================================================

CREATE POLICY "children_bucket_read_staff"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'children'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin', 'pastor', 'coordinator', 'teacher')
  );

CREATE POLICY "children_bucket_write_staff"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'children'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin', 'pastor', 'coordinator', 'teacher')
  );

-- ============================================================
-- BUCKET: admin (backups e arquivos administrativos)
-- ============================================================

CREATE POLICY "admin_bucket_read_admin"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'admin'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin')
  );

CREATE POLICY "admin_bucket_write_admin"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'admin'
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('super_admin', 'admin')
  );
