import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  String location = 'Jakarta';
  int woeid = 1047378;
  String weather = 'clear';
  String abbreviation = '';

  String errorMessage = '';

  var minTemperature = List.filled(7, 0);
  var maxTemperature = List.filled(7, 0);
  var abbreviationForecast = List.filled(7, ' ');

  //1v
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';

  //2v
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  /* fungsi yang akan langsung djalankan ketika aplikasi dijalankan adalah
    fungsi yang ada didalam initState */
  @override
  void initState() {
    fetchLocation();
    fetchLocationDay();
    super.initState();
  }

  //1f
  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result['title'];
        woeid = result['woeid'];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage =
            'Maaf, Lokasi yang anda minta tidak ditemukan, silahkan cari kota lainnya.';
      });
    }
  }

  //2f
  void fetchLocation() async {
    var locationResult =
        await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode(locationResult.body);
    var consolidated_weather = result['consolidated_weather'];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data['weather_state_abbr'];
    });
  }

  void fetchLocationDay() async {
    var today = DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(Uri.parse(locationApiUrl +
          woeid.toString() +
          '/' +
          DateFormat('y/M/d')
              .format(today.add(Duration(days: i + 1)))
              .toString()));
      var result = json.decode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemperature[i] = data['min_temp'].round();
        maxTemperature[i] = data['max_temp'].round();
        abbreviationForecast[i] = data['weather_state_abbr'];
      });
    }
  }

  //3
  void onTextFieldSubmitted(String input) async {
    fetchSearch(input);
    fetchLocation();
    fetchLocationDay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/$weather.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6), BlendMode.dstATop)),
        ),
        child: temperature == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/' +
                                abbreviation +
                                '.png',
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + ' °C',
                            style: const TextStyle(
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          forecastElement(
                            0,
                            abbreviationForecast[0],
                            maxTemperature[0],
                            minTemperature[0],
                          ),
                          forecastElement(
                            1,
                            abbreviationForecast[1],
                            maxTemperature[1],
                            minTemperature[1],
                          ),
                          forecastElement(
                            2,
                            abbreviationForecast[2],
                            maxTemperature[2],
                            minTemperature[2],
                          ),
                          forecastElement(
                            3,
                            abbreviationForecast[3],
                            maxTemperature[3],
                            minTemperature[3],
                          ),
                          forecastElement(
                            4,
                            abbreviationForecast[4],
                            maxTemperature[4],
                            minTemperature[4],
                          ),
                          forecastElement(
                            5,
                            abbreviationForecast[5],
                            maxTemperature[5],
                            minTemperature[5],
                          ),
                          forecastElement(
                            6,
                            abbreviationForecast[6],
                            maxTemperature[6],
                            minTemperature[6],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                            },
                            style: const TextStyle(
                                color: Colors.white, fontSize: 25),
                            decoration: const InputDecoration(
                                hintText: 'Search The Another Location...',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: Platform.isAndroid ? 15.0 : 20.0,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, minTemperature, maxTemperature) {
  var now = DateTime.now();
  var oneDayFromNow = now.add(Duration(days: daysFromNow));
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Container(
      decoration: BoxDecoration(
          color: const Color.fromRGBO(205, 212, 228, 0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              DateFormat.E().format(oneDayFromNow),
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
            Text(
              DateFormat.MMMd().format(oneDayFromNow),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviation +
                    '.png',
                width: 50,
              ),
            ),
            Text(
              'High: ' + maxTemperature.toString() + ' °C',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Low: ' + minTemperature.toString() + ' °C',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
