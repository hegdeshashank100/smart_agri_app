import 'package:flutter/material.dart';
import 'package:smartagri/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService auth = AuthService();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Home
        break;
      case 1: // Weather
        Navigator.pushNamed(context, '/city_search');
        break;
      case 2: // Diseases
        Navigator.pushNamed(context, '/disease_library');
        break;
      case 3: // AI
        Navigator.pushNamed(context, '/homeai');
        break;
      case 4: // Logout
        _confirmLogout();
        break;
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Welcome to SmartAgri',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/smart_agri_logo.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About SmartAgri',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'SmartAgri is an innovative solution designed to help arecanut farmers with:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletPoint(
                  text: 'Accurate weather forecasts for your farm location',
                ),
                _BulletPoint(text: 'Comprehensive arecanut disease library'),
                _BulletPoint(
                  text: 'Early disease detection and prevention tips',
                ),
                _BulletPoint(text: 'Personalized farming recommendations'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How to Use',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberedStep(
                  number: 1,
                  text: 'Check weather for your farm location',
                ),
                _NumberedStep(
                  number: 2,
                  text: 'Browse disease library for information',
                ),
                _NumberedStep(
                  number: 3,
                  text: 'Get alerts for potential disease risks',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartAgri Home'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: _buildHomeContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Diseases',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ', style: const TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
