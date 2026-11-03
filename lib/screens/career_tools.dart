import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../models/job.dart';
import '../services/job_store.dart';

class ResumeBuilderPage extends StatefulWidget {
  const ResumeBuilderPage({super.key, required this.store});
  final JobStore store;

  @override
  State<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends State<ResumeBuilderPage> {
  late final name = TextEditingController(text: widget.store.name);
  final role = TextEditingController();
  final contact = TextEditingController();
  final summary = TextEditingController();
  final experience = TextEditingController();
  final education = TextEditingController();
  late final skills = TextEditingController(text: widget.store.skills);
  bool preview = false;

  @override
  void dispose() {
    name.dispose();
    role.dispose();
    contact.dispose();
    summary.dispose();
    experience.dispose();
    education.dispose();
    skills.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Buat CV')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      children: [
        const _ToolIntro(
          eyebrow: 'CERITAKAN POTENSIMU',
          title: 'CV yang terasa\nseperti dirimu.',
          subtitle:
              'Mulai dari hal yang relevan. Proyek kuliah dan pengalaman organisasi juga berarti.',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 18),
        const _LocalDraftNotice(),
        const SizedBox(height: 18),
        _field(name, 'Nama lengkap', 'Nama yang ingin dicantumkan'),
        _field(role, 'Posisi yang dituju', 'Contoh: Junior UI/UX Designer'),
        _field(
          contact,
          'Kontak profesional',
          'Email · nomor telepon · tautan portofolio',
        ),
        _field(
          summary,
          'Ringkasan singkat',
          'Apa kekuatan dan arah kariermu?',
          lines: 3,
        ),
        _field(
          experience,
          'Pengalaman atau proyek',
          'Peran, kontribusi, dan hasil yang relevan',
          lines: 4,
        ),
        _field(
          education,
          'Pendidikan',
          'Institusi, jurusan, dan tahun',
          lines: 2,
        ),
        _field(skills, 'Keterampilan', 'Pisahkan dengan koma', lines: 2),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => setState(() => preview = true),
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Lihat pratinjau CV'),
        ),
        if (preview) ...[
          const SizedBox(height: 22),
          const Text(
            'PRATINJAU',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: muted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _ResumePreview(
            name: name.text,
            role: role.text,
            contact: contact.text,
            summary: summary.text,
            experience: experience.text,
            education: education.text,
            skills: skills.text,
          ),
          Center(
            child: TextButton.icon(
              onPressed: _copyResume,
              icon: const Icon(Icons.copy_outlined, size: 17),
              label: const Text('Salin teks CV'),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLength: lines > 1 ? 1200 : 180,
      maxLines: lines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: lines > 1,
      ),
      onChanged: preview ? (_) => setState(() {}) : null,
    ),
  );

  Future<void> _copyResume() async {
    final sections = [
      name.text.trim(),
      role.text.trim(),
      contact.text.trim(),
      '',
      'PROFIL\n${summary.text.trim()}',
      'PENGALAMAN / PROYEK\n${experience.text.trim()}',
      'PENDIDIKAN\n${education.text.trim()}',
      'KETERAMPILAN\n${skills.text.trim()}',
    ].where((section) => section.isNotEmpty).join('\n\n');
    await Clipboard.setData(ClipboardData(text: sections));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'CV disalin. Tempel ke editor dokumen untuk menyimpannya.',
          ),
        ),
      );
    }
  }
}

class _ResumePreview extends StatelessWidget {
  const _ResumePreview({
    required this.name,
    required this.role,
    required this.contact,
    required this.summary,
    required this.experience,
    required this.education,
    required this.skills,
  });

  final String name, role, contact, summary, experience, education, skills;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? 'Nama lengkap' : name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: plum,
            ),
          ),
          if (role.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              role,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
          if (contact.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(contact, style: const TextStyle(fontSize: 10, color: muted)),
          ],
          const Divider(height: 24),
          _previewSection('PROFIL', summary),
          _previewSection('PENGALAMAN / PROYEK', experience),
          _previewSection('PENDIDIKAN', education),
          _previewSection('KETERAMPILAN', skills),
        ],
      ),
    ),
  );

  Widget _previewSection(String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            color: muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Tambahkan informasi yang relevan.' : value,
          style: const TextStyle(fontSize: 11, height: 1.6),
        ),
      ],
    ),
  );
}

