-- =====================================================
-- SENTOUKI - Row Level Security Policies
-- Exécuter dans Supabase SQL Editor
-- =====================================================

-- 1. ACTIVER RLS SUR TOUTES LES TABLES
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. POLICIES USERS
-- =====================================================

-- Lecture: utilisateur peut voir son profil uniquement
CREATE POLICY "Users can read own profile"
ON users FOR SELECT
USING (auth.uid() = id);

-- Mise à jour: utilisateur peut modifier son profil
CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Admins peuvent tout voir
CREATE POLICY "Admins can read all users"
ON users FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- =====================================================
-- 3. POLICIES CITIES (Public)
-- =====================================================

-- Lecture publique
CREATE POLICY "Cities are publicly readable"
ON cities FOR SELECT
USING (true);

-- Création/modification: admin uniquement
CREATE POLICY "Only admins can manage cities"
ON cities FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- =====================================================
-- 4. POLICIES BUSES
-- =====================================================

-- Lecture publique (bus actifs uniquement)
CREATE POLICY "Public can read active buses"
ON buses FOR SELECT
USING (statut = 'actif');

-- Admins peuvent tout voir et modifier
CREATE POLICY "Admins can manage buses"
ON buses FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- =====================================================
-- 5. POLICIES TRIPS
-- =====================================================

-- Lecture publique (trajets actifs uniquement)
CREATE POLICY "Public can read active trips"
ON trips FOR SELECT
USING (
  statut IN ('programme', 'en_cours')
  AND places_disponibles > 0
);

-- Admins peuvent tout voir et modifier
CREATE POLICY "Admins can manage trips"
ON trips FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- =====================================================
-- 6. POLICIES RESERVATIONS (CRITIQUE)
-- =====================================================

-- Lecture: utilisateur voit ses réservations uniquement
CREATE POLICY "Users can read own reservations"
ON reservations FOR SELECT
USING (auth.uid() = user_id);

-- Admins peuvent tout voir
CREATE POLICY "Admins can read all reservations"
ON reservations FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- Création: utilisateur authentifié pour lui-même uniquement
CREATE POLICY "Users can create own reservations"
ON reservations FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Mise à jour: utilisateur peut modifier ses réservations (statut limité)
CREATE POLICY "Users can update own reservations"
ON reservations FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id
  AND statut IN ('en_attente', 'annule') -- Pas de modification si déjà confirmé
);

-- Admins peuvent tout modifier
CREATE POLICY "Admins can manage all reservations"
ON reservations FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- =====================================================
-- 7. POLICIES PAYMENTS
-- =====================================================

-- Lecture: utilisateur voit ses paiements (via reservation)
CREATE POLICY "Users can read own payments"
ON payments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM reservations
    WHERE reservations.id = payments.reservation_id
    AND reservations.user_id = auth.uid()
  )
);

-- Admins peuvent tout voir
CREATE POLICY "Admins can read all payments"
ON payments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- Création: via service backend uniquement (policy stricte)
CREATE POLICY "Payments created by authenticated users"
ON payments FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM reservations
    WHERE reservations.id = payments.reservation_id
    AND reservations.user_id = auth.uid()
  )
);

-- =====================================================
-- 8. POLICIES TICKETS
-- =====================================================

-- Lecture: utilisateur voit ses tickets (via reservation)
CREATE POLICY "Users can read own tickets"
ON tickets FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM reservations
    WHERE reservations.id = tickets.reservation_id
    AND reservations.user_id = auth.uid()
  )
);

-- Admins peuvent tout voir
CREATE POLICY "Admins can read all tickets"
ON tickets FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  )
);

-- =====================================================
-- 9. FONCTION HELPER: Vérifier si admin
-- =====================================================

CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
  );
END;
$$;

-- =====================================================
-- 10. FONCTION: Vérifier disponibilité siège
-- =====================================================

CREATE OR REPLACE FUNCTION is_seat_available(
  p_trip_id UUID,
  p_seat_number INTEGER
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM reservations
    WHERE trip_id = p_trip_id
    AND seat_number = p_seat_number
    AND status IN ('pending', 'confirmed')
  );
END;
$$;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Lister toutes les policies créées
SELECT schemaname, tablename, policyname, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Vérifier RLS activé
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;
