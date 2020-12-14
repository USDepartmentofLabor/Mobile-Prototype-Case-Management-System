import 'dart:io';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddFileView extends StatefulWidget {
  AddFileView({Key key, this.title, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _AddFileViewState createState() => _AddFileViewState();
}

class _AddFileViewState extends State<AddFileView> {
  var _image;
  var _file;
  String _filePath;

  // localizations
  var localizationClose = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationClose =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CLOSE,
      );
    });
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
  }

  Future getImage() async {
    //var image = await ImagePicker.pickImage(source: ImageSource.camera);
    PickedFile image = await ImagePicker().getImage(source: ImageSource.camera);
    var file = await getFileFromPickedFile(image);
    setState(() {
      _image = file;
      _file = null;
    });
  }

  Future getFile() async {
    //var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    PickedFile image =
        await ImagePicker().getImage(source: ImageSource.gallery);
    var file = await getFileFromPickedFile(image);
    setState(() {
      _image = file;
      _file = null;
    });
  }

  Future<File> getFileFromPickedFile(
    PickedFile pickedFile,
  ) async {
    var path = pickedFile.path;
    return File('$path');
  }

  @override
  void initState() {
    super.initState();
    widget.epsState.currentContext = context;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: this.widget.buildMainDrawer
            ? MainDrawerView(
                epsState: this.widget.epsState,
              )
            : null,
        appBar: AppBar(
          title: Text(this.widget.title),
        ),
        body: buildBody(context),
        bottomSheet: buildBottomBar(context),
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
  ) {
    var height = 72.0;
    var width = MediaQuery.of(context).size.width * 0.2;
    var buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: RaisedButton(
              child: Icon(
                Icons.camera_alt,
                size: 32.0,
              ),
              onPressed: () async {
                await getImage();
              },
            ),
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: RaisedButton(
              child: Icon(
                Icons.insert_photo,
                size: 32.0,
              ),
              onPressed: () async {
                await getFile();
              },
            ),
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: RaisedButton(
              child: Icon(
                Icons.attach_file,
                size: 32.0,
              ),
              onPressed: () async {
                //var data = await FilePicker.getFile();
                var data = await FilePicker.platform.pickFiles();
                if (data != null) {
                  setState(() {
                    _image = null;
                    _file = data;
                    _filePath = path.basename(data.files.single.path);
                  });
                } else {
                  // User canceled the picker
                }
              },
            ),
          ),
        ),
      ],
    );

    if (_image != null) {
      return ListView(
        children: <Widget>[
          buttonRow,
          Image.file(_image),
        ],
      );
    } else if (_file != null) {
      return ListView(
        children: <Widget>[
          buttonRow,
          Center(
            child: Text(
              _filePath,
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return buttonRow;
    }
  }

  Widget buildBottomBar(
    BuildContext context,
  ) {
    var height2 = 64.0;
    var width2 = MediaQuery.of(context).size.width * 0.34;
    var okCancelRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: height2,
          width: width2,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              child: Icon(
                Icons.check_box,
              ),
              onPressed: () async {
                if (_image != null) {
                  Navigator.pop(context, _image);
                } else if (_file != null) {
                  Navigator.pop(context, _file);
                } else {
                  Navigator.pop(context, null);
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: height2,
          width: width2,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              child: Icon(
                Icons.cancel,
              ),
              onPressed: () async {
                Navigator.pop(context, null);
              },
            ),
          ),
        ),
      ],
    );
    return okCancelRow;
  }
}
