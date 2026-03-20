# 🔒 SENTOUKI - Guide Sécurité Professionnel

**Date:** 19 mars 2026  
**Version:** 1.0.0

---

## ✅ PROTECTIONS IMPLÉMENTÉES

### 1. Row Level Security (RLS) Supabase ✅

**Fichier:** `supabase/rls-policies.sql`

**Ce qui est protégé:**
- ✅ **Users:** Lecture/modification profil propre uniquement
- ✅ **Cities:** Lecture publique, gestion admin uniquement
- ✅ **Buses:** Lecture publique (actifs), gestion admin
- ✅ **Trips:** Lecture publique (actifs), gestion admin
- ✅ **Reservations:** Lecture ses réservations, création authentifiée
- ✅ **Payments:** Lecture ses paiements uniquement
- ✅ **Tickets:** Lecture ses tickets uniquement

**Admins:** Accès complet lecture/écriture sur tout.

**Comment activer:**
```bash
# 1. Ouvrir Supabase Dashboard
# 2. SQL Editor → New Query
# 3. Copier-coller tout le contenu de rls-policies.sql
# 4. Exécuter (Run)
# 5. Vérifier dans Table Editor que RLS = ON
```

---

### 2. Authentification Role-Based ✅

**Fichiers créés:**
- `lib/auth/session.ts` - Gestion session utilisateur
- `lib/api/auth-middleware.ts` - Middlewares auth API

**Fonctions disponibles:**
```typescript
// Récupérer session actuelle
const session = await getSession()
// → { user, isAuthenticated, isAdmin }

// Require auth (401 si non connecté)
const session = await requireAuth()

// Require admin (403 si pas admin)
const session = await requireAdmin()
```

**Middleware pour API routes:**
```typescript
import { withAuth, withAdminAuth } from '@/lib/api/auth-middleware'

// Route protégée (auth requis)
export const POST = withAuth(async (request, session) => {
  // session.user.id disponible
})

// Route admin uniquement
export const DELETE = withAdminAuth(async (request, session) => {
  // session.user.role = 'admin' ou 'super_admin'
})
```

---

### 3. Validation Serveur Prix ✅

**Fichier:** `app/api/trips/[tripId]/seats/route.ts`

**Protection contre manipulation prix:**

```typescript
// ❌ JAMAIS FAIRE CONFIANCE AU PRIX CLIENT
const clientPrice = body.price // Ignoré!

// ✅ TOUJOURS RÉCUPÉRER PRIX DU SERVEUR
const { data: trip } = await supabase
  .from('trips')
  .select('prix')
  .eq('id', tripId)
  .single()

const serverPrice = trip.prix // Utilisé pour réservation
```

**Vérifications additionnelles:**
- ✅ Vérifier statut voyage (programme/en_cours uniquement)
- ✅ Vérifier places disponibles > 0
- ✅ Vérifier numéro siège valide (1 - total_seats)
- ✅ Double check siège disponible (race condition)
- ✅ Log audit trail (IP, user, timestamp)

---

### 4. Protection Race Conditions ✅

**Problème:** 2 utilisateurs réservent même siège en même temps

**Solution:**
1. Contrainte unique DB: `unique_trip_seat_number`
2. Double vérification avant insert
3. Gestion erreur unique constraint (23505)

```typescript
// Vérification 1
const existing = await supabase
  .from('reservations')
  .select('id')
  .eq('trip_id', tripId)
  .eq('seat_number', seatNumber)
  .maybeSingle()

if (existing) throw APIError(409, 'Siège déjà réservé')

// Vérification 2: Constraint DB
try {
  await supabase.from('reservations').insert(...)
} catch (error) {
  if (error.code === '23505') {
    throw APIError(409, 'Siège vient d\'être réservé')
  }
}
```

---

### 5. Rate Limiting ✅

**Fichier:** `lib/api/rate-limit.ts`

**Configuration:**
- 5 requêtes POST / minute / IP
- 10 requêtes GET / minute / IP

```typescript
// Dans API route
const ip = request.headers.get('x-forwarded-for') || 'unknown'
if (!checkRateLimit(`booking:${ip}`, 5, 60000)) {
  throw APIError(429, 'Trop de tentatives')
}
```

**⚠️ Production:** Utiliser Redis (Upstash/Vercel KV)

---

### 6. Validation Schémas Zod ✅

**Fichiers:**
- `lib/validations/booking.ts` - Réservations client
- `lib/validations/admin.ts` - Opérations admin

**Validation stricte:**
```typescript
// Réservation
bookingSchema.parse({
  seatNumber: 1,                    // int > 0
  passengerName: "Amadou Diallo",   // 2-100 chars, lettres
  passengerPhone: "+221771234567"   // format sénégalais
})

// Trip admin
tripSchema.parse({
  prix: 5000,                       // int > 0, < 1M
  ville_depart_id: "uuid...",       // UUID valide
  date_depart: "2026-03-20",        // YYYY-MM-DD
  heure_depart: "14:30",            // HH:MM
})
```

