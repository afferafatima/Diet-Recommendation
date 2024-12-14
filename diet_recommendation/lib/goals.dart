import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Issues',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HealthIssuesScreen(),
    );
  }
}

class HealthIssuesScreen extends StatefulWidget {
  @override
  _HealthIssuesScreenState createState() => _HealthIssuesScreenState();
}

class _HealthIssuesScreenState extends State<HealthIssuesScreen> {
  String _selectedIssue = 'Diabetes'; // Default selection

  // Sample data for health issues and their images
  final Map<String, String> _healthIssues = {
    'Diabetes': 'assets/images/diabetes.jpeg', // Replace with your image path
    'Blood Pressure':
        'assets/images/blood_pressure.jpeg', // Replace with your image path
    'Cholesterol':
        'assets/images/cholesterol.jpeg', // Replace with your image path
    'Food Allergies':
        'assets/images/allergies.png', // Replace with your image path
  };

  // Controller for the additional information text field
  TextEditingController _additionalInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Issues'),
        backgroundColor: Color(0xFF78BC45),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                height: 100, // Adjust height as needed
              ),
            ),
            // Title
            Text(
              'Select Your Health Issue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78BC45),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Health Issue Options
            Expanded(
              child: ListView.builder(
                itemCount: _healthIssues.keys.length,
                itemBuilder: (context, index) {
                  String issue = _healthIssues.keys.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIssue = issue; // Update selected issue
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedIssue == issue
                              ? Color(0xFF78BC45) // Highlight selected option
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 4), // Shadow position
                          ),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          // Image for the health issue
                          Image.asset(
                            _healthIssues[issue]!,
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              issue,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Text box for additional information
            TextField(
              controller: _additionalInfoController,
              decoration: InputDecoration(
                labelText: 'Enter additional information',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Handle submission
                String additionalInfo = _additionalInfoController.text;

                _showSelectionDialog(context, _selectedIssue, additionalInfo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF78BC45), // Background color
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show selection confirmation dialog
  void _showSelectionDialog(BuildContext context, String title, String info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submission Details'),
          content: Text('You selected: $title\nAdditional Info: $info'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
