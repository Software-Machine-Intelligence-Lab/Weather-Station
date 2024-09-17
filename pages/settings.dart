import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bgm.png', // Replace with your actual background image asset
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Weather Station Settings",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // 50% transparent black
                    borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Existing settings
                      ListTile(
                        title: Text(
                          "Temperature Unit",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "Celsius",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Colors.white),
                        onTap: () {
                          // Handle temperature unit selection
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Notification Settings",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "Receive weather updates",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Colors.white),
                        onTap: () {
                          // Handle notification settings
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Permissions",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "Location, Gyroscope",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Colors.white),
                        onTap: () {
                          // Handle notification settings
                        },
                      ),

                      // Dark Mode Switch
                      ListTile(
                        title: Text(
                          "Dark Mode",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              isDarkMode = value;
                              if (isDarkMode) {
                                // Navigate to the /darksettings page
                                Navigator.pushNamed(context, '/darkhome');
                              }
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.grey,
                        ),
                      ),
                      // Add more settings as needed
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
