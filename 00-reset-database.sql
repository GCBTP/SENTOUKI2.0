-- =====================================================
-- SENTOUKI - RESET COMPLET DE LA BASE DE DONNÉES
-- ⚠️  ATTENTION: Supprime TOUTES les tables et données
-- =====================================================

-- Désactiver les triggers temporairement
SET session_replication_role = 'replica';

-- Supprimer toutes les vues
DROP VIEW IF EXISTS admin_stats CASCADE;

-- Supprimer toutes les tables dans l'ordre (en tenant compte des dépendances)
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS seats CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS buses CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Supprimer les fonctions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS generate_reservation_reference() CASCADE;
DROP FUNCTION IF EXISTS generate_ticket_number() CASCADE;
DROP FUNCTION IF EXISTS create_bus_seats() CASCADE;
DROP FUNCTION IF EXISTS update_trip_availability() CASCADE;

-- Réactiver les triggers
SET session_replication_role = 'origin';

-- Message de confirmation
DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE '✅ BASE DE DONNÉES NETTOYÉE';
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Toutes les tables, vues et fonctions ont été supprimées.';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Prochaine étape:';
    RAISE NOTICE '   1. Exécuter schema.sql';
    RAISE NOTICE '   2. Exécuter seed.sql';
    RAISE NOTICE '   3. Exécuter fix-rls-policies.sql';
    RAISE NOTICE '=====================================================';
END $$;
