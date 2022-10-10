import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:souvenir/providers/scanner_state_provider.dart';
import 'package:souvenir/utils/helpers.dart';
import 'package:souvenir/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionStatus extends StatefulWidget {
  final String signature;
  const TransactionStatus({super.key, required this.signature});

  @override
  State<TransactionStatus> createState() => _TransactionStatusState();
}

class _TransactionStatusState extends State<TransactionStatus> {
  //
  SignatureStatus? _transactionStatus;
  bool isConfirmed = false;

  RpcClient rpcClient = RpcClient("https://api.devnet.solana.com");
  TextStyle textStyle = const TextStyle(
      color: Colors.blue, fontSize: 22, fontWeight: FontWeight.w900);
  TextStyle textStyle2 = const TextStyle(
    color: Colors.grey,
    fontSize: 30,
    fontWeight: FontWeight.w500,
  );

  getTransactionStatus() async {
    while (!isConfirmed) {
      List<SignatureStatus?> status =
          await rpcClient.getSignatureStatuses([widget.signature]);

      try {
        setState(() {
          _transactionStatus = status[0]!;
        });

        if (_transactionStatus?.confirmationStatus == Commitment.finalized) {
          setState(() {
            isConfirmed = true;
            return;
          });
        }
      } catch (e) {
        logger.e(e);
      }
      await delay(100);
    }
  }

  @override
  void initState() {
    getTransactionStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState =
        Provider.of<ScannerStateProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Status'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: !isConfirmed
              ? [
                  Text(
                    "Confirmations: ${_transactionStatus?.confirmations ?? 0}",
                    style: textStyle,
                  ),
                ]
              : [
                  Text(
                    "Status: ${_transactionStatus?.confirmationStatus}",
                    style: textStyle,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      launchUrl(
                          Uri.parse(
                              "https://explorer.solana.com/tx/${widget.signature}?cluster=devnet"),
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text("View it on Solana Explorer"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      scannerState.updateStatus(false);
                      scannerState.updateIntializer(false);
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"),
                  ),
                ],
        ),
      ),
    );
  }
}
