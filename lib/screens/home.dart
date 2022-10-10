import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:souvenir/components/connected/connected.dart';
import 'package:souvenir/components/views/mint_nft/mint_nft.dart';
import 'package:souvenir/components/views/settings/settings.dart';
import 'package:souvenir/components/views/transaction_status/transaction_status.dart';
import 'package:souvenir/components/sidebar/sidebar.dart';
import 'package:souvenir/components/wallet_connect/wallet_connect.dart';
import 'package:souvenir/components/widgets/colors.dart';
import 'package:souvenir/providers/wallet_state_provider.dart';
import 'package:souvenir/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:souvenir/utils/scafold_message.dart';
import 'package:uni_links/uni_links.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final phantomConnectInstance = PhantomConnect(
    appUrl: "https://solgallery.vercel.app",
    deepLink: "dapp://souvenir.io",
  );

  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks(context);
  }

  @override
  void dispose() {
    logger.w("Dispose");
    super.dispose();
    sub.cancel();
  }

  int selectedIndex = 0;

  void _handleIncomingLinks(context) async {
    final provider = Provider.of<WalletStateProvider>(context, listen: false);
    try {
      sub = uriLinkStream.listen((Uri? link) {
        if (!mounted) return;
        Map<String, String> params = link?.queryParameters ?? {};
        logger.i("Params: $params");
        if (params.containsKey("errorCode")) {
          showSnackBar(context,
              params["errorMessage"] ?? "Error connecting wallet", "error");
          logger.e(params["errorMessage"]);
        } else {
          switch (link?.path) {
            case '/connected':
              if (phantomConnectInstance.createSession(params)) {
                provider.updateConnection(true);
                showSnackBar(context, "Connected to Wallet", "success");
              } else {
                showSnackBar(context, "Error connecting to Wallet", "error");
              }
              break;
            case '/disconnected':
              setState(() {
                provider.updateConnection(false);
              });
              showSnackBar(context, "Wallet Disconnected", "success");
              break;
            case '/signAndSendTransaction':
              var data = phantomConnectInstance.decryptPayload(
                  data: params["data"]!, nonce: params["nonce"]!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionStatus(
                    signature: data['signature'],
                  ),
                ),
              );
              break;
            default:
              logger.i('unknown');
              showSnackBar(context, "Unknown Redirect", "error");
          }
        }
      }, onError: (err) {
        logger.e('OnError Error: $err');
      });
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      logger.e("Error occured PlatfotmException");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletStateProvider>(context, listen: true);

    List<Widget> bodyItems = [
      Connected(phantomConnectInstance: phantomConnectInstance),
      MintNFTScreen(phantomConnectInstance: phantomConnectInstance),
      Settings(phantomConnectInstance: phantomConnectInstance)
    ];

    return provider.isConnected
        ? Scaffold(
            bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: AppColor.primaryColor,
                currentIndex: selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code),
                    label: "Scan QR",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: "Settings",
                  ),
                ],
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                }),
            drawer: Sidebar(phantomConnectInstance: phantomConnectInstance),
            body: Builder(
              builder: (context) {
                return bodyItems[selectedIndex];
              },
            ),
          )
        : Scaffold(
            body: Builder(
              builder: (context) {
                return WalletConnect(
                  phantomConnectInstance: phantomConnectInstance,
                );
              },
            ),
          );
  }
}
