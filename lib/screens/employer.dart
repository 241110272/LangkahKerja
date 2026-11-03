import 'package:flutter/material.dart';
import '../main.dart';
import '../models/job.dart';
import '../services/job_store.dart';
import '../services/cloud.dart';
import '../widgets/brand.dart';
import '../widgets/role_switcher.dart';
import '../widgets/job_card.dart';
import 'detail.dart';
import 'privacy.dart';

class EmployerShell extends StatefulWidget {
  const EmployerShell({super.key, required this.store, this.cloud});
  final JobStore store;
  final CloudController? cloud;

  @override
  State<EmployerShell> createState() => _EmployerShellState();
}

class _EmployerShellState extends State<EmployerShell>
    with SingleTickerProviderStateMixin {
  int tab = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final menuAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  // Filter for applicants tab
  String selectedJobFilter = 'all';
  String selectedStatusFilter = 'all';

  // Form controllers for posting job
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final locationController = TextEditingController();
  final salaryController = TextEditingController();
  final tagsController = TextEditingController();
  final descriptionController = TextEditingController();
  final requirementsController = TextEditingController();
  final applicationContactController = TextEditingController();
  String selectedJobType = 'Penuh Waktu';
  String selectedWorkplace = 'Di Kantor (On-site)';
  String selectedCategory = 'Teknologi & IT';

  // Company profile controllers
  final profileNameController = TextEditingController();
  final profileIndustryController = TextEditingController();
  final profileCityController = TextEditingController();
  final profileWebsiteController = TextEditingController();
  final profileEmailController = TextEditingController();
  final profileAboutController = TextEditingController();

  JobStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _initProfileControllers();
  }

  void _initProfileControllers() {
    profileNameController.text = store.companyProfile['name'] ?? '';
    profileIndustryController.text = store.companyProfile['industry'] ?? '';
    profileCityController.text = store.companyProfile['city'] ?? '';
    profileWebsiteController.text = store.companyProfile['website'] ?? '';
    profileEmailController.text = store.companyProfile['email'] ?? '';
    profileAboutController.text = store.companyProfile['about'] ?? '';

    if (companyController.text.isEmpty &&
        profileNameController.text.isNotEmpty) {
      companyController.text = profileNameController.text;
    }
  }

  @override
  void dispose() {
    menuAnimation.dispose();
    titleController.dispose();
    companyController.dispose();
    locationController.dispose();
    salaryController.dispose();
    tagsController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    applicationContactController.dispose();
    profileNameController.dispose();
    profileIndustryController.dispose();
    profileCityController.dispose();
    profileWebsiteController.dispose();
    profileEmailController.dispose();
    profileAboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        key: scaffoldKey,
        backgroundColor: canvas,
        onDrawerChanged: (opened) {
          if (opened) {
            menuAnimation.forward();
          } else {
            menuAnimation.reverse();
          }
        },
        drawer: _employerDrawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Buka menu employer',
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                      style: IconButton.styleFrom(
                        backgroundColor: lavender.withValues(alpha: 0.8),
                        fixedSize: const Size(40, 40),
                      ),
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: menuAnimation,
                        color: plum,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Brand(),
                    const SizedBox(width: 8),
                    const Spacer(),
                    RoleSwitcher(store: store),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: switch (tab) {
                  0 => _myJobsTab(),
                  1 => _postJobTab(),
                  2 => _applicantsTab(),
                  _ => _companyProfileTab(),
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: _employerBottomBar(),
      ),
    );
  }

  // BOTTOM BAR
  Widget _employerBottomBar() {
    const labels = ['Lowongan', 'Pasang', 'Pelamar', 'Profil'];
    const icons = [
      Icons.work_outline_rounded,
      Icons.add_circle_outline_rounded,
      Icons.people_outline_rounded,
      Icons.business_outlined,
    ];
    const selectedIcons = [
      Icons.work_rounded,
      Icons.add_circle_rounded,
      Icons.people_rounded,
      Icons.business_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFD).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: plum.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Row(
            children: List.generate(
              labels.length,
              (i) => Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => tab = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 64,
                          height: 32,
                          decoration: BoxDecoration(
                            color: tab == i ? lavender : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            tab == i ? selectedIcons[i] : icons[i],
                            size: 23,
                            color: tab == i ? plum : muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: tab == i ? plum : muted,
                            fontWeight: tab == i
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // DRAWER
  Widget _employerDrawer() {
    return Drawer(
      backgroundColor: canvas,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 14, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [plum, Color(0xFF493451)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Portal Employer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup menu',
                        onPressed: () =>
                            scaffoldKey.currentState?.closeDrawer(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    store.companyProfile['name']?.isNotEmpty == true
                        ? store.companyProfile['name']!
                        : 'Kelola lowongan & rekrut talenta terbaik',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                children: [
                  _drawerSectionTitle('MENU UTAMA EMPLOYER'),
                  _drawerItem(
                    icon: Icons.work_outline_rounded,
                    title: 'Lowongan Saya',
                    subtitle: '${store.employerJobs.length} lowongan terpasang',
                    onTap: () => setState(() => tab = 0),
                  ),
                  _drawerItem(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Pasang Lowongan Baru',
                    subtitle: 'Buat & publikasikan lowongan baru',
                    onTap: () => setState(() => tab = 1),
                  ),
                  _drawerItem(
                    icon: Icons.people_outline_rounded,
                    title: 'Kelola Pelamar',
                    subtitle:
                        '${store.employerApplicants.length} kandidat tercatat',
                    onTap: () => setState(() => tab = 2),
                  ),
                  _drawerItem(
                    icon: Icons.business_outlined,
                    title: 'Profil Perusahaan',
                    subtitle: 'Informasi dan identitas bisnis',
                    onTap: () => setState(() => tab = 3),
                  ),
                  const SizedBox(height: 16),
                  _drawerSectionTitle('GANTI PERAN & MODE'),
                  _drawerItem(
                    icon: Icons.person_search_rounded,
                    title: 'Beralih ke Cari Kerja (Employee)',
                    subtitle: 'Kembali ke menu pencarian kerja',
                    onTap: () => store.setActiveRole('employee'),
                  ),
                  _drawerItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Menu Pilih Peran',
                    subtitle: 'Tampilkan pilihan peran awal',
                    onTap: () => store.setActiveRole(null),
                  ),
                  const SizedBox(height: 16),
                  _drawerSectionTitle('LAINNYA'),
                  _drawerItem(
                    icon: Icons.shield_outlined,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Ketentuan dan keamanan data',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyPage(),
                      ),
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

  Widget _drawerSectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
    child: Text(
      title,
      style: const TextStyle(
        color: muted,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: lavender.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: plum, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 10, color: muted),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: muted),
      onTap: () {
        scaffoldKey.currentState?.closeDrawer();
        onTap();
      },
    ),
  );

  // TAB 0: LOWONGAN SAYA (DASHBOARD)
  Widget _myJobsTab() {
    final jobs = store.employerJobs.values.toList();
    final applicantsCount = store.employerApplicants.length;
    final remoteCount = jobs.where((j) => j.remote).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Kelola & Pantau\nLowongan Kerja.',
          style: TextStyle(
            fontSize: 32,
            height: 1.05,
            letterSpacing: -1.5,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Semua lowongan yang Anda terbitkan langsung aktif dan dapat dicari di menu Cari Kerja (Employee).',
          style: TextStyle(color: muted, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 18),

        // Statistics Cards
        Row(
          children: [
            _statBox('${jobs.length}', 'Lowongan Aktif', Icons.work_rounded),
            const SizedBox(width: 8),
            _statBox(
              '$applicantsCount',
              'Pelamar Masuk',
              Icons.people_alt_rounded,
              onTap: () => setState(() => tab = 2),
            ),
            const SizedBox(width: 8),
            _statBox(
              '$remoteCount',
              'Pekerjaan Remote',
              Icons.home_work_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Primary Call To Action Button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: plum,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => setState(() => tab = 1),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Pasang Lowongan Baru',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lowongan Anda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            if (jobs.isNotEmpty)
              Text(
                '${jobs.length} lowongan',
                style: const TextStyle(fontSize: 12, color: muted),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (jobs.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: line),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: lavender,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.post_add_rounded,
                    color: plum,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Lowongan yang Dipasang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Publikasikan lowongan pekerjaan pertama Anda untuk menjangkau para pencari kerja di seluruh Indonesia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: muted, height: 1.5),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () => setState(() => tab = 1),
                      child: const Text('Pasang Sekarang'),
                    ),
                    TextButton(
                      onPressed: store.useDemo,
                      child: const Text('Muat Data Demo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          for (final job in jobs) _employerJobCard(job),
        ],
      ],
    );
  }

  Widget _statBox(
    String count,
    String label,
    IconData icon, {
    VoidCallback? onTap,
  }) => Expanded(
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: plum, size: 20),
              const SizedBox(height: 6),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _employerJobCard(Job job) {
    final candidateCount = store.employerApplicants
        .where((a) => a['jobId'] == job.id)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyMark(job.company, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company,
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: lime,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: plum,
                  ),
                ),
              ),
            ],
          ),
          if (job.salary != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: lavender.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Gaji: ${job.salary}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: plum,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final type in job.jobTypes) _smallTag(type, isPlum: true),
              for (final tag in job.tags.take(3)) _smallTag(tag),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedJobFilter = job.id;
                    tab = 2; // Jump to applicants tab
                  });
                },
                icon: const Icon(Icons.people_alt_outlined, size: 16),
                label: Text(
                  'Pelamar ($candidateCount)',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => JobDetail(job: job, store: store),
                  ),
                ),
                child: const Text('Pratinjau', style: TextStyle(fontSize: 11)),
              ),
              IconButton(
                tooltip: 'Hapus lowongan',
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Lowongan?'),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus lowongan "${job.title}"? Lowongan ini tidak akan lagi tampil di menu Cari Kerja.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await store.deleteEmployerJob(job.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String label, {bool isPlum = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isPlum ? lavender : line.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: isPlum ? plum : muted,
      ),
    ),
  );

  // TAB 1: FORM PASANG LOWONGAN (POST JOB)
  Widget _postJobTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formSectionTitle('INFORMASI PEKERJAAN'),
            _textField(
              controller: titleController,
              label: 'Judul Posisi / Pekerjaan',
              hint: 'Contoh: Senior Flutter Developer, UI Designer',
              validator: (v) => v?.trim().isEmpty == true
                  ? 'Judul pekerjaan wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 12),
            _textField(
              controller: companyController,
              label: 'Nama Perusahaan / Bisnis',
              hint: 'Contoh: PT Kreasi Digital Nusantara',
              validator: (v) => v?.trim().isEmpty == true
                  ? 'Nama perusahaan wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 12),
            _textField(
              controller: locationController,
              label: 'Kota / Lokasi Penempatan',
              hint: 'Contoh: Jakarta Selatan, Bandung, Surabaya',
              validator: (v) =>
                  v?.trim().isEmpty == true ? 'Lokasi wajib diisi.' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tipe Pekerjaan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final type in [
                  'Penuh Waktu',
                  'Paruh Waktu',
                  'Kontrak',
                  'Magang',
                  'Freelance',
                ])
                  ChoiceChip(
                    label: Text(type),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    selected: selectedJobType == type,
                    onSelected: (s) {
                      if (s) setState(() => selectedJobType = type);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Kebijakan Tempat Kerja',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final mode in [
                  'Di Kantor (On-site)',
                  'Hybrid',
                  'Remote (WFH)',
                ])
                  ChoiceChip(
                    label: Text(mode),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    selected: selectedWorkplace == mode,
                    onSelected: (s) {
                      if (s) setState(() => selectedWorkplace = mode);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 22),

            _formSectionTitle('KOMPENSASI & KATEGORI'),
            _textField(
              controller: salaryController,
              label: 'Rentang Gaji (Opsional)',
              hint: 'Contoh: Rp 8.000.000 - Rp 12.000.000 / bulan',
            ),
            const SizedBox(height: 12),
            _textField(
              controller: tagsController,
              label: 'Tag Keahlian (Pisahkan dengan koma)',
              hint: 'Contoh: Flutter, Dart, Firebase, REST API, Git',
            ),
            const SizedBox(height: 16),

            _formSectionTitle('DESKRIPSI & PERSYARATAN'),
            _textField(
              controller: descriptionController,
              label: 'Deskripsi & Tanggung Jawab Pekerjaan',
              hint:
                  'Jelaskan tanggung jawab utama kandidat dalam pekerjaan ini...',
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty == true
                  ? 'Deskripsi pekerjaan wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 12),
            _textField(
              controller: requirementsController,
              label: 'Kualifikasi & Persyaratan',
              hint:
                  'Sebutkan kualifikasi pendidikan, pengalaman, dan keahlian yang dibutuhkan...',
              maxLines: 4,
              validator: (v) =>
                  v?.trim().isEmpty == true ? 'Persyaratan wajib diisi.' : null,
            ),
            const SizedBox(height: 16),

            _formSectionTitle('METODE PENDAFTARAN'),
            _textField(
              controller: applicationContactController,
              label: 'Link Pendaftaran atau Email Lamaran',
              hint:
                  'Contoh: https://perusahaan.com/karir atau hrd@perusahaan.com',
              validator: (v) => v?.trim().isEmpty == true
                  ? 'Kanal lamaran wajib diisi.'
                  : null,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: plum,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _submitJobPost,
                label: const Text(
                  'Publish',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _resetForm,
                child: const Text('Reset Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: plum,
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: maxLines > 1,
    ),
  );

  Future<void> _submitJobPost() async {
    if (!formKey.currentState!.validate()) return;

    final isRemote = selectedWorkplace.contains('Remote');
    final locText = locationController.text.trim();
    final workplaceSuffix = selectedWorkplace.contains('Remote')
        ? ' (Remote)'
        : selectedWorkplace.contains('Hybrid')
        ? ' (Hybrid)'
        : '';

    final tags = tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final desc =
        '<h3>Deskripsi Pekerjaan</h3><p>${descriptionController.text.trim().replaceAll('\n', '<br>')}</p><h3>Kualifikasi</h3><p>${requirementsController.text.trim().replaceAll('\n', '<br>')}</p>';

    final newJob = Job(
      id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text.trim(),
      company: companyController.text.trim(),
      location: '$locText$workplaceSuffix',
      remote: isRemote,
      salary: salaryController.text.trim().isEmpty
          ? null
          : salaryController.text.trim(),
      jobTypes: [selectedJobType],
      tags: tags,
      description: desc,
      url: applicationContactController.text.trim(),
      source: 'Pemberi Kerja LangkahKerja',
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    await store.postEmployerJob(newJob);

    if (!mounted) return;

    // Show celebration dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Lowongan Terbit!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lowongan "${newJob.title}" berhasil dipublikasikan!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pencari kerja di menu Cari Kerja (Employee) sekarang dapat langsung menemukan dan melihat lowongan ini di feed eksplorasi.',
              style: TextStyle(fontSize: 12, color: muted, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
              setState(() => tab = 0); // View in My Jobs
            },
            child: const Text('Lihat Lowongan Saya'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
              store.setActiveRole('employee'); // Jump to employee mode
            },
            child: const Text('Buka Menu Cari Kerja'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    titleController.clear();
    locationController.clear();
    salaryController.clear();
    tagsController.clear();
    descriptionController.clear();
    requirementsController.clear();
    applicationContactController.clear();
    if (store.companyProfile['name']?.isNotEmpty == true) {
      companyController.text = store.companyProfile['name']!;
    }
  }

  // TAB 2: KELOLA PELAMAR (APPLICANTS)
  Widget _applicantsTab() {
    var list = List<Map<String, dynamic>>.from(store.employerApplicants);

    if (selectedJobFilter != 'all') {
      list = list.where((a) => a['jobId'] == selectedJobFilter).toList();
    }
    if (selectedStatusFilter != 'all') {
      list = list.where((a) => a['status'] == selectedStatusFilter).toList();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Filter Job Dropdown
        if (store.employerJobs.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedJobFilter,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('Semua Lowongan'),
                  ),
                  for (final job in store.employerJobs.values)
                    DropdownMenuItem(
                      value: job.id,
                      child: Text(
                        job.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => selectedJobFilter = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final st in [
                'all',
                'Ditinjau',
                'Wawancara',
                'Diterima',
                'Ditolak',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(st == 'all' ? 'Semua Status' : st),
                    selected: selectedStatusFilter == st,
                    onSelected: (s) {
                      if (s) setState(() => selectedStatusFilter = st);
                    },
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Pelamar (${list.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (list.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: line),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  size: 42,
                  color: muted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Belum Ada Data Pelamar',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kandidat yang melamar lowongan Anda atau diinput manual akan tercatat di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _showAddApplicantDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Input Pelamar Baru'),
                ),
              ],
            ),
          ),
        ] else ...[
          for (final applicant in list) _applicantCard(applicant),
        ],
      ],
    );
  }

  Widget _applicantCard(Map<String, dynamic> applicant) {
    final status = applicant['status'] ?? 'Ditinjau';
    final statusColor = switch (status) {
      'Wawancara' => lavender,
      'Diterima' => lime,
      'Ditolak' => const Color(0xFFFFDACE),
      _ => const Color(0xFFFFF2D6),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: lavender,
                child: Text(
                  '${applicant['candidateName'] ?? '?'}'.characters.first
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: plum,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${applicant['candidateName']}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Posisi: ${applicant['jobTitle'] ?? 'Umum'}',
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: plum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (applicant['candidateEmail']?.isNotEmpty == true ||
              applicant['candidatePhone']?.isNotEmpty == true) ...[
            Row(
              children: [
                if (applicant['candidateEmail']?.isNotEmpty == true) ...[
                  const Icon(Icons.email_outlined, size: 13, color: muted),
                  const SizedBox(width: 4),
                  Text(
                    '${applicant['candidateEmail']}',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(width: 12),
                ],
                if (applicant['candidatePhone']?.isNotEmpty == true) ...[
                  const Icon(Icons.phone_outlined, size: 13, color: muted),
                  const SizedBox(width: 4),
                  Text(
                    '${applicant['candidatePhone']}',
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (applicant['notes']?.isNotEmpty == true) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Catatan: ${applicant['notes']}',
                style: const TextStyle(fontSize: 11, color: ink, height: 1.4),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const Divider(height: 1),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _changeApplicantStatusDialog(applicant),
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text(
                  'Ubah Status',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Hapus pelamar',
                icon: const Icon(Icons.delete_outline, size: 18, color: muted),
                onPressed: () => store.deleteEmployerApplicant(applicant['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddApplicantDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String targetJobId = store.employerJobs.isNotEmpty
        ? store.employerJobs.keys.first
        : 'umum';
    String targetJobTitle = store.employerJobs.isNotEmpty
        ? store.employerJobs.values.first.title
        : 'Posisi Umum';
    String initialStatus = 'Ditinjau';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Input Data Pelamar'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (store.employerJobs.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: targetJobId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Lowongan'),
                      items: [
                        for (final j in store.employerJobs.values)
                          DropdownMenuItem(
                            value: j.id,
                            child: Text(
                              j.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            targetJobId = v;
                            targetJobTitle = store.employerJobs[v]?.title ?? '';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kandidat',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email Kontak',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'No. WhatsApp',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: initialStatus,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Status Awal'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Ditinjau',
                        child: Text(
                          'Ditinjau',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Wawancara',
                        child: Text(
                          'Wawancara',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Diterima',
                        child: Text(
                          'Diterima',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Ditolak',
                        child: Text('Ditolak', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => initialStatus = v);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Kandidat',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                store.addEmployerApplicant({
                  'id': 'cand-${DateTime.now().millisecondsSinceEpoch}',
                  'jobId': targetJobId,
                  'jobTitle': targetJobTitle,
                  'candidateName': nameCtrl.text.trim(),
                  'candidateEmail': emailCtrl.text.trim(),
                  'candidatePhone': phoneCtrl.text.trim(),
                  'status': initialStatus,
                  'appliedAt': DateTime.now().toIso8601String(),
                  'notes': notesCtrl.text.trim(),
                });
                Navigator.pop(ctx);
              },
              child: const Text('Simpan Pelamar'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeApplicantStatusDialog(Map<String, dynamic> applicant) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Status: ${applicant['candidateName']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<String>(
              groupValue: applicant['status'] as String?,
              onChanged: (value) {
                if (value != null) {
                  store.updateApplicantStatus(applicant['id'], value);
                  Navigator.pop(ctx);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final st in [
                    'Ditinjau',
                    'Wawancara',
                    'Diterima',
                    'Ditolak',
                  ])
                    RadioListTile<String>(title: Text(st), value: st),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 3: PROFIL PERUSAHAAN (COMPANY PROFILE)
  Widget _companyProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Perusahaan\n& Bisnis.',
            style: TextStyle(
              fontSize: 32,
              height: 1.05,
              letterSpacing: -1.5,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Informasi profil perusahaan ini akan otomatis digunakan untuk melengkapi data lowongan yang Anda terbitkan.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 20),

          _textField(
            controller: profileNameController,
            label: 'Nama Perusahaan / Organisasi',
            hint: 'Contoh: PT Kreasi Solusi Indonesia',
          ),
          const SizedBox(height: 12),
          _textField(
            controller: profileIndustryController,
            label: 'Industri / Sektor Bisnis',
            hint: 'Contoh: Teknologi Informasi, E-commerce, Kreatif',
          ),
          const SizedBox(height: 12),
          _textField(
            controller: profileCityController,
            label: 'Kota Kantor Utama',
            hint: 'Contoh: Jakarta Selatan, DKI Jakarta',
          ),
          const SizedBox(height: 12),
          _textField(
            controller: profileWebsiteController,
            label: 'Website Resmi',
            hint: 'Contoh: https://perusahaan.co.id',
          ),
          const SizedBox(height: 12),
          _textField(
            controller: profileEmailController,
            label: 'Email Kontak HR / Rekrutmen',
            hint: 'Contoh: karir@perusahaan.co.id',
          ),
          const SizedBox(height: 12),
          _textField(
            controller: profileAboutController,
            label: 'Tentang Perusahaan',
            hint: 'Ceritakan singkat visi, misi, dan budaya perusahaan...',
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: plum,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                await store.saveCompanyProfile({
                  'name': profileNameController.text.trim(),
                  'industry': profileIndustryController.text.trim(),
                  'city': profileCityController.text.trim(),
                  'website': profileWebsiteController.text.trim(),
                  'email': profileEmailController.text.trim(),
                  'about': profileAboutController.text.trim(),
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil perusahaan berhasil disimpan!'),
                    ),
                  );
                }
              },
              child: const Text(
                'Simpan Profil Perusahaan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
