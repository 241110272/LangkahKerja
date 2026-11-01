import 'package:flutter/material.dart';

import '../main.dart';
import '../services/cloud.dart';
import '../services/job_store.dart';
import '../widgets/brand.dart';
import '../widgets/role_switcher.dart';

/// Frontend-only Admin mode.
class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
    required this.store,
    this.cloud,
  });

  final JobStore store;
  final CloudController? cloud;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  int tab = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late final menuAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  String vacancyQuery = '';
  String employeeQuery = '';
  String employerQuery = '';

  String vacancyFilter = 'Semua';
  String employeeFilter = 'Semua';
  String employerFilter = 'Semua';

  // Dummy vacancy records.
  final List<_AdminVacancy> vacancies = [
    _AdminVacancy(
      id: 'JOB-001',
      title: 'Junior UI/UX Designer',
      company: 'Studio Tumbuh',
      location: 'Jakarta',
      type: 'Full-time',
      status: 'Menunggu',
      source: 'Employer',
    ),
    _AdminVacancy(
      id: 'JOB-002',
      title: 'Flutter Developer Intern',
      company: 'Ruang Digital',
      location: 'Bandung',
      type: 'Internship',
      status: 'Aktif',
      source: 'Employer',
    ),
    _AdminVacancy(
      id: 'JOB-003',
      title: 'Digital Marketing Associate',
      company: 'Kawan Usaha',
      location: 'Surabaya',
      type: 'Full-time',
      status: 'Aktif',
      source: 'Admin',
    ),
    _AdminVacancy(
      id: 'JOB-004',
      title: 'Junior Data Analyst',
      company: 'Arah Data',
      location: 'Yogyakarta',
      type: 'Contract',
      status: 'Ditolak',
      source: 'Employer',
    ),
  ];

  // Dummy employee accounts.
  final List<_AdminUser> employees = [
    _AdminUser(
      id: 'EMP-001',
      name: 'John Doe',
      email: 'john.doe@email.com',
      detail: 'UI/UX Designer · Jakarta',
      status: 'Aktif',
    ),
    _AdminUser(
      id: 'EMP-002',
      name: 'Jane Smith',
      email: 'jane.smith@email.com',
      detail: 'Flutter Developer · Bandung',
      status: 'Aktif',
    ),
    _AdminUser(
      id: 'EMP-003',
      name: 'Rizky Pratama',
      email: 'rizky@email.com',
      detail: 'Data Analyst · Medan',
      status: 'Ditangguhkan',
    ),
    _AdminUser(
      id: 'EMP-004',
      name: 'Nadia Putri',
      email: 'nadia@email.com',
      detail: 'Digital Marketing · Surabaya',
      status: 'Aktif',
    ),
  ];

  // Dummy employer accounts.
  final List<_AdminUser> employers = [
    _AdminUser(
      id: 'HIR-001',
      name: 'Studio Tumbuh',
      email: 'hr@studiotumbuh.id',
      detail: 'Design & Creative · Jakarta',
      status: 'Terverifikasi',
    ),
    _AdminUser(
      id: 'HIR-002',
      name: 'Ruang Digital',
      email: 'career@ruangdigital.id',
      detail: 'Technology · Bandung',
      status: 'Menunggu',
    ),
    _AdminUser(
      id: 'HIR-003',
      name: 'Kawan Usaha',
      email: 'people@kawanusaha.id',
      detail: 'Marketing · Surabaya',
      status: 'Terverifikasi',
    ),
    _AdminUser(
      id: 'HIR-004',
      name: 'Arah Data',
      email: 'talent@arahdata.id',
      detail: 'Data & Analytics · Yogyakarta',
      status: 'Ditangguhkan',
    ),
  ];

  int get activeVacancies =>
      vacancies.where((item) => item.status == 'Aktif').length;

  int get pendingVacancies =>
      vacancies.where((item) => item.status == 'Menunggu').length;

  int get activeEmployees =>
      employees.where((item) => item.status == 'Aktif').length;

  int get verifiedEmployers =>
      employers.where((item) => item.status == 'Terverifikasi').length;

  @override
  void dispose() {
    menuAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
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
        drawer: _adminDrawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(),
              const Divider(height: 1),
              Expanded(
                child: switch (tab) {
                  0 => _dashboardTab(),

                  1 => _vacancyTab(),

                  2 => _userTab(
                      title: 'Employee',
                      subtitle: 'Kelola akun pencari kerja',
                      records: employees,
                      query: employeeQuery,
                      filter: employeeFilter,
                      onQueryChanged: (value) =>
                          setState(() => employeeQuery = value),
                      onFilterChanged: (value) =>
                          setState(() => employeeFilter = value),
                      filters: const [
                        'Semua',
                        'Aktif',
                        'Ditangguhkan',
                      ],
                      emptyMessage: 'Employee tidak ditemukan.',
                      isEmployer: false,
                    ),

                  _ => _userTab(
                      title: 'Employer',
                      subtitle: 'Kelola akun perusahaan',
                      records: employers,
                      query: employerQuery,
                      filter: employerFilter,
                      onQueryChanged: (value) =>
                          setState(() => employerQuery = value),
                      onFilterChanged: (value) =>
                          setState(() => employerFilter = value),
                      filters: const [
                        'Semua',
                        'Terverifikasi',
                        'Menunggu',
                        'Ditangguhkan',
                      ],
                      emptyMessage: 'Employer tidak ditemukan.',
                      isEmployer: true,
                    ),
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: _adminBottomBar(),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Buka menu admin',
            onPressed: () =>
                scaffoldKey.currentState?.openDrawer(),
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
          const Spacer(),

          RoleSwitcher(store: widget.store),
        ],
      ),
    );
  }

  Widget _adminDrawer() {
    final width = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: width < 360 ? width * 0.9 : 340,
      backgroundColor: canvas,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                22, 22, 14, 22,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    plum,
                    Color(0xFF493451),
                  ],
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
                          'Portal Admin',
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
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Kelola lowongan, employee, dan employer.',
                    style: TextStyle(
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
                padding: const EdgeInsets.fromLTRB(
                  14, 18, 14, 22,
                ),
                children: [
                  _drawerSectionTitle('MENU ADMIN'),

                  _drawerItem(
                    order: 0,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    subtitle: 'Ringkasan aktivitas platform',
                    onTap: () => setState(() => tab = 0),
                  ),

                  _drawerItem(
                    order: 1,
                    icon: Icons.work_outline_rounded,
                    title: 'Kelola Lowongan',
                    subtitle: 'Tinjau dan moderasi lowongan kerja',
                    onTap: () => setState(() => tab = 1),
                  ),

                  _drawerItem(
                    order: 2,
                    icon: Icons.people_outline_rounded,
                    title: 'Kelola Employee',
                    subtitle: 'Lihat dan kelola akun pencari kerja',
                    onTap: () => setState(() => tab = 2),
                  ),

                  _drawerItem(
                    order: 3,
                    icon: Icons.business_outlined,
                    title: 'Kelola Employer',
                    subtitle: 'Verifikasi dan kelola akun perusahaan',
                    onTap: () => setState(() => tab = 3),
                  ),

                  const SizedBox(height: 16),

                  _drawerSectionTitle('GANTI PERAN & MODE'),

                  _drawerItem(
                    order: 4,
                    icon: Icons.person_search_rounded,
                    title: 'Beralih ke Cari Kerja (Hiree)',
                    subtitle: 'Buka menu pencarian kerja',
                    onTap: () =>
                        widget.store.setActiveRole('employee'),
                  ),

                  _drawerItem(
                    order: 5,
                    icon: Icons.business_center_outlined,
                    title: 'Beralih ke Post Kerja (Hirer)',
                    subtitle: 'Buka menu pengelolaan lowongan',
                    onTap: () =>
                        widget.store.setActiveRole('employer'),
                  ),

                  _drawerItem(
                    order: 6,
                    icon: Icons.swap_horiz_rounded,
                    title: 'Menu Pilih Peran',
                    subtitle: 'Kembali ke pilihan peran awal',
                    onTap: () =>
                        widget.store.setActiveRole(null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerSectionTitle(String title) {
    return Padding(
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
  }

  Widget _drawerItem({
    required int order,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: menuAnimation,
      builder: (context, child) {
        final begin =
            (order * 0.07).clamp(0.0, 0.55).toDouble();

        final progress = Interval(
          begin,
          1,
          curve: Curves.easeOutCubic,
        ).transform(menuAnimation.value);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(16 * (1 - progress), 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: lavender.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: plum,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: muted,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: muted,
          ),
          onTap: () {
            scaffoldKey.currentState?.closeDrawer();
            onTap();
          },
        ),
      ),
    );
  }


  Widget _adminBottomBar() {
    const labels = [
      'Dashboard',
      'Lowongan',
      'Employee',
      'Employer',
    ];

    const icons = [
      Icons.dashboard_outlined,
      Icons.work_outline_rounded,
      Icons.people_outline_rounded,
      Icons.business_outlined,
    ];

    const selectedIcons = [
      Icons.dashboard_rounded,
      Icons.work_rounded,
      Icons.people_rounded,
      Icons.business_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFD).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          width: 64,
                          height: 32,
                          decoration: BoxDecoration(
                            color: tab == i
                                ? lavender
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            tab == i
                                ? selectedIcons[i]
                                : icons[i],
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

  // ============================================================
  // GENERAL PAGE
  // ============================================================

  Widget _page({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: muted,
          ),
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _dashboardTab() {
    return _page(
      title: 'Admin Dashboard',
      subtitle: 'Ringkasan aktivitas platform LangkahKerja.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _statCard(
                'Lowongan aktif',
                '$activeVacancies',
                Icons.work_outline_rounded,
                const Color(0xFFE8DFFA),
              ),
              _statCard(
                'Menunggu review',
                '$pendingVacancies',
                Icons.pending_actions_rounded,
                const Color(0xFFFFEBC2),
              ),
              _statCard(
                'Employee aktif',
                '$activeEmployees',
                Icons.people_outline_rounded,
                const Color(0xFFDDF1E8),
              ),
              _statCard(
                'Employer verified',
                '$verifiedEmployers',
                Icons.verified_outlined,
                const Color(0xFFDDEAF8),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionHeading(
            'Perlu ditinjau',
            'Lowongan menunggu persetujuan',
          ),
          const SizedBox(height: 10),
          ...vacancies
              .where((item) => item.status == 'Menunggu')
              .map(_vacancyCard),
          if (pendingVacancies == 0)
            _emptyCard(
              'Tidak ada lowongan yang menunggu review.',
            ),
          const SizedBox(height: 22),
          _sectionHeading(
            'Aktivitas akun',
            'Ringkasan akun terdaftar',
          ),
          const SizedBox(height: 10),
          _summaryRow(
            icon: Icons.person_outline,
            label: 'Employee',
            value: '${employees.length} akun contoh',
          ),
          _summaryRow(
            icon: Icons.business_outlined,
            label: 'Employer',
            value: '${employers.length} akun contoh',
          ),
          const SizedBox(height: 12),
          const Text(
            'Data pada dashboard ini adalah data dummy untuk prototipe frontend.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color tint,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 18,
              color: plum,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VACANCY MANAGEMENT
  // ============================================================

  Widget _vacancyTab() {
    final filtered = vacancies.where((item) {
      final query = vacancyQuery.toLowerCase();

      final matchesQuery =
          item.title.toLowerCase().contains(query) ||
          item.company.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);

      final matchesFilter =
          vacancyFilter == 'Semua' ||
          item.status == vacancyFilter;

      return matchesQuery && matchesFilter;
    }).toList();

    return _page(
      title: 'Manajemen Lowongan',
      subtitle: 'Tinjau dan moderasi lowongan pekerjaan.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) =>
                setState(() => vacancyQuery = value),
            decoration: const InputDecoration(
              hintText: 'Cari posisi, perusahaan, atau ID...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          _filterChips(
            values: const [
              'Semua',
              'Menunggu',
              'Aktif',
              'Ditolak',
            ],
            selected: vacancyFilter,
            onSelected: (value) =>
                setState(() => vacancyFilter = value),
          ),
          const SizedBox(height: 14),
          _resultCount(filtered.length),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            _emptyCard('Tidak ada lowongan yang cocok.')
          else
            ...filtered.map(_vacancyCard),
        ],
      ),
    );
  }

  Widget _vacancyCard(_AdminVacancy item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.company} · ${item.location}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(item.status),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _smallTag(item.id),
              _smallTag(item.type),
              _smallTag('Sumber: ${item.source}'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (item.status == 'Menunggu')
                _actionButton(
                  label: 'Setujui',
                  icon: Icons.check_rounded,
                  onPressed: () =>
                      _setVacancyStatus(item, 'Aktif'),
                ),
              if (item.status != 'Ditolak')
                _actionButton(
                  label: 'Tolak',
                  icon: Icons.close_rounded,
                  outlined: true,
                  onPressed: () =>
                      _setVacancyStatus(item, 'Ditolak'),
                ),
              if (item.status != 'Aktif')
                _actionButton(
                  label: 'Aktifkan',
                  icon: Icons.publish_rounded,
                  outlined: true,
                  onPressed: () =>
                      _setVacancyStatus(item, 'Aktif'),
                ),
              _actionButton(
                label: 'Hapus',
                icon: Icons.delete_outline,
                outlined: true,
                onPressed: () => _confirmDeleteVacancy(item),
              ),
              _actionButton(
                label: 'Detail',
                icon: Icons.visibility_outlined,
                outlined: true,
                onPressed: () => _showVacancyDetails(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPLOYEE AND EMPLOYER MANAGEMENT
  // ============================================================

  Widget _userTab({
    required String title,
    required String subtitle,
    required List<_AdminUser> records,
    required String query,
    required String filter,
    required ValueChanged<String> onQueryChanged,
    required ValueChanged<String> onFilterChanged,
    required List<String> filters,
    required String emptyMessage,
    required bool isEmployer,
  }) {
    final filtered = records.where((item) {
      final q = query.toLowerCase();

      final matchesQuery =
          item.name.toLowerCase().contains(q) ||
          item.email.toLowerCase().contains(q) ||
          item.id.toLowerCase().contains(q) ||
          item.detail.toLowerCase().contains(q);

      final matchesFilter =
          filter == 'Semua' || item.status == filter;

      return matchesQuery && matchesFilter;
    }).toList();

    return _page(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: isEmployer
                  ? 'Cari perusahaan atau email...'
                  : 'Cari nama, keahlian, atau email...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          _filterChips(
            values: filters,
            selected: filter,
            onSelected: onFilterChanged,
          ),
          const SizedBox(height: 14),
          _resultCount(filtered.length),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            _emptyCard(emptyMessage)
          else
            ...filtered.map(
              (item) => _userCard(
                item,
                isEmployer: isEmployer,
              ),
            ),
        ],
      ),
    );
  }

  Widget _userCard(
    _AdminUser item, {
    required bool isEmployer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: lavender,
                foregroundColor: plum,
                child: Icon(
                  isEmployer
                      ? Icons.business_rounded
                      : Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    Text(
                      item.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(item.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detail,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${item.id}',
            style: const TextStyle(
              fontSize: 10,
              color: muted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isEmployer && item.status == 'Menunggu')
                _actionButton(
                  label: 'Verifikasi',
                  icon: Icons.verified_outlined,
                  onPressed: () =>
                      _setUserStatus(item, 'Terverifikasi'),
                ),
              if (item.status == 'Ditangguhkan')
                _actionButton(
                  label: 'Aktifkan',
                  icon: Icons.check_circle_outline,
                  onPressed: () => _setUserStatus(
                    item,
                    isEmployer ? 'Terverifikasi' : 'Aktif',
                  ),
                )
              else
                _actionButton(
                  label: 'Tangguhkan',
                  icon: Icons.block_outlined,
                  outlined: true,
                  onPressed: () =>
                      _setUserStatus(item, 'Ditangguhkan'),
                ),
              _actionButton(
                label: 'Detail',
                icon: Icons.visibility_outlined,
                outlined: true,
                onPressed: () =>
                    _showUserDetails(item, isEmployer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER CHIPS
  // ============================================================

  Widget _filterChips({
    required List<String> values,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((value) {
          final isSelected = selected == value;

          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
              labelStyle: TextStyle(
                fontSize: 11,
                color: isSelected ? plum : muted,
                fontWeight: isSelected
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // GENERAL WIDGETS
  // ============================================================

  Widget _sectionHeading(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: muted,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 19, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: ink),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCount(int count) {
    return Text(
      '$count data ditemukan',
      style: const TextStyle(
        color: muted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: muted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: canvas,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: muted,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color background;
    Color foreground;

    switch (status) {
      case 'Aktif':
      case 'Terverifikasi':
        background = const Color(0xFFDDF1E8);
        foreground = const Color(0xFF246B4D);
        break;

      case 'Menunggu':
        background = const Color(0xFFFFEBC2);
        foreground = const Color(0xFF805B12);
        break;

      case 'Ditolak':
      case 'Ditangguhkan':
        background = const Color(0xFFF8DEDE);
        foreground = const Color(0xFF9A3636);
        break;

      default:
        background = lavender;
        foreground = plum;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    const buttonTextStyle = TextStyle(
      fontFamily: 'Manrope',
      fontSize: 10,
      fontWeight: FontWeight.w700,
    );

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: buttonTextStyle,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: plum,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          textStyle: buttonTextStyle,
          visualDensity: VisualDensity.compact,
          side: const BorderSide(color: line),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: buttonTextStyle,
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        textStyle: buttonTextStyle,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: line),
    );
  }

  // ============================================================
  // ADMIN ACTIONS
  // ============================================================

  Future<void> _setVacancyStatus(
    _AdminVacancy item,
    String newStatus,
  ) async {
    setState(() => item.status = newStatus);

    _message(
      '${item.title}: status diubah menjadi $newStatus.',
    );
  }

  Future<void> _confirmDeleteVacancy(
    _AdminVacancy item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus lowongan?'),
        content: Text(
          'Lowongan "${item.title}" akan dihapus dari data dummy Admin.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => vacancies.remove(item));

      _message(
        'Lowongan berhasil dihapus dari data dummy.',
      );
    }
  }

  Future<void> _setUserStatus(
    _AdminUser item,
    String newStatus,
  ) async {
    setState(() => item.status = newStatus);

    _message(
      '${item.name}: status diubah menjadi $newStatus.',
    );
  }

  void _showUserDetails(
    _AdminUser item,
    bool isEmployer,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isEmployer ? 'Detail Employer' : 'Detail Employee',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailLine('ID', item.id),
            _detailLine(
              isEmployer ? 'Perusahaan' : 'Nama',
              item.name,
            ),
            _detailLine('Email', item.email),
            _detailLine(
              isEmployer
                  ? 'Industri / Lokasi'
                  : 'Keahlian / Lokasi',
              item.detail,
            ),
            _detailLine('Status', item.status),
            const SizedBox(height: 10),
            const Text(
              'Informasi ini merupakan data contoh, bukan data akun terdaftar.',
              style: TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showVacancyDetails(_AdminVacancy item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detail Lowongan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailLine('ID Lowongan', item.id),
              _detailLine('Posisi', item.title),
              _detailLine('Perusahaan', item.company),
              _detailLine('Lokasi', item.location),
              _detailLine('Tipe Pekerjaan', item.type),
              _detailLine('Sumber', item.source),
              _detailLine('Status', item.status),
              const SizedBox(height: 10),
              const Text(
                'Informasi ini merupakan data contoh untuk prototipe frontend.',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class _AdminVacancy {
  _AdminVacancy({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.status,
    required this.source,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String source;

  String status;
}

class _AdminUser {
  _AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.detail,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String detail;

  String status;
}