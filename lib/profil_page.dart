import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'login_page.dart';
import 'about_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  Future<List<int>> _chargerStats() async {
    final diagnostics = await FirebaseFirestore.instance
        .collection('diagnostics')
        .where('userId', isEqualTo: currentUser!.uid)
        .get();

    final conversations = await FirebaseFirestore.instance
        .collection('conversations')
        .get();

    final mesConversations = conversations.docs.where((doc) {
      return doc.id.contains(currentUser!.uid);
    }).length;

    int precision = 0;
    if (diagnostics.docs.isNotEmpty) {
      int total = 0;
      for (var doc in diagnostics.docs) {
        final data = doc.data();
        final confiance = data['confiance'] ?? '0%';
        final valeur =
            int.tryParse(confiance.toString().replaceAll('%', '')) ?? 0;
        total += valeur;
      }
      precision = total ~/ diagnostics.docs.length;
    }

    return [diagnostics.docs.length, mesConversations, precision];
  }

  Future<void> _changerPhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (photo == null) return;

    setState(() => _isLoading = true);

    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        photo.path,
        quality: 40,
      );

      if (compressed == null) return;

      final base64Image = base64Encode(compressed);

      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(currentUser!.uid)
          .update({'photoBase64': base64Image});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo mise à jour !')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _afficherFormulaireCompletionProfil(
    BuildContext context,
    String role,
    Map<String, dynamic>? data,
  ) {
    final zoneController = TextEditingController(text: data?['zone'] ?? '');
    final specialiteController = TextEditingController(
      text: data?['specialite'] ?? '',
    );
    final experienceController = TextEditingController(
      text: data?['experience'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compléter votre profil',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),

              // Zone (pour tous)
              TextField(
                controller: zoneController,
                decoration: InputDecoration(
                  labelText: 'Ville / Zone',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Champs agent uniquement
              if (role == 'agent') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: specialiteController,
                  decoration: InputDecoration(
                    labelText: 'Spécialité',
                    prefixIcon: const Icon(Icons.science),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: experienceController,
                  decoration: InputDecoration(
                    labelText: 'Années d\'expérience',
                    prefixIcon: const Icon(Icons.star),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final Map<String, dynamic> updates = {
                      'zone': zoneController.text.trim(),
                    };

                    if (role == 'agent') {
                      updates['specialite'] = specialiteController.text.trim();
                      updates['experience'] =
                          '${experienceController.text.trim()} ans';

                      // Mettre à jour aussi dans la collection agents
                      final agentDocs = await FirebaseFirestore.instance
                          .collection('agents')
                          .where('uid', isEqualTo: currentUser!.uid)
                          .get();

                      for (var doc in agentDocs.docs) {
                        await doc.reference.update({
                          'zone': zoneController.text.trim(),
                          'specialite': specialiteController.text.trim(),
                          'experience':
                              '${experienceController.text.trim()} ans',
                        });
                      }
                    }

                    await FirebaseFirestore.instance
                        .collection('utilisateurs')
                        .doc(currentUser!.uid)
                        .update(updates);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil mis à jour !')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Enregistrer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculerProgression(String role, Map<String, dynamic>? data) {
    if (data == null) return 0;
    int total = role == 'agent' ? 5 : 3;
    int remplis = 0;
    if ((data['nom'] ?? '').toString().isNotEmpty) remplis++;
    if ((data['email'] ?? '').toString().isNotEmpty) remplis++;
    if ((data['zone'] ?? '').toString().isNotEmpty) remplis++;
    if (role == 'agent') {
      if ((data['specialite'] ?? '').toString().isNotEmpty) remplis++;
      if ((data['experience'] ?? '').toString().isNotEmpty) remplis++;
    }
    if (data['photoBase64'] != null) remplis++;
    return remplis / (total + 1);
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('utilisateurs')
                .doc(currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final nom = data?['nom'] ?? 'Utilisateur';
              final email = data?['email'] ?? currentUser!.email ?? '';
              final role = data?['role'] ?? 'agriculteur';
              final photoBase64 = data?['photoBase64'];
              final zone = data?['zone'] ?? '';
              final specialite = data?['specialite'] ?? '';
              final experience = data?['experience'] ?? '';
              final progression = _calculerProgression(role, data);

              return FutureBuilder<List<int>>(
                future: _chargerStats(),
                builder: (context, statsSnapshot) {
                  final stats = statsSnapshot.data ?? [0, 0, 0];
                  final nbDiagnostics = stats[0];
                  final nbAgents = stats[1];
                  final precision = stats[2];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Mon Profil',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Card profil
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _changerPhoto,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.green.shade100,
                                      backgroundImage: photoBase64 != null
                                          ? MemoryImage(
                                              base64Decode(photoBase64),
                                            )
                                          : null,
                                      child: photoBase64 == null
                                          ? Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.green.shade700,
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade700,
                                          shape: BoxShape.circle,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                nom,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              Text(
                                role == 'agent'
                                    ? 'Agent agricole'
                                    : 'Agriculteur',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatItem(
                                    value: '$nbDiagnostics',
                                    label: 'Diagnostics',
                                  ),
                                  _StatItem(
                                    value: '$nbAgents',
                                    label: 'Agents contactés',
                                  ),
                                  _StatItem(
                                    value: precision > 0 ? '$precision%' : '-',
                                    label: 'Précision',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section compléter le profil
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: progression < 1.0
                                  ? Colors.orange.shade200
                                  : Colors.green.shade200,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    progression < 1.0
                                        ? '⚠️ Complétez votre profil'
                                        : '✅ Profil complet',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: progression < 1.0
                                          ? Colors.orange.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  Text(
                                    '${(progression * 100).toInt()}%',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: progression < 1.0
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progression,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progression < 1.0
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Champs manquants
                              if (zone.isEmpty)
                                _ChampManquant(
                                  label: 'Ville / Zone non renseignée',
                                ),
                              if (role == 'agent' && specialite.isEmpty)
                                _ChampManquant(
                                  label: 'Spécialité non renseignée',
                                ),
                              if (role == 'agent' && experience.isEmpty)
                                _ChampManquant(
                                  label: 'Expérience non renseignée',
                                ),
                              if (photoBase64 == null)
                                _ChampManquant(
                                  label: 'Photo de profil manquante',
                                ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: Text(
                                    'Modifier mon profil',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: progression < 1.0
                                        ? Colors.orange
                                        : Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _afficherFormulaireCompletionProfil(
                                        context,
                                        role,
                                        data,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Informations personnelles
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informations personnelles',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoTile(
                                icon: Icons.person,
                                label: 'Nom',
                                value: nom,
                              ),
                              _InfoTile(
                                icon: Icons.email,
                                label: 'Email',
                                value: email,
                              ),
                              _InfoTile(
                                icon: Icons.location_on,
                                label: 'Zone',
                                value: zone.isNotEmpty
                                    ? zone
                                    : 'Non renseignée',
                              ),
                              _InfoTile(
                                icon: Icons.work,
                                label: 'Rôle',
                                value: role == 'agent'
                                    ? 'Agent agricole'
                                    : 'Agriculteur',
                              ),
                              if (role == 'agent') ...[
                                _InfoTile(
                                  icon: Icons.science,
                                  label: 'Spécialité',
                                  value: specialite.isNotEmpty
                                      ? specialite
                                      : 'Non renseignée',
                                ),
                                _InfoTile(
                                  icon: Icons.star,
                                  label: 'Expérience',
                                  value: experience.isNotEmpty
                                      ? experience
                                      : 'Non renseignée',
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Paramètres
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paramètres',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _SettingsTile(
                                icon: Icons.notifications,
                                label: 'Notifications',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Notifications bientôt disponibles !',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _SettingsTile(
                                icon: Icons.language,
                                label: 'Langue',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Changement de langue bientôt disponible !',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _SettingsTile(
                                icon: Icons.info_outline,
                                label: 'À propos',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AboutPage(),
                                    ),
                                  );
                                },
                              ),
                              _SettingsTile(
                                icon: Icons.logout,
                                label: 'Déconnexion',
                                isRed: true,
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChampManquant extends StatelessWidget {
  final String label;
  const _ChampManquant({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.orange.shade400),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade600, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRed;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.isRed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isRed ? Colors.red : Colors.green.shade600),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: isRed ? Colors.red : Colors.black87,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
