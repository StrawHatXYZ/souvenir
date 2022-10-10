import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:souvenir/providers/wallet_state_provider.dart';
import 'package:souvenir/utils/logger.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletConnect extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;
  const WalletConnect({super.key, required this.phantomConnectInstance});

  @override
  State<WalletConnect> createState() => _WalletConnectState();
}

class _WalletConnectState extends State<WalletConnect> {
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks(context);
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  void _handleIncomingLinks(context) async {
    logger.i("Handle incoming links");
    final provider = Provider.of<WalletStateProvider>(context, listen: false);
    try {
      sub = uriLinkStream.listen((Uri? link) {
        if (!mounted) return;
        Map<String, String> params = link?.queryParameters ?? {};
        logger.i("Params: $params");
        if (params.containsKey("errorCode")) {
          _showSnackBar(context,
              params["errorMessage"] ?? "Error connecting wallet", "error");
          logger.e(params["errorMessage"]);
        } else {
          switch (link?.path) {
            case '/connected':
              if (widget.phantomConnectInstance.createSession(params)) {
                provider.updateConnection(true);
                _showSnackBar(context, "Connected to Wallet", "success");
              } else {
                _showSnackBar(context, "Error connecting to Wallet", "error");
              }
              break;

            default:
              logger.i('unknown');
              _showSnackBar(context, "Unknown Redirect", "error");
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

  connectWallet() async {
    Uri launchUri = widget.phantomConnectInstance
        .generateConnectUri(cluster: 'devnet', redirect: '/connected');
    logger.d(launchUri);
    await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/images/welcome.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hello Traveller",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF324bcd),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: const Text(
                      "Welcome to Souvenir, Travel the world and collect souvenirs. Show case your travel NFTs to world.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0x99324bcd),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: connectWallet,
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    child: const Text("Connect Wallet"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showSnackBar(BuildContext context, String message, String variant) {
    Color backgroundColor = Colors.blueAccent;
    if (variant == 'error') {
      backgroundColor = Colors.red.shade400;
    } else if (variant == 'success') {
      backgroundColor = Colors.green.shade500;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        backgroundColor: backgroundColor,
        content: Text(message),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
