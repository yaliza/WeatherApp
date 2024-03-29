import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'package:flutter_app/entities/weather_info_predictions.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChartsPage extends StatefulWidget {
  ChartsPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _ChartsPageState createState() => new _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  var weatherInfoPredictions,
      tempUnitValue = '',
      dots = [FlSpot(0, 20.0)],
      gradientColors = [Color(0xff23b6e6), Color(0xff02d39a)],
      showAreaBelowPlot = true,
      showGrid = true,
      marketCitiesIds;

  _ChartsPageState() {
    PreferencesHelper.getTempUnit().then(_changeTempUnit);
    PreferencesHelper.getFillAreaBelowPlot().then(_changeShowAreaBelowPlot);
    PreferencesHelper.getShowGrid().then(_changeShowGrid);
    PreferencesHelper.getMarkedCitiesIds().then(_changeMarkedCitiesIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: marketCitiesIds != null && marketCitiesIds.length == 0
            ? Center(child: Text('No data to display. Please, add cities.'))
            : weatherInfoPredictions != null
                ? mainContentWidget()
                : SpinKitChasingDots(color: Colors.blueAccent, size: 50.0));
  }

  Widget getChartWidget() {
    return FlChart(
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
            drawHorizontalGrid: true,
            getDrawingVerticalGridLine: (value) =>
                const FlLine(color: Color(0xff37434d), strokeWidth: 1),
            getDrawingHorizontalGridLine: (value) =>
                const FlLine(color: Color(0xff37434d), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            horizontalTitlesTextStyle:
                TextStyle(color: Color(0xff68737d), fontSize: 16),
            getHorizontalTitles: (val) => getDateLabel(val),
            verticalTitlesTextStyle:
                TextStyle(color: Color(0xff67727d), fontSize: 13),
            getVerticalTitles: (val) => val.toStringAsFixed(2),
            verticalTitlesReservedWidth: 28,
            verticalTitleMargin: 12,
            horizontalTitleMargin: 8,
          ),
          borderData: FlBorderData(
              show: true,
              border: Border.all(color: Color(0xff37434d), width: 1)),
          minX: 0,
          maxX: weatherInfoPredictions.predictions.length.toDouble(),
          minY: weatherInfoPredictions.minTemp,
          maxY: weatherInfoPredictions.maxTemp + 1,
          lineBarsData: [
            LineChartBarData(
              spots: dots,
              isCurved: true,
              colors: gradientColors,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BelowBarData(
                show: showAreaBelowPlot,
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getKeyValueWiget(String key, String value) {
    return Expanded(
        flex: 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text(value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15))),
            Align(
                alignment: FractionalOffset.topCenter,
                child: Text(key,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12)))
          ],
        ));
  }

  Widget mainContentWidget() {
    return Column(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: FractionalOffset.center,
                        child: Text(weatherInfoPredictions.cityName,
                            style: TextStyle(fontSize: 22),
                            textAlign: TextAlign.center))),
                Expanded(
                  flex: 1,
                  child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    getKeyValueWiget("Avg temp",
                        weatherInfoPredictions.averageTemp.toStringAsFixed(2)),
                    Container(color: Colors.black26, width: 1),
                    getKeyValueWiget(
                        "Avg humidity",
                        weatherInfoPredictions.averageHumidity
                            .toStringAsFixed(2)),
                    Container(color: Colors.black26, width: 1),
                    getKeyValueWiget(
                        "Avg pressure",
                        weatherInfoPredictions.averagePressure
                            .toStringAsFixed(2))
                  ]),
                )
              ],
            )),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Color(0xff232d37)),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          right: 18.0, left: 12.0, top: 45, bottom: 12),
                      child: getChartWidget()),
                  // ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  String getDateLabel(double value) {
    switch (value.toInt()) {
      case 5:
        return formatDateFullFormat(DateTime.now());
      case 15:
        return formatDateFullFormat(DateTime.now().add(Duration(days: 1)));
      case 25:
        return formatDateFullFormat(DateTime.now().add(Duration(days: 2)));
      case 35:
        return formatDateFullFormat(DateTime.now().add(Duration(days: 3)));
    }
    return "";
  }

  void _changeWeatherPredictions(WeatherInfoPredictions weatherPredictions) {
    var newDots = <FlSpot>[];
    weatherPredictions.predictions.forEach((pred) {
      newDots.add(FlSpot(double.parse((newDots.length).toString()), pred.temp));
    });
    setState(() {
      this.weatherInfoPredictions = weatherPredictions;
      dots = newDots;
    });
  }

  void _changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void _changeShowAreaBelowPlot(bool value) {
    setState(() {
      showAreaBelowPlot = value;
    });
  }

  void _changeShowGrid(bool value) {
    setState(() {
      showGrid = value;
    });
  }

  void _changeMarkedCitiesIds(List<String> ids) {
    setState(() {
      this.marketCitiesIds = ids;
    });
    if (ids.length != 0) {
      RequestHelper.getPredictions(
          _changeWeatherPredictions, () => print('error'), ids[0]);
    }
  }
}
