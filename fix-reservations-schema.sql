-- =====================================================
-- CORRECTION SCHÉMA RÉSERVATIONS
-- Simplifier: utiliser seat_number au lieu de seat_id
-- =====================================================

-- 1. Ajouter les colonnes manquantes à reservations
ALTER TABLE reservations 
ADD COLUMN IF NOT EXISTS seat_number INTEGER;

ALTER TABLE reservations
ADD COLUMN IF NOT EXISTS passenger_name VARCHAR(255);

ALTER TABLE reservations
ADD COLUMN IF NOT EXISTS passenger_phone VARCHAR(20);

-- 2. Rendre seat_id optionnel (nullable)
ALTER TABLE reservations 
ALTER COLUMN seat_id DROP NOT NULL;

-- 3. Renommer reference_reservation en reference (plus court)
ALTER TABLE reservations 
RENAME COLUMN reference_reservation TO reference;

-- 4. Renommer statut pour correspondre au code (status au lieu de statut)
ALTER TABLE reservations
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending';

-- Copier les valeurs si elles existent
UPDATE reservations SET status = 
  CASE statut
    WHEN 'en_attente' THEN 'pending'
    WHEN 'confirme' THEN 'confirmed'
    WHEN 'annule' THEN 'cancelled'
    WHEN 'termine' THEN 'completed'
    ELSE 'pending'
  END
WHERE status IS NULL;

-- 5. Créer index pour seat_number
CREATE INDEX IF NOT EXISTS idx_reservations_seat_number ON reservations(seat_number);
CREATE INDEX IF NOT EXISTS idx_reservations_trip_seat ON reservations(trip_id, seat_number);

-- 6. Fonction pour générer une référence unique
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

-- 7. Trigger pour auto-générer la référence
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

-- 8. Contrainte unique: un seat_number par trip
DROP INDEX IF EXISTS reservations_trip_id_seat_id_key;
CREATE UNIQUE INDEX IF NOT EXISTS unique_trip_seat_number 
  ON reservations(trip_id, seat_number) 
  WHERE status IN ('pending', 'confirmed');

SELECT 'Schéma reservations corrigé avec succès!' as status;
