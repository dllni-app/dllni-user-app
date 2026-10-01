import 'package:flutter/material.dart';

import 'legal_links_launcher.dart';

class SupportHandoffScreen extends StatelessWidget {
  const SupportHandoffScreen({super.key, required this.onOpenWhatsApp});

  final Future<void> Function(BuildContext context) onOpenWhatsApp;

  static const _navy = Color(0xFF1E2A78);
  static const _ink = Color(0xFF172033);
  static const _muted = Color(0xFF667085);
  static const _border = Color(0xFFE4E7EC);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Column(
            children: [
              _SupportHeader(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9F9FA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              color: Color(0xFF0F8E98),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'تواصل مع فريق الدعم',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'سنفتح واتساب لإكمال المحادثة مع فريق الدعم.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () => onOpenWhatsApp(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF138A62),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text(
                              'فتح واتساب',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0FA),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, color: _navy, size: 20),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'سيتم فتح تطبيق خارجي. لا تشارك كلمة مرورك أو رمز التحقق مع أي شخص.',
                              style: TextStyle(
                                color: Color(0xFF66708C),
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LegalTile(
                      title: 'الشروط والأحكام',
                      onTap: () => launchTermsAndConditions(context),
                    ),
                    const SizedBox(height: 8),
                    _LegalTile(
                      title: 'سياسة الخصوصية',
                      onTap: () => launchPrivacyPolicy(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  const _SupportHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: SupportHandoffScreen._border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: SupportHandoffScreen._navy,
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'الدعم والمساعدة',
              style: TextStyle(
                color: SupportHandoffScreen._ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SupportHandoffScreen._border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: SupportHandoffScreen._navy,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: SupportHandoffScreen._ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
