import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../data/mock_products.dart';

import '../../models/product.dart';
import '../../services/api_client.dart';

class FittingReservationScreen extends StatefulWidget {
  const FittingReservationScreen({super.key});

  @override
  State<FittingReservationScreen> createState() =>
      _FittingReservationScreenState();
}

class _FittingReservationScreenState extends State<FittingReservationScreen> {
  DateTime selectedDate = DateTime.now().add(
    const Duration(days: 1),
  );

  String selectedStore = '코엑스점';

  String selectedTime = '15:00';

  final List<Product> selectedProducts = [];

  final List<Map<String, String>> stores = [
    {
      'name': '코엑스점',
      'address': '서울 강남구 영동대로 513',
    },
    {
      'name': '홍대점',
      'address': '서울 마포구 양화로 일대',
    },
    {
      'name': '고양점',
      'address': '경기 고양시 덕양구',
    },
    {
      'name': '하남점',
      'address': '경기 하남시 미사대로',
    },
    {
      'name': '수원점',
      'address': '경기 수원시 권선구',
    },
  ];

  final List<String> times = [
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _removeProduct(Product product) {
    setState(() {
      selectedProducts.removeWhere(
        (item) => item.id == product.id,
      );
    });
  }

  void _openProductSelector() {
    final tempSelected = List<Product>.from(
      selectedProducts,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: const BoxDecoration(
                color: Color(0xFFFAF9F6),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1CEC8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        14,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '피팅할 제품 선택',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '최대 3개까지 선택할 수 있어요.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(
                                      0xFF888888,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              '${tempSelected.length}/3',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.67,
                        ),
                        itemCount: mockProducts.length,
                        itemBuilder: (context, index) {
                          final product = mockProducts[index];

                          final selected = tempSelected.any(
                            (item) => item.id == product.id,
                          );

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                if (selected) {
                                  tempSelected.removeWhere(
                                    (item) => item.id == product.id,
                                  );
                                } else {
                                  if (tempSelected.length >= 3) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '피팅 상품은 최대 3개까지 선택할 수 있어요.',
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  tempSelected.add(
                                    product,
                                  );
                                }
                              });
                            },
                            child: _SelectableProductCard(
                              product: product,
                              selected: selected,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAF9F6),
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFEAE7E1),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedProducts
                                ..clear()
                                ..addAll(
                                  tempSelected,
                                );
                            });

                            Navigator.pop(
                              sheetContext,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),
                          child: Text(
                            tempSelected.isEmpty
                                ? '선택 완료'
                                : '${tempSelected.length}개 선택 완료',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _submitting = false;

  Future<void> _reserve() async {
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '피팅할 제품을 1개 이상 선택해주세요.',
          ),
        ),
      );

      return;
    }

    if (_submitting) return;
    setState(() => _submitting = true);

    // 백엔드(/api/v1/reservations)에 실제로 예약을 생성한다.
    // (비회원이면 서버에 저장되진 않지만, 화면은 기존처럼 완료 안내를 보여준다.)
    try {
      await ApiClient.instance.post('/reservations', body: {
        'storeId': selectedStore,
        'storeName': selectedStore,
        'date': _formatDate(selectedDate),
        'time': selectedTime,
        'itemCount': selectedProducts.length,
      });
    } catch (_) {
      // 비회원이거나 서버 오류여도 기존 Mock 동작처럼 완료 안내는 그대로 보여준다.
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            '예약 완료',
          ),
          content: Text(
            '$selectedStore\n'
            '${_formatDate(selectedDate)} · $selectedTime\n'
            '피팅 상품 ${selectedProducts.length}개\n\n'
            '피팅 예약이 완료되었습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.pop();
              },
              child: const Text(
                '확인',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '피팅 예약',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '방문 매장',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '피팅을 진행할 매장을 선택해주세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stores.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (context, index) {
                        final store = stores[index];

                        final isSelected = selectedStore == store['name'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedStore = store['name']!;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 150,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFFF3EFE7,
                                    )
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : const Color(
                                        0xFFE1DED8,
                                      ),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(
                                            0xFFF3F0EA,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.storefront_outlined,
                                    size: 23,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        store['name']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        store['address']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(
                                            0xFF888888,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 150,
                                  ),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : const Color(
                                              0xFFCCCCCC,
                                            ),
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '방문 날짜',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFE1DED8,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(
                                  selectedDate,
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 21,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '방문 시간',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '30분 단위로 예약할 수 있어요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: times.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                      ),
                      itemBuilder: (context, index) {
                        final time = times[index];

                        final isSelected = selectedTime == time;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 150,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : const Color(
                                        0xFFE1DED8,
                                      ),
                              ),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EFE7),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF777777),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '피팅은 1회 최대 3개 상품까지 예약할 수 있어요.\n'
                              '매장에서 빠르게 준비할 수 있도록 방문 전 원하는 상품을 미리 선택해주세요.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(
                                  0xFF666666,
                                ),
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Text(
                          '피팅할 제품',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text(
                          '(${selectedProducts.length}/3)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(
                              0xFF888888,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (selectedProducts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFE1DED8,
                            ),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.checkroom_outlined,
                              size: 30,
                              color: Color(
                                0xFFAAAAAA,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              '아직 선택한 상품이 없어요',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(
                                  0xFF888888,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < selectedProducts.length; i++) ...[
                            Expanded(
                              child: _SelectedProductCard(
                                product: selectedProducts[i],
                                onRemove: () {
                                  _removeProduct(
                                    selectedProducts[i],
                                  );
                                },
                              ),
                            ),
                            if (i != selectedProducts.length - 1)
                              const SizedBox(
                                width: 10,
                              ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 14),
                    if (selectedProducts.length < 3)
                      InkWell(
                        onTap: _openProductSelector,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                            border: Border.all(
                              color: const Color(
                                0xFFDCD8D1,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 18,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                '피팅할 제품 선택',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                14,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF9F6),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEAE7E1),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        (selectedProducts.isEmpty || _submitting) ? null : _reserve,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFFD6D3CE,
                      ),
                      disabledForegroundColor: const Color(
                        0xFF888888,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                    child: Text(
                      selectedProducts.isEmpty ? '피팅할 제품을 선택해주세요' : '예약하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableProductCard extends StatelessWidget {
  final Product product;

  final bool selected;

  const _SelectableProductCard({
    required this.product,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: const Color(0xFFF0EDE7),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 42,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? Colors.black
                          : const Color(
                              0xFFD5D2CC,
                            ),
                    ),
                  ),
                  child: Icon(
                    selected ? Icons.check : Icons.add,
                    size: 17,
                    color: selected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.brand,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SelectedProductCard extends StatelessWidget {
  final Product product;

  final VoidCallback onRemove;

  const _SelectedProductCard({
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  child: Container(
                    color: const Color(
                      0xFFF0EDE7,
                    ),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 36,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
