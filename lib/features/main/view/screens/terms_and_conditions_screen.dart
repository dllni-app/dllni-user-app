import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/legal_links_launcher.dart';

@AutoRoutePage(path: '/termsAndConditions')
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            _LegalHeader(onBack: context.pop),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                children: [
                  const _LegalIntroCard(),
                  const SizedBox(height: 14),
                  _LegalLinkCard(
                    icon: Icons.description_outlined,
                    title: 'الشروط والأحكام',
                    subtitle: 'افتح النسخة الرسمية الحالية للشروط والأحكام.',
                    onTap: () => launchTermsAndConditions(context),
                  ),
                  const SizedBox(height: 12),
                  _LegalLinkCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    subtitle: 'اطّلع على سياسة الخصوصية الرسمية للتطبيق.',
                    onTap: () => launchPrivacyPolicy(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  const _LegalHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF172554),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'الشروط والخصوصية',
              style: TextStyle(
                color: Colors.white,
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

class _LegalIntroCard extends StatelessWidget {
  const _LegalIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: const Column(
        children: [
          Icon(Icons.gavel_rounded, size: 38, color: Color(0xFF172554)),
          SizedBox(height: 12),
          Text(
            'المستندات القانونية الرسمية',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF172033),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'تفتح الروابط التالية النسخ الرسمية الحالية المنشورة للتطبيق خارج التطبيق.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalLinkCard extends StatelessWidget {
  const _LegalLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF172554)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
