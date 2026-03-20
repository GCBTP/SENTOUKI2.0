-- =====================================================
-- SENTOUKI - CORRECTION COMPLÈTE DES RLS POLICIES
-- Résout: "permission denied for table cities" (erreur 42501)
-- =====================================================

-- =====================================================
-- ÉTAPE 1: SUPPRIMER TOUTES LES POLICIES EXISTANTES
-- =====================================================

DROP POLICY IF EXISTS "Public read cities" ON cities;
DROP POLICY IF EXISTS "Public read buses" ON buses;
DROP POLICY IF EXISTS "Public read trips" ON trips;
DROP POLICY IF EXISTS "Public read seats" ON seats;

DROP POLICY IF EXISTS "Users can read their own data" ON users;
DROP POLICY IF EXISTS "Users can update their own data" ON users;
DROP POLICY IF EXISTS "Admins can manage all users" ON users;

DROP POLICY IF EXISTS "Users can read their reservations" ON reservations;
DROP POLICY IF EXISTS "Users can create reservations" ON reservations;
DROP POLICY IF EXISTS "Users can cancel their reservations" ON reservations;

DROP POLICY IF EXISTS "Users can read their payments" ON payments;
DROP POLICY IF EXISTS "Users can read their tickets" ON tickets;

-- =====================================================
-- ÉTAPE 2: DÉSACTIVER RLS TEMPORAIREMENT (PHASE DEV)
-- =====================================================

ALTER TABLE cities DISABLE ROW LEVEL SECURITY;
ALTER TABLE buses DISABLE ROW LEVEL SECURITY;
ALTER TABLE trips DISABLE ROW LEVEL SECURITY;
ALTER TABLE seats DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE reservations DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE tickets DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- CONFIRMATION
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'RLS DÉSACTIVÉ SUR TOUTES LES TABLES';
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Mode: DÉVELOPPEMENT';
    RAISE NOTICE 'Accès: PUBLIC (tous les utilisateurs)';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANT: Réactiver RLS avant production!';
    RAISE NOTICE '=====================================================';
END $$;

-- =====================================================
-- NOTE POUR LA PRODUCTION (À UTILISER PLUS TARD)
-- =====================================================

/*
-- Pour réactiver RLS en production avec les bonnes policies:

-- 1. Réactiver RLS
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- 2. Policies publiques (lecture seule)
CREATE POLICY "Public can read cities" ON cities FOR SELECT USING (true);
CREATE POLICY "Public can read active buses" ON buses FOR SELECT USING (statut = 'actif');
CREATE POLICY "Public can read available trips" ON trips FOR SELECT USING (statut IN ('programme', 'en_cours'));
CREATE POLICY "Public can read seats" ON seats FOR SELECT USING (true);

-- 3. Policies utilisateurs authentifiés
CREATE POLICY "Authenticated users can read their profile" ON users 
    FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Authenticated users can update their profile" ON users 
    FOR UPDATE 
    USING (auth.uid() = id);

-- 4. Policies réservations
CREATE POLICY "Users can read their reservations" ON reservations 
    FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create reservations" ON reservations 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can cancel their reservations" ON reservations 
    FOR UPDATE 
    USING (auth.uid() = user_id AND statut = 'en_attente');

-- 5. Policies paiements
CREATE POLICY "Users can read their payments" ON payments 
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM reservations 
            WHERE reservations.id = payments.reservation_id 
            AND reservations.user_id = auth.uid()
        )
    );

-- 6. Policies tickets
CREATE POLICY "Users can read their tickets" ON tickets 
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM reservations 
            WHERE reservations.id = tickets.reservation_id 
            AND reservations.user_id = auth.uid()
        )
    );

-- 7. Policies admin (pour super_admin)
CREATE POLICY "Admins can manage everything on users" ON users 
    FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Admins can manage buses" ON buses 
    FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Admins can manage trips" ON trips 
    FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Admins can read all reservations" ON reservations 
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Admins can read all payments" ON payments 
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Admins can read all tickets" ON tickets 
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role IN ('admin', 'super_admin')
        )
    );
*/
