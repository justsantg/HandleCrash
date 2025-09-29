import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  final Function(int) onNavigate;

  const Homepage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFA8DADC).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.directions_car,
                        size: 60,
                        color: Color(0xFFA8DADC),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'HandleCrash',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFA8DADC),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Detect vehicle damages with AI',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'HandleCrash te ayuda a detectar daños en vehículos con IA, acceder a números de emergencia en Colombia y consultar guías de reparación externa.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => onNavigate(1),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Iniciar Cámara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA8DADC),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    elevation: 5,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => onNavigate(2),
                  icon: Icon(Icons.phone),
                  label: Text('Números de Emergencia'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA8DADC),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    elevation: 5,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => onNavigate(3),
                  icon: Icon(Icons.help_outline),
                  label: Text('Guías de Reparación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA8DADC),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    elevation: 5,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

