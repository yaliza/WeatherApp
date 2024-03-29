import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';

class PreferencesPage extends StatefulWidget {
  PreferencesPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _PreferencesPageState createState() => new _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  var tempUnits = ['metric', 'imperial'],
      tempUnitValue = 'metric',
      fillAreaBelow = true,
      showGrid = true,
      appIdTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    PreferencesHelper.getAppId().then(_changeAppId);
    PreferencesHelper.getTempUnit().then(_changeTempUnit);
    PreferencesHelper.getFillAreaBelowPlot().then(_changeFillBelowPlotArea);
    PreferencesHelper.getShowGrid().then(_changeShowGrid);
    appIdTextController.addListener(_onAppIdChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: new Text(widget.title)),
        body: Container(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
      getSettingsTitle('General settings'),
      Row(
        children: [
          new Expanded(child: Text('Temp unit: '), flex: 1),
          new Expanded(
            child: DropdownButton<String>(
                value: tempUnitValue,
                items: tempUnits.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (val) => _onTempUnitChanged(val)),
            flex: 3,
          )
        ],
      ),
      Row(
        children: [
          Expanded(child: Text('Api key: '), flex: 1),
          Expanded(child: TextField(controller: appIdTextController), flex: 3)
        ],
      ),
      getSettingsTitle('Charts settings'),
      Row(
        children: [
          Expanded(child: Text('Fill area below plot: '), flex: 3),
          Expanded(
              child: Checkbox(
                  value: fillAreaBelow, onChanged: _changeFillBelowPlotArea),
              flex: 1)
        ],
      ),
      Row(
        children: [
          Expanded(child: Text('Show grid: '), flex: 3),
          Expanded(
              child: Checkbox(value: showGrid, onChanged: _changeShowGrid),
              flex: 1)
        ],
      )
    ])));
  }

  Widget getSettingsTitle(String title) => Container(
        margin: const EdgeInsets.only(top: 15.0, bottom: 10.0),
        child: Text(title, style: TextStyle(fontSize: 15)),
      );

  void _changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void _changeAppId(String value) {
    appIdTextController.text = value;
  }

  void _changeFillBelowPlotArea(bool value) {
    PreferencesHelper.setFillAreBelowPlot(value);
    setState(() {
      fillAreaBelow = value;
    });
  }

  void _changeShowGrid(bool value) {
    PreferencesHelper.setShowGrid(value);
    setState(() {
      showGrid = value;
    });
  }

  void _onAppIdChanged() {
    PreferencesHelper.setAppId(appIdTextController.text);
  }

  void _onTempUnitChanged(String value) {
    _changeTempUnit(value);
    PreferencesHelper.setTempUnit(value);
  }
}
