import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userName; // Nama pengirim (misal diambil dari login)
  const ChatScreen({super.key, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi Kirim Pesan
  Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    try {
      await _firestore.collection('chats').add({
        'text': _msgController.text.trim(),
        'sender': widget.userName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _msgController.clear();
    } catch (e) {
      // --- TAMBAHKAN BARIS INI ---
      if (!mounted) return;
      // ---------------------------

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diskusi Katering (Live)")),
      body: Column(
        children: [
          // Bagian List Pesan (Realtime Stream)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Error memuat chat"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(child: Text("Belum ada pesan."));

                return ListView.builder(
                  reverse: true, // Pesan baru di bawah
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['sender'] == widget.userName;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['sender'] ?? 'Anonim',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isMe ? Colors.blue[800] : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(data['text'] ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bagian Input Pesan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
