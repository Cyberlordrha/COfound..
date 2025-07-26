import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agentic AI App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/next': (context) => const NextPage(),
        '/business_input': (context) => const BusinessInputPage(),
        '/business_results': (context) => const BusinessResultsPage(
          name: '', // Placeholder, will not be used directly
          logoPath: '',
          marketingPlan: '',
          businessPlan: '',
          area: '',
          location: '',
          region: '',
          budget: 0.0,
          concept: '',
        ),
        '/name_suggestions': (context) => const NameSuggestionsPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/co.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(_videoListener);
      });
  }

  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: _controller.value.isInitialized
            ? Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> contentPages = [
    "Ready to explore all the opportunities and features we have installed for you 🫣 ",
    "This Agentic AI Transforms Your Scattered Ideas into a Thriving Business 🤔",
    "Organize, Plan, Analyze, and Succeed with our Powerful AI-Driven Insights 💸",
    "Ready to Launch Your Dream Business Today!!😮‍💨"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/coo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * (1 / 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(65),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65),
                    child: Column(
                      children: [
                        Text(
                          "AN AGENTIC AI APP",
                          style: TextStyle(
                            fontFamily: 'Iceberg-Regular',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: const Color(0xFF230aef),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10),
                          child: Center(
                            child: Text(
                              contentPages[index],
                              style: TextStyle(
                                fontFamily: 'Zain-Regular',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < contentPages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          Navigator.pushNamed(context, '/next');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF230aef), // Base color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFF230aef),
                            width: 2,
                          ),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        _currentPage == contentPages.length - 1
                            ? "LETS DO THIS"
                            : "NEXT",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Description"),
        backgroundColor: const Color(0xFF230aef),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Margins from top, bottom, left, and right
          padding: const EdgeInsets.all(20), // Padding inside the container
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the container
            borderRadius: BorderRadius.circular(20), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To fit the content
            children: [
              Text(
                "Description",
                style: TextStyle(
                  color: const Color(0xFF230aef), // Color of the header text
                  fontSize: 24, // Editable font size
                  fontWeight: FontWeight.bold, // Editable font weight
                ),
              ),
              const SizedBox(height: 20), // Space between header and description
              Text(
                "This app provides a platform for users to generate business ideas and plans using AI-driven insights. Explore various features and tools to help you succeed in your entrepreneurial journey.",
                textAlign: TextAlign.center, // Center the description text
                style: TextStyle(
                  fontSize: 16, // Editable font size for description
                  color: Colors.black, // Color of the description text
                ),
              ),
              const SizedBox(height: 20), // Space before the button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BusinessInputPage()),
                  );
                },
                child: const Text(
                  "Go to Business Input",
                  style: TextStyle(
                    fontFamily: 'Zain-Regular', // Replace with your desired font family
                    fontSize: 24, // Editable font size for button text
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF230aef), // Base color
                  foregroundColor: Colors.white, // Button text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
class BusinessInputPage extends StatefulWidget {
  const BusinessInputPage({super.key});

  @override
  State<BusinessInputPage> createState() => _BusinessInputPageState();
}

class _BusinessInputPageState extends State<BusinessInputPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text("Loading suggested names...")),
            ],
          ),
        );
      },
    );
  }

  void _showProcessingPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text("Processing your request... Please wait."),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog(context); // Show loading dialog

      // Fetch name suggestions from the API
      final suggestions = await _fetchNameSuggestions();

      Navigator.of(context).pop(); // Dismiss loading dialog

      if (suggestions.isNotEmpty) {
        // Show dialog to select a name
        String? selectedName = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Choose a Business Name"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: suggestions.map((name) {
                    return ListTile(
                      title: Text(name),
                      onTap: () {
                        Navigator.of(context).pop(name); // Return the selected name
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog without selecting
                  },
                ),
              ],
            );
          },
        );

        if (selectedName != null) {
          // Proceed with the selected name
          _nameController.text = selectedName; // Set the selected name in the text field
          _launchBusiness(); // Call the method to launch the business
        }
      } else {
        // Handle case where no suggestions are available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No name suggestions available.')),
        );
      }
    }
  }

  Future<List<String>> _fetchNameSuggestions() async {
    final Map<String, dynamic> data = {
      'area': _areaController.text,
      'location': _locationController.text,
      'region': _regionController.text,
      'budget': double.tryParse(_budgetController.text) ?? 0.0,
      'concept': _conceptController.text,
      'logo_style': 'modern, sleek, contemporary', // Set default logo style
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/suggest_names'), // Ensure this is correct
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        return List<String>.from(results['suggestions'] ?? []);
      } else {
        throw Exception('Failed to fetch name suggestions: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  void _launchBusiness() async {
    // Prepare the data to send to the API
    String name = _nameController.text.isNotEmpty ? _nameController.text : "";
    String area = _areaController.text;
    String location = _locationController.text;
    String region = _regionController.text;
    double budget = double.tryParse(_budgetController.text) ?? 0.0;
    String concept = _conceptController.text;

    final Map<String, dynamic> data = {
      'name': name,
      'area': area,
      'location': location,
      'region': region,
      'budget': budget,
      'concept': concept,
      'logo_style': 'modern, sleek, contemporary', // Ensure this matches the LogoStyle enum
    };

    try {
      _showProcessingPage(context); // Show processing page

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/process_business'), // Replace with your server IP
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      Navigator.pop(context); // Dismiss processing page

      if (response.statusCode == 200) {
        final results = json.decode(response.body)['data'];

        // Ensure the API response contains the required fields
        String logoPath = results['logo_path'] ?? '';
        String marketingPlan = results['marketing_plan'] ?? ''; // Get the JSON string
        String businessPlan = results['business_plan'] ?? ''; // Get the plain text

        // Navigate to the results page with the actual data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessResultsPage(
              name: name, // Use the name from the text field
              logoPath: logoPath,
              marketingPlan: marketingPlan,
              businessPlan: businessPlan,
              area: area,
              location: location,
              region: region,
              budget: budget,
              concept: concept,
            ),
          ),
        );
      } else {
        throw Exception('Failed to generate business assets');
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss processing page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _loadLastSession() async {
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/load_last_session'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Populate the text fields with the loaded data
      _nameController.text = data['business_name'];
      _areaController.text = data['area'];
      _locationController.text = data['location'];
      _regionController.text = data['region'];
      _budgetController.text = data['budget'].toString();
      _conceptController.text = data['concept'];
      // Optionally, navigate to the results page or show a success message
    } else {
      throw Exception('Failed to load last session');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Input details and ideas"),
        backgroundColor: Color(0xFF230aef),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Enter a business name. But if you do not have one will be recommended",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: "Business Area",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: "Country/State",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: "Budget in Dollars",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _conceptController,
                decoration: const InputDecoration(
                  labelText: "Your Business Idea",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF230aef), // Base color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF230aef),
                      width: 2,
                    ),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                  child: const Text("Launch your Dream Business"),
                ),
                  const SizedBox(height: 10), // Add some space between the buttons
                  TextButton(
                    onPressed: _loadLastSession,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF230aef), // Text color
      ),
                  child: const Text("Load Your Last Session"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
class NameSuggestionsPage extends StatelessWidget {
  const NameSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy name suggestions for demonstration
    final List<String> nameSuggestions = [
      "Eco Fashion Co.",
      "Green Threads",
      "Sustainable Styles",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Name Suggestions"),
        backgroundColor: const Color(0xFF230aef),
      ),
      body: ListView.builder(
        itemCount: nameSuggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(nameSuggestions[index]),
            onTap: () {
              // When a name is selected, navigate back to the input page
              Navigator.pop(context, nameSuggestions[index]);
            },
          );
        },
      ),
    );
  }
}

