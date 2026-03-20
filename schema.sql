-- =====================================================
-- SENTOUKI - Schéma de Base de Données
-- Plateforme de réservation de bus inter-région
-- Compatible: Supabase PostgreSQL
-- =====================================================

-- Activer les extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. TABLE: users (Utilisateurs)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'admin', 'super_admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour recherche rapide
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- =====================================================
-- 2. TABLE: cities (Villes)
-- =====================================================
CREATE TABLE IF NOT EXISTS cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour recherche rapide
CREATE INDEX idx_cities_nom ON cities(nom);
CREATE INDEX idx_cities_region ON cities(region);

-- =====================================================
-- 3. TABLE: buses (Bus)
-- =====================================================
CREATE TABLE IF NOT EXISTS buses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom_bus VARCHAR(100) NOT NULL,
    immatriculation VARCHAR(50) UNIQUE NOT NULL,
    nombre_places INTEGER NOT NULL CHECK (nombre_places > 0),
    modele VARCHAR(100),
    statut VARCHAR(20) DEFAULT 'actif' CHECK (statut IN ('actif', 'maintenance', 'inactif')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_buses_statut ON buses(statut);

-- =====================================================
-- 4. TABLE: trips (Voyages/Trajets)
-- =====================================================
CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ville_depart_id UUID NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
    ville_arrivee_id UUID NOT NULL REFERENCES cities(id) ON DELETE RESTRICT,
    bus_id UUID NOT NULL REFERENCES buses(id) ON DELETE RESTRICT,
    date_depart DATE NOT NULL,
    heure_depart TIME NOT NULL,
    heure_arrivee TIME,
    prix DECIMAL(10, 2) NOT NULL CHECK (prix >= 0),
    places_disponibles INTEGER NOT NULL CHECK (places_disponibles >= 0),
    statut VARCHAR(20) DEFAULT 'programme' CHECK (statut IN ('programme', 'en_cours', 'termine', 'annule')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte: ville départ != ville arrivée
    CONSTRAINT check_different_cities CHECK (ville_depart_id != ville_arrivee_id)
);

-- Index pour recherche rapide
CREATE INDEX idx_trips_date_depart ON trips(date_depart);
CREATE INDEX idx_trips_ville_depart ON trips(ville_depart_id);
CREATE INDEX idx_trips_ville_arrivee ON trips(ville_arrivee_id);
CREATE INDEX idx_trips_statut ON trips(statut);
CREATE INDEX idx_trips_bus ON trips(bus_id);

-- Index composite pour recherche de trajets
CREATE INDEX idx_trips_search ON trips(ville_depart_id, ville_arrivee_id, date_depart);

-- =====================================================
-- 5. TABLE: seats (Sièges)
-- =====================================================
CREATE TABLE IF NOT EXISTS seats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bus_id UUID NOT NULL REFERENCES buses(id) ON DELETE CASCADE,
    numero INTEGER NOT NULL CHECK (numero > 0),
    position VARCHAR(20), -- ex: "fenetre", "couloir"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte: un numéro de siège unique par bus
    CONSTRAINT unique_seat_per_bus UNIQUE (bus_id, numero)
);

-- Index
CREATE INDEX idx_seats_bus ON seats(bus_id);

-- =====================================================
-- 6. TABLE: reservations (Réservations)
-- =====================================================
CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    seat_id UUID NOT NULL REFERENCES seats(id) ON DELETE RESTRICT,
    reference_reservation VARCHAR(20) UNIQUE NOT NULL,
    statut VARCHAR(20) DEFAULT 'en_attente' CHECK (statut IN ('en_attente', 'confirme', 'annule', 'termine')),
    nombre_passagers INTEGER DEFAULT 1 CHECK (nombre_passagers > 0),
    montant_total DECIMAL(10, 2) NOT NULL CHECK (montant_total >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte: un siège ne peut être réservé qu'une fois par voyage
    CONSTRAINT unique_seat_per_trip UNIQUE (trip_id, seat_id)
);

-- Index
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_reservations_trip ON reservations(trip_id);
CREATE INDEX idx_reservations_reference ON reservations(reference_reservation);
CREATE INDEX idx_reservations_statut ON reservations(statut);

-- =====================================================
-- 7. TABLE: payments (Paiements)
-- =====================================================
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    montant DECIMAL(10, 2) NOT NULL CHECK (montant >= 0),
    statut_paiement VARCHAR(20) DEFAULT 'en_attente' CHECK (statut_paiement IN ('en_attente', 'paye', 'echoue', 'rembourse')),
    methode_paiement VARCHAR(50), -- ex: "wave", "orange_money", "carte_bancaire"
    reference_transaction VARCHAR(100) UNIQUE,
    date_paiement TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_payments_reservation ON payments(reservation_id);
