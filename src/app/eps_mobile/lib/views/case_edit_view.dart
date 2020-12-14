import 'dart:convert';
import 'package:eps_mobile/custom_fields/helpers/custom_field_helper.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_check_box_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_date_time_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_number_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_radio_button_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_rank_list_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_select_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_text_area_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_text_widget.dart';
import 'package:eps_mobile/helpers/color_helper.dart';
import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/helpers/datetime_helper.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/case_status.dart';
import 'package:eps_mobile/models/custom_field.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/queries/case_queries.dart';
import 'package:eps_mobile/queries/case_status_queries.dart';
import 'package:eps_mobile/service_helpers/case_add.dart';
import 'package:eps_mobile/service_helpers/case_edit.dart';
import 'package:eps_mobile/service_helpers/case_edit_custom_field.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tuple/tuple.dart';

class CaseEditView extends StatefulWidget {
  CaseEditView(
      {Key key,
      this.title,
      this.buildMainDrawer,
      this.caseDefinition,
      this.caseInstance,
      this.caseStatus,
      this.isNew,
      this.epsState})
      : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final CaseDefinition caseDefinition;
  final CaseInstance caseInstance;
  final CaseStatus caseStatus;
  final bool isNew;
  final EpsState epsState;

  @override
  _CaseEditViewState createState() => _CaseEditViewState();
}

