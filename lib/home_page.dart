import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diagnostic_page.dart';

class PremiumHomePage extends StatefulWidget {
  const PremiumHomePage({super.key});

  @override
  State<PremiumHomePage> createState() => _PremiumHomePageState();
}

class _PremiumHomePageState extends State<PremiumHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _reveillerBackend();
  }

  Future<void> _reveillerBackend() async {
    try {
      await http.get(Uri.parse('https://agrodiag-backend.onrender.com/'));
    } catch (e) {
      // Silencieux, juste un ping
    }
  }

  String _getConseilDuJour() {
    final conseils = [
      'Surveillez régulièrement les feuilles jaunissantes pour prévenir rapidement les infections.',
      'Arrosez vos plantes tôt le matin pour réduire l\'évaporation et les risques de maladies fongiques.',
      'Évitez de mouiller le feuillage lors de l\'arrosage pour limiter la propagation des champignons.',
      'Inspectez le dessous des feuilles chaque semaine — c\'est là que les insectes se cachent.',
      'Utilisez un compost naturel pour renforcer les défenses immunitaires de vos plantes.',
      'Pratiquez la rotation des cultures pour éviter l\'épuisement des sols et les maladies récurrentes.',
      'Un sol bien drainé prévient les pourritures racinaires — vérifiez votre drainage régulièrement.',
      'Les plantes stressées sont plus vulnérables — maintenez un arrosage régulier et adapté.',
      'Taillez les parties malades immédiatement pour éviter la propagation aux parties saines.',
      'Introduisez des insectes bénéfiques comme les coccinelles pour lutter contre les pucerons.',
      'Évitez l\'excès d\'engrais azotés — ils favorisent la croissance rapide mais fragilisent les plantes.',
      'Gardez vos outils de jardinage propres et désinfectés pour éviter de propager les maladies.',
      'Un paillage autour des plantes conserve l\'humidité et limite la propagation des maladies du sol.',
      'Observez la couleur de vos feuilles — le jaunissement peut indiquer une carence en nutriments.',
      'Plantez des variétés résistantes aux maladies locales pour réduire les traitements chimiques.',
      'L\'espacement correct entre les plants favorise la circulation d\'air et réduit les maladies fongiques.',
      'Récupérez l\'eau de pluie pour arroser — elle est meilleure que l\'eau du robinet pour les plantes.',
      'Vérifiez le pH de votre sol — un pH inadapté peut causer des carences et des maladies.',
      'Les plantes en bonne santé résistent mieux — nourrissez bien votre sol avec des matières organiques.',
      'Photographiez vos plantes régulièrement pour détecter les changements subtils avant qu\'ils s\'aggravent.',
      'Évitez de travailler dans votre jardin quand les feuilles sont mouillées pour ne pas propager les maladies.',
      'Un diagnostic précoce avec AgroDiag AI peut sauver toute votre récolte !',
      'La prévention vaut mieux que le traitement — inspectez vos cultures deux fois par semaine.',
      'Les mauvaises herbes peuvent héberger des parasites — désherber régulièrement protège vos cultures.',
      'Traitez vos graines avant la plantation pour éliminer les pathogènes présents en surface.',
      'Les périodes de chaleur excessive favorisent certaines maladies — augmentez la surveillance en été.',
      'Un bon drainage est la première défense contre les maladies racinaires.',
      'Associez des plantes compagnes pour repousser naturellement certains insectes nuisibles.',
      'Notez vos observations dans un carnet pour identifier les patterns de maladies.',
      'Consultez un agent agricole dès que vous observez des symptômes inhabituels sur vos cultures.',
      'Les fongicides naturels comme le bicarbonate de soude peuvent traiter certaines maladies fongiques.',
    ];

    final index = DateTime.now().day % conseils.length;
    return conseils[index];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50), Color(0xFFE8F5E9)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header avec bonjour
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('utilisateurs')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        final nom = data?['nom'] ?? '';
                        final prenom = nom.isNotEmpty
                            ? nom.split(' ').last
                            : '';
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prenom.isNotEmpty
                                      ? 'Bonjour $prenom ! 👋'
                                      : 'AgroDiag AI',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Agriculture intelligente',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.agriculture,
                                size: 30,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Image.asset('assets/images/plante.png', height: 170),
                          const SizedBox(height: 20),
                          Text(
                            'Détection intelligente des maladies végétales',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt, size: 28),
                        label: Text(
                          'Lancer un diagnostic',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 10,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DiagnosticPage()),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: PremiumStatCard(
                            title: 'Diagnostics',
                            value: '128+',
                            icon: Icons.analytics,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: PremiumStatCard(
                            title: 'Précision',
                            value: '95%',
                            icon: Icons.verified,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fonctionnalités Premium',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const FeatureTile(
                            icon: Icons.camera,
                            text: 'Analyse instantanée par photo',
                          ),
                          const FeatureTile(
                            icon: Icons.psychology,
                            text: 'Diagnostic assisté par IA',
                          ),
                          const FeatureTile(
                            icon: Icons.healing,
                            text: 'Conseils de traitement agricoles',
                          ),
                          const FeatureTile(
                            icon: Icons.history,
                            text: 'Historique complet des analyses',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🌿 Conseil du jour',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _getConseilDuJour(),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 32),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 15))),
        ],
      ),
    );
  }
}
