class ProfileTentang {
  final String namaRs;
  final String alamat;
  final String email;
  final String notelpAmbulan;
  final String noAmbulanWa;
  final String nomorHotline;
  final String deskripsi;
  final String visi;
  final String misi;
  final String fotoLogo;

  ProfileTentang({
    required this.namaRs,
    required this.alamat,
    required this.email,
    required this.notelpAmbulan,
    required this.noAmbulanWa,
    required this.nomorHotline,
    required this.deskripsi,
    required this.visi,
    required this.misi,
    required this.fotoLogo,
  });

  factory ProfileTentang.fromJson(Map<String, dynamic> json) {

  final rawFotoLogo = json['FOTOLOGO'];
  String fotoLogoUrl = '';

  if (rawFotoLogo != null && rawFotoLogo.toString().isNotEmpty) {
    if (rawFotoLogo.toString().startsWith('http')) {
      fotoLogoUrl = rawFotoLogo;
    } else {
      final path = rawFotoLogo.toString().startsWith('/')
          ? rawFotoLogo
          : '/$rawFotoLogo';
      fotoLogoUrl = 'http://10.0.2.2:4100$path';
    }
  }

    return ProfileTentang(
      namaRs: json['NAMARS'] ?? '',
      alamat: json['ALAMAT'] ?? '',
      email: json['EMAIL'] ?? '',
      notelpAmbulan: json['NOTELPAMBULAN'] ?? '',
      noAmbulanWa: json['NOAMBULANWA'] ?? '',
      nomorHotline: json['NOMORHOTLINE'] ?? '',
      deskripsi: json['DESKRIPSI'] ?? '',
      visi: json['VISI'] ?? '',
      misi: json['MISI'] ?? '',
      fotoLogo: fotoLogoUrl,
    );
  }
}
