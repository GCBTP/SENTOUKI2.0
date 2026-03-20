import Link from 'next/link'

export default function HomePage() {
  return (
    <div>
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-blue-600 to-blue-800 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 md:py-32">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Voyagez à travers le Sénégal
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-blue-100">
              Réservez votre siège de bus en ligne, simplement et rapidement
            </p>
            <Link 
              href="/search"
              className="inline-block bg-white text-blue-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-gray-100 transition-colors shadow-lg"
            >
              Rechercher un trajet
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-12 text-gray-900">
            Pourquoi choisir SENTOUKI ?
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Feature 1 */}
            <div className="bg-white p-8 rounded-lg shadow-md hover:shadow-xl transition-shadow">
              <div className="text-4xl mb-4">🎫</div>
              <h3 className="text-xl font-semibold mb-3 text-gray-900">
                Réservation simple
              </h3>
              <p className="text-gray-600">
                Réservez votre billet en quelques clics. Payez en ligne et recevez votre ticket instantanément.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="bg-white p-8 rounded-lg shadow-md hover:shadow-xl transition-shadow">
              <div className="text-4xl mb-4">🚌</div>
              <h3 className="text-xl font-semibold mb-3 text-gray-900">
                Bus confortables
              </h3>
              <p className="text-gray-600">
                Voyagez dans des bus modernes et confortables avec des sièges spacieux et climatisés.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="bg-white p-8 rounded-lg shadow-md hover:shadow-xl transition-shadow">
              <div className="text-4xl mb-4">📱</div>
              <h3 className="text-xl font-semibold mb-3 text-gray-900">
                Ticket numérique
              </h3>
              <p className="text-gray-600">
                Recevez votre ticket avec QR code sur votre téléphone. Plus besoin d&apos;imprimer !
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Destinations populaires */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl md:text-4xl font-bold text-center mb-12 text-gray-900">
            Destinations populaires
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {['Dakar → Saint-Louis', 'Dakar → Touba', 'Dakar → Ziguinchor', 'Dakar → Tambacounda'].map((route) => (
              <div 
                key={route}
                className="bg-white border border-gray-200 rounded-lg p-6 hover:border-blue-500 hover:shadow-lg transition-all cursor-pointer"
              >
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  {route}
                </h3>
                <p className="text-blue-600 font-medium">
                  À partir de 5 000 FCFA
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-blue-600 text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            Prêt à voyager ?
          </h2>
          <p className="text-xl mb-8 text-blue-100">
            Trouvez votre prochain trajet et réservez dès maintenant
          </p>
          <Link 
            href="/search"
            className="inline-block bg-white text-blue-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-gray-100 transition-colors shadow-lg"
          >
            Commencer maintenant
          </Link>
        </div>
      </section>
    </div>
  )
}
