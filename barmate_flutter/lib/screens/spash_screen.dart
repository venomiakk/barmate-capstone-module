import 'package:barmate/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:barmate/Utils/colors.dart';
import 'package:barmate/screens/sign_in.dart'; // Ensure this is the correct path to the SignIn class

class SpashScreen extends StatelessWidget {
  const SpashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: backgroundColor1,
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size.height * 0.5,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    image: const DecorationImage(
                      image: AssetImage('images/spash_screen3.jpg'),
                      fit: BoxFit.fill
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(50),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.6,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Discover your dream drink",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor1,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Explore the best drinks in the world",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor2,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.07),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        height: size.height * 0.08,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: backgroundColor3,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset:const Offset(0, -1),
                              )
                              ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Row(children: [
                            GestureDetector(
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUp(),
                                  ),
                                ),
                              },
                              child: Container(
                                height: size.height * 0.08,
                                width: size.width /2.2,
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text("Sign Up",style: TextStyle(
                                    color: textColor1,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignIn(),
                                  ),
                                ),
                              },
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  color: textColor1,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ]),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
