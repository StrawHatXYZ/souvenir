import 'package:flutter/material.dart';
import 'package:souvenir/screens/main_screen.dart';
import 'package:souvenir/components/views/mint_nft/mint_nft.dart';
import 'package:souvenir/components/views/screens.dart';
import 'package:souvenir/components/views/sign_and_send_transaction/sign_and_send_tx.dart';
import 'package:souvenir/providers/screen_provider.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:provider/provider.dart';

class Connected extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;
  const Connected({super.key, required this.phantomConnectInstance});

  @override
  State<Connected> createState() => _ConnectedState();
}

class _ConnectedState extends State<Connected> {
  @override
  Widget build(BuildContext context) {
    final scrrenProvider = Provider.of<ScreenProvider>(context, listen: true);

    return Container(child: _buildScreen(scrrenProvider.currentScreen));
  }

  Widget _buildScreen(Screens screen) {
    switch (screen) {
      case Screens.send:
        return SignAndSendTransactionScreen(
            phantomConnectInstance: widget.phantomConnectInstance);
      case Screens.scan:
        return MintNFTScreen(
            phantomConnectInstance: widget.phantomConnectInstance);
      default:
        return const MainScreen();
    }
  }
}