---

### 7. Audit Logging ✅

**Implémenté dans:** `app/api/trips/[tripId]/seats/route.ts`

**Log chaque réservation:**
```typescript
console.log('[BOOKING_CREATED]', {
  bookingId: booking.id,
  tripId,
  userId,
  seatNumber,
  amount: serverPrice,
  ip,
  timestamp: new Date().toISOString(),
})
```

**Production:** Envoyer à Sentry/LogRocket

---

## 🚨 VULNÉRABILITÉS RÉSIDUELLES

### 1. Authentification Anonymous
**État actuel:** `userId: 'anonymous'`

**Risque:** Utilisateurs non authentifiés peuvent réserver

**Solution requise:**
```typescript
// Activer Supabase Auth
const { data: { session } } = await supabase.auth.getSession()
if (!session) {
  throw APIError(401, 'Authentification requise')
}
const userId = session.user.id
```

**Priorité:** 🔴 P0 - Urgent

---

### 2. Rate Limiting In-Memory
**Risque:** Reset au redémarrage serveur, pas de partage multi-instances

**Solution:**
```bash
# Utiliser Redis (Upstash gratuit)
npm install @upstash/redis

# Dans lib/api/rate-limit.ts
import { Redis } from '@upstash/redis'
const redis = Redis.fromEnv()
```

**Priorité:** 🟡 P1 - Important

---

### 3. Pas de 2FA pour Admins
**Risque:** Compte admin compromis = accès total

**Solution:** Activer 2FA Supabase pour rôles admin

**Priorité:** 🟡 P1 - Important

---

### 4. Pas de Webhook Vérification
**Risque:** Paiements non vérifiés (si Wave/Orange Money)

**Solution:** Webhooks signatures (HMAC SHA256)

**Priorité:** 🟡 P1 - Important

---

## 📋 CHECKLIST DÉPLOIEMENT SÉCURISÉ

### Avant Production

- [ ] ✅ RLS activé sur toutes tables
- [ ] ✅ Policies testées (lecture/écriture)
- [ ] ⏳ Authentification Supabase activée
- [ ] ⏳ Clés API régénérées
- [ ] ⏳ Rate limiting Redis (production)
- [ ] ⏳ Monitoring erreurs (Sentry)
- [ ] ⏳ Audit logs centralisés
- [ ] ⏳ Tests sécurité (OWASP)
- [ ] ⏳ Backup automatique DB

### Variables d'environnement

```env
# Supabase (régénérées)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...

# Redis (Upstash)
UPSTASH_REDIS_REST_URL=https://xxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=Axxx

# Monitoring
SENTRY_DSN=https://xxx@sentry.io/xxx
NEXT_PUBLIC_VERCEL_ENV=production
```

---

## 🛡️ TESTS DE SÉCURITÉ

### 1. Test RLS
```sql
-- En tant que user normal
SET ROLE authenticated;
SET request.jwt.claims.sub TO 'user-uuid-here';

-- Doit échouer (pas admin)
SELECT * FROM users;

-- Doit réussir (ses réservations)
SELECT * FROM reservations WHERE user_id = 'user-uuid-here';
```

### 2. Test Manipulation Prix
```bash
# Essayer de réserver avec prix modifié
curl -X POST http://localhost:3000/api/trips/xxx/seats \
  -H "Content-Type: application/json" \
  -d '{
    "seatNumber": 1,
    "passengerName": "Test",
    "passengerPhone": "+221771234567",
    "price": 1  # ❌ Prix falsifié
  }'

# Vérifier que le prix serveur est utilisé
# Check montant_total dans DB = prix voyage (pas 1)
```

### 3. Test Race Condition
```bash
# Lancer 2 requêtes simultanées même siège
curl -X POST ... & curl -X POST ...

# Résultat attendu:
# 1ère requête: 201 Created
# 2ème requête: 409 Conflict "Siège déjà réservé"
```

### 4. Test Rate Limiting
```bash
# Spammer 10 requêtes rapidement
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/trips/xxx/seats ...
done

# Résultat attendu après 5 requêtes:
# 429 Too Many Requests
```

---

## 📚 RESSOURCES

- [Supabase RLS Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Next.js Security Headers](https://nextjs.org/docs/app/api-reference/next-config-js/headers)
- [Upstash Redis](https://upstash.com/docs/redis/overall/getstarted)

---

## 🎯 PROCHAINES ÉTAPES

### Cette Semaine (P0)
1. ✅ Implémenter RLS Supabase
2. ✅ Validation serveur prix
3. ⏳ Activer Supabase Auth
4. ⏳ Régénérer clés API

### Semaine Prochaine (P1)
5. ⏳ Rate limiting Redis
6. ⏳ Monitoring Sentry
7. ⏳ Tests sécurité automatisés
8. ⏳ Audit logs centralisés

---

**Rapport créé:** 2026-03-19 21:50 GMT+1  
**Par:** Mohaly (Grevitbot)  
**Status:** 7/10 protections critiques implémentées
