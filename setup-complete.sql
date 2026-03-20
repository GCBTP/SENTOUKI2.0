-- =====================================================
-- SENTOUKI - INSTALLATION COMPLÈTE
-- Fichier unique pour setup complet de la base de données
-- =====================================================
-- 
-- Ce fichier combine:
-- 1. Schéma (tables, contraintes, index)
-- 2. Fonctions et triggers
-- 3. Row Level Security (RLS)
-- 4. Données initiales (seed)
--
-- USAGE: Copier-coller dans SQL Editor de Supabase
-- =====================================================

-- =====================================================
-- ÉTAPE 1: EXTENSIONS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ÉTAPE 2: TABLES
-- =====================================================

-- users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'admin', 'super_admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- cities
CREATE TABLE IF NOT EXISTS cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- buses
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

-- trips
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
    CONSTRAINT check_different_cities CHECK (ville_depart_id != ville_arrivee_id)
);

-- seats
CREATE TABLE IF NOT EXISTS seats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bus_id UUID NOT NULL REFERENCES buses(id) ON DELETE CASCADE,
    numero INTEGER NOT NULL CHECK (numero > 0),
    position VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_seat_per_bus UNIQUE (bus_id, numero)
);

-- reservations
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
    CONSTRAINT unique_seat_per_trip UNIQUE (trip_id, seat_id)
);

-- payments
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    montant DECIMAL(10, 2) NOT NULL CHECK (montant >= 0),
    statut_paiement VARCHAR(20) DEFAULT 'en_attente' CHECK (statut_paiement IN ('en_attente', 'paye', 'echoue', 'rembourse')),
    methode_paiement VARCHAR(50),
    reference_transaction VARCHAR(100) UNIQUE,
    date_paiement TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- tickets
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
    numero_ticket VARCHAR(50) UNIQUE NOT NULL,
    qr_code TEXT,
    statut VARCHAR(20) DEFAULT 'valide' CHECK (statut IN ('valide', 'utilise', 'annule', 'expire')),
    date_utilisation TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÉTAPE 3: INDEX
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_cities_nom ON cities(nom);
CREATE INDEX IF NOT EXISTS idx_cities_region ON cities(region);
CREATE INDEX IF NOT EXISTS idx_buses_statut ON buses(statut);
CREATE INDEX IF NOT EXISTS idx_trips_date_depart ON trips(date_depart);
CREATE INDEX IF NOT EXISTS idx_trips_ville_depart ON trips(ville_depart_id);
CREATE INDEX IF NOT EXISTS idx_trips_ville_arrivee ON trips(ville_arrivee_id);
CREATE INDEX IF NOT EXISTS idx_trips_statut ON trips(statut);
CREATE INDEX IF NOT EXISTS idx_trips_bus ON trips(bus_id);
CREATE INDEX IF NOT EXISTS idx_trips_search ON trips(ville_depart_id, ville_arrivee_id, date_depart);
CREATE INDEX IF NOT EXISTS idx_seats_bus ON seats(bus_id);
CREATE INDEX IF NOT EXISTS idx_reservations_user ON reservations(user_id);
CREATE INDEX IF NOT EXISTS idx_reservations_trip ON reservations(trip_id);
CREATE INDEX IF NOT EXISTS idx_reservations_reference ON reservations(reference_reservation);
CREATE INDEX IF NOT EXISTS idx_reservations_statut ON reservations(statut);
CREATE INDEX IF NOT EXISTS idx_payments_reservation ON payments(reservation_id);
CREATE INDEX IF NOT EXISTS idx_payments_statut ON payments(statut_paiement);
CREATE INDEX IF NOT EXISTS idx_payments_reference ON payments(reference_transaction);
CREATE INDEX IF NOT EXISTS idx_tickets_reservation ON tickets(reservation_id);
CREATE INDEX IF NOT EXISTS idx_tickets_numero ON tickets(numero_ticket);
CREATE INDEX IF NOT EXISTS idx_tickets_statut ON tickets(statut);

-- =====================================================
-- ÉTAPE 4: FONCTIONS
-- =====================================================

-- Update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Générer référence réservation
CREATE OR REPLACE FUNCTION generate_reservation_reference()
RETURNS TEXT AS $$
DECLARE
    ref TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        ref := 'SENT' || UPPER(substring(md5(random()::text) from 1 for 10));
        SELECT EXISTS(SELECT 1 FROM reservations WHERE reference_reservation = ref) INTO exists;
        IF NOT exists THEN
            RETURN ref;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Générer numéro de ticket
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TEXT AS $$
DECLARE
    ticket_num TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        ticket_num := 'TKT' || LPAD(floor(random() * 1000000000000)::text, 12, '0');
        SELECT EXISTS(SELECT 1 FROM tickets WHERE numero_ticket = ticket_num) INTO exists;
        IF NOT exists THEN
            RETURN ticket_num;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Créer sièges automatiquement
