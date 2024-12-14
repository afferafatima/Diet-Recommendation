import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Issues',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HealthIssuesScreen(),
    );
  }
}

class HealthIssuesScreen extends StatefulWidget {
  const HealthIssuesScreen({Key? key}) : super(key: key);

  @override
  _HealthIssuesScreenState createState() => _HealthIssuesScreenState();
}

class _HealthIssuesScreenState extends State<HealthIssuesScreen> {
  String _selectedIssue = 'Diabetes'; // Default selection
  String _customIssue = ''; // Store custom health issue text

  // Sample data for health issues and their images
  final Map<String, String> _healthIssues = {
    'Diabetes': 'assets/images/diabetes.jpeg',
    'Blood Pressure': 'assets/images/blood_pressure.jpeg',
    'Cholesterol': 'assets/images/cholesterol.jpeg',
    'Food Allergies': 'assets/images/allergies.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Issues'),
        backgroundColor: const Color(0xFF78BC45),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align items to the start
          children: <Widget>[
            // Logo
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                height: 200, // Adjust height as needed
              ),
            ),
            // Title
            const Text(
              'Select Your Health Issue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78BC45),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Health Issue Options
            Expanded(
              child: ListView.builder(
                itemCount: _healthIssues.keys.length +
                    1, // Add one for the custom issue text field
                itemBuilder: (context, index) {
                  if (index < _healthIssues.keys.length) {
                    String issue = _healthIssues.keys.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIssue = issue; // Update selected issue
                          _customIssue =
                              ''; // Clear custom issue when a predefined issue is selected
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedIssue == issue
                                ? const Color(
                                    0xFF78BC45) // Highlight selected option
                                : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2), // Shadow position
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            // Image for the health issue
                            Image.asset(
                              _healthIssues[issue] ??
                                  'assets/images/default.png', // Default image if needed
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                issue,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // This is the custom health issue text field at the end of the list
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Other (Please specify)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _customIssue =
                                value; // Update the custom issue text
                            _selectedIssue =
                                ''; // Clear predefined issue when a custom issue is entered
                          });
                        },
                      ),
                    );
                  }
                },
              ),
            ),

            // Submit button with reduced margin
            Container(
              width: 150, // Set fixed width for the button
              // margin: const EdgeInsets.only(top: 10), // Reduced top margin
              child: ElevatedButton(
                onPressed: () {
                  // Handle submission
                  String finalSelection = _customIssue.isNotEmpty
                      ? _customIssue
                      : _selectedIssue; // Use custom issue if provided
                  debugPrint('Selected Health Issue: $finalSelection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF78BC45), // Background color
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16), // Adjust font size if needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