CREATE INDEX idx_payments_statut ON payments(statut_paiement);
CREATE INDEX idx_payments_reference ON payments(reference_transaction);

-- =====================================================
-- 8. TABLE: tickets (Tickets numériques)
-- =====================================================
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    numero_ticket VARCHAR(50) UNIQUE NOT NULL,
    qr_code TEXT, -- URL ou base64 du QR code
    statut VARCHAR(20) DEFAULT 'valide' CHECK (statut IN ('valide', 'utilise', 'annule', 'expire')),
    date_utilisation TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_tickets_reservation ON tickets(reservation_id);
CREATE INDEX idx_tickets_numero ON tickets(numero_ticket);
CREATE INDEX idx_tickets_statut ON tickets(statut);

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger sur les tables concernées
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_buses_updated_at BEFORE UPDATE ON buses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trips_updated_at BEFORE UPDATE ON trips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Fonction pour générer une référence de réservation
-- =====================================================
CREATE OR REPLACE FUNCTION generate_reservation_reference()
RETURNS TEXT AS $$
DECLARE
    ref TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        -- Générer une référence: SENT + 10 caractères alphanumériques
        ref := 'SENT' || UPPER(substring(md5(random()::text) from 1 for 10));
        
        -- Vérifier si elle existe déjà
        SELECT EXISTS(SELECT 1 FROM reservations WHERE reference_reservation = ref) INTO exists;
        
        -- Si elle n'existe pas, on la retourne
        IF NOT exists THEN
            RETURN ref;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Fonction pour générer un numéro de ticket
-- =====================================================
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TEXT AS $$
DECLARE
    ticket_num TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        -- Générer un numéro: TKT + 12 chiffres
        ticket_num := 'TKT' || LPAD(floor(random() * 1000000000000)::text, 12, '0');
        
        -- Vérifier si il existe déjà
        SELECT EXISTS(SELECT 1 FROM tickets WHERE numero_ticket = ticket_num) INTO exists;
        
        IF NOT exists THEN
            RETURN ticket_num;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Fonction pour créer automatiquement les sièges d'un bus
-- =====================================================
CREATE OR REPLACE FUNCTION create_bus_seats()
RETURNS TRIGGER AS $$
DECLARE
    i INTEGER;
BEGIN
    -- Créer les sièges de 1 à nombre_places
    FOR i IN 1..NEW.nombre_places LOOP
        INSERT INTO seats (bus_id, numero, position)
        VALUES (
            NEW.id, 
            i,
            CASE 
                WHEN i % 4 IN (1, 2) THEN 'fenetre'
                ELSE 'couloir'
            END
        );
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour créer les sièges automatiquement
CREATE TRIGGER auto_create_seats AFTER INSERT ON buses
    FOR EACH ROW EXECUTE FUNCTION create_bus_seats();

-- =====================================================
-- Fonction pour mettre à jour les places disponibles
-- =====================================================
CREATE OR REPLACE FUNCTION update_trip_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.statut = 'confirme' THEN
        -- Décrémenter les places disponibles
        UPDATE trips 
        SET places_disponibles = places_disponibles - NEW.nombre_passagers
        WHERE id = NEW.trip_id;
        
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.statut = 'confirme' AND NEW.statut = 'annule' THEN
            -- Incrémenter les places disponibles (annulation)
            UPDATE trips 
            SET places_disponibles = places_disponibles + OLD.nombre_passagers
            WHERE id = OLD.trip_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour gérer les places disponibles
CREATE TRIGGER manage_trip_availability AFTER INSERT OR UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION update_trip_availability();

-- =====================================================
-- Vue pour les statistiques admin
-- =====================================================
CREATE OR REPLACE VIEW admin_stats AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'client') as total_clients,
    (SELECT COUNT(*) FROM buses WHERE statut = 'actif') as buses_actifs,
    (SELECT COUNT(*) FROM trips WHERE statut = 'programme') as trips_programmes,
    (SELECT COUNT(*) FROM reservations WHERE statut = 'confirme') as reservations_confirmees,
    (SELECT COALESCE(SUM(montant), 0) FROM payments WHERE statut_paiement = 'paye') as revenus_total;

-- =====================================================
-- COMMENTAIRES (Documentation)
-- =====================================================
COMMENT ON TABLE users IS 'Utilisateurs de la plateforme (clients et administrateurs)';
COMMENT ON TABLE cities IS 'Villes et régions du Sénégal';
COMMENT ON TABLE buses IS 'Flotte de bus de la compagnie';
COMMENT ON TABLE trips IS 'Voyages programmés avec horaires et tarifs';
COMMENT ON TABLE seats IS 'Sièges disponibles dans chaque bus';
COMMENT ON TABLE reservations IS 'Réservations effectuées par les clients';
COMMENT ON TABLE payments IS 'Paiements et transactions';
COMMENT ON TABLE tickets IS 'Tickets numériques avec QR code';
