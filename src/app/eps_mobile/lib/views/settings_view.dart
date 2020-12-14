import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/service_info.dart';
import 'package:eps_mobile/views/main_drawer.dart';

class SettingsView extends StatefulWidget {
  SettingsView({
    Key key,
    this.title,
    this.buildMainDrawer,
    this.epsState,
  }) : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  List<Localization> localizations;
  var _selectedLocalization = 0;

  // localizations
  var localizationApiUrl = '';
  var localizationThisMustBeAValidUrl = '';
  var localizationSettings = '';

  void getLocalizations() {
    setState(() {
      // all localizations available
      localizations =
          widget.epsState.localizationValueHelper.getAllLocalizations();

      // currently selected from the state
      var search = widget.epsState.localizationValueHelper
          .getAllLocalizations()
          .where((x) => x.code == widget.epsState.localization.code)
          .first;
      _selectedLocalization = localizations.indexOf(search);

      // values for this view
      localizationApiUrl =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.API_URL,
      );
      localizationThisMustBeAValidUrl =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.THIS_MUST_BE_A_VALID_URL,
      );
      localizationSettings =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SETTINGS,
      );
    });
  }

  // values
  String apiUrl = '';

  bool buildSave = false;

  @override
  void initState() {
    super.initState();
    widget.epsState.currentContext = context;
    refresh();
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
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
          title: Text(localizationSettings),
        ),
        body: buildBody(context),
        bottomSheet: buildSave ? buildBottomSheet(context) : null,
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
  ) {
    var widgets = List<Widget>();

    // API URL
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'api_url',
        decoration: InputDecoration(
          labelText: localizationApiUrl,
        ),
        initialValue: getDisplayUrl(widget.epsState.serviceInfo),
        keyboardType: TextInputType.text,
        autofocus: true,
        //autovalidate: true,
        autovalidateMode: AutovalidateMode.always,
        onChanged: (_) {
          setState(() {
            buildSave = getDisplayUrl(widget.epsState.serviceInfo) != _;
          });
        },
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.url(
            errorText: localizationThisMustBeAValidUrl,
            protocols: ['http', 'https'],
          ),
        ],
      ),
    ));

    // Localizations
    var index = 0;
    for (var localization in localizations) {
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
        child: RadioListTile(
          title: Text(localization.name),
          value: index,
          groupValue: _selectedLocalization,
          onChanged: _handleLocalizationValueChange,
        ),
      ));
      index++;
    }

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
          child: Text(
            //'Save'
            widget.epsState.localizationValueHelper.getValueFromEnum(
              widget.epsState.localization,
              LocalizationKeyValues.SAVE,
            ),
          ),
          onPressed: () => onSubmit(context),
        ),
      ),
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    gatherValues();
    if (_fbKey.currentState.validate()) {
      var parseResult = parseUrl(apiUrl);
      save(
        widget.epsState,
        parseResult.item1,
        parseResult.item2,
      );
    }
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('api_url')) {
      apiUrl = values['api_url'];
    }
  }

  static Tuple2<bool, String> parseUrl(
    String fullUrl,
  ) {
    try {
      String http = 'http://';
      String https = 'https://';

      bool useHttps = false;
      var url = '';

      if (fullUrl.contains(https)) {
        useHttps = true;
        url = fullUrl.replaceFirst(https, '');
      } else {
        url = fullUrl.replaceFirst(http, '');
      }

      return Tuple2<bool, String>(useHttps, url);
    } catch (e) {
      return Tuple2<bool, String>(false, '');
    }
  }

  void save(
    EpsState epsState,
    bool useHttps,
    String url,
  ) {
    epsState.serviceInfo.useHttps = useHttps;
    epsState.serviceInfo.url = url;
  }

  String getFullUrl(
    ServiceInfo serviceInfo,
  ) {
    var prefix = serviceInfo.useHttps ? 'https://' : 'http://';
    return prefix + serviceInfo.url;
  }

  String getDisplayUrl(
    ServiceInfo serviceInfo,
  ) {
    return getFullUrl(serviceInfo);
  }

  void _handleLocalizationValueChange(int value) {
    setState(() {
      _selectedLocalization = value;

      if (value < localizations.length) {
        widget.epsState.changeLocalization(localizations[value]);
      } else {
        widget.epsState.changeLocalization(localizations[0]);
      }

      refresh();
    });
  }
}
