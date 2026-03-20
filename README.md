# Configuration Base de Données Supabase - SENTOUKI

Ce dossier contient tous les fichiers SQL nécessaires pour configurer la base de données PostgreSQL sur Supabase.

## 📁 Fichiers SQL

### 1. `schema.sql` - Schéma de la base de données
Contient:
- ✅ 8 tables principales
- ✅ Clés étrangères et contraintes
- ✅ Index pour performances
- ✅ Triggers automatiques
- ✅ Fonctions utilitaires
- ✅ Vue pour statistiques admin

**Tables créées:**
1. `users` - Utilisateurs (clients + admins)
2. `cities` - Villes et régions du Sénégal
3. `buses` - Flotte de bus
4. `trips` - Voyages programmés
5. `seats` - Sièges des bus
6. `reservations` - Réservations clients
7. `payments` - Paiements et transactions
8. `tickets` - Tickets numériques avec QR code

### 2. `seed.sql` - Données initiales
Contient:
- ✅ 40+ villes du Sénégal (toutes les régions)
- ✅ 5 utilisateurs de test (2 admins, 3 clients)
- ✅ 7 bus de la flotte
- ✅ Trajets populaires (Dakar → Saint-Louis, Touba, Ziguinchor, etc.)
- ✅ Génération automatique des sièges

### 3. `rls-policies.sql` - Sécurité (Row Level Security)
Contient:
- ✅ Activation RLS sur toutes les tables
- ✅ Policies pour clients (accès à leurs propres données)
- ✅ Policies pour admins (accès complet)
- ✅ Données publiques (villes, trajets programmés)

---

## 🚀 Installation

### Option A: Interface Supabase (Recommandé pour débutants)

1. **Créer un compte Supabase**
   - Aller sur [supabase.com](https://supabase.com)
   - Créer un compte gratuit
   - Créer un nouveau projet

2. **Exécuter les scripts SQL**
   - Dans le dashboard Supabase, aller dans **SQL Editor**
   - Créer une nouvelle query

3. **Exécuter dans l'ordre:**

   **a) Créer le schéma**
   ```sql
   -- Copier-coller le contenu de schema.sql
   -- Cliquer sur "Run"
   ```

   **b) Insérer les données**
   ```sql
   -- Copier-coller le contenu de seed.sql
   -- Cliquer sur "Run"
   ```

   **c) Configurer la sécurité**
   ```sql
   -- Copier-coller le contenu de rls-policies.sql
   -- Cliquer sur "Run"
   ```

4. **Vérifier**
   - Aller dans **Table Editor**
   - Vous devriez voir toutes les tables
   - Vérifier que les données sont présentes

### Option B: Via CLI Supabase

```bash
# Installer le CLI Supabase
npm install -g supabase

# Se connecter
supabase login

# Initialiser (si pas déjà fait)
supabase init

# Lancer Supabase localement (optionnel)
supabase start

# Appliquer les migrations
supabase db push

# Ou exécuter les fichiers SQL manuellement
supabase db execute -f schema.sql
supabase db execute -f seed.sql
supabase db execute -f rls-policies.sql
```

---

## 🔑 Récupérer les clés Supabase

1. Dans le dashboard Supabase, aller dans **Settings → API**

2. Copier:
   - `Project URL` → `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

3. Créer `.env.local` à la racine du projet:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://votre-projet.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=votre-anon-key
   NEXT_PUBLIC_APP_URL=http://localhost:3000
   ```

---

## 🧪 Tester la base de données

### Via SQL Editor Supabase

```sql
-- Compter les villes
SELECT COUNT(*) FROM cities;

-- Voir les trajets programmés
SELECT 
    t.id,
    c1.nom as depart,
    c2.nom as arrivee,
    t.date_depart,
    t.prix,
    t.places_disponibles
FROM trips t
JOIN cities c1 ON t.ville_depart_id = c1.id
JOIN cities c2 ON t.ville_arrivee_id = c2.id
WHERE t.statut = 'programme';

-- Voir les bus et leurs sièges
SELECT 
    b.nom_bus,
    b.nombre_places,
    COUNT(s.id) as sieges_crees
FROM buses b
LEFT JOIN seats s ON s.bus_id = b.id
GROUP BY b.id, b.nom_bus, b.nombre_places;

-- Statistiques admin
SELECT * FROM admin_stats;
```

### Via l'application Next.js

1. Démarrer l'app:
   ```bash
   npm run dev
   ```

2. Ouvrir http://localhost:3000

