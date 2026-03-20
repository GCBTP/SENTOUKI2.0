# Diagramme de Base de Données - SENTOUKI

## Schéma Visuel des Relations

```
┌─────────────────────────┐
│         users           │
│─────────────────────────│
│ • id (UUID, PK)         │
│ • email                 │
│ • nom                   │
│ • telephone             │
│ • role                  │
│ • created_at            │
│ • updated_at            │
└────────────┬────────────┘
             │
             │ 1:N
             │
             ▼
┌─────────────────────────┐
│     reservations        │
│─────────────────────────│
│ • id (UUID, PK)         │
│ • user_id (FK) ◄────────┘
│ • trip_id (FK)          │
│ • seat_id (FK)          │
│ • reference_reservation │
│ • statut                │
│ • nombre_passagers      │
│ • montant_total         │
│ • created_at            │
│ • updated_at            │
└──────┬──────────┬───────┘
       │          │
       │ 1:N      │ 1:1
       │          │
       ▼          ▼
┌─────────┐  ┌─────────┐
│payments │  │ tickets │
│─────────│  │─────────│
│• id     │  │• id     │
│• reserv.│  │• reserv.│
│• montant│  │• numero │
│• statut │  │• qr_code│
│• methode│  │• statut │
└─────────┘  └─────────┘

┌─────────────────────────┐
│         trips           │
│─────────────────────────│
│ • id (UUID, PK)         │
│ • ville_depart_id (FK)  │───┐
│ • ville_arrivee_id (FK) │───┤
│ • bus_id (FK)           │   │
│ • date_depart           │   │
│ • heure_depart          │   │
│ • heure_arrivee         │   │
│ • prix                  │   │
│ • places_disponibles    │   │
│ • statut                │   │
└────────────┬────────────┘   │
             │                │
             │ N:1            │ N:1
             │                │
             ▼                ▼
┌─────────────────────┐  ┌──────────┐
│       buses         │  │  cities  │
│─────────────────────│  │──────────│
│ • id (UUID, PK)     │  │• id (PK) │
│ • nom_bus           │  │• nom     │
│ • immatriculation   │  │• region  │
│ • nombre_places     │  │• code    │
│ • modele            │  └──────────┘
│ • statut            │
└──────────┬──────────┘
           │
           │ 1:N
           │
           ▼
┌─────────────────────┐
│       seats         │
│─────────────────────│
│ • id (UUID, PK)     │
│ • bus_id (FK)       │
│ • numero            │
│ • position          │
└─────────────────────┘
```

## Cardinalités

### users ↔ reservations
- **1:N** - Un utilisateur peut avoir plusieurs réservations

### reservations ↔ payments
- **1:N** - Une réservation peut avoir plusieurs paiements (cas des paiements partiels)

### reservations ↔ tickets
- **1:1** - Une réservation génère un ticket unique

### reservations ↔ trips
- **N:1** - Plusieurs réservations pour un même voyage

### reservations ↔ seats
- **N:1** - Plusieurs réservations (différents voyages) peuvent utiliser le même siège

### trips ↔ buses
- **N:1** - Plusieurs voyages peuvent utiliser le même bus

### trips ↔ cities
- **N:1** - Un voyage a une ville de départ et une ville d'arrivée

### buses ↔ seats
- **1:N** - Un bus a plusieurs sièges

## Types de Contraintes

### Clés Primaires (PK)
- Toutes les tables utilisent `UUID` pour les IDs
- Génération automatique avec `uuid_generate_v4()`

### Clés Étrangères (FK)
- `reservations.user_id` → `users.id`
- `reservations.trip_id` → `trips.id`
- `reservations.seat_id` → `seats.id`
- `trips.ville_depart_id` → `cities.id`
- `trips.ville_arrivee_id` → `cities.id`
- `trips.bus_id` → `buses.id`
- `seats.bus_id` → `buses.id`
- `payments.reservation_id` → `reservations.id`
- `tickets.reservation_id` → `reservations.id`

### Contraintes UNIQUE
- `users.email`
- `buses.immatriculation`
- `reservations.reference_reservation`
- `payments.reference_transaction`
- `tickets.numero_ticket`
- `seats.bus_id + numero` (composite)

