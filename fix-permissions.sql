-- FIX PERMISSIONS COMPLÈTES - SENTOUKI
-- Résout: "permission denied for table cities"

-- 1. Désactiver RLS
ALTER TABLE cities DISABLE ROW LEVEL SECURITY;
ALTER TABLE buses DISABLE ROW LEVEL SECURITY;
ALTER TABLE trips DISABLE ROW LEVEL SECURITY;
ALTER TABLE seats DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE reservations DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;

-- 2. Donner toutes les permissions aux rôles Supabase
GRANT ALL ON cities TO anon, authenticated;
GRANT ALL ON buses TO anon, authenticated;
GRANT ALL ON trips TO anon, authenticated;
GRANT ALL ON seats TO anon, authenticated;
GRANT ALL ON users TO anon, authenticated;
GRANT ALL ON reservations TO anon, authenticated;
GRANT ALL ON payments TO anon, authenticated;
GRANT ALL ON tickets TO anon, authenticated;

-- 3. Permissions sur les séquences (pour les ID auto-increment)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- 4. Permissions sur les fonctions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

SELECT 'Permissions OK - Toutes les tables accessibles!' as status;
