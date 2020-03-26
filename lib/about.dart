import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: double.maxFinite,
            ),
            CircleAvatar(
              radius: 64,
              backgroundImage: AssetImage('assets/mypic.jpg'),
            ),
            SizedBox(height: 32),
            Text(
              'Seshan K S',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Hello everyone !\nI created this app during 21 days of quarantine due to COVID-19. I was too bored and wanted to do something productive but not too productive. So I found this idea to be just right.',
              textAlign: TextAlign.center,
              strutStyle: StrutStyle(
                height: 1.75,
              ),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 64),
            Text(
              'For feedback or if you have an equally dumb but interesting idea,\n\nMail me at zeshan.nandan@gmail.com',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
