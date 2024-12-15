import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(RandomJokeApp());
}

class RandomJokeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Joke App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JokeScreen(),
    );
  }
}

class JokeScreen extends StatefulWidget {
  @override
  _JokeScreenState createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> with SingleTickerProviderStateMixin {
  String _joke = 'Press the button to get a joke!';
  bool _isLoading = false;
  bool _isError = false;

  late AnimationController _controller;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: Colors.blue.shade300,
      end: Colors.blue.shade100,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchJoke() async {
    const url = 'https://official-joke-api.appspot.com/random_joke';

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _joke = "${data['setup']} - ${data['punchline']}";
          _isError = false;
        });
      } else {
        setState(() {
          _joke = 'Failed to load joke. Try again!';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _joke = 'Failed to load joke. Check your connection.';
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showReactionPopup(bool isFunny) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isFunny ? "Glad You Liked It!" : "We'll Try Better Next Time!",
            style: TextStyle(color: isFunny ? Colors.green : Colors.red),
          ),
          content: Text(
            isFunny
                ? "Thank you for appreciating the humor! 😂"
                : "Sorry the joke didn't land. We'll find a better one! 🙁",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade800,
            title: Text(
              'Random Joke App',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value!,
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      Text(
                        _joke,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _isError ? Colors.red : Colors.black87,
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : fetchJoke,
                      child: Text(_isError ? 'Retry' : 'Get Joke'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                    if (!_isLoading && !_isError && _joke != 'Press the button to get a joke!')
                      Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Was the joke funny?",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _showReactionPopup(true),
                                child: Text("Funny 😂"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _showReactionPopup(false),
                                child: Text("Not Funny 🙁"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
