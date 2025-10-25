class Berita {
  final int id;
  final String judul;
  final String deskripsiSingkat;
  final String pratinjau;
  final String url;

  Berita({
    required this.id,
    required this.judul,
    required this.deskripsiSingkat,
    required this.pratinjau,
    required this.url,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['IDBERITA'],
      judul: json['JUDUL'],
      deskripsiSingkat: json['DESKRIPSISINGKAT'],
      pratinjau: json['PRATINJAU'],
      url: json['URL'] ?? '',
    );
  }
}
