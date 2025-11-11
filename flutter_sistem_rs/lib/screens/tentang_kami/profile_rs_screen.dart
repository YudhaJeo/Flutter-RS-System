import 'package:flutter/material.dart';
import '../../models/profileTentang_model.dart';
import '../../services/profile_rs_service.dart';

class ProfileRsScreen extends StatefulWidget {
  const ProfileRsScreen({super.key});

  @override
  State<ProfileRsScreen> createState() => _ProfileRsScreenState();
}

class _ProfileRsScreenState extends State<ProfileRsScreen> {
  ProfileRs? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileRs();
  }

  Future<void> _fetchProfileRs() async {
    setState(() => _loading = true);
    final data = await ProfileRsService.fetchProfileRs();
    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Tentang Rumah Sakit',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : _profile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Data profil belum tersedia',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchProfileRs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section with Gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blue[700]!, Colors.blue[500]!],
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // Logo dengan Shadow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _profile!.fotoLogo.isNotEmpty
                                ? ClipOval(
                                    child: Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(16),
                                      child: Image.network(
                                        _profile!.fotoLogo,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.contain,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              print('Error load logo: $error');
                                              return const Icon(
                                                Icons.local_hospital,
                                                size: 80,
                                                color: Colors.blueAccent,
                                              );
                                            },
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital,
                                      size: 80,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          // Nama RS
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _profile!.namaRs,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Alamat
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _profile!.alamat,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Contact Cards
                          _buildContactCard(
                            Icons.support_agent,
                            "Customer Service",
                            _profile!.nomorHotline,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            Icons.email_outlined,
                            "Email",
                            _profile!.email,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            Icons.local_phone,
                            "Ambulan",
                            _profile!.notelpAmbulan,
                            Colors.red,
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            Icons.chat,
                            "WhatsApp Ambulan",
                            _profile!.noAmbulanWa,
                            Colors.green,
                          ),

                          const SizedBox(height: 24),

                          // Deskripsi
                          _buildInfoSection(
                            "Deskripsi",
                            _profile!.deskripsi,
                            Icons.info_outline,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),

                          // Visi
                          _buildInfoSection(
                            "Visi",
                            _profile!.visi,
                            Icons.visibility_outlined,
                            Colors.purple,
                          ),
                          const SizedBox(height: 16),

                          // Misi
                          _buildInfoSection(
                            "Misi",
                            _profile!.misi,
                            Icons.flag_outlined,
                            Colors.teal,
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : '-',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
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

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content.isNotEmpty ? content : '-',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
