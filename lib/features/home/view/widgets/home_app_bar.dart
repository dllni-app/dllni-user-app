import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      "مرحباً بعودتك 👋",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                    Text(
                      "أحمد محمد",
                      style: TextStyle(
                        color: Color(0xFF1E2A78),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 28 / 18,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                customBorder: CircleBorder(),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFF3F4F6)),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.bell,
                    size: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _HomeSearchField(onSearch: (search) {}, onVoiceTap: () {}),
        ],
      ),
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.onSearch, required this.onVoiceTap});
  final void Function(String search) onSearch;
  final void Function() onVoiceTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: onSearch,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 11),
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        hintText: "ابحث عن مطعم أو وجبة...",
        hintStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 26 / 14,
        ),
        prefixIconConstraints: BoxConstraints(maxWidth: 50),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 16, left: 12),
          child: Icon(Icons.search, size: 18, color: Color(0xFF1E2A78)),
        ),
        suffixIconConstraints: BoxConstraints(maxWidth: 44),
        suffixIcon: Padding(
          padding: EdgeInsets.only(left: 16),
          child: InkWell(
            onTap: onVoiceTap,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0x1A1E2A78),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Icon(Icons.mic, size: 14, color: Color(0xFF1E2A78)),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
