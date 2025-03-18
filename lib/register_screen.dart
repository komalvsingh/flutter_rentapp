import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_app/login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  String _errorMessage = "";
  bool _isEmailSent = false;

  Future<void> _register(BuildContext context) async {
    // Validate input
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Email and password cannot be empty";
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    // Clear previous errors
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Verification email sent. Please check your inbox.')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getReadableErrorMessage(e);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Registration failed: ${_getReadableErrorMessage(e)}')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An unexpected error occurred: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  String _getReadableErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'weak-password':
        return 'The password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return e.message ?? 'An unknown error occurred';
    }
  }

  void _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Reload user to get fresh data
      await _auth.currentUser?.reload();
      User? user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Email not verified yet. Please check your inbox.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to check verification status: $e";
      });
    }
  }

  void _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.currentUser?.sendEmailVerification();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Verification email sent again. Please check your inbox.')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to resend verification email: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend email: $e')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 152, 118, 246), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  if (!_isEmailSent) ...[
                    TextField(
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onEditingComplete: () =>
                          _passwordFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: passwordController,
                      focusNode: _passwordFocusNode,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onEditingComplete: () =>
                          _confirmPasswordFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      decoration: const InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onEditingComplete: () => _register(context),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _register(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Register"),
                    ),
                  ],
                  if (_isEmailSent) ...[
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'We\'ve sent a verification email to your address. Please check your inbox and click the verification link.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkEmailVerification,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("I've Verified My Email"),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: _isLoading ? null : _resendVerificationEmail,
                      child: const Text("Resend Verification Email"),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Or continue with"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.g_mobiledata,
                            color: Color.fromARGB(255, 128, 19, 236)),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.facebook,
                            color: Colors.deepPurple),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
