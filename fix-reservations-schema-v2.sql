-- =====================================================
-- CORRECTION SCHÉMA RÉSERVATIONS - VERSION ROBUSTE
-- Vérifie et ajoute les colonnes manquantes
-- =====================================================

-- 1. Ajouter seat_number si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='seat_number'
  ) THEN
    ALTER TABLE reservations ADD COLUMN seat_number INTEGER;
    RAISE NOTICE 'Colonne seat_number ajoutée';
  ELSE
    RAISE NOTICE 'Colonne seat_number existe déjà';
  END IF;
END $$;

-- 2. Ajouter passenger_name si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='passenger_name'
  ) THEN
    ALTER TABLE reservations ADD COLUMN passenger_name VARCHAR(255);
    RAISE NOTICE 'Colonne passenger_name ajoutée';
  ELSE
    RAISE NOTICE 'Colonne passenger_name existe déjà';
  END IF;
END $$;

-- 3. Ajouter passenger_phone si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='passenger_phone'
  ) THEN
    ALTER TABLE reservations ADD COLUMN passenger_phone VARCHAR(20);
    RAISE NOTICE 'Colonne passenger_phone ajoutée';
  ELSE
    RAISE NOTICE 'Colonne passenger_phone existe déjà';
  END IF;
END $$;

-- 4. Ajouter status si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='status'
  ) THEN
    ALTER TABLE reservations ADD COLUMN status VARCHAR(20) DEFAULT 'pending';
    RAISE NOTICE 'Colonne status ajoutée';
  ELSE
    RAISE NOTICE 'Colonne status existe déjà';
  END IF;
END $$;

-- 5. Ajouter reference si elle n'existe pas, sinon renommer reference_reservation
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='reference'
  ) THEN
    -- Vérifier si reference_reservation existe
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name='reservations' AND column_name='reference_reservation'
    ) THEN
      -- Renommer
      ALTER TABLE reservations RENAME COLUMN reference_reservation TO reference;
      RAISE NOTICE 'Colonne reference_reservation renommée en reference';
    ELSE
      -- Créer la colonne
      ALTER TABLE reservations ADD COLUMN reference VARCHAR(20) UNIQUE;
      RAISE NOTICE 'Colonne reference créée';
    END IF;
  ELSE
    RAISE NOTICE 'Colonne reference existe déjà';
  END IF;
END $$;

-- 6. Copier les valeurs de statut vers status si nécessaire
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='statut'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name='reservations' AND column_name='status'
  ) THEN
    UPDATE reservations SET status = 
      CASE statut
        WHEN 'en_attente' THEN 'pending'
        WHEN 'confirme' THEN 'confirmed'
        WHEN 'annule' THEN 'cancelled'
        WHEN 'termine' THEN 'completed'
        ELSE 'pending'
      END
    WHERE status IS NULL;
    RAISE NOTICE 'Valeurs copiées de statut vers status';
  END IF;
END $$;

-- 7. Rendre seat_id optionnel (nullable)
ALTER TABLE reservations ALTER COLUMN seat_id DROP NOT NULL;

-- 8. Créer index pour seat_number
CREATE INDEX IF NOT EXISTS idx_reservations_seat_number ON reservations(seat_number);
CREATE INDEX IF NOT EXISTS idx_reservations_trip_seat ON reservations(trip_id, seat_number);

-- 9. Fonction pour générer une référence unique
CREATE OR REPLACE FUNCTION generate_booking_reference()
RETURNS TEXT AS $$
DECLARE
  ref TEXT;
  exists BOOLEAN;
BEGIN
  LOOP
    -- Générer référence: SEN + 8 caractères alphanumériques
    ref := 'SEN' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT || CLOCK_TIMESTAMP()::TEXT) FROM 1 FOR 8));
    
    -- Vérifier si elle existe déjà
    SELECT EXISTS(SELECT 1 FROM reservations WHERE reference = ref) INTO exists;
    
    EXIT WHEN NOT exists;
  END LOOP;
  
  RETURN ref;
END;
$$ LANGUAGE plpgsql;

-- 10. Trigger pour auto-générer la référence
CREATE OR REPLACE FUNCTION set_reservation_reference()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reference IS NULL OR NEW.reference = '' THEN
    NEW.reference := generate_booking_reference();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_reservation_reference ON reservations;
CREATE TRIGGER trigger_set_reservation_reference
  BEFORE INSERT ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION set_reservation_reference();

-- 11. Contrainte unique: un seat_number par trip (supprime l'ancienne contrainte si elle existe)
DROP INDEX IF EXISTS unique_trip_seat_number;
CREATE UNIQUE INDEX IF NOT EXISTS unique_trip_seat_number 
  ON reservations(trip_id, seat_number) 
  WHERE status IN ('pending', 'confirmed');

-- 12. Permissions
GRANT EXECUTE ON FUNCTION generate_booking_reference TO anon, authenticated;

SELECT 'Schéma reservations corrigé avec succès! ✅' as status;
