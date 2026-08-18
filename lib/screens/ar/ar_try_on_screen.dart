import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../data/mock_products.dart';

import '../../models/product.dart';

import '../../services/ar_session_provider.dart';

import '../../services/wishlist_provider.dart';

import '../../theme/app_colors.dart';

import '../../utils/formatters.dart';

/// AR Try-On

///

/// 현재는 실제 Unity AR 연동 전 단계의 Mock 화면.

/// 추후 Unity AR 화면으로 교체할 수 있도록 독립 Screen으로 구성.

///

/// 유지 기능

/// - AR 체험 시간 기록

/// - 컬러 변경

/// - 상품 변경

/// - 찜

/// - 촬영 Mock

///

/// 제거

/// - 하단 상품 이미지 캐러셀

/// - 중앙 Mock 상품 이미지

/// - Rotate 테스트 UI

class ArTryOnScreen extends StatefulWidget {
  final String productId;

  final String? initialColor;

  const ArTryOnScreen({
    super.key,
    required this.productId,
    this.initialColor,
  });

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen> {
  late String _currentProductId;

  late String _currentColor;

  Timer? _tick;

  Duration _elapsed = Duration.zero;

  bool _sessionEnded = false;

  @override
  void initState() {
    super.initState();

    _currentProductId = widget.productId;

    final product = findMockProductById(
      _currentProductId,
    );

    _currentColor = widget.initialColor ?? product?.colors.first ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _startSession();
    });
  }

  void _startSession() {
    _elapsed = Duration.zero;

    context.read<ArSessionProvider>().start(
          _currentProductId,
        );

    _tick?.cancel();

    _tick = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        final active = context.read<ArSessionProvider>().active;

        if (active == null) return;

        setState(() {
          _elapsed = active.duration;
        });
      },
    );
  }

  void _endSession() {
    if (_sessionEnded) return;

    _sessionEnded = true;

    _tick?.cancel();

    context.read<ArSessionProvider>().end();
  }

  void _switchProduct(Product product) {
    if (product.id == _currentProductId) {
      return;
    }

    _endSession();

    setState(() {
      _currentProductId = product.id;

      _currentColor = product.colors.first;

      _sessionEnded = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _startSession();
    });
  }

  void _exit() {
    _endSession();

    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _tick?.cancel();

    if (!_sessionEnded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ArSessionProvider>().end();
      });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = findMockProductById(
      _currentProductId,
    );

    final arProducts =
        mockProducts.where((product) => product.arAvailable).toList();

    final isFavorite = context.select<WishlistProvider, bool>(
      (wishlist) => wishlist.isFavorite(_currentProductId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _endSession();

        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            //

            // AR CAMERA AREA

            //

            const _CameraPreviewPlaceholder(),

            //

            // TOP UI

            //

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _OverlayIconButton(
                          icon: Icons.close,
                          onTap: _exit,
                        ),
                        const Spacer(),
                        _TimerChip(
                          elapsed: _elapsed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (product != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.overlayChip,
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.brand,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                '${product.name} · $_currentColor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                Formatters.price(
                                  product.price,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            //

            // RIGHT ACTION BUTTONS

            //

            Positioned(
              right: 16,
              bottom: 170,
              child: Column(
                children: [
                  _OverlayIconButton(
                    icon: Icons.palette_outlined,
                    label: '컬러',
                    onTap: product == null
                        ? null
                        : () => _showColorSheet(
                              context,
                              product,
                            ),
                  ),
                  const SizedBox(height: 14),
                  _OverlayIconButton(
                    icon: Icons.sync_alt,
                    label: '상품 변경',
                    onTap: () => _showProductSheet(
                      context,
                      arProducts,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _OverlayIconButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    label: '찜',
                    iconColor: isFavorite ? AppColors.error : Colors.white,
                    onTap: () {
                      context.read<WishlistProvider>().toggle(
                            _currentProductId,
                          );
                    },
                  ),
                ],
              ),
            ),

            //

            // BOTTOM CAMERA BUTTON

            //

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 32,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.82,
                      ),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '촬영되었습니다 (Mock)',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
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

  void _showColorSheet(
    BuildContext context,
    Product product,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in product.colors)
                  ChoiceChip(
                    label: Text(color),
                    selected: color == _currentColor,
                    onSelected: (_) {
                      setState(() {
                        _currentColor = color;
                      });

                      Navigator.pop(
                        sheetContext,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductSheet(
    BuildContext context,
    List<Product> arProducts,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              itemCount: arProducts.length,
              itemBuilder: (context, index) {
                final product = arProducts[index];

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    child: Image.network(
                      product.image,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width: 44,
                          height: 44,
                          color: AppColors.divider,
                          child: const Icon(
                            Icons.image_outlined,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    product.name,
                  ),
                  subtitle: Text(
                    Formatters.price(
                      product.price,
                    ),
                  ),
                  selected: product.id == _currentProductId,
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _switchProduct(
                      product,
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// 실제 Unity AR 카메라가 들어갈 자리.

///

/// 현재는 상품 사진을 띄우지 않고

/// 카메라 Preview 영역만 Mock으로 표현한다.

class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B1B1B),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 220,
            color: Colors.white10,
          ),
          Positioned(
            bottom: 230,
            child: Text(
              'AR CAMERA PREVIEW',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;

  final String? label;

  final VoidCallback? onTap;

  final Color? iconColor;

  const _OverlayIconButton({
    required this.icon,
    this.label,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.overlayChip,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 20,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final Duration elapsed;

  const _TimerChip({
    required this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlayChip,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            size: 10,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 6),
          Text(
            Formatters.duration(
              elapsed,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
