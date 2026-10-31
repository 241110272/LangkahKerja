import 'package:flutter/material.dart';
import '../main.dart';
import '../services/job_store.dart';
import '../services/cloud.dart';
import '../widgets/brand.dart';
import 'privacy.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.store, this.cloud});
  final JobStore store;
  final CloudController? cloud;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Brand(),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: lime,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SDG 8 · Karir Inklusif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: plum,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Langkahmu,\npilihanmu.',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.08,
                  letterSpacing: -1.8,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selamat datang di LangkahKerja. Tentukan peran yang ingin Anda gunakan hari ini untuk memulai:',
                style: TextStyle(fontSize: 13, color: muted, height: 1.6),
              ),
              const SizedBox(height: 26),

              // CARD 1: Cari Kerja (Employee)
              _RoleCard(
                badgeLabel: 'Pencari Kerja · Menu Utama',
                badgeColor: lavender,
                badgeTextColor: plum,
                icon: Icons.person_search_rounded,
                title: 'Cari Kerja (Employee)',
                subtitle:
                    'Jelajahi lowongan, buat CV & surat lamaran, serta kelola progres lamaran kerja Anda.',
                highlights: const [
                  'Eksplorasi ribuan lowongan kerja se-Indonesia',
                  'Pembuat CV profesional & surat lamaran kerja',
                  'Pencatatan riwayat lamaran & jadwal interview',
                ],
                buttonLabel: 'Mulai Cari Kerja',
                buttonColor: plum,
                buttonTextColor: Colors.white,
                onTap: () => store.setActiveRole('employee'),
              ),

              const SizedBox(height: 18),

              // CARD 2: Post Kerja (Employer)
              _RoleCard(
                badgeLabel: 'Pemberi Kerja · Pasang Lowongan',
                badgeColor: lime,
                badgeTextColor: plum,
                icon: Icons.business_center_rounded,
                title: 'Post Kerja (Employer)',
                subtitle:
                    'Publikasikan lowongan kerja untuk bisnis atau perusahaan Anda dan kelola kandidat pelamar.',
                highlights: const [
                  'Pasang lowongan kerja langsung ke aplikasi',
                  'Atur kualifikasi, deskripsi & rentang gaji',
                  'Kelola kandidat pelamar dalam alur rekrutmen',
                ],
                buttonLabel: 'Mulai Pasang Lowongan',
                buttonColor: plum,
                buttonTextColor: Colors.white,
                onTap: () => store.setActiveRole('employer'),
              ),

              const SizedBox(height: 24),

              // Note about switching
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: lavender.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: line),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, color: plum, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Anda dapat beralih antara menu Cari Kerja dan Post Kerja kapan saja melalui menu drawer samping.',
                        style: TextStyle(fontSize: 11, color: ink, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Privacy & terms
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyPage(),
                    ),
                  ),
                  child: const Text(
                    'Baca kebijakan privasi & data',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlights,
    required this.buttonLabel,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.onTap,
  });

  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> highlights;
  final String buttonLabel;
  final Color buttonColor;
  final Color buttonTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: plum.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: plum, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: badgeTextColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: muted, height: 1.5),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          for (final item in highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4, right: 8),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: plum,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ink,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
