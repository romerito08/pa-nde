// lib/features/partner/partner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  String? _companyName;

  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  }

  Future<void> _loadPartnerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _companyName = doc.data()?['companyName'] ?? 'Aliado';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Aliado'),
        backgroundColor: const Color(0xff1A1F16),
        foregroundColor: const Color(0xffE2E600),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xff1A1F16),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Bienvenido, ${_companyName ?? user?.email ?? 'Aliado'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildMenuCard(
              context,
              icon: Icons.hotel,
              title: 'Mis Hoteles',
              description: 'Ver, editar o eliminar tus publicaciones',
              onTap: () => Navigator.pushNamed(context, '/partner-hotels'),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.add_business,
              title: 'Publicar Nuevo Hotel',
              description: 'Registra un nuevo alojamiento o servicio',
              onTap: () => Navigator.pushNamed(context, '/create-hotel'),
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.person,
              title: 'Mi Perfil',
              description: 'Editar información de tu cuenta',
              onTap: () => Navigator.pushNamed(context, '/partner-profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon, required String title, required String description, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xff1C241B),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xffE2E600)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: Color(0xffA1A89B))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xffE2E600), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}