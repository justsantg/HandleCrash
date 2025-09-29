import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLink extends StatelessWidget {
  const ExternalLink({super.key});

  void _openCarCareKiosk() async {
    const url = 'https://es.carcarekiosk.com/';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to in-app webview if external fails
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  void _openIFixIt() async {
    const url = 'https://es.ifixit.com/Device/Car_and_Truck';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to in-app webview if external fails
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.web,
              size: 60,
              color: Color(0xFFA8DADC),
            ),
            SizedBox(height: 16),
            Text(
              'External Links',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Color(0xFFA8DADC),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.grey[900],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Color(0xFFA8DADC),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Car Care Kiosk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA8DADC),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Guías de mantenimiento y reparaciones DIY para vehículos. Encuentra tutoriales paso a paso para el cuidado de tu auto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openCarCareKiosk,
                      icon: Icon(Icons.open_in_browser),
                      label: Text('Abrir Sitio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA8DADC),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.grey[900],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.build,
                      size: 50,
                      color: Color(0xFFA8DADC),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'iFixit Car & Truck',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA8DADC),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manuales de reparación detallados para autos y camiones. Comunidad de expertos con guías gratuitas para reparaciones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openIFixIt,
                      icon: Icon(Icons.open_in_browser),
                      label: Text('Abrir Sitio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA8DADC),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