class CoverLetterBuilderPage extends StatefulWidget {
  const CoverLetterBuilderPage({super.key, required this.store});
  final JobStore store;

  @override
  State<CoverLetterBuilderPage> createState() => _CoverLetterBuilderPageState();
}

class _CoverLetterBuilderPageState extends State<CoverLetterBuilderPage> {
  final position = TextEditingController();
  final company = TextEditingController();
  final highlight = TextEditingController();
  String? selectedJobId;
  String? draft;

  List<Job> get availableJobs {
    final jobs = [
      ...widget.store.applicationJobs.values,
      ...widget.store.saved.values,
      ...widget.store.jobs,
    ];
    return {for (final job in jobs) job.id: job}.values.toList();
  }

  @override
  void dispose() {
    position.dispose();
    company.dispose();
    highlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = availableJobs;
    return Scaffold(
      appBar: AppBar(title: const Text('Surat lamaran kerja')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        children: [
          const _ToolIntro(
            eyebrow: 'SATU SURAT, SATU TUJUAN',
            title: 'Buat surat\nyang personal.',
            subtitle:
                'Draf sederhana untuk kamu sesuaikan dengan posisi dan perusahaan.',
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 18),
          const _LocalDraftNotice(),
          const SizedBox(height: 18),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Ambil dari peluang yang sudah ada',
              helperText: jobs.isEmpty
                  ? 'Belum ada peluang dimuat. Posisi dapat diisi manual.'
                  : 'Pilih dari lowongan, favorit, atau lamaran tersimpan.',
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: jobs.any((job) => job.id == selectedJobId)
                    ? selectedJobId
                    : null,
                hint: Text(
                  jobs.isEmpty
                      ? 'Belum ada peluang'
                      : 'Pilih peluang (opsional)',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
                items: jobs
                    .map(
                      (job) => DropdownMenuItem(
                        value: job.id,
                        child: Text(
                          '${job.title} · ${job.company}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: jobs.isEmpty
                    ? null
                    : (id) {
                        final job = jobs
                            .where((job) => job.id == id)
                            .firstOrNull;
                        if (job == null) return;
                        setState(() {
                          selectedJobId = id;
                          position.text = job.title;
                          company.text = job.company;
                          draft = null;
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: position,
            decoration: const InputDecoration(
              labelText: 'Posisi yang dilamar',
              hintText: 'Contoh: Staf Administrasi',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: company,
            decoration: const InputDecoration(
              labelText: 'Nama perusahaan',
              hintText: 'Contoh: PT Tumbuh Bersama',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: highlight,
            maxLength: 700,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Pengalaman yang paling relevan',
              hintText:
                  'Ceritakan kontribusi atau proyek yang mendukung lamaranmu.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => setState(() => draft = _makeDraft()),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Susun draf surat'),
          ),
          if (draft != null) ...[
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'DRAF UNTUK DITINJAU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: muted,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: draft!));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Draf disalin. Periksa kembali sebelum dikirim.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Salin'),
                ),
              ],
            ),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SelectableText(
                  draft!,
                  style: const TextStyle(fontSize: 12, height: 1.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _makeDraft() {
    final applicant = widget.store.name.trim().isEmpty
        ? 'Nama kamu'
        : widget.store.name.trim();
    final target = position.text.trim().isEmpty
        ? 'posisi yang tersedia'
        : position.text.trim();
    final companyName = company.text.trim().isEmpty
        ? 'Tim Rekrutmen'
        : company.text.trim();
    final detail = highlight.text.trim().isEmpty
        ? 'Saya siap menjelaskan pengalaman dan motivasi saya lebih lanjut dalam proses seleksi.'
        : highlight.text.trim();
    return 'Yth. Tim Rekrutmen ${companyName == 'Tim Rekrutmen' ? '' : companyName}\n\nDengan hormat,\n\nSaya $applicant bermaksud mengajukan lamaran untuk posisi $target. Saya tertarik untuk berkontribusi dan terus berkembang bersama tim ${companyName == 'Tim Rekrutmen' ? 'yang Bapak/Ibu pimpin' : companyName}.\n\n$detail\n\nBesar harapan saya untuk dapat berdiskusi lebih lanjut mengenai kontribusi yang dapat saya berikan. Terima kasih atas waktu dan perhatian Bapak/Ibu.\n\nHormat saya,\n$applicant';
  }
}

class Photo3x4Page extends StatefulWidget {
  const Photo3x4Page({super.key});

  @override
  State<Photo3x4Page> createState() => _Photo3x4PageState();
}

class _Photo3x4PageState extends State<Photo3x4Page> {
  Uint8List? sourceBytes, outputBytes;
  String? fileName;
  bool busy = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pasfoto 3×4')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      children: [
        const _ToolIntro(
          eyebrow: 'FOTO UNTUK BERKAS KERJA',
          title: 'Siapkan pasfoto\ndengan mudah.',
          subtitle:
              'Pilih foto, lalu buat crop tengah rasio 3:4 yang siap dibagikan.',
          icon: Icons.portrait_outlined,
        ),
        const SizedBox(height: 18),
        _notice(
          icon: Icons.lock_outline,
          color: lavender,
          text:
              'Foto diproses di perangkat untuk membuat pratinjau. Tidak dikirim ke server atau disimpan ke akun.',
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: line),
            ),
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: outputBytes == null
                    ? DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2EEF5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              color: muted,
                              size: 34,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sourceBytes == null
                                  ? 'Pratinjau 3:4'
                                  : 'Siap dipotong',
                              style: const TextStyle(
                                fontSize: 10,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.memory(outputBytes!, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        if (fileName != null) ...[
          const SizedBox(height: 9),
          Text(
            fileName!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: muted),
          ),
        ],
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: busy ? null : _pickPhoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(sourceBytes == null ? 'Pilih foto' : 'Ganti foto'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: sourceBytes == null || busy ? null : _generate,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.crop),
          label: Text(busy ? 'Menyiapkan…' : 'Buat foto rasio 3:4'),
        ),
        if (outputBytes != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _sharePhoto,
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('Bagikan / simpan hasil'),
          ),
          const Text(
            'Hasil berupa PNG rasio 3:4. Atur ukuran fisik 3×4 cm saat mencetak jika dibutuhkan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, height: 1.6, color: muted),
          ),
        ],
      ],
    ),
  );

  Future<void> _pickPhoto() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Foto',
            extensions: ['jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 15 * 1024 * 1024) {
        throw const FormatException('Ukuran foto maksimal 15 MB.');
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        sourceBytes = bytes;
        outputBytes = null;
        fileName = file.name;
      });
    } catch (error) {
      if (mounted) {
        _message(
          error is FormatException
              ? error.message
              : 'Foto belum bisa dibuka. Coba pilih berkas gambar lain.',
        );
      }
    }
  }

  Future<void> _generate() async {
    final bytes = sourceBytes;
    if (bytes == null) return;
    setState(() => busy = true);
    ui.Codec? codec;
    ui.Image? decoded;
    ui.Image? generated;
    try {
      final imageCodec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1200,
      );
      codec = imageCodec;
      final frame = await imageCodec.getNextFrame();
      final source = frame.image;
      decoded = source;
      final sourceRatio = source.width / source.height;
      const targetWidth = 600.0, targetHeight = 800.0;
      final sourceRect = sourceRatio > .75
          ? ui.Rect.fromLTWH(
              (source.width - source.height * .75) / 2,
              0,
              source.height * .75,
              source.height.toDouble(),
            )
          : ui.Rect.fromLTWH(
              0,
              (source.height - source.width / .75) / 2,
              source.width.toDouble(),
              source.width / .75,
            );
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        source,
        sourceRect,
        const ui.Rect.fromLTWH(0, 0, targetWidth, targetHeight),
        ui.Paint()..filterQuality = ui.FilterQuality.high,
      );
      final outputImage = await recorder.endRecording().toImage(
        targetWidth.toInt(),
        targetHeight.toInt(),
      );
      generated = outputImage;
      final data = await outputImage.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Foto hasil belum dapat dibuat.');
      if (!mounted) return;
      setState(
        () => outputBytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ),
      );
    } catch (_) {
      if (mounted) {
        _message('Foto belum bisa diproses. Coba berkas gambar lain.');
      }
    } finally {
      codec?.dispose();
      decoded?.dispose();
      generated?.dispose();
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _sharePhoto() async {
    final bytes = outputBytes;
    if (bytes == null) return;
    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          title: 'Pasfoto 3:4',
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: 'pasfoto-3x4.png',
            ),
          ],
          fileNameOverrides: const ['pasfoto-3x4.png'],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) _message('Hasil belum bisa dibagikan dari perangkat ini.');
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class IdentityUploadPage extends StatefulWidget {
  const IdentityUploadPage({super.key});

  @override
  State<IdentityUploadPage> createState() => _IdentityUploadPageState();
}