CREATE OR REPLACE FUNCTION create_bus_seats()
RETURNS TRIGGER AS $$
DECLARE
    i INTEGER;
BEGIN
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

-- Gérer disponibilité des places
CREATE OR REPLACE FUNCTION update_trip_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.statut = 'confirme' THEN
        UPDATE trips 
        SET places_disponibles = places_disponibles - NEW.nombre_passagers
        WHERE id = NEW.trip_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.statut = 'confirme' AND NEW.statut = 'annule' THEN
            UPDATE trips 
            SET places_disponibles = places_disponibles + OLD.nombre_passagers
            WHERE id = OLD.trip_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ÉTAPE 5: TRIGGERS
-- =====================================================
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_buses_updated_at ON buses;
CREATE TRIGGER update_buses_updated_at BEFORE UPDATE ON buses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_trips_updated_at ON trips;
CREATE TRIGGER update_trips_updated_at BEFORE UPDATE ON trips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_reservations_updated_at ON reservations;
CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS auto_create_seats ON buses;
CREATE TRIGGER auto_create_seats AFTER INSERT ON buses
    FOR EACH ROW EXECUTE FUNCTION create_bus_seats();

DROP TRIGGER IF EXISTS manage_trip_availability ON reservations;
CREATE TRIGGER manage_trip_availability AFTER INSERT OR UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION update_trip_availability();

-- =====================================================
-- ÉTAPE 6: VUE ADMIN
-- =====================================================
CREATE OR REPLACE VIEW admin_stats AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'client') as total_clients,
    (SELECT COUNT(*) FROM buses WHERE statut = 'actif') as buses_actifs,
    (SELECT COUNT(*) FROM trips WHERE statut = 'programme') as trips_programmes,
    (SELECT COUNT(*) FROM reservations WHERE statut = 'confirme') as reservations_confirmees,
    (SELECT COALESCE(SUM(montant), 0) FROM payments WHERE statut_paiement = 'paye') as revenus_total;

-- =====================================================
-- ÉTAPE 7: ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Activer RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- Policies (simplifié - tout public pour l'instant)
-- IMPORTANT: À adapter selon vos besoins de sécurité

CREATE POLICY "Public read cities" ON cities FOR SELECT TO public USING (true);
CREATE POLICY "Public read buses" ON buses FOR SELECT TO public USING (statut = 'actif');
CREATE POLICY "Public read trips" ON trips FOR SELECT TO public USING (statut IN ('programme', 'en_cours'));
CREATE POLICY "Public read seats" ON seats FOR SELECT TO public USING (true);

-- =====================================================
-- ÉTAPE 8: SEED DATA
-- =====================================================

-- Villes principales du Sénégal
INSERT INTO cities (nom, region, code) VALUES
('Dakar', 'Dakar', 'DKR'),
('Thiès', 'Thiès', 'THS'),
('Saint-Louis', 'Saint-Louis', 'STL'),
('Touba', 'Diourbel', 'TBA'),
('Kaolack', 'Kaolack', 'KLK'),
('Ziguinchor', 'Ziguinchor', 'ZGR'),
('Tambacounda', 'Tambacounda', 'TMB'),
('Louga', 'Louga', 'LGA'),
('Matam', 'Matam', 'MTM'),
('Kolda', 'Kolda', 'KLD')
ON CONFLICT (code) DO NOTHING;

-- Admin
INSERT INTO users (email, nom, telephone, role) VALUES
('admin@sentouki.sn', 'Administrateur SENTOUKI', '+221 77 123 45 67', 'super_admin')
ON CONFLICT (email) DO NOTHING;

-- Bus
INSERT INTO buses (nom_bus, immatriculation, nombre_places, modele, statut) VALUES
('Express Dakar', 'DK-4521-AB', 45, 'Mercedes-Benz Tourismo', 'actif'),
('Rapide Saint-Louis', 'SL-3421-CD', 40, 'Volvo 9700', 'actif'),
('Confort Casamance', 'ZG-7821-EF', 50, 'Scania Touring', 'actif')
ON CONFLICT (immatriculation) DO NOTHING;

-- =====================================================
-- RÉSULTAT FINAL
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'INSTALLATION COMPLÈTE - SENTOUKI';
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Tables créées: 8';
    RAISE NOTICE 'Fonctions: 4';
    RAISE NOTICE 'Triggers: 7';
    RAISE NOTICE 'Vue admin: 1';
    RAISE NOTICE 'RLS activé sur toutes les tables';
    RAISE NOTICE '-----------------------------------------------------';
    RAISE NOTICE 'Villes: % ', (SELECT COUNT(*) FROM cities);
    RAISE NOTICE 'Bus: %', (SELECT COUNT(*) FROM buses);
    RAISE NOTICE 'Sièges: %', (SELECT COUNT(*) FROM seats);
    RAISE NOTICE 'Utilisateurs: %', (SELECT COUNT(*) FROM users);
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Installation terminée avec succès!';
    RAISE NOTICE '=====================================================';
END $$;
