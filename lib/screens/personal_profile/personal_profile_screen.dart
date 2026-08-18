import 'package:flutter/material.dart';

class PersonalProfileScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const PersonalProfileScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<PersonalProfileScreen> createState() =>
      _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  String bodyType = '슬림 체형';
  String personalColor = '웜톤 (가을)';
  String styleType = '미니멀 / 시크';
  String lifestyle = '직장인';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    'AI 퍼스널 프로필 생성',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '1/4',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A8A8A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                '당신의 취향을 알려주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 34),

              _ProfileItem(
                title: '체형',
                value: bodyType,
                onTap: () {
                  _showSelectionSheet(
                    title: '체형',
                    options: const [
                      '슬림 체형',
                      '보통 체형',
                      '볼륨 체형',
                    ],
                    currentValue: bodyType,
                    onSelected: (value) {
                      setState(() {
                        bodyType = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 14),

              _ProfileItem(
                title: '퍼스널 컬러',
                value: personalColor,
                onTap: () {
                  _showSelectionSheet(
                    title: '퍼스널 컬러',
                    options: const [
                      '웜톤 (봄)',
                      '웜톤 (가을)',
                      '쿨톤 (여름)',
                      '쿨톤 (겨울)',
                    ],
                    currentValue: personalColor,
                    onSelected: (value) {
                      setState(() {
                        personalColor = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 14),

              _ProfileItem(
                title: '스타일 성향',
                value: styleType,
                onTap: () {
                  _showSelectionSheet(
                    title: '스타일 성향',
                    options: const [
                      '미니멀 / 시크',
                      '캐주얼',
                      '스트릿',
                      '클래식',
                      '스포티',
                    ],
                    currentValue: styleType,
                    onSelected: (value) {
                      setState(() {
                        styleType = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 14),

              _ProfileItem(
                title: '라이프스타일',
                value: lifestyle,
                onTap: () {
                  _showSelectionSheet(
                    title: '라이프스타일',
                    options: const [
                      '직장인',
                      '대학생',
                      '프리랜서',
                      '학생',
                      '기타',
                    ],
                    currentValue: lifestyle,
                    onSelected: (value) {
                      setState(() {
                        lifestyle = value;
                      });
                    },
                  );
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '프로필 생성하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F6F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                ...options.map((option) {
                  final selected = option == currentValue;

                  return InkWell(
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1EEE8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 74,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF999999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
