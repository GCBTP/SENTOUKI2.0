import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import ToastProvider from '@/lib/providers/ToastProvider'
import ErrorBoundary from '@/components/ui/ErrorBoundary'

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  preload: true,
})

export const metadata: Metadata = {
  title: 'SENTOUKI - Réservation de Bus au Sénégal',
  description: 'Réservez vos billets de bus inter-région au Sénégal en ligne. Simple, rapide et sécurisé.',
  keywords: ['bus', 'Sénégal', 'réservation', 'transport', 'voyage', 'Dakar', 'Saint-Louis'],
  authors: [{ name: 'SENTOUKI' }],
  openGraph: {
    title: 'SENTOUKI - Réservation de Bus au Sénégal',
    description: 'Réservez vos billets de bus inter-région au Sénégal en ligne',
    type: 'website',
    locale: 'fr_FR',
  },
  robots: {
    index: true,
    follow: true,
  },
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 5,
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>
        <ErrorBoundary>
          {children}
          <ToastProvider />
        </ErrorBoundary>
      </body>
    </html>
  )
}
