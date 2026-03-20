# 🎫 INSTALLATION SYSTÈME DE TICKETS

## Scripts SQL à exécuter dans l'ordre

### 1. Corriger le schéma reservations
```bash
supabase/fix-reservations-schema.sql
```
Ce script:
- Ajoute `seat_number`, `passenger_name`, `passenger_phone` à la table reservations
- Renomme `reference_reservation` en `reference`
- Ajoute la colonne `status` (compatible avec le code)
- Crée la fonction de génération automatique de référence unique (format: SEN12345678)
- Configure les triggers pour auto-générer les références

### 2. Ajouter les fonctions de gestion des sièges
```bash
supabase/add-seat-functions.sql
```
Ce script:
- Crée les fonctions `decrement_available_seats()` et `increment_available_seats()`
- Configure le trigger automatique pour mettre à jour les places disponibles
- Ajoute la fonction `is_seat_available()` pour vérification

### 3. Vérifier que les permissions sont OK
```bash
supabase/fix-permissions.sql
```
(À réexécuter si besoin)

## Test du système

Une fois les scripts exécutés:

1. **Aller sur l'app:** `http://localhost:3000/search`
2. **Chercher un trajet:** Sélectionner Dakar → Saint-Louis
3. **Cliquer sur "Réserver"** sur un trajet
4. **Sélectionner un siège** dans le plan du bus
5. **Remplir les informations passager**
6. **Confirmer la réservation**
7. **Le ticket s'affiche** avec:
   - Référence unique (ex: SEN3F8A9B2C)
   - QR Code scannable
   - Toutes les informations du voyage
   - Boutons "Imprimer" et "Télécharger PDF"

## Fonctionnalités du ticket

✅ **Design professionnel** - Style transport moderne  
✅ **QR Code unique** - Généré avec les données de réservation  
✅ **Imprimable** - CSS optimisé pour impression (A4)  
✅ **Responsive** - Fonctionne sur mobile et desktop  
✅ **Informations complètes:**
- Nom et téléphone du passager
- Ville départ → arrivée
- Date et heure de départ
- Numéro de siège (grande taille, bien visible)
- Référence de réservation
- Prix du billet
- QR Code de vérification

## Structure des fichiers créés

```
app/
├── booking/
│   └── [tripId]/
│       └── confirmation/
│           └── page.tsx          # Page de confirmation avec ticket
├── api/
│   ├── bookings/
│   │   └── [bookingId]/
│   │       └── route.ts          # API pour récupérer une réservation
│   └── trips/
│       └── [tripId]/
│           └── seats/
│               └── route.ts      # API sièges (GET + POST)
components/
└── booking/
    ├── SeatSelector.tsx          # Sélecteur de siège interactif
    └── Ticket.tsx                # Composant ticket imprimable
supabase/
├── fix-reservations-schema.sql   # Correction schéma DB
├── add-seat-functions.sql        # Fonctions gestion sièges
└── fix-permissions.sql           # Permissions DB
```

## Dépendances installées

```json
{
  "qrcode.react": "^4.1.0"  // Génération QR codes
}
```

## Prochaines étapes possibles

- [ ] Envoi du ticket par email
- [ ] Génération PDF côté serveur (PDF-lib ou Puppeteer)
- [ ] Système de paiement (Wave, Orange Money)
- [ ] Notifications SMS avec référence
- [ ] Interface admin pour scanner les QR codes

---

**Note:** Le système génère automatiquement des références uniques au format `SEN` + 8 caractères alphanumériques.
