-- =====================================================
-- SENTOUKI - Données Initiales (Seed Data)
-- Villes et régions du Sénégal
-- =====================================================

-- =====================================================
-- VILLES DU SÉNÉGAL par région
-- =====================================================

-- Région de Dakar
INSERT INTO cities (nom, region, code) VALUES
('Dakar', 'Dakar', 'DKR'),
('Pikine', 'Dakar', 'PIK'),
('Guédiawaye', 'Dakar', 'GDW'),
('Rufisque', 'Dakar', 'RUF');

-- Région de Thiès
INSERT INTO cities (nom, region, code) VALUES
('Thiès', 'Thiès', 'THS'),
('Mbour', 'Thiès', 'MBR'),
('Tivaouane', 'Thiès', 'TIV');

-- Région de Saint-Louis
INSERT INTO cities (nom, region, code) VALUES
('Saint-Louis', 'Saint-Louis', 'STL'),
('Dagana', 'Saint-Louis', 'DGN'),
('Podor', 'Saint-Louis', 'PDR');

-- Région de Diourbel
INSERT INTO cities (nom, region, code) VALUES
('Diourbel', 'Diourbel', 'DRB'),
('Touba', 'Diourbel', 'TBA'),
('Mbacké', 'Diourbel', 'MBK');

-- Région de Kaolack
INSERT INTO cities (nom, region, code) VALUES
('Kaolack', 'Kaolack', 'KLK'),
('Nioro du Rip', 'Kaolack', 'NRO'),
('Guinguinéo', 'Kaolack', 'GGN');

-- Région de Ziguinchor (Casamance)
INSERT INTO cities (nom, region, code) VALUES
('Ziguinchor', 'Ziguinchor', 'ZGR'),
('Oussouye', 'Ziguinchor', 'OSY'),
('Bignona', 'Ziguinchor', 'BGN');

-- Région de Kolda
INSERT INTO cities (nom, region, code) VALUES
('Kolda', 'Kolda', 'KLD'),
('Vélingara', 'Kolda', 'VLG'),
('Médina Yoro Foulah', 'Kolda', 'MYF');

-- Région de Tambacounda
INSERT INTO cities (nom, region, code) VALUES
('Tambacounda', 'Tambacounda', 'TMB'),
('Bakel', 'Tambacounda', 'BKL'),
('Kédougou', 'Tambacounda', 'KDG');

-- Région de Matam
INSERT INTO cities (nom, region, code) VALUES
('Matam', 'Matam', 'MTM'),
('Kanel', 'Matam', 'KNL'),
('Ranérou', 'Matam', 'RNR');

-- Région de Louga
INSERT INTO cities (nom, region, code) VALUES
('Louga', 'Louga', 'LGA'),
('Linguère', 'Louga', 'LGR'),
('Kébémer', 'Louga', 'KBM');

-- Région de Fatick
INSERT INTO cities (nom, region, code) VALUES
('Fatick', 'Fatick', 'FTK'),
('Foundiougne', 'Fatick', 'FDG'),
('Gossas', 'Fatick', 'GSS');

-- Région de Kaffrine
INSERT INTO cities (nom, region, code) VALUES
('Kaffrine', 'Kaffrine', 'KFR'),
('Koungheul', 'Kaffrine', 'KGL'),
('Birkelane', 'Kaffrine', 'BRK');

-- Région de Sédhiou
INSERT INTO cities (nom, region, code) VALUES
('Sédhiou', 'Sédhiou', 'SDH'),
('Goudomp', 'Sédhiou', 'GDP'),
('Bounkiling', 'Sédhiou', 'BNK');

-- =====================================================
-- UTILISATEURS DE TEST
-- =====================================================

-- Admin par défaut
INSERT INTO users (email, nom, telephone, role) VALUES
('admin@sentouki.sn', 'Administrateur SENTOUKI', '+221 77 123 45 67', 'super_admin'),
('admin2@sentouki.sn', 'Admin Support', '+221 77 123 45 68', 'admin');

-- Clients de test
INSERT INTO users (email, nom, telephone, role) VALUES
('client1@example.com', 'Moussa Diop', '+221 77 234 56 78', 'client'),
('client2@example.com', 'Fatou Sall', '+221 77 234 56 79', 'client'),
('client3@example.com', 'Abdou Kane', '+221 77 234 56 80', 'client');

-- =====================================================
-- BUS DE LA FLOTTE
-- =====================================================

INSERT INTO buses (nom_bus, immatriculation, nombre_places, modele, statut) VALUES
('Express Dakar', 'DK-4521-AB', 45, 'Mercedes-Benz Tourismo', 'actif'),
('Rapide Saint-Louis', 'SL-3421-CD', 40, 'Volvo 9700', 'actif'),
('Confort Casamance', 'ZG-7821-EF', 50, 'Scania Touring', 'actif'),
('Touba Express', 'TB-2341-GH', 45, 'MAN Lion''s Coach', 'actif'),
('Tambacounda Direct', 'TM-8721-IJ', 42, 'Iveco Magelys', 'actif'),
('Kaolack Shuttle', 'KL-5621-KL', 38, 'Mercedes-Benz Tourismo', 'actif'),
('Grand Ligne', 'DK-9821-MN', 48, 'Volvo 9700', 'maintenance');

