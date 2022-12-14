import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hypha_wallet/core/error_handler/model/hypha_error.dart';
import 'package:hypha_wallet/core/error_handler/model/hypha_error_type.dart';
import 'package:hypha_wallet/core/logging/log_helper.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';
import 'package:hypha_wallet/design/themes/extensions/theme_extension_provider.dart';
import 'package:hypha_wallet/ui/blocs/error_handler/error_handler_bloc.dart';
import 'package:hypha_wallet/ui/home_page/interactor/home_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget();

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  bool isActive = false;
  double _width = 50;
  double _heightFactor = .30;
  Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive
          ? null
          : () {
              // context.read<HomeBloc>().add(HomeEvent.onQRCodeScanned('code'));
              setState(() {
                isActive = true;
                _heightFactor = 0.40;
              });
            },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/graphics/qr_back.png'), fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(30),
          ),
          height: Get.height * _heightFactor,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: isActive
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: MobileScanner(
                            allowDuplicates: false,
                            controller: MobileScannerController(
                              facing: CameraFacing.back,
                              torchEnabled: false,
                            ),
                            onDetect: (barcode, args) {
                              if (barcode.rawValue == null) {
                                LogHelper.d('Failed to scan Barcode');
                                context.read<ErrorHandlerBloc>().add(ErrorHandlerEvent.onError(HyphaError(
                                      message: 'Failed to scan QR code',
                                      type: HyphaErrorType.generic,
                                    )));
                              } else {
                                final String code = barcode.rawValue!;
                                LogHelper.d('Barcode found! $code');
                                context.read<HomeBloc>().add(HomeEvent.onQRCodeScanned(code));
                              }
                            },
                          ),
                        ),
                      ),
                      Align(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isActive = false;
                              _heightFactor = 0.30;
                            });
                          },
                          icon: Icon(Icons.add_circle, size: 36, color: HyphaColors.primaryBlu),
                        ),
                        alignment: Alignment.bottomCenter,
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 80, color: HyphaColors.primaryBlu),
                        SizedBox(height: 12),
                        Text('Scan QR', style: context.hyphaTextTheme.smallTitles.copyWith(color: HyphaColors.white)),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