class _IdentityUploadPageState extends State<IdentityUploadPage> {
  String? selectedName;
  bool busy = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Upload identitas')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      children: [
        const _ToolIntro(
          eyebrow: 'DOKUMEN SENSITIF',
          title: 'Identitas tetap\ndalam kendalimu.',
          subtitle:
              'Gunakan hanya jika perusahaan meminta melalui kanal resmi dan aman.',
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 18),
        _notice(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFFFF0D6),
          text:
              'Jangan kirim KTP, nomor identitas, OTP, atau data rekening melalui chat yang tidak terverifikasi. LangkahKerja tidak mengirim dokumen ini ke perusahaan.',
        ),
        const SizedBox(height: 18),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih dokumen bila memang diperlukan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'PDF, JPG, atau PNG · maksimal 10 MB',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
                const SizedBox(height: 14),
                if (selectedName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file_outlined, color: plum),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          selectedName!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus pilihan',
                        onPressed: () => setState(() => selectedName = null),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: busy ? null : _pickIdentity,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(
                    busy ? 'Membuka berkas…' : 'Pilih berkas identitas',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _notice(
          icon: Icons.info_outline,
          color: lavender.withValues(alpha: .65),
          text:
              'Ini masih pratinjau alur UI: nama berkas hanya tampil selama halaman terbuka. File tidak dibaca, disalin, disimpan, atau diunggah.',
        ),
      ],
    ),
  );

  Future<void> _pickIdentity() async {
    setState(() => busy = true);
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Dokumen identitas',
            extensions: ['pdf', 'jpg', 'jpeg', 'png'],
            mimeTypes: ['application/pdf', 'image/jpeg', 'image/png'],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 10 * 1024 * 1024) {
        throw const FormatException('Ukuran dokumen maksimal 10 MB.');
      }
      if (mounted) setState(() => selectedName = file.name);
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? error.message
            : 'Dokumen belum bisa dipilih. Coba lagi.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _ToolIntro extends StatelessWidget {
  const _ToolIntro({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String eyebrow, title, subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                fontSize: 9,
                color: muted,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 31,
                height: 1.08,
                letterSpacing: -1.4,
                color: ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, height: 1.6, color: muted),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: lavender,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: plum),
      ),
    ],
  );
}

class _LocalDraftNotice extends StatelessWidget {
  const _LocalDraftNotice();

  @override
  Widget build(BuildContext context) => _notice(
    icon: Icons.lock_outline,
    color: lavender.withValues(alpha: .6),
    text:
        'Isi dan draf hanya ada selama halaman ini terbuka. Belum disimpan ke akun atau dikirim ke perusahaan.',
  );
}

Widget _notice({
  required IconData icon,
  required Color color,
  required String text,
}) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(17),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 19, color: plum),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, height: 1.6, color: ink),
        ),
      ),
    ],
  ),
);
