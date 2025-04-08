import 'package:barmate/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:barmate/Utils/colors.dart';
import 'package:barmate/screens/sign_up.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

final authService = AuthService();
final emailController = TextEditingController();
final passwordController = TextEditingController();

bool seeablePassword = true;

void login() async {
  final email = emailController.text;
  final password = passwordController.text;
  try {
    await authService.signInWithEmailPassword(email, password);
    if (!mounted) return; // Ensure the widget is still mounted
    Navigator.pop(context); // Navigate to the home screen
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [backgroundColor2, backgroundColor2, backgroundColor4],
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              SizedBox(height: size.height * 0.06),
              Text(
                "Hello Again!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor1,
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome back to Barmate\nyou've been missed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor2,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.08),
              myTextField("email", Colors.black45, emailController),
              myTextField("password", Colors.black45, passwordController, seeable: seeablePassword),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Forgot Password?           ",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: textColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: login,
                      child: Container(
                        width: size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: size.width * 0.2,
                          color: Colors.white,
                        ),
                        Text(
                          "   or continue with   ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: textColor2,
                          ),
                        ),
                        Container(
                          height: 2,
                          width: size.width * 0.2,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        socialIcon("images/google.png"),
                        socialIcon("images/apple.png"),
                        socialIcon("images/facebook.png"),
                      ],
                    ),
                    SizedBox(height: size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a member?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor2,
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            "   Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                          onTap: () => {
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUp(),
                                  ),
                                ),
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container socialIcon(image) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Image.asset(image, height: 35),
    );
  }

  Container myTextField(String hintText, Color color, TextEditingController controller, {bool seeable = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        obscureText: seeable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black45, fontSize: 19),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                seeablePassword = !seeablePassword;
              });
            },
            child: Icon(Icons.visibility_off_outlined, color: color),
          ),
        ),
      ),
    );
  }
}
