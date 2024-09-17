import 'package:flutter/material.dart';

class DarkProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/darkm.png', // Replace with your actual background image asset
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/sayor.PNG'),
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
                      // Name and Email Box
                      Column(
                        children: [
                          Text(
                            'Mamur Sayor',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '1901029@iot.bdu.ac.bd',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 24.0),
                        ],
                      ),

                      // Edit Profile Box
                      ListTile(
                        title: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(Icons.edit, color: Colors.white),
                        onTap: () {
                          // Handle profile editing
                        },
                      ),
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
