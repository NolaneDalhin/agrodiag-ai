import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profil_agent_page.dart';
import 'profil_agriculteur_page.dart';

class MessagingPage extends StatefulWidget {
  final String agentNom;
  final String agentSpecialite;
  final String agentUid;

  const MessagingPage({
    super.key,
    required this.agentNom,
    required this.agentSpecialite,
    required this.agentUid,
  });

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;
  late String _conversationId;
  Map<String, dynamic>? _agentData;

  @override
  void initState() {
    super.initState();
    final ids = [currentUser!.uid, widget.agentUid]..sort();
    _conversationId = ids.join('_');
    _chargerDonneesAgent();
  }

  Future<void> _chargerDonneesAgent() async {
    final doc = await FirebaseFirestore.instance
        .collection('agents')
        .where('uid', isEqualTo: widget.agentUid)
        .limit(1)
        .get();
    if (doc.docs.isNotEmpty) {
      setState(() {
        _agentData = doc.docs.first.data();
      });
    }
  }

  void _ouvrirProfil() {
    FirebaseFirestore.instance
        .collection('utilisateurs')
        .doc(currentUser!.uid)
        .get()
        .then((doc) {
          final role = doc.data()?['role'] ?? 'agriculteur';
          if (role == 'agent') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilAgriculteurPage(
                  agriculteurUid: widget.agentUid,
                  agentUid: currentUser!.uid,
                ),
              ),
            );
          } else {
            if (_agentData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilAgentPage(
                    agentData: _agentData!,
                    currentUserUid: currentUser!.uid,
                  ),
                ),
              );
            }
          }
        });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text.trim();
    _controller.clear();

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .set({
          'participants': [currentUser!.uid, widget.agentUid],
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .add({
          'text': message,
          'senderId': currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GestureDetector(
          onTap: _ouvrirProfil,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  widget.agentNom.isNotEmpty
                      ? widget.agentNom[0].toUpperCase()
                      : 'A',
                  style: GoogleFonts.poppins(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.agentNom,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.agentSpecialite.isNotEmpty)
                    Text(
                      widget.agentSpecialite,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50), Color(0xFFE8F5E9)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(_conversationId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Commencez la conversation !',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data =
                          messages[index].data() as Map<String, dynamic>;
                      final bool isMe = data['senderId'] == currentUser!.uid;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final time = timestamp != null
                          ? '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                          : '';

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green.shade800 : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data['text'] ?? '',
                                style: GoogleFonts.poppins(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: GoogleFonts.poppins(
                                  color: isMe ? Colors.white60 : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, bottomPadding + 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
