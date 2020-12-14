import 'dart:io';
import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String localizationUseThisPicture;

  const DisplayPictureScreen(
      {Key key, this.imagePath, this.localizationUseThisPicture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(localizationUseThisPicture)),
        body: buildBody(context),
        bottomNavigationBar: buildBottomBar(context),
      ),
    );
  }

  Widget basic() {
    return Center(
      child: Image.file(
        File(imagePath),
        fit: BoxFit.scaleDown,
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.scaleDown,
          ),
        ),
      ],
    );
  }

  Widget buildBottomBar(BuildContext context) {
    var items = new List<BottomNavigationBarItem>();

    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.check_box),
      //title: Text('Yes'),
      label: 'Yes',
    ));

    items.add(BottomNavigationBarItem(
      icon: Icon(Icons.cancel),
      //title: Text('No'),
      label: 'No',
    ));

    void bottomBarTap(int index) async {
      if (index == 0) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
    }

    return BottomNavigationBar(
      items: items,
      onTap: bottomBarTap,
    );
  }
}
