import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:souvenir/components/widgets/colors.dart';
import 'package:souvenir/components/widgets/textwidget.dart';
import 'package:souvenir/utils/constants.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.white),
      child: ListView(
        children: [
          customAppBar(context),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: destination.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(left: index == 0 ? 30 : 0),
                child:
                    destinationCard(context, destination[index]['imagePath']),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 25, right: 25, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                PrimaryText(
                  text: 'Hot Destinations',
                  size: 24,
                ),
                PrimaryText(text: 'More', size: 16, color: Colors.white24),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hotDestination.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(left: index == 0 ? 30 : 0),
                child: hotDestinationCard(
                    hotDestination[index]['imagePath'],
                    hotDestination[index]['placeName'],
                    hotDestination[index]['placeCount'],
                    context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget hotDestinationCard(String? imagePath, String? placeName,
      String? touristPlaceCount, BuildContext context) {
    return GestureDetector(
      child: Stack(children: [
        Hero(
          tag: imagePath ?? "",
          child: Container(
            height: 200,
            width: 140,
            margin: const EdgeInsets.only(right: 25),
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: AssetImage(imagePath ?? ""),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            height: 200,
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColor.secondaryColor, Colors.transparent]),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PrimaryText(
                    text: placeName ?? "",
                    color: Colors.white,
                    size: 15,
                    fontWeight: FontWeight.w800),
                const SizedBox(height: 4),
                PrimaryText(
                    text: touristPlaceCount ?? "",
                    color: Colors.white54,
                    size: 10,
                    fontWeight: FontWeight.w800)
              ]),
        ),
      ]),
    );
  }

  Widget destinationCard(BuildContext context, String? imagePath) {
    return GestureDetector(
      onTap: () => {
        print("Hello World"),
      },
      child: Stack(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.only(right: 20),
            width: MediaQuery.of(context).size.width - 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(imagePath ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 1.0,
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width - 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColor.secondaryColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding customAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: IconButton(
              onPressed: () => {Scaffold.of(context).openDrawer()},
              icon: SvgPicture.asset(
                "assets/icon/menu.svg",
                color: AppColor.primaryColor,
              ),
            ),
          ),
          const PrimaryText(
            text: 'Souvenir',
            size: 32,
            fontWeight: FontWeight.w700,
          ),
          const RawMaterialButton(
            constraints: BoxConstraints(minWidth: 0),
            onPressed: null,
            elevation: 2.0,
            fillColor: Colors.white10,
            padding: EdgeInsets.all(8),
            shape: CircleBorder(),
            child: Icon(Icons.search_rounded,
                color: AppColor.primaryColor, size: 30),
          )
        ],
      ),
    );
  }
}
