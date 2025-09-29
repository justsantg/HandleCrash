import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  void _callNumber(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: <Widget>[
            Text(
              'Emergency Numbers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Color(0xFFA8DADC),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.local_police, color: Color(0xFFA8DADC)),
                      title: Text('Police', style: TextStyle(color: Colors.white)),
                      subtitle: Text('123', style: TextStyle(color: Colors.grey[400])),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Color(0xFFA8DADC)),
                        onPressed: () => _callNumber('123'),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.fire_truck, color: Color(0xFFA8DADC)),
                      title: Text('Fire', style: TextStyle(color: Colors.white)),
                      subtitle: Text('119', style: TextStyle(color: Colors.grey[400])),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Color(0xFFA8DADC)),
                        onPressed: () => _callNumber('119'),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.local_hospital, color: Color(0xFFA8DADC)),
                      title: Text('Ambulance', style: TextStyle(color: Colors.white)),
                      subtitle: Text('125', style: TextStyle(color: Colors.grey[400])),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Color(0xFFA8DADC)),
                        onPressed: () => _callNumber('125'),
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.traffic, color: Color(0xFFA8DADC)),
                      title: Text('Traffic', style: TextStyle(color: Colors.white)),
                      subtitle: Text('147', style: TextStyle(color: Colors.grey[400])),
                      trailing: IconButton(
                        icon: Icon(Icons.call, color: Color(0xFFA8DADC)),
                        onPressed: () => _callNumber('147'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
