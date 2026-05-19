import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'À propos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50), Color(0xFFE8F5E9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 30),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: screenHeight * 0.12,
                  width: screenHeight * 0.12,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              Text(
                'AgroDiag AI',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),

              SizedBox(height: screenHeight * 0.03),

              _InfoCard(
                titre: '🌱 Notre mission',
                contenu:
                    'AgroDiag AI est une application intelligente conçue pour aider les agriculteurs à détecter rapidement les maladies de leurs plantes grâce à l\'intelligence artificielle. Notre objectif est de réduire les pertes agricoles et d\'améliorer les rendements en Afrique de l\'Ouest.',
              ),

              SizedBox(height: screenHeight * 0.02),

              _InfoCard(
                titre: '🤖 Comment ça marche ?',
                contenu:
                    'L\'utilisateur prend une photo de sa plante suspecte. Notre modèle d\'intelligence artificielle analyse l\'image et détecte la maladie probable avec un taux de précision élevé. Des recommandations de traitement adaptées sont ensuite proposées.',
              ),

              SizedBox(height: screenHeight * 0.02),

              _InfoCard(
                titre: '👨‍🌾 Agents agricoles',
                contenu:
                    'Pour les cas complexes, AgroDiag AI permet de contacter directement des agents agricoles qualifiés. Ces spécialistes peuvent intervenir pour traiter le problème et accompagner l\'agriculteur dans la gestion de ses cultures.',
              ),

              SizedBox(height: screenHeight * 0.02),

              _InfoCard(
                titre: '🔧 Technologies utilisées',
                contenu:
                    'Flutter • Firebase • Intelligence Artificielle • Groq API • Python FastAPI • Cloud Firestore',
              ),

              SizedBox(height: screenHeight * 0.02),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenHeight * 0.025),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '👨‍💻 Développeur',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Dalhin',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'TOLENOU',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Étudiant en TIC3',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Text(
                      'Projet de soutenance 2025-2026',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String titre;
  final String contenu;

  const _InfoCard({required this.titre, required this.contenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            contenu,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
