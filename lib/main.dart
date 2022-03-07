import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  //3
  void onTextFieldSubmitted(String input) async {
    fetchSearch(input);
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/$weather.png'), fit: BoxFit.cover),
        ),
        child: temperature == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
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
                            temperature.toString() + ' C',
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
                    Column(
                      children: [
                        Container(
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
