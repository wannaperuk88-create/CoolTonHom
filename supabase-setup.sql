-- ============================================================
-- SUPABASE DATABASE SETUP: ระบบเช็คชื่อเข้าแถว
-- วิธีใช้: คัดลอก SQL นี้ไปรันใน Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. ตารางอาจารย์
CREATE TABLE IF NOT EXISTS public.teachers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  pin TEXT NOT NULL,
  role TEXT DEFAULT 'teacher'
);

-- 2. ตารางห้องเรียน
CREATE TABLE IF NOT EXISTS public.rooms (
  id TEXT PRIMARY KEY,
  teacher_id TEXT NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ตารางนักเรียน
CREATE TABLE IF NOT EXISTS public.students (
  id TEXT PRIMARY KEY,
  room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  order_num INTEGER DEFAULT 0
);

-- 4. ตารางการเช็คชื่อ
CREATE TABLE IF NOT EXISTS public.attendance (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
  student_id TEXT NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  status TEXT DEFAULT 'none',
  checkin_time TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, date)
);

-- ============================================================
-- เปิด Row Level Security (RLS) ทุกตาราง
-- ============================================================
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- RLS Policies: อนุญาตให้ anon key เข้าถึงได้ทุก operation
-- (เพราะใช้ระบบ PIN เอง ไม่ได้ใช้ Supabase Auth)
-- ============================================================
CREATE POLICY "anon_all_teachers" ON public.teachers FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_rooms"    ON public.rooms    FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_students" ON public.students  FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_attendance" ON public.attendance FOR ALL TO anon USING (true) WITH CHECK (true);

-- ============================================================
-- สร้าง Admin คนแรก (สามารถแก้ชื่อและ PIN ได้ภายหลัง)
-- ============================================================
INSERT INTO public.teachers (id, name, pin, role)
VALUES ('t_admin', 'แอดมิน (Admin)', '1234', 'admin')
ON CONFLICT (id) DO NOTHING;
