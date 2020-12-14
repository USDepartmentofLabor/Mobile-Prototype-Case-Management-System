import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eps_mobile/helpers/datetime_helper.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/project.dart';
import 'package:eps_mobile/queries/project_queries.dart';
import 'package:eps_mobile/views/main_drawer.dart';

class ProjectView extends StatefulWidget {
  ProjectView({
    Key key,
    this.title,
    this.buildMainDrawer,
    this.epsState,
  }) : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _ProjectViewState createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  final formatCurrency = new NumberFormat.simpleCurrency();

  Project _project;

  // localizations
  var localizationName = '';
  var localizationTitle = '';
  var localizationOrganization = '';
  var localizationLocation = '';
  var localizationFundingAmount = '';
  var localizationAgreementNumber = '';
  var localizationStartDate = '';
  var localizationEndDate = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationName =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NAME,
      );
      localizationTitle =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.TITLE,
      );
      localizationOrganization =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ORGANIZATION,
      );
      localizationLocation =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.LOCATION,
      );
      localizationFundingAmount =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.FUNDING_AMOUNT,
      );
      localizationAgreementNumber =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.AGREEMENT_NUMBER,
      );
      localizationStartDate =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.START_DATE,
      );
      localizationEndDate =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.END_DATE,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    widget.epsState.currentContext = context;
    refresh();
  }

  void refresh() {
    getLoadData().then((result) {
      setState(() {
        _project = result;
        getLocalizations();
      });
    });
  }

  Future<Project> getLoadData() async {
    return await ProjectQueries.getProject(
      widget.epsState.database.database,
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
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
  ) {
    var widgets = List<Widget>();

    widgets.add(getItem(
      localizationName,
      _project.name,
    ));

    widgets.add(getItem(
      localizationTitle,
      _project.title,
    ));

    widgets.add(getItem(
      localizationOrganization,
      _project.organization,
    ));

    widgets.add(getItem(
      localizationLocation,
      _project.location,
    ));

    widgets.add(getItem(
      localizationFundingAmount,
      '${formatCurrency.format(_project.fundingAmount)}',
    ));

    widgets.add(getItem(
      localizationAgreementNumber,
      _project.agreementNumber,
    ));

    widgets.add(getItem(
      localizationStartDate,
      DateTimeHelper.getDateTimeAsYYYYMMDDString(
        _project.startDate,
      ),
    ));

    widgets.add(getItem(
      localizationEndDate,
      DateTimeHelper.getDateTimeAsYYYYMMDDString(
        _project.endDate,
      ),
    ));

    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: widgets,
      ),
    );
  }

  Widget getItem(
    String title,
    String dataValue,
  ) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            child: Text(
              title + ':',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            child: Text(
              dataValue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