class _CaseEditViewState extends State<CaseEditView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  List<CaseStatus> caseStatuses = new List<CaseStatus>();
  List<DropdownMenuItem<CaseStatus>> caseStatusMenuItems =
      new List<DropdownMenuItem<CaseStatus>>();
  List<Tuple2<CustomField, Widget>> customFields =
      List<Tuple2<CustomField, Widget>>();
  Map newValue;

  List<String> allCaseNames = List<String>();

  // values
  String name = '';
  bool _nameHasError = false;
  String description = '';
  int caseStatusId = -1;

  // localizations
  var localizationName = '';
  var localizationDescription = '';
  var localizationSubmit = '';
  var localizationMustSelectAtLeastOne = '';
  var localizationClear = '';
  var localizationPickdate = '';
  var localizationThisIsNotANumber = '';
  var localizationMustMakeASelection = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationName =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NAME,
      );
      localizationDescription =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DESCRIPTION,
      );
      localizationSubmit =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SUBMIT,
      );
      localizationMustSelectAtLeastOne =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.MUST_SELECT_AT_LEAST_ONE,
      );
      localizationClear =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CLEAR,
      );
      localizationPickdate =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PICK_DATE,
      );
      localizationThisIsNotANumber =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.THIS_IS_NOT_A_NUMBER,
      );
      localizationMustMakeASelection =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.MUST_MAKE_A_SELECTION,
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

    // query all case statuses in local database
    CaseStatusQueries.getAllCaseStatuses(
      widget.epsState.database.database,
    ).then((result) {
      setState(() {
        caseStatuses = result;
        caseStatusMenuItems = caseStatuses
            .map((status) => DropdownMenuItem(
                  value: status,
                  //child: Text(status.name),
                  child: Container(
                    margin: EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 30,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Container(
                        color: ColorHelper.getColorFromHexString(status.color),
                        child: Text(status.name),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ))
            .toList();
      });
    });

    // get all case names
    CaseQueries.getAllCaseNamesServerAndLocal(
      widget.epsState.database.database,
    ).then((value) {
      var caseNames = value;
      if (!widget.isNew) {
        caseNames.remove(widget.caseInstance.name);
      }
      setState(() {
        this.allCaseNames = caseNames;
      });
    });

    // Custom Fields List
    customFields = CustomFieldHelper.initCustomFields(
      widget.caseInstance.customFieldData,
      localizationMustMakeASelection,
      localizationMustSelectAtLeastOne,
      localizationClear,
      localizationThisIsNotANumber,
      localizationPickdate,
    );
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

    // Key
    if (widget.caseInstance.key != '') {
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.caseInstance.key,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ));
    }

    // Name
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'name',
        decoration: InputDecoration(
          labelText: localizationName,
          suffixIcon: _nameHasError
              ? Icon(Icons.error, color: Colors.red)
              : Icon(Icons.check, color: Colors.green),
        ),
        initialValue: widget.caseInstance.name,
        keyboardType: TextInputType.text,
        autofocus: true,
        //autovalidate: true,
        autovalidateMode: AutovalidateMode.always,
        onChanged: (val) {
          print(val);
          setState(() {
            _nameHasError =
                !_fbKey.currentState.fields['name'].currentState.validate();
          });
        },
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.minLength(8),
          FormBuilderValidators.maxLength(50),
          (val) {
            if (this.allCaseNames.contains(val)) {
              return 'Case name must be unique';
            }
            return null;
          },
        ],
      ),
    ));

    // Status
    if (caseStatusMenuItems.length > 0) {
      var caseStatusFormBuilderDropdown = FormBuilderDropdown(
        attribute: 'caseStatusId',
        items: caseStatusMenuItems,
        initialValue: (widget.caseStatus != null
            ? caseStatuses.where((x) => x.id == widget.caseStatus.id).first
            : null),
      );
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: caseStatusFormBuilderDropdown,
      ));
    }

    // Description
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'description',
        decoration: InputDecoration(labelText: localizationDescription),
        initialValue: widget.caseInstance.description,
        keyboardType: TextInputType.text,
        maxLines: 4,
        onChanged: null,
      ),
    ));

    for (var item in customFields) {
      widgets.add(item.item2);
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
      ));
    }

    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
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
          child: Text(localizationSubmit),
          onPressed: () => onSubmit(context),
        ),
      ),
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    if (widget.isNew) {
      await addNewCase(context);
    } else {
      await editCase(context);
    }
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('name')) {
      name = values['name'];
    }
    if (values.containsKey('description')) {
      description = values['description'];
    }
    if (values.containsKey('caseStatusId')) {
      if (values['caseStatusId'] == null) {
        caseStatusId = this.caseStatuses.first.id;
      } else {
        caseStatusId = values['caseStatusId'].id;
      }
    }
    gatherCustomValues();
  }

  void gatherCustomValues() {
    var customFieldsList = List<CustomField>();
    for (var item in customFields) {
      customFieldsList.add(item.item1);
      switch (item.item1.fieldType) {
        case 'text':
          {
            CustomTextWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'textarea':
          {
            CustomTextAreaWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'select':
          {
            CustomSelectWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'check_box':
          {
            CustomCheckBoxWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'radio_button':
          {
            CustomRadioButtonWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'number':
          {
            CustomNumberWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'date':
          {
            CustomDateTimeWidget widget = item.item2;
            try {
              item.item1.value =
                  DateTimeHelper.getDateTimeAsYYYYMMDDString(widget.getValue());
            } catch (e) {
              //
            }
          }
          break;
        case 'rank_list':
          {
            CustomRankListWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
      }
    }
    var data = CustomFieldHelper.customFieldToJson(
      customFieldsList,
    );
    newValue = data;
  }

  Future<void> addNewCase(
    BuildContext context,
  ) async {
    gatherValues();

    var newCaseInstance = new CaseInstance();
    newCaseInstance.id = -1;
    newCaseInstance.caseDefinitionId = widget.caseDefinition.id;
    newCaseInstance.name = name;
    newCaseInstance.description = description;
    if (caseStatusId != -1) {
      newCaseInstance.caseStatusId = caseStatusId;
    }
    newCaseInstance.customFieldData = json.encode(newValue);

    newCaseInstance.createdBy = widget.epsState.user.id;
    newCaseInstance.updatedBy = widget.epsState.user.id;
    newCaseInstance.createdAt = DateTime.now().toUtc();
    newCaseInstance.updatedAt = DateTime.now().toUtc();
    newCaseInstance.assignedTo = -1;

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachale = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );
    if (isOnline && apiIsReachale) {
      var addNewCase = new CaseAdd(widget.epsState);
      var result = await addNewCase.addCase(widget.epsState.serviceInfo.url,
          widget.epsState.serviceInfo.useHttps, newCaseInstance);
      if (result.item1 == true) {
        CaseQueries.insertCase(
          widget.epsState.database.database,
          newCaseInstance,
        );
      } else {
        widget.epsState.showFlashBasic(
          context,
          'error',
        );
      }
    } else {
      // offline
      try {
        await CaseQueries.insertLocal(
          widget.epsState.database.database,
          newCaseInstance,
        );
      } catch (e) {
        widget.epsState.showFlashBasic(
          context,
          'error',
        );
      }
    }

    Navigator.of(context).pop();
  }

  Future<void> editCase(BuildContext context) async {
    gatherValues();

    widget.caseInstance.name = name;
    widget.caseInstance.description = description;
    if (caseStatusId != -1) {
      widget.caseInstance.caseStatusId = caseStatusId;
    }
    widget.caseInstance.customFieldData = json.encode(newValue);

    widget.caseInstance.updatedAt = DateTime.now().toUtc();
    widget.caseInstance.updatedBy = widget.epsState.user.id;

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    if (isOnline && apiIsReachable) {
      // online
      if (widget.caseInstance.isLocal != null &&
          widget.caseInstance.isLocal == true) {
        // local
        // add to server (it is local so we can edit here but since we are online go ahead and add it)
        var caseAdd = await CaseAdd(widget.epsState).addCase(
          widget.epsState.serviceInfo.url,
          widget.epsState.serviceInfo.useHttps,
          widget.caseInstance,
        );
        if (caseAdd.item1 == true) {
          // add to server table
          CaseQueries.insertCase(
            widget.epsState.database.database,
            caseAdd.item2,
          );
          // remove from local table
          CaseQueries.deleteCaseLocal(
            widget.epsState.database.database,
            widget.caseInstance.id,
          );
        } else {
          // error
          widget.epsState.showFlashBasic(
            context,
            'error',
          );
        }
      } else {
        // server
        var editCase = new CaseEdit(widget.epsState);
        var result = await editCase.editCase(widget.epsState.serviceInfo.url,
            widget.epsState.serviceInfo.useHttps, widget.caseInstance);
        if (result.item1 == true) {
          CaseQueries.insertCase(
            widget.epsState.database.database,
            widget.caseInstance,
          );
        }
        // Custom Fields
        var customFields = json.decode(widget.caseInstance.customFieldData);
        for (var item in customFields['data']) {
          var editCustomField = CaseEditCustomField(widget.epsState);
          var result = await editCustomField.editCaseCustomField(
            widget.epsState.serviceInfo.url,
            widget.epsState.serviceInfo.useHttps,
            widget.caseInstance,
            item['id'],
            item['value'],
          );
          if (result.item1 == false) {
            print('error');
          }
        }
      }
    } else {
      // offline
      if (widget.caseInstance.isLocal != null &&
          widget.caseInstance.isLocal == true) {
        // local
        await CaseQueries.insertLocal(
          widget.epsState.database.database,
          widget.caseInstance,
        );
      } else {
        // server
        await CaseQueries.insertCase(
          widget.epsState.database.database,
          widget.caseInstance,
        );
      }
    }

    Navigator.of(context).pop();
  }
}
