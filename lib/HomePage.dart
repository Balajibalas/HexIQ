import 'package:flutter/material.dart';
import 'package:hexiq/company.dart';
import 'package:hexiq/person.dart';
import 'package:hexiq/product.dart';
import 'package:hexiq/quiz.dart';
import 'package:video_player/video_player.dart';
import 'package:hexiq/LoginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late VideoPlayerController _controller;
  int id = 0; // Public variable to hold the user ID
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/background.mp4')
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _getCurrentUserId(); // Get the current user ID on init
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _getCurrentUserId() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await _supabase
          .from('user_id')
          .select('id')
          .eq('email', user.email ?? '')
          .single();

   
        setState(() {
          id = response['id']; // Assign the ID to the public variable
        });
      
    } else {
      _showErrorMessage('User not logged in.');
    }
  }

  Widget _buildMenuButton(String title, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between elements
    children: [
      SizedBox(width: 0), // Left padding (adjust as needed)
      Text(
        "HexIQ",
        style: TextStyle(
          fontSize: 36, // Adjust the font size to make it bigger
          color: Colors.white, // Set the color to white
          fontWeight: FontWeight.bold, // Make it bold (optional)
        ),
      ),
      SizedBox(width: 75), // Right padding (adjust as needed)
    ],
  ),
  toolbarHeight: 80, // Optionally adjust the height of the AppBar
),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          _buildMenuButton('Person', Icons.person, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonPage(userId: id),
                              ),
                            );
                          }),
                          _buildMenuButton('Product', Icons.shopping_bag, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductPage(userId: id),
                              ),
                            );
                          }),
                          _buildMenuButton('Company', Icons.business, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompanyPage(userId: id),
                              ),
                            );
                          }),
                          _buildMenuButton('Quiz', Icons.quiz, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(userId: id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
