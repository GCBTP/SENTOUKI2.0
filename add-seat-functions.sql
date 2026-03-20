-- =====================================================
-- FONCTIONS POUR GESTION AUTOMATIQUE DES SIÈGES
-- =====================================================

-- Fonction pour décrémenter les places disponibles
CREATE OR REPLACE FUNCTION decrement_available_seats(trip_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE trips
  SET places_disponibles = GREATEST(places_disponibles - 1, 0)
  WHERE id = trip_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour incrémenter les places disponibles (en cas d'annulation)
CREATE OR REPLACE FUNCTION increment_available_seats(trip_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE trips
  SET places_disponibles = places_disponibles + 1
  WHERE id = trip_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger automatique: décrémenter lors d'une nouvelle réservation confirmée
CREATE OR REPLACE FUNCTION auto_update_seats_on_booking()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'confirmed' AND (OLD IS NULL OR OLD.status != 'confirmed') THEN
    -- Nouvelle réservation confirmée: décrémenter
    PERFORM decrement_available_seats(NEW.trip_id);
  ELSIF OLD.status = 'confirmed' AND NEW.status = 'cancelled' THEN
    -- Réservation annulée: incrémenter
    PERFORM increment_available_seats(NEW.trip_id);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger sur la table reservations
DROP TRIGGER IF EXISTS trigger_update_seats ON reservations;
CREATE TRIGGER trigger_update_seats
  AFTER INSERT OR UPDATE ON reservations
  FOR EACH ROW
  EXECUTE FUNCTION auto_update_seats_on_booking();

-- Index pour améliorer les performances des requêtes de sièges
CREATE INDEX IF NOT EXISTS idx_reservations_trip_seat ON reservations(trip_id, seat_number);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);

-- Fonction pour vérifier si un siège est disponible (utilisable côté serveur)
CREATE OR REPLACE FUNCTION is_seat_available(p_trip_id UUID, p_seat_number INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
  seat_exists BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM reservations
    WHERE trip_id = p_trip_id
      AND seat_number = p_seat_number
      AND status = 'confirmed'
  ) INTO seat_exists;
  
  RETURN NOT seat_exists;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERMISSIONS POUR LES FONCTIONS
-- =====================================================

GRANT EXECUTE ON FUNCTION decrement_available_seats TO anon, authenticated;
GRANT EXECUTE ON FUNCTION increment_available_seats TO anon, authenticated;
GRANT EXECUTE ON FUNCTION is_seat_available TO anon, authenticated;

SELECT 'Fonctions de gestion des sièges créées avec succès!' as status;