class BusinessResultsPage extends StatelessWidget {
  final String? name;
  final String logoPath;
  final String marketingPlan; // Pass the marketing plan as a Map
  final String businessPlan; // Store the actual business plan text
  final String area;
  final String location;
  final String region;
  final double budget;
  final String concept;

  const BusinessResultsPage({
    super.key,
    this.name,
    required this.logoPath,
    required this.marketingPlan, // Pass the marketing plan as a Map
    required this.businessPlan, // Pass the business plan text
    required this.area,
    required this.location,
    required this.region,
    required this.budget,
    required this.concept,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Results"),
        backgroundColor: const Color(0xFF230aef),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text("Business Name"),
              subtitle: Text(name ?? 'no name'),
            ),
            ListTile(
              title: const Text("Logo"),
              subtitle: logoPath.isNotEmpty
                  ? Image.network(
                      logoPath,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Failed to load image');
                      },
                    )
                  : const Text('No logo available'),
            ),
            ExpansionTile(
              title: const Text("Marketing Plan"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(marketingPlan), // Display the marketing plan text directly
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Business Plan"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(businessPlan), // Display the business plan text
                ),
              ],
            ),
            ListTile(
              title: const Text("Area"),
              subtitle: Text(area),
            ),
            ListTile(
              title: const Text("Location"),
              subtitle: Text(location),
            ),
            ListTile(
              title: const Text("Region"),
              subtitle: Text(region),
            ),
            ListTile(
              title: const Text("Budget"),
              subtitle: Text('\$${budget.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text("Concept"),
              subtitle: Text(concept),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF230aef), // Base color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color(0xFF230aef),
                    width: 2,
                  ),
                ),
                elevation: 5,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Proceed"),
            ),
          ],
        ),
      ),
    );
  }
}