### Contraintes CHECK
- `users.role` IN ('client', 'admin', 'super_admin')
- `buses.statut` IN ('actif', 'maintenance', 'inactif')
- `buses.nombre_places > 0`
- `trips.ville_depart_id != ville_arrivee_id`
- `trips.prix >= 0`
- `trips.places_disponibles >= 0`
- `trips.statut` IN ('programme', 'en_cours', 'termine', 'annule')
- `reservations.statut` IN ('en_attente', 'confirme', 'annule', 'termine')
- `reservations.nombre_passagers > 0`
- `payments.statut_paiement` IN ('en_attente', 'paye', 'echoue', 'rembourse')
- `tickets.statut` IN ('valide', 'utilise', 'annule', 'expire')
- `seats.numero > 0`

## Index Créés

### Performance de recherche
```sql
-- Recherche d'utilisateurs
idx_users_email
idx_users_role

-- Recherche de villes
idx_cities_nom
idx_cities_region

-- Recherche de bus
idx_buses_statut

-- Recherche de trajets
idx_trips_date_depart
idx_trips_ville_depart
idx_trips_ville_arrivee
idx_trips_statut
idx_trips_bus
idx_trips_search (composite: départ, arrivée, date)

-- Recherche de sièges
idx_seats_bus

-- Recherche de réservations
idx_reservations_user
idx_reservations_trip
idx_reservations_reference
idx_reservations_statut

-- Recherche de paiements
idx_payments_reservation
idx_payments_statut
idx_payments_reference

-- Recherche de tickets
idx_tickets_reservation
idx_tickets_numero
idx_tickets_statut
```

## Triggers Automatiques

### 1. update_updated_at_column
**Appliqué sur:** users, buses, trips, reservations, payments

**Fonction:** Met à jour automatiquement `updated_at` à chaque UPDATE

### 2. auto_create_seats
**Appliqué sur:** buses (AFTER INSERT)

**Fonction:** Crée automatiquement tous les sièges (1 à nombre_places) quand un bus est créé

### 3. manage_trip_availability
**Appliqué sur:** reservations (AFTER INSERT OR UPDATE)

**Fonction:**
- Décrémente `trips.places_disponibles` quand réservation confirmée
- Incrémente si réservation annulée

## Fonctions Personnalisées

### generate_reservation_reference()
**Retour:** TEXT (ex: `SENTA1B2C3D4E5`)

**Usage:**
```sql
INSERT INTO reservations (reference_reservation, ...)
VALUES (generate_reservation_reference(), ...);
```

### generate_ticket_number()
**Retour:** TEXT (ex: `TKT123456789012`)

**Usage:**
```sql
INSERT INTO tickets (numero_ticket, ...)
VALUES (generate_ticket_number(), ...);
```

## Vue Admin

### admin_stats
**Colonnes:**
- `total_clients` - Nombre de clients enregistrés
- `buses_actifs` - Nombre de bus actifs
- `trips_programmes` - Voyages à venir
- `reservations_confirmees` - Réservations confirmées
- `revenus_total` - Somme des paiements réussis

**Usage:**
```sql
SELECT * FROM admin_stats;
```

## Stratégies ON DELETE

### CASCADE (suppression en cascade)
- `reservations` → supprime les `payments` et `tickets` associés
- `buses` → supprime les `seats` associés
- `users` → supprime les `reservations` associées

### RESTRICT (empêche la suppression)
- `cities` → ne peut pas être supprimée si utilisée dans `trips`
- `buses` → ne peut pas être supprimé si utilisé dans `trips`
- `trips` → ne peut pas être supprimé si a des `reservations`
- `seats` → ne peut pas être supprimé si utilisé dans `reservations`

## Flux de Données Typique

### Création d'une Réservation

1. **Client recherche un trajet**
   ```sql
   SELECT * FROM trips WHERE ville_depart_id = ? AND date_depart = ?
   ```

2. **Sélection d'un siège disponible**
   ```sql
   SELECT s.* FROM seats s
   WHERE s.bus_id = ?
   AND s.id NOT IN (
     SELECT seat_id FROM reservations WHERE trip_id = ?
   )
   ```

3. **Création de la réservation**
   ```sql
   INSERT INTO reservations (...)
   -- Trigger: décrémente places_disponibles
   ```

4. **Paiement**
   ```sql
   INSERT INTO payments (reservation_id, montant, ...)
   ```

5. **Confirmation + Ticket**
   ```sql
   UPDATE reservations SET statut = 'confirme'
   INSERT INTO tickets (...)
   ```

---

**Ce diagramme représente la structure complète de la base de données SENTOUKI.**
