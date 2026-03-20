-- ============================================
-- SEED TRIPS - Trajets de test pour Sentouki
-- ============================================
-- Exécuter après seed.sql
-- Crée des trajets entre les villes principales

-- Variables pour les IDs (à adapter selon votre base)
-- Villes : Dakar, Saint-Louis, Kaolack, Thiès, Ziguinchor, etc.
-- Bus : Express Dakar, Rapide Saint-Louis, Confort Casamance

-- ============================================
-- TRAJETS DAKAR → SAINT-LOUIS
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id as ville_depart_id,
  a.id as ville_arrivee_id,
  b.id as bus_id,
  CURRENT_DATE as date_depart,
  '08:00:00' as heure_depart,
  '12:00:00' as heure_arrivee,
  5000 as prix,
  b.nombre_places as places_disponibles,
  'programme' as statut
FROM cities d
CROSS JOIN cities a
CROSS JOIN buses b
WHERE d.nom = 'Dakar'
  AND a.nom = 'Saint-Louis'
  AND b.nom_bus = 'Express Dakar';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '14:00:00', '18:00:00',
  5500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Saint-Louis' AND b.nom_bus = 'Rapide Saint-Louis';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '18:00:00', '22:00:00',
  4800, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Saint-Louis' AND b.nom_bus = 'Confort Casamance';

-- ============================================
-- TRAJETS DAKAR → THIÈS
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '07:00:00', '08:30:00',
  1500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Thiès' AND b.nom_bus = 'Express Dakar';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '15:00:00', '16:30:00',
  1500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Thiès' AND b.nom_bus = 'Rapide Saint-Louis';

-- ============================================
-- TRAJETS DAKAR → KAOLACK
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '09:00:00', '12:30:00',
  3500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Kaolack' AND b.nom_bus = 'Express Dakar';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '16:00:00', '19:30:00',
  3200, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Kaolack' AND b.nom_bus = 'Confort Casamance';

-- ============================================
-- TRAJETS DAKAR → ZIGUINCHOR
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '08:00:00', '16:00:00',
  8000, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Ziguinchor' AND b.nom_bus = 'Confort Casamance';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '20:00:00', '05:00:00',
  7500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Ziguinchor' AND b.nom_bus = 'Express Dakar';

-- ============================================
-- TRAJETS RETOUR SAINT-LOUIS → DAKAR
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '09:00:00', '13:00:00',
  5000, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Saint-Louis' AND a.nom = 'Dakar' AND b.nom_bus = 'Rapide Saint-Louis';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE,
  '15:00:00', '19:00:00',
  5200, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Saint-Louis' AND a.nom = 'Dakar' AND b.nom_bus = 'Express Dakar';

-- ============================================
-- TRAJETS POUR DEMAIN (CURRENT_DATE + 1)
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE + INTERVAL '1 day',
  '08:00:00', '12:00:00',
  5000, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Saint-Louis' AND b.nom_bus = 'Express Dakar';

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE + INTERVAL '1 day',
  '14:00:00', '18:00:00',
  5500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Saint-Louis' AND b.nom_bus = 'Rapide Saint-Louis';

-- ============================================
-- TRAJETS POUR APRÈS-DEMAIN (CURRENT_DATE + 2)
-- ============================================

INSERT INTO trips (ville_depart_id, ville_arrivee_id, bus_id, date_depart, heure_depart, heure_arrivee, prix, places_disponibles, statut)
SELECT 
  d.id, a.id, b.id,
  CURRENT_DATE + INTERVAL '2 days',
  '09:00:00', '12:30:00',
  3500, b.nombre_places, 'programme'
FROM cities d, cities a, buses b
WHERE d.nom = 'Dakar' AND a.nom = 'Kaolack' AND b.nom_bus = 'Express Dakar';

-- ============================================
-- VÉRIFICATION
-- ============================================

-- Compter le nombre de trajets créés
SELECT 
  COUNT(*) as total_trajets,
  COUNT(DISTINCT ville_depart_id) as villes_depart,
  COUNT(DISTINCT ville_arrivee_id) as villes_arrivee,
  COUNT(DISTINCT bus_id) as bus_utilises
FROM trips;

-- Afficher un résumé par date
SELECT 
  date_depart,
  COUNT(*) as nb_trajets,
  SUM(places_disponibles) as total_places
FROM trips
GROUP BY date_depart
ORDER BY date_depart;
