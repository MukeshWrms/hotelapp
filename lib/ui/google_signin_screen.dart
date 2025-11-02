import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  GoogleSignInAccount? _user;
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _checkSignedIn();
  }

  Future<void> _checkSignedIn() async {
    // Auto sign-in if already logged in
    final account = await _googleSignIn.signInSilently();
    if (account != null && mounted) {
      setState(() => _user = account);
      _navigateToDashboard(account);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account != null && mounted) {
        setState(() => _user = account);
        _navigateToDashboard(account);
      }
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-In failed: $error')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard(GoogleSignInAccount account) {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         DashboardScreen(user: account, googleSignIn: _googleSignIn),
    //   ),
    // );
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() => _user = null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSignInUI() {
    return FadeTransition(
      opacity: _fadeIn,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Text(
            "Welcome to MyHotX",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Sign in with your Google Account",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            icon: Image.asset('assets/google.jpeg', height: 24),
            label: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _user == null
                  ? _buildSignInUI()
                  : const CircularProgressIndicator(), // Just to show while redirecting
            ),
          ),
        ),
      ),
    );
  }
}
