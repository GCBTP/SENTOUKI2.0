# 🔧 CORRECTIONS RAPIDES - À appliquer maintenant

## 1. Nettoyer dossiers obsolètes

```bash
cd ~/Desktop/sentouki

# Supprimer dossiers qui causent erreurs build
rm -rf app/admin
rm -rf app/payment  
rm -rf app/client
rm -rf app/my-bookings

# Supprimer duplication lib/utils
rm -rf lib/utils

# Vérifier qu'il ne reste que lib/utils.ts
ls -la lib/utils.ts
```

## 2. Sécuriser .env.local

```bash
# 1. Vérifier que .env.local est ignoré
grep "\.env" .gitignore

# 2. S'assurer qu'il n'est PAS commité
git rm --cached .env.local 2>/dev/null || echo "Déjà ignoré"
git status

# 3. Régénérer les clés Supabase
# → Aller sur https://vgosyoaxwldxuopjslll.supabase.co
# → Settings → API → Reset anon key
```

## 3. Créer lib/types/api.ts (types réponses API)

**Fichier:** `lib/types/api.ts`

```typescript
// Types pour réponses API standardisées

export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  error?: string
  message?: string
}

export interface ApiError {
  statusCode: number
  message: string
  code?: string
  details?: unknown
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  hasMore: boolean
}

// Types spécifiques
export interface BookingResponse {
  success: boolean
  booking: {
    id: string
    reference: string
    seat_number: number
    passenger_name: string
    passenger_phone: string
    status: string
    created_at: string
  }
  message: string
}

export interface SearchResponse {
  success: boolean
  trips: Array<{
    id: string
    departure_city: string
    arrival_city: string
    departure_date: string
    departure_time: string
    arrival_time: string
    price: number
    available_seats: number
    bus: {
      name: string
      total_seats: number
    }
  }>
}
```

## 4. Créer lib/api/client.ts (fetch centralisé)

**Fichier:** `lib/api/client.ts`

```typescript
import { APIError } from './error-handler'

interface FetchOptions extends RequestInit {
  timeout?: number
}

export async function apiClient<T>(
  url: string,
  options: FetchOptions = {}
): Promise<T> {
  const { timeout = 10000, ...fetchOptions } = options

  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), timeout)

  try {
    const response = await fetch(url, {
      ...fetchOptions,
      headers: {
        'Content-Type': 'application/json',
        ...fetchOptions.headers,
      },
      signal: controller.signal,
    })

    clearTimeout(timeoutId)

    const data = await response.json()

    if (!response.ok) {
      throw new APIError(
        response.status,
        data.error || 'Request failed',
        data.code
      )
    }

    return data
  } catch (error) {
    clearTimeout(timeoutId)

    if (error instanceof APIError) {
      throw error
    }

    if (error instanceof Error) {
      if (error.name === 'AbortError') {
        throw new APIError(408, 'Request timeout', 'TIMEOUT')
      }
      throw new APIError(500, error.message, 'NETWORK_ERROR')
    }

    throw new APIError(500, 'Unknown error', 'UNKNOWN')
  }
}

// Helpers typés
export const api = {
  get: <T>(url: string, options?: FetchOptions) =>
    apiClient<T>(url, { ...options, method: 'GET' }),

  post: <T>(url: string, body?: unknown, options?: FetchOptions) =>
    apiClient<T>(url, {
      ...options,
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    }),

  put: <T>(url: string, body?: unknown, options?: FetchOptions) =>
    apiClient<T>(url, {
      ...options,
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    }),

  delete: <T>(url: string, options?: FetchOptions) =>
    apiClient<T>(url, { ...options, method: 'DELETE' }),
}
```

## 5. Corriger types any dans catch blocks

**Avant:**
```typescript
} catch (error: any) {
  toast.error(error.message)
}
```

**Après:**
```typescript
} catch (error) {
  const message = error instanceof Error ? error.message : 'Une erreur est survenue'
  toast.error(message)
}
```

**Commande pour trouver tous les catch any:**
```bash
grep -rn "catch (error: any)" app/ components/ lib/
```

## 6. Ajouter revalidate aux API routes

**app/api/cities/route.ts:**
```typescript
export const revalidate = 3600 // Cache 1 heure

export async function GET() {
  // ...
}
```

**app/api/search/route.ts:**
```typescript
export const revalidate = 300 // Cache 5 minutes

export async function POST(request: NextRequest) {
  // ...
}
```

## 7. Optimiser imports lucide-react

**Avant:**
```typescript
import { Bus, Calendar, Clock, MapPin, User, Phone, ... } from 'lucide-react'
```

**Après:** (rien à changer, déjà optimisé si imports nommés)

Vérifier qu'on n'a PAS:
```typescript
import * as Icons from 'lucide-react' // ❌ MAUVAIS
```

**Commande:**
```bash
grep -rn "import \* as.*lucide" app/ components/
```

## 8. Ajouter .gitattributes

**Fichier:** `.gitattributes`

```gitattributes
# Auto detect text files and perform LF normalization
* text=auto

# TypeScript
*.ts text eol=lf
*.tsx text eol=lf

# JSON
*.json text eol=lf

# CSS
*.css text eol=lf

# Markdown
*.md text eol=lf

# Exclude from exports
.env* export-ignore
node_modules/ export-ignore
.next/ export-ignore
```

## 9. Ajouter sitemap.ts

**Fichier:** `app/sitemap.ts`

```typescript
import { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://sentouki.sn'

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    {
      url: `${baseUrl}/search`,
      lastModified: new Date(),
      changeFrequency: 'always',
      priority: 0.9,
    },
  ]
}
```

## 10. Optimiser middleware

**Fichier:** `middleware.ts`

```typescript
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname

  // Protection routes admin (temporairement désactivé - pas d'admin pour l'instant)
  if (path.startsWith('/admin')) {
    // Rediriger vers home car admin supprimé
    return NextResponse.redirect(new URL('/', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

---

## ✅ CHECKLIST D'EXÉCUTION

Exécuter dans l'ordre:

```bash
cd ~/Desktop/sentouki

# 1. Nettoyer dossiers
rm -rf app/admin app/payment app/client app/my-bookings lib/utils

# 2. Créer nouveaux fichiers
# → Créer lib/types/api.ts (copier contenu ci-dessus)
# → Créer lib/api/client.ts (copier contenu ci-dessus)
# → Créer app/sitemap.ts (copier contenu ci-dessus)
# → Créer .gitattributes (copier contenu ci-dessus)

# 3. Modifier fichiers existants
# → Modifier middleware.ts (copier contenu ci-dessus)

# 4. Tester build
npm run build

# 5. Commiter
git add .
git commit -m "fix: audit corrections - clean structure, add types, optimize middleware"
```

---

## 🎯 RÉSULTAT ATTENDU

Après ces corrections:
- ✅ Structure propre (pas de dossiers obsolètes)
- ✅ Types API centralisés
- ✅ Fetch client réutilisable
- ✅ Middleware optimisé
- ✅ Sitemap.xml généré
- ✅ .gitattributes configuré
- ✅ Build toujours fonctionnel

**Temps estimé:** 15 minutes  
**Risque:** ⚠️ Faible (modifications non-breaking)
