import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:souvenir/components/views/mint_nft/border_paint.dart';
import 'package:souvenir/components/widgets/colors.dart';
import 'package:souvenir/providers/scanner_state_provider.dart';
import 'package:souvenir/utils/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MintNFTScreen extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;

  const MintNFTScreen({super.key, required this.phantomConnectInstance});

  @override
  State<MintNFTScreen> createState() => _MintNFTScreenState();
}

class _MintNFTScreenState extends State<MintNFTScreen> {
  late String urlEndpoint;
  late String location;
  late String name;
  late int rating;
  late String description;
  late String image;

  late dynamic _scanResult;
  // Controller for the camera controls
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    cameraController.start();
  }

  // Get location data from api using the QR code
  getLocation(encoded, provider) async {
    logger.wtf("Get location data from api using the QR code");
    _scanResult = jsonDecode(encoded!);
    String url = _scanResult['endpoint'];
    logger.wtf(url);
    try {
      final response = await http.get(Uri.parse(url));
      final resBody = jsonDecode(response.body);
      logger.i(resBody);
      final data = resBody['result'];
      setState(() {
        urlEndpoint = data['url'];
        name = data['name'];
        location = data['location'];
        rating = data['rating'];
        description = data['description'];
        image = data['image'];
      });
      provider.updateIntializer(true);
    } catch (e) {
      logger.e("Error getting location data $e.toString()");
    }
  }

  void _foundQRCode(Barcode barcode, MobileScannerArguments? args,
      ScannerStateProvider provider) async {
    HapticFeedback.heavyImpact();
    if (barcode.rawValue == null) {
      debugPrint('Failed to scan Barcode');
    } else {
      final String code = barcode.rawValue!;
      logger.i('Barcode found! $code');
      await getLocation(code, provider);
    }
  }

  // The send transaction function
  sendTransax() async {
    try {
      urlEndpoint =
          '$urlEndpoint/${widget.phantomConnectInstance.userPublicKey}';
      logger.e(urlEndpoint);
      final response = await http.get(Uri.parse(urlEndpoint));
      final data = jsonDecode(response.body);
      logger.wtf(data);
      String rawdata = data['tx'];

      var launchUri =
          widget.phantomConnectInstance.generateSignAndSendTransactionUri(
        transaction: rawdata,
        redirect: '/signAndSendTransaction',
      );
      await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      logger.e("Error sending transaction $e.toString()");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScannerStateProvider>(context, listen: true);

    return Container(
      child: !provider.isinitialized
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Scan the QR code to mint the NFTs",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondaryColor,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: CustomPaint(
                    // painter: MyCustomPainter(frameSFactor: .1, padding: 10),
                    painter: BorderPainter(),
                    child: Container(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: MobileScanner(
                        allowDuplicates: false,
                        controller: cameraController,
                        onDetect: (barcode, args) async {
                          _foundQRCode(barcode, args, provider);
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: AppColor.primaryColor,
                      icon: ValueListenableBuilder(
                        valueListenable: cameraController.torchState,
                        builder: (context, state, child) {
                          switch (state) {
                            case TorchState.off:
                              return const Icon(
                                Icons.flash_off,
                                color: Colors.red,
                              );
                            case TorchState.on:
                              return const Icon(Icons.flash_on,
                                  color: Colors.yellow);
                          }
                        },
                      ),
                      iconSize: 26.0,
                      onPressed: () => cameraController.toggleTorch(),
                    ),
                    IconButton(
                      color: AppColor.primaryColor,
                      icon: ValueListenableBuilder(
                        valueListenable: cameraController.cameraFacingState,
                        builder: (context, state, child) {
                          switch (state) {
                            case CameraFacing.front:
                              return const Icon(Icons.camera_front);
                            case CameraFacing.back:
                              return const Icon(Icons.camera_rear);
                          }
                        },
                      ),
                      iconSize: 26.0,
                      onPressed: () => cameraController.switchCamera(),
                    ),
                  ],
                ),
              ],
            )
          : SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.maxFinite,
                      height: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 330,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 25,
                        left: 20,
                        right: 20,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 500,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColor.secondaryColor,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                location,
                                style: const TextStyle(
                                  color: AppColor.secondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Wrap(
                                children: List.generate(
                                    5,
                                    (index) => Icon(
                                          Icons.star,
                                          color: index < 4
                                              ? AppColor.golden
                                              : Colors.grey,
                                        )),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "($rating)",
                                style: const TextStyle(
                                  color: AppColor.secondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Description",
                            style: TextStyle(
                              color: AppColor.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              color: AppColor.black.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      children: [
                        AbsorbPointer(
                          absorbing: provider.isprocessing,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              provider.updateStatus(true);
                              sendTransax();
                            }),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: provider.isprocessing
                                    ? Colors.grey
                                    : AppColor.primaryColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  provider.isprocessing
                                      ? const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                        ),
                                  const SizedBox(width: 20),
                                  Text(
                                    provider.isprocessing
                                        ? "Please Wait..."
                                        : "Mint NFT",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
