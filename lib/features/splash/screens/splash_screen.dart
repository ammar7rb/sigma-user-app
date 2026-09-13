import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  // late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    // bool firstTime = true;
    // _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   if(!firstTime) {
    //     bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
    //     isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       backgroundColor: isNotConnected ? Colors.red : Colors.green,
    //       duration: Duration(seconds: isNotConnected ? 6000 : 3),
    //       content: Text(isNotConnected ? getTranslated('no_connection', context)! : getTranslated('connected', context)!,
    //         textAlign: TextAlign.center)));
    //     if(!isNotConnected) {
    //       _route();
    //     }
    //   }
    //   firstTime = false;
    // });

    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    // Keep the branded entrance visible long enough to feel intentional while
    // still keeping the application startup fast.
    await Future.delayed(const Duration(milliseconds: 1500));
    _route();
  }

  @override
  void dispose() {
    super.dispose();
    // _onConnectivityChanged.cancel();
  }

  void _route() {
    // connectivity_plus streams can fail before the browser plugin is ready.
    // The API call itself remains the source of truth for Web connectivity.
    if (!kIsWeb) {
      NetworkInfo.checkConnectivity(context);
    }
    Provider.of<SplashController>(context, listen: false).initConfig(
      context,
      (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(
          Get.context!,
          listen: false,
        ).configModel?.userAppVersionControl;
        if (!kIsWeb && Platform.isAndroid) {
          minimumVersion = appVersion?.forAndroid?.version ?? '0';
        } else if (!kIsWeb && Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(
          Get.context!,
          listen: false,
        ).initSharedPrefData();
        // Timer(const Duration(seconds: 2), () {
        final config = Provider.of<SplashController>(
          Get.context!,
          listen: false,
        ).configModel;

        Future.delayed(const Duration(milliseconds: 0)).then((_) {
          if (compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
            RouterHelper.getUpdateRoute(
              action: RouteAction.pushReplacement,
            );
          } else if (config?.maintenanceModeData?.maintenanceStatus == 1 &&
              config?.maintenanceModeData?.selectedMaintenanceSystem
                      ?.customerApp ==
                  1 &&
              !Provider.of<SplashController>(
                Get.context!,
                listen: false,
              ).isConfigCall) {
            RouterHelper.getMaintenanceRoute(
              action: RouteAction.pushReplacement,
            );
          } else if (Provider.of<AuthController>(
            Get.context!,
            listen: false,
          ).isLoggedIn()) {
            Provider.of<AuthController>(
              Get.context!,
              listen: false,
            ).updateToken(Get.context!);
            if (widget.body != null) {
              if (widget.body!.type == 'order') {
                RouterHelper.getOrderDetailsScreenRoute(
                  action: RouteAction.pushReplacement,
                  orderId: widget.body!.orderId!,
                );
              } else if (widget.body!.type == 'notification') {
                RouterHelper.getNotificationRoute(
                  action: RouteAction.pushReplacement,
                );
              } else if (widget.body!.type == 'wallet') {
                RouterHelper.getWalletRoute(
                  action: RouteAction.pushReplacement,
                  isBackButtonExist: true,
                );
              } else if (widget.body!.type == 'chatting') {
                RouterHelper.getInboxScreenRoute(
                  action: RouteAction.pushReplacement,
                  isBackButtonExist: true,
                  fromNotification: true,
                  initIndex:
                      widget.body!.messageKey == 'message_from_delivery_man'
                          ? 0
                          : 1,
                );
              } else if (widget.body!.type == 'product_restock_update') {
                RouterHelper.getProductDetailsRoute(
                  action: RouteAction.pushReplacement,
                  productId: int.parse(widget.body!.productId!),
                  slug: widget.body!.slug,
                  isNotification: true,
                );
              } else {
                RouterHelper.getNotificationRoute(
                  action: RouteAction.pushReplacement,
                  fromNotification: true,
                );
              }
            } else {
              // Navigator.of(Get.context!).pushReplacement(
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
              //     transitionDuration: Duration.zero, // Removes transition duration
              //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
              //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
              //   ),
              // );

              RouterHelper.getDashboardRoute(
                action: RouteAction.pushReplacement,
              );
            }
          } else if (Provider.of<SplashController>(
            Get.context!,
            listen: false,
          ).showIntro()!) {
            RouterHelper.getOnboardingRoute(
              action: RouteAction.pushReplacement,
              indicatorColor: Provider.of<ThemeController>(
                Get.context!,
                listen: false,
              ).darkTheme
                  ? Theme.of(Get.context!).colorScheme.onTertiary
                  : Theme.of(Get.context!).hintColor,
              selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
            );
          } else {
            if (Provider.of<AuthController>(
                      Get.context!,
                      listen: false,
                    ).getGuestToken() !=
                    null &&
                Provider.of<AuthController>(
                      Get.context!,
                      listen: false,
                    ).getGuestToken() !=
                    '1') {
              // Navigator.of(Get.context!).pushReplacement(
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
              //     transitionDuration: Duration.zero, // Removes transition duration
              //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
              //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
              //   ),
              // );

              RouterHelper.getDashboardRoute(
                action: RouteAction.pushReplacement,
              );
            } else {
              Provider.of<AuthController>(
                Get.context!,
                listen: false,
              ).getGuestIdUrl();
              RouterHelper.getDashboardRoute(
                action: RouteAction.pushReplacement,
              );

              // Navigator.of(Get.context!).pushReplacement(
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
              //     transitionDuration: Duration.zero, // Removes transition duration
              //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
              //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
              //   ),
              // );
            }
          }
        });
        //  });
      },
      (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(
          Get.context!,
          listen: false,
        ).configModel?.userAppVersionControl;
        if (!kIsWeb && Platform.isAndroid) {
          minimumVersion = appVersion?.forAndroid?.version ?? '0';
        } else if (!kIsWeb && Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(
          Get.context!,
          listen: false,
        ).initSharedPrefData();
        // Timer(const Duration(seconds: 1), () {
        final config = Provider.of<SplashController>(
          Get.context!,
          listen: false,
        ).configModel;
        if (compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
          RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
        } else if (config?.maintenanceModeData?.maintenanceStatus == 1 &&
            config?.maintenanceModeData?.selectedMaintenanceSystem
                    ?.customerApp ==
                1 &&
            !config!.localMaintenanceMode!) {
          RouterHelper.getMaintenanceRoute(
            action: RouteAction.pushReplacement,
          );
        } else if (Provider.of<AuthController>(
              Get.context!,
              listen: false,
            ).isLoggedIn() &&
            !configModel!.hasLocaldb!) {
          Provider.of<AuthController>(
            Get.context!,
            listen: false,
          ).updateToken(Get.context!);
          if (widget.body != null) {
            if (widget.body!.type == 'order') {
              RouterHelper.getOrderDetailsScreenRoute(
                action: RouteAction.pushReplacement,
                orderId: widget.body!.orderId!,
              );
            } else if (widget.body!.type == 'notification') {
              RouterHelper.getNotificationRoute(
                action: RouteAction.pushReplacement,
              );
            } else if (widget.body!.type == 'wallet') {
              RouterHelper.getWalletRoute(
                action: RouteAction.pushReplacement,
                isBackButtonExist: true,
              );
            } else if (widget.body!.type == 'chatting') {
              RouterHelper.getInboxScreenRoute(
                action: RouteAction.push,
                isBackButtonExist: true,
                fromNotification: true,
                initIndex:
                    widget.body!.messageKey == 'message_from_delivery_man'
                        ? 0
                        : 1,
              );
            } else if (widget.body!.type == 'product_restock_update') {
              RouterHelper.getProductDetailsRoute(
                action: RouteAction.push,
                productId: int.parse(widget.body!.productId!),
                slug: widget.body!.slug,
                isNotification: true,
              );
            } else {
              RouterHelper.getNotificationRoute(
                action: RouteAction.pushReplacement,
                fromNotification: true,
              );
            }
          } else {
            RouterHelper.getDashboardRoute(
              action: RouteAction.pushReplacement,
            );
          }
        } else if (Provider.of<SplashController>(
              Get.context!,
              listen: false,
            ).showIntro()! &&
            !configModel!.hasLocaldb!) {
          RouterHelper.getOnboardingRoute(
            action: RouteAction.pushReplacement,
            indicatorColor: Provider.of<ThemeController>(
              Get.context!,
              listen: false,
            ).darkTheme
                ? Theme.of(Get.context!).colorScheme.onTertiary
                : Theme.of(Get.context!).hintColor,
            selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
          );
        } else if (!configModel!.hasLocaldb! ||
            (configModel.hasLocaldb! &&
                configModel.localMaintenanceMode! &&
                !(config?.maintenanceModeData?.maintenanceStatus == 1 &&
                    config?.maintenanceModeData?.selectedMaintenanceSystem
                            ?.customerApp ==
                        1))) {
          if (Provider.of<AuthController>(
                    Get.context!,
                    listen: false,
                  ).getGuestToken() !=
                  null &&
              Provider.of<AuthController>(
                    Get.context!,
                    listen: false,
                  ).getGuestToken() !=
                  '1') {
            RouterHelper.getDashboardRoute(
              action: RouteAction.pushReplacement,
            );
          } else {
            Provider.of<AuthController>(
              Get.context!,
              listen: false,
            ).getGuestIdUrl();
            RouterHelper.getDashboardRoute(
              action: RouteAction.pushNamedAndRemoveUntil,
            );
          }
        }
        // });
      },
    ).then((bool isSuccess) {
      if (isSuccess) {}
    });
  }

  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part =
          i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part =
          i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Provider.of<SplashController>(context).hasConnection
          ? SplashWidget()
          : const NoInternetOrDataScreenWidget(
              isNoInternet: true,
              child: SplashScreen(),
            ),
    );
  }
}

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _backgroundOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..forward();

    _backgroundOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .55, curve: Curves.easeOut),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.18, .82, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: .94, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.18, 1, curve: Curves.easeOutCubic),
      ),
    );
    _logoOffset =
        Tween<Offset>(begin: const Offset(0, .09), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.18, 1, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF001C68),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: ColoredBox(
        color: const Color(0xFF00349A),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: _backgroundOpacity,
              child: Image.asset(
                'assets/images/sigma_splash_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x14001255),
                    Color(0x00001255),
                    Color(0x30001255),
                  ],
                  stops: [0, .46, 1],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final logoWidth = (constraints.maxWidth * .74).clamp(
                    250.0,
                    400.0,
                  );
                  return Align(
                    alignment: Alignment.center,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: SlideTransition(
                        position: _logoOffset,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: RepaintBoundary(
                            child: SizedBox(
                              width: logoWidth,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  Images.logoWithNameImage,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: const Center(
                  child: SizedBox(
                    width: 34,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      backgroundColor: Color(0x30FFFFFF),
                      color: Colors.white,
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
