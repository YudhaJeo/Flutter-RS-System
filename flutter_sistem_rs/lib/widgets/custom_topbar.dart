import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomTopBar({
    Key? key,
    required this.title,
    this.onBack,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0), // abu-abu muda (divider)
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 18, // lebih kecil dari teks
              ),
              color: Colors.lightBlue,
              padding: const EdgeInsets.only(left: 8, right: 4),
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}