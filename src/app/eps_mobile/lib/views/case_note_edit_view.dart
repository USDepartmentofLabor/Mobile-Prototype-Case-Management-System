import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/queries/case_note_queries.dart';
import 'package:eps_mobile/service_helpers/case_note_add.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CaseNoteEditView extends StatefulWidget {
  CaseNoteEditView({
    Key key,
    this.title,
    this.buildMainDrawer,
    this.epsState,
    this.isNew,
    this.caseInstance,
    this.caseNote,
  }) : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;
  final bool isNew;
  final CaseInstance caseInstance;
  final CaseNote caseNote;

  final _CaseNoteEditViewState _widgetState = new _CaseNoteEditViewState();

  @override
  _CaseNoteEditViewState createState() {
    return getState();
  }

  _CaseNoteEditViewState getState() {
    return _widgetState;
  }

  bool getWasAddOrEditChange() {
    return _widgetState.wasAddOrEditAction;
  }
}

class _CaseNoteEditViewState extends State<CaseNoteEditView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool wasAddOrEditAction = false;

  String noteText;

  // localizations
  var localizationSave = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationSave =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SAVE,
      );
    });
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
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
        bottomSheet: buildBottomSheet(context),
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
  ) {
    var widgets = new List<Widget>();

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'note',
        //decoration: InputDecoration(labelText: ''),
        initialValue: '',
        keyboardType: TextInputType.text,
        autofocus: true,
        onChanged: null,
        maxLines: 100,
      ),
    ));

    return ListView(
      children: <Widget>[
        FormBuilder(
          key: _fbKey,
          child: Column(
            children: widgets,
          ),
        ),
      ],
    );
  }

  Widget buildBottomSheet(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
        child: RaisedButton(
          child: Text(localizationSave),
          onPressed: () => onSave(context),
        ),
      ),
    );
  }

  Future<void> onSave(BuildContext context) async {
    if (widget.isNew) {
      await addNewNote(context);
    } else {
      await editNote(context);
    }
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('note')) {
      noteText = values['note'];
    }
  }

  Future<void> addNewNote(
    BuildContext context,
  ) async {
    gatherValues();

    var caseNote = new CaseNote();
    caseNote.id = 1;
    caseNote.caseId = widget.caseInstance.id;
    caseNote.note = noteText;
    caseNote.createdAt = DateTime.now().toUtc();
    caseNote.updatedAt = DateTime.now().toUtc();

    // add
    if (widget.epsState.syncData) {
      // online
      var addResult = await CaseNoteAdd.addCaseNote(
        widget.epsState,
        widget.caseInstance,
        caseNote,
      );
      if (addResult.item1 == true) {
        CaseNoteQueries.insertCaseNote(
          widget.epsState.database.database,
          addResult.item2,
        );
      }
    } else {
      // offline
      // store local, sync later
      CaseNoteQueries.insertLocalCaseNote(
        widget.epsState.database.database,
        caseNote,
      );
    }

    setState(() {
      wasAddOrEditAction = true;
    });

    Navigator.of(context).pop();
  }

  Future<void> editNote(
    BuildContext context,
  ) async {
    gatherValues();
    // edit

    setState(() {
      wasAddOrEditAction = true;
    });

    Navigator.of(context).pop();
  }
}
