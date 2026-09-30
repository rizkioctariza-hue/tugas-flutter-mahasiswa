//=================================
//===== Hasil Ujian Mahasiswa =====
//=================================

import 'package:flutter/material.dart';
import 'pages/form_mahasiswa_page.dart';

void main() {
  runApp(const MyApp());
}

class AppColor {
  static const Color background = Color(0xFFF5F7FA);
  static const Color gradientEnd = Color.fromARGB(255, 2, 86, 29);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hasil Ujian Mahasiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.gradientEnd,
        ),
      ),
      home: const HasilUjianPage(),
    );
  }
}

class Mahasiswa {
  final String nama;
  final double nilai;

  Mahasiswa({
    required this.nama,
    required this.nilai,
  });

  /// status untuk kelulusannya:
  /// true = lulus, false = tidak lulus
  bool get lulus => nilai >= 75;

  String get statusText => lulus ? 'Lulus' : 'Tidak Lulus';
}

class HasilUjianPage extends StatefulWidget {
  const HasilUjianPage({super.key});

  @override
  State<HasilUjianPage> createState() => _HasilUjianPageState();
}

class _HasilUjianPageState extends State<HasilUjianPage> {
  // Data awal
  final List<Mahasiswa> _daftarMahasiswa = [
    Mahasiswa(nama: 'Andi', nilai: 80),
    Mahasiswa(nama: 'Budi', nilai: 65),
    Mahasiswa(nama: 'Dzaky', nilai: 55),
    Mahasiswa(nama: 'Fakih', nilai: 90),
  ];

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nilaiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Filter: Semua, Lulus, Tidak Lulus
  String _filter = 'Semua';

  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Mahasiswa> get _dataTampil {
    switch (_filter) {
      case 'Lulus':
        return _daftarMahasiswa.where((m) => m.lulus).toList();

      case 'Tidak Lulus':
        return _daftarMahasiswa.where((m) => !m.lulus).toList();

      default:
        return List.from(_daftarMahasiswa);
    }
  }

  void _tambahData() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final nilai = double.parse(_nilaiController.text.trim());

      setState(() {
        _daftarMahasiswa.add(
          Mahasiswa(
            nama: nama,
            nilai: nilai,
          ),
        );
      });

      _namaController.clear();
      _nilaiController.clear();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data "$nama" berhasil ditambahkan',
          ),
        ),
      );
    }
  }

  void _hapusData(Mahasiswa m) {
    setState(() {
      _daftarMahasiswa.remove(m);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data "${m.nama}" dihapus',
        ),
      ),
    );
  }

  void _dialogTambahData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Tambah Data Mahasiswa',
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nilaiController,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Akhir',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nilai tidak boleh kosong';
                    }

                    final n = double.tryParse(value);

                    if (n == null) {
                      return 'Nilai harus berupa angka';
                    }

                    if (n < 0 || n > 100) {
                      return 'Nilai harus 0 - 100';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _tambahData,
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _sort<T>(
    Comparable<T> Function(Mahasiswa m) getField,
    int columnIndex,
    bool ascending,
  ) {
    _daftarMahasiswa.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jumlahLulus = _daftarMahasiswa.where((m) => m.lulus).length;
    final jumlahTidakLulus = _daftarMahasiswa.length - jumlahLulus;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          'Data Nilai Mahasiswa',
        ),
        backgroundColor: AppColor.gradientEnd,
        foregroundColor: Colors.white,
        actions: [
          // Tombol untuk membuka halaman FormMahasiswaPage
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Isi Data Mahasiswa',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormMahasiswaPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Statistik
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildStatCard(
                  'Total',
                  _daftarMahasiswa.length.toString(),
                  AppColor.gradientEnd,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Lulus',
                  jumlahLulus.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Tidak Lulus',
                  jumlahTidakLulus.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),

          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: Row(
              children: [
                const Text('Filter: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(
                      value: 'Semua',
                      child: Text('Semua'),
                    ),
                    DropdownMenuItem(
                      value: 'Lulus',
                      child: Text('Lulus'),
                    ),
                    DropdownMenuItem(
                      value: 'Tidak Lulus',
                      child: Text('Tidak Lulus'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filter = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tabel
          Expanded(
            child: _dataTampil.isEmpty
                ? const Center(
                    child: Text('Tidak ada data'),
                  )
                : SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        // ===== TAMPILAN HEADER =====
                        headingRowColor: WidgetStateProperty.all(
                          AppColor.gradientEnd,
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),

                        // ===== UKURAN TABEL =====
                        dataRowMinHeight: 58,
                        dataRowMaxHeight: 65,
                        columnSpacing: 28,
                        horizontalMargin: 45,

                        // ===== GARIS TABEL =====
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),

                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,

                        // ===== KOLOM =====
                        columns: [
                          DataColumn(
                            label: const Text('Nama'),
                            onSort: (columnIndex, ascending) {
                              _sort(
                                (m) => m.nama,
                                columnIndex,
                                ascending,
                              );
                            },
                          ),
                          DataColumn(
                            label: const Text('Nilai'),
                            numeric: true,
                            onSort: (columnIndex, ascending) {
                              _sort(
                                (m) => m.nilai,
                                columnIndex,
                                ascending,
                              );
                            },
                          ),
                          const DataColumn(
                            label: Text('Status'),
                          ),
                          const DataColumn(
                            label: Text('Aksi'),
                          ),
                        ],

                        // ===== ISI TABEL =====
                        rows: _dataTampil.map((m) {
                          return DataRow(
                            cells: [
                              // NAMA
                              DataCell(
                                Text(
                                  m.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // NILAI
                              DataCell(
                                Text(
                                  m.nilai.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // STATUS
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: m.lulus
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    m.statusText,
                                    style: TextStyle(
                                      color: m.lulus
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),

                              // AKSI
                              DataCell(
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade600,
                                      size: 20,
                                    ),
                                    tooltip: 'Hapus',
                                    onPressed: () {
                                      _hapusData(m);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColor.gradientEnd,
        foregroundColor: Colors.white,
        onPressed: _dialogTambahData,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data'),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nilaiController.dispose();
    super.dispose();
  }
}