import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DarkHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<DarkHomePage> {
  late VideoPlayerController _controller;
  double rating = 0.0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/darkhome.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather Station",
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the icon color to white
        ),
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
                SizedBox(height: 8.0), // Add space above the search bar
                Container(
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    decoration: InputDecoration(
                      hintText: 'Search for cities',
                      hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon:
                      Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        // Adjust the radius as needed
                      ),
                    ),
                    onChanged: (value) {
                      // Handle search logic here
                    },
                  ),
                ),
                SizedBox(height: 8.0), // Add space between the search bar and information boxes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox("Temperature", "25°C", Icons.thermostat),
                      SizedBox(width: 8.0), // Add space between Temperature and Humidity boxes
                      _buildInfoBox("Humidity", "60%", Icons.opacity),
                      SizedBox(width: 8.0), // Add space between Humidity and Light Intensity boxes
                      _buildInfoBox("Wind Speed", "21 km/hr", Icons.wind_power),
                    ],
                  ),
                ),
                SizedBox(height: 8.0), // Add space below the information boxes and before the new information boxes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  color: Colors.black.withOpacity(0.0),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoBox("Air Pressure", "1012 hPa", Icons.compress),
                      SizedBox(width: 8.0), // Add space between Air Pressure and Visibility boxes
                      _buildInfoBox("Visibility", "10 km", Icons.visibility),
                      SizedBox(width: 8.0), // Add space between Visibility and Rain boxes
                      _buildInfoBox("Rain", "5 mm", Icons.beach_access),
                    ],
                  ),
                ),
                SizedBox(height: 8.0), // Add space below the new information boxes and before the circular summary section
                _buildCircularSummary(),
                SizedBox(height: 16.0), // Add space between the circular summary and the forecast table
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
                          'Mamur Sayor',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '1901029@iot.bdu.ac.bd',
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
                Navigator.pushNamed(context, '/darkprofile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/darksettings');
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
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white,size: 30.0),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Share App'),
                            content: Text('Share the app logic goes here.'),
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
                    icon: Icon(Icons.feedback,color: Colors.white,size: 30.0 ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String userFeedback = '';

                          return AlertDialog(
                            title: Text('Feedback'),
                            content: Container(
                              height: 150.0,
                              child: Column(
                                children: [
                                  SizedBox(height: 6.0),
                                  TextField(
                                    maxLines: 4,
                                    onChanged: (value) {
                                      userFeedback = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Type your feedback here...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  print('User Feedback: $userFeedback');
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
            Container(
              width: 60.0,
              height: 60.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.star, color: Colors.white,size: 30.0),
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
        color: Colors.black, // Set the BottomAppBar background color to black
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
              'Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            // Add your circular summary widgets here
            Icon(Icons.cloud, color: Colors.white, size: 30.0),
            SizedBox(height: 4.0),
            Text(
              'Cloudy',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSevenDayForecastTable() {
    // Add your 7-day forecast table here
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '7 Day Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 150.0),

          // Add your 7-day forecast table widgets here
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
