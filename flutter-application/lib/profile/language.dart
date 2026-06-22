import 'package:flutter/material.dart';
import 'package:gardproject/service/profile_service.dart';

class LanguagePage extends StatefulWidget {
  final VoidCallback onBack;

  const LanguagePage({
    super.key,
    required this.onBack,
  });

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _lang = "English";
  bool _isLoading = false;

  final ProfileService _profileService = ProfileService();

  static const bg = Color(0xFFF3F5F6);
  static const accent = Color(0xFFB5DD47);
  static const textDark = Color(0xFF101010);

  Future<void> _updateLanguage(String selectedLabel) async {
    final oldLang = _lang;
    final apiValue = selectedLabel == "Arabic" ? "ar" : "en";

    setState(() {
      _lang = selectedLabel;
      _isLoading = true;
    });

    final result = await _profileService.updateLanguage(
      language: apiValue,
    );

    if (!mounted) return;

    if (result["success"] != true) {
      setState(() {
        _lang = oldLang;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ?? "Failed to update language",
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon:        const Icon(Icons.arrow_back_outlined,size: 24,),
          onPressed: widget.onBack,
        ),
        centerTitle: true,
        title: const Text(
          "Language",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 35, 16, 12),
              decoration: BoxDecoration(
                
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Suggested",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LangRow(
                    title: "Arabic",
                    selected: _lang == "Arabic",
                    onTap: _isLoading ? null : () => _updateLanguage("Arabic"),
                    accent: accent,
                  ),
                  const SizedBox(height: 8),
                  _LangRow(
                    title: "English",
                    selected: _lang == "English",
                    onTap: _isLoading ? null : () => _updateLanguage("English"),
                    accent: accent,
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final Color accent;

  const _LangRow({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101010),
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : const Color(0xFFBDBDBD),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}