-- Note: Les sièges seront créés automatiquement par le trigger

-- =====================================================
-- TRAJETS POPULAIRES (Exemples)
-- =====================================================

-- Variables pour stocker les IDs (à adapter selon vos besoins)
DO $$
DECLARE
    dakar_id UUID;
    stlouis_id UUID;
    touba_id UUID;
    ziguinchor_id UUID;
    tambacounda_id UUID;
    kaolack_id UUID;
    thies_id UUID;
    
    bus1_id UUID;
    bus2_id UUID;
    bus3_id UUID;
    bus4_id UUID;
    bus5_id UUID;
BEGIN
    -- Récupérer les IDs des villes
    SELECT id INTO dakar_id FROM cities WHERE nom = 'Dakar' LIMIT 1;
    SELECT id INTO stlouis_id FROM cities WHERE nom = 'Saint-Louis' LIMIT 1;
    SELECT id INTO touba_id FROM cities WHERE nom = 'Touba' LIMIT 1;
    SELECT id INTO ziguinchor_id FROM cities WHERE nom = 'Ziguinchor' LIMIT 1;
    SELECT id INTO tambacounda_id FROM cities WHERE nom = 'Tambacounda' LIMIT 1;
    SELECT id INTO kaolack_id FROM cities WHERE nom = 'Kaolack' LIMIT 1;
    SELECT id INTO thies_id FROM cities WHERE nom = 'Thiès' LIMIT 1;
    
    -- Récupérer les IDs des bus
    SELECT id INTO bus1_id FROM buses WHERE nom_bus = 'Express Dakar' LIMIT 1;
    SELECT id INTO bus2_id FROM buses WHERE nom_bus = 'Rapide Saint-Louis' LIMIT 1;
    SELECT id INTO bus3_id FROM buses WHERE nom_bus = 'Confort Casamance' LIMIT 1;
    SELECT id INTO bus4_id FROM buses WHERE nom_bus = 'Touba Express' LIMIT 1;
    SELECT id INTO bus5_id FROM buses WHERE nom_bus = 'Tambacounda Direct' LIMIT 1;
    
    -- Dakar → Saint-Louis (tous les jours)
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (dakar_id, stlouis_id, bus2_id, CURRENT_DATE + 1, '07:00', '11:00', 5000, 40),
        (dakar_id, stlouis_id, bus2_id, CURRENT_DATE + 1, '14:00', '18:00', 5000, 40),
        (dakar_id, stlouis_id, bus2_id, CURRENT_DATE + 2, '07:00', '11:00', 5000, 40);
    
    -- Dakar → Touba
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (dakar_id, touba_id, bus4_id, CURRENT_DATE + 1, '06:00', '09:30', 4000, 45),
        (dakar_id, touba_id, bus4_id, CURRENT_DATE + 1, '15:00', '18:30', 4000, 45),
        (dakar_id, touba_id, bus4_id, CURRENT_DATE + 2, '06:00', '09:30', 4000, 45);
    
    -- Dakar → Ziguinchor
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (dakar_id, ziguinchor_id, bus3_id, CURRENT_DATE + 1, '22:00', '08:00', 12000, 50),
        (dakar_id, ziguinchor_id, bus3_id, CURRENT_DATE + 3, '22:00', '08:00', 12000, 50);
    
    -- Dakar → Tambacounda
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (dakar_id, tambacounda_id, bus5_id, CURRENT_DATE + 1, '21:00', '05:00', 10000, 42),
        (dakar_id, tambacounda_id, bus5_id, CURRENT_DATE + 2, '21:00', '05:00', 10000, 42);
    
    -- Dakar → Kaolack
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (dakar_id, kaolack_id, bus1_id, CURRENT_DATE + 1, '08:00', '11:00', 3500, 45),
        (dakar_id, kaolack_id, bus1_id, CURRENT_DATE + 1, '16:00', '19:00', 3500, 45);
    
    -- Dakar → Thiès (courte distance)
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (dakar_id, thies_id, bus1_id, CURRENT_DATE + 1, '09:00', '10:30', 2000, 45),
        (dakar_id, thies_id, bus1_id, CURRENT_DATE + 1, '17:00', '18:30', 2000, 45);
    
    -- Trajets retours
    -- Saint-Louis → Dakar
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (stlouis_id, dakar_id, bus2_id, CURRENT_DATE + 1, '13:00', '17:00', 5000, 40);
    
    -- Touba → Dakar
    INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles)
    VALUES 
        (touba_id, dakar_id, bus4_id, CURRENT_DATE + 1, '11:00', '14:30', 4000, 45);

END $$;

-- =====================================================
-- Vérifications
-- =====================================================

-- Afficher un résumé des données insérées
DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'SEED DATA - Résumé';
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Villes insérées: %', (SELECT COUNT(*) FROM cities);
    RAISE NOTICE 'Utilisateurs créés: %', (SELECT COUNT(*) FROM users);
    RAISE NOTICE 'Bus ajoutés: %', (SELECT COUNT(*) FROM buses);
    RAISE NOTICE 'Sièges créés: %', (SELECT COUNT(*) FROM seats);
    RAISE NOTICE 'Trajets programmés: %', (SELECT COUNT(*) FROM trips);
    RAISE NOTICE '=====================================================';
END $$;
