import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseMonitorScreen extends StatelessWidget {
  const FirebaseMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("orders");

    return Scaffold(
      appBar: AppBar(title: const Text("Realtime Orders")),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return const Center(child: Text("Data pesanan realtime aktif"));
        },
      ),
    );
  }
}
