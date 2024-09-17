import 'package:demo1/pages/variables.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

String _latitude = '';
String _longitude = '';

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  double rating = 0.0;
  TextEditingController searchController = TextEditingController();

  dynamic userInfo;

  Future<void> fetchUserInfo() async {
    final response = await http
        .get(Uri.parse($domain+'/userInfo?username=' + $username));
    if (response.statusCode == 200) {
      setState(() {
        userInfo = json.decode(response.body)['records'];
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  dynamic weatherSummaryStatus = "";
  List<dynamic> weatherData = [];

  Future<void> fetchWeatherData() async {
    final response = await http
        .get(Uri.parse($domain+'/weather-data/get/last'));
    if (response.statusCode == 200) {
      setState(() {
        weatherData = json.decode(response.body)['records'];
      });
      if (weatherData.length == 1) {
        if (weatherData[0]['isRaining'] == 0) {
          setState(() {
            weatherSummaryStatus = "Sunny";
          });
        } else {
          setState(() {
            weatherSummaryStatus = "Raining";
          });
        }
      }
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void fetchWeatherDataPeriodically() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchWeatherData();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = 'Latitude: ${position.latitude}';
        _longitude = 'Longitude: ${position.longitude}';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('My Location'),
            content: Text('$_latitude\n$_longitude'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/w2.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..play();
    fetchWeatherData();
    fetchWeatherDataPeriodically();
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Station"),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
            Column(
              children: [
                SizedBox(height: 8.0),
                Container(
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    decoration: InputDecoration(
                      hintText: 'Search for cities',
                      hintStyle:
                          TextStyle(color: Colors.black.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.black.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (value) {
                      // Handle search logic here
                    },
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox("Temperature", '${weatherData[0]['temp']}',
                          Icons.thermostat),
                      SizedBox(width: 8.0),
                      _buildInfoBox("Humidity",
                          "${weatherData[0]['humidity']}%", Icons.opacity),
                      SizedBox(width: 8.0),
                      _buildInfoBox(
                          "Light Intensity",
                          "${weatherData[0]['lightIntensity']} Lux",
                          Icons.lightbulb),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox("Air Pressure", "1012 hPa", Icons.compress),
                      SizedBox(width: 8.0),
                      _buildInfoBox(
                          "Wind Speed",
                          "${weatherData[0]['windSpeed']} m/s",
                          Icons.wind_power),
                      SizedBox(width: 8.0),
                      _buildInfoBox("Rain", "5 mm", Icons.beach_access),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                _buildCircularSummary(),
                SizedBox(height: 16.0),
                _buildSevenDayForecastTable(),
              ],
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/sayor.PNG'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${userInfo[0]['username']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${userInfo[0]['email']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.share, size: 30.0),
                    onPressed: () {
                      launch(
                          'https://play.google.com/store/games?hl=en_US&gl=US&pli=1');
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: 50.0,
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.location_on, size: 30.0),
                    onPressed: () {
                      _getCurrentLocation();
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: 60.0,
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.star, size: 30.0),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Rating'),
                            content: RatingBar.builder(
                              initialRating: rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 40.0,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (value) {
                                setState(() {
                                  rating = value;
                                });
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  print('User Rating: $rating');
                                  Navigator.pop(context);
                                },
                                child: Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, IconData iconData) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Icon(iconData, color: Colors.white, size: 30.0),
            SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularSummary() {
    return Container(
      width: 180.0,
      height: 180.0,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Summary",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Icon(
                weatherSummaryStatus == "Sunny"
                    ? Icons.wb_sunny
                    : Icons.umbrella,
                color: Colors.white,
                size: 30.0),
            SizedBox(height: 4.0),
            Text(
              weatherSummaryStatus,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> weatherData2 = [
    {
      'date': '2024-05-08',
      'maxTemp': 28,
      'minTemp': 20,
      'rain': 5,
      'humidity': 60,
    },
    {
      'date': '2024-05-09',
      'maxTemp': 27,
      'minTemp': 19,
      'rain': 2,
      'humidity': 55,
    },
    {
      'date': '2024-05-09',
      'maxTemp': 27,
      'minTemp': 19,
      'rain': 2,
      'humidity': 55,
    },
    // Add more days as needed
  ];

  Widget _buildSevenDayForecastTable() {
    return Container(
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weather Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            width: 10,
            height: 200,
            child: DataTable(
            columns: [
              DataColumn(
                  label: Text('Date', style: TextStyle(color: Colors.white,fontSize: 12))),
              DataColumn(
                  label:
                      Text('Max Temp', style: TextStyle(color: Colors.white,fontSize: 12))),
              DataColumn(
                  label:
                      Text('Min Temp', style: TextStyle(color: Colors.white,fontSize: 12))),
              DataColumn(
                  label: Text('Rain', style: TextStyle(color: Colors.white,fontSize: 12))),
              // DataColumn(label: Text('Humidity', style: TextStyle(color: Colors.white))),
            ],
            rows: weatherData2.map<DataRow>((record) {
              return DataRow(
                cells: [
                  DataCell(Text('${record['date']}',
                      style: TextStyle(color: Colors.white))),
                  DataCell(Text('${record['maxTemp']}',
                      style: TextStyle(color: Colors.white))),
                  DataCell(Text('${record['minTemp']}',
                      style: TextStyle(color: Colors.white))),
                  DataCell(Text('${record['rain']} mm',
                      style: TextStyle(color: Colors.white))),
                  // DataCell(Text('${record['humidity']}%',
                  //     style: TextStyle(color: Colors.white))),
                ],
              );
            }).toList(),
          ),
    ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
