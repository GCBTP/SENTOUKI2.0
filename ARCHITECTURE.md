# Architecture SENTOUKI

## 🏗️ Structure Globale

### Route Groups (Next.js 14)

1. **(admin)** - Espace administration
   - Routes: `/admin/*`
   - Protection: Authentication + Role check
   - Layout dédié avec navigation admin

2. **(client)** - Espace client public
   - Routes: `/search`, `/booking`, `/my-tickets`
   - Protection: Authentication pour certaines routes
   - Layout client avec header/footer public

3. **api** - API Routes
   - Routes: `/api/*`
   - Gestion des actions serveur
   - Intégration Supabase

## 📂 Organisation des Fichiers

### `/app`
```
app/
├── (admin)/
│   ├── layout.tsx          # Layout admin
│   ├── dashboard/
│   ├── buses/
│   ├── cities/
│   ├── routes/
│   ├── trips/
│   └── bookings/
├── (client)/
│   ├── layout.tsx          # Layout client
│   ├── page.tsx            # Page d'accueil
│   ├── search/
│   ├── booking/
│   └── my-tickets/
└── api/
    ├── auth/
    ├── bookings/
    └── payments/
```

### `/components`
```
components/
├── admin/
│   ├── BusForm.tsx
│   ├── TripList.tsx
│   └── BookingTable.tsx
├── client/
│   ├── SearchForm.tsx
│   ├── TripCard.tsx
│   └── TicketView.tsx
└── shared/
    ├── Button.tsx
    ├── Input.tsx
    └── Modal.tsx
```

### `/lib`
```
lib/
├── supabase/
│   ├── client.ts           # Client-side Supabase
│   ├── server.ts           # Server-side Supabase
│   └── middleware.ts       # Middleware auth
├── types/
│   └── index.ts            # Types globaux
└── utils/
    ├── formatters.ts       # Format dates, prix, etc.
    └── validators.ts       # Validation des données
```

## 🔄 Flux de Données

### Client Side
```
User Action → Component → Supabase Client → Database
                ↓
            Update UI
```

### Server Side (API Routes)
```
Request → API Route → Supabase Server → Database
           ↓
        Response (JSON)
```

### Server Components (Recommended)
```
Page Load → Server Component → Supabase Server → Database
              ↓
          Render HTML
```

## 🔐 Authentification

### Flow
1. User → Supabase Auth (Email/Password)
2. JWT Token stocké dans cookie
3. Middleware vérifie le token
4. RLS (Row Level Security) appliqué sur DB

### Rôles
- `customer` - Client standard
- `admin` - Administrateur
- `super_admin` - Super administrateur

## 📊 Base de Données

### Relations
```
cities ←→ routes (departure/arrival)
buses ←→ trips
routes ←→ trips
trips ←→ bookings
passengers ←→ bookings
bookings ←→ tickets
users ←→ passengers
```

### RLS Policies
- Customers: READ leurs propres bookings
- Admins: CRUD sur toutes les tables
- Public: READ cities, routes, trips disponibles

## 🎨 Composants Partagés

### Principles
- **Atomic Design**: Atoms → Molecules → Organisms
- **Reusability**: Composants génériques
- **TypeScript**: Tous typés strictement
- **Tailwind**: Classes utilitaires

### Exemple Structure
```tsx
// components/shared/Button.tsx
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger'
  size: 'sm' | 'md' | 'lg'
  onClick?: () => void
  children: React.ReactNode
}

export function Button({ variant, size, onClick, children }: ButtonProps) {
  // Implementation
}
```

## 🚀 Performance

### Optimisations
- ✅ Server Components par défaut
- ✅ Client Components uniquement si interactivité
- ✅ Image optimization (next/image)
- ✅ Dynamic imports pour gros composants
- ✅ Caching avec Supabase

## 📱 Responsive Design

### Breakpoints (Tailwind)
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### Stratégie
- Mobile-first CSS
- Composants adaptables
- Touch-friendly pour mobile

## 🧪 Testing (À venir)

### Structure
```
__tests__/
├── components/
├── pages/
└── utils/
```

### Tools (Recommandé)
- Jest
- React Testing Library
- Playwright (E2E)

## 📈 Monitoring (Production)

### Métriques
- Performance (Web Vitals)
- Erreurs (Error Boundary)
- Analytics (Google Analytics / Plausible)
- Logs (Vercel Logs / Supabase Logs)

---

**Note:** Cette architecture est évolutive et sera ajustée selon les besoins du projet.