3. Les données devraient s'afficher (villes, trajets, etc.)

---

## 📊 Structure des Relations

```
users ───┐
         │
         └──► reservations ──► payments
                  │
                  ├──► tickets
                  │
                  └──► trips ──┬──► buses ──► seats
                               │
                               ├──► cities (départ)
                               │
                               └──► cities (arrivée)
```

---

## 🔒 Sécurité RLS - Résumé

### Données publiques (sans auth):
- ✅ Villes (lecture)
- ✅ Trajets programmés (lecture)
- ✅ Bus actifs (lecture)
- ✅ Sièges (lecture)

### Clients authentifiés:
- ✅ Voir leurs propres réservations
- ✅ Créer des réservations
- ✅ Voir leurs paiements
- ✅ Voir leurs tickets

### Administrateurs:
- ✅ Accès complet (CRUD) sur toutes les tables
- ✅ Statistiques et rapports
- ✅ Gestion complète de la plateforme

---

## 🛠️ Fonctionnalités Automatiques

### Triggers créés:

1. **Auto-update `updated_at`**
   - Se déclenche sur UPDATE
   - Met à jour automatiquement la date de modification

2. **Génération automatique des sièges**
   - Quand un bus est créé
   - Crée automatiquement tous les sièges (1 à nombre_places)

3. **Gestion des places disponibles**
   - Quand une réservation est confirmée → décrémente les places
   - Quand une réservation est annulée → incrémente les places

### Fonctions utilitaires:

1. **`generate_reservation_reference()`**
   - Génère une référence unique: `SENT + 10 caractères`
   - Ex: `SENTA1B2C3D4E5`

2. **`generate_ticket_number()`**
   - Génère un numéro de ticket: `TKT + 12 chiffres`
   - Ex: `TKT123456789012`

---

## 📝 Exemple de Requêtes Courantes

### Rechercher des trajets
```sql
SELECT 
    t.id,
    cd.nom as ville_depart,
    ca.nom as ville_arrivee,
    t.date_depart,
    t.heure_depart,
    t.prix,
    t.places_disponibles,
    b.nom_bus
FROM trips t
JOIN cities cd ON t.ville_depart_id = cd.id
JOIN cities ca ON t.ville_arrivee_id = ca.id
JOIN buses b ON t.bus_id = b.id
WHERE cd.nom = 'Dakar'
  AND ca.nom = 'Saint-Louis'
  AND t.date_depart >= CURRENT_DATE
  AND t.statut = 'programme'
ORDER BY t.date_depart, t.heure_depart;
```

### Créer une réservation
```sql
INSERT INTO reservations (
    user_id, 
    trip_id, 
    seat_id, 
    reference_reservation, 
    montant_total,
    statut
) VALUES (
    'user-uuid',
    'trip-uuid',
    'seat-uuid',
    generate_reservation_reference(),
    5000,
    'en_attente'
);
```

### Confirmer une réservation après paiement
```sql
-- 1. Créer le paiement
INSERT INTO payments (reservation_id, montant, statut_paiement, methode_paiement)
VALUES ('reservation-uuid', 5000, 'paye', 'wave');

-- 2. Mettre à jour la réservation
UPDATE reservations
SET statut = 'confirme'
WHERE id = 'reservation-uuid';

-- 3. Créer le ticket
INSERT INTO tickets (reservation_id, numero_ticket, statut)
VALUES ('reservation-uuid', generate_ticket_number(), 'valide');
```

---

## 🐛 Troubleshooting

### Erreur: "extension uuid-ossp does not exist"
**Solution:**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Erreur: "relation already exists"
**Solution:** Les tables existent déjà. Pour recommencer:
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
-- Puis ré-exécuter schema.sql
```

### Les sièges ne sont pas créés
**Solution:** Vérifier que le trigger existe:
```sql
SELECT * FROM pg_trigger WHERE tgname = 'auto_create_seats';
```

---

## 📚 Ressources

- [Documentation Supabase](https://supabase.com/docs)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

## ✅ Checklist de Configuration

- [ ] Compte Supabase créé
- [ ] Projet Supabase créé
- [ ] `schema.sql` exécuté
- [ ] `seed.sql` exécuté
- [ ] `rls-policies.sql` exécuté
- [ ] Clés API récupérées
- [ ] `.env.local` configuré
- [ ] Base de données testée
- [ ] Application Next.js connectée

---

**Configuration terminée! La base de données est prête à l'emploi! 🎉**
