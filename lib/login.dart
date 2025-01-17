import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:health_wellness/dashboard_screen.dart';
import 'package:health_wellness/reset_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'services/api_services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var isChecked = false;
  var isLoading = false;
  bool passwordVisible = false;

  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F7),
      appBar: null,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(45.0, 100.0, 45.0, 30.0),
          children: [
            SizedBox(
                height: 250,
                width: 250,
                child: Image(image: AssetImage('assets/Images/login.png'))),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top:30.0),
                child: Text(
                  "Welcome To HELTHYR",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 25),
              child: TextFormField(
                  controller: controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                      return 'Enter a valid email!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    //<-- SEE HERE
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    hintText: 'Enter your Email',
                    labelText: "Email",
                    
                  )),
            ),
            Container(
              margin: EdgeInsets.only(top: 18),
              child: TextFormField(
                  obscureText: passwordVisible,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 3) {
                      return 'Enter a valid password!';
                    }
                    return null;
                  },
                  controller: controllerPassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      filled: true,
                      //<-- SEE HERE
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      hintText: 'Enter your Password',
                      labelText: "Password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(
                            () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        },
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ))),
            ),
            ListTileTheme(
              contentPadding: EdgeInsets.only(right: 20.0),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Align(
                  alignment: Alignment(-1.5, 0),
                  child: Text("I agree with term & condition and privacy policy",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),)),
                checkColor: Colors.white,
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: SizedBox(
                height: 52,
                child: isLoading
                    ? CupertinoActivityIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final isValid = _formKey.currentState!.validate();
                          if (isValid) {
                            if (!isChecked) {
                              Fluttertoast.showToast(
                                  msg: "Please check term & condition");
                              return;
                            }
                            setState(() => isLoading = true);
                            var email = controllerEmail.text;
                            var password = controllerPassword.text;
                            var result =
                                await ApiService().getUser(email, password);
                            print("resultresult_${result}");
                            if (result.containsKey('errors')) {
                              Fluttertoast.showToast(
                                  msg: result["errors"]["email"][0]);
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            setState(() {
                              isLoading = false;
                            });
                            prefs.setString("_result", jsonEncode(result));
                            prefs.setString("_token", result['data']['token']);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) {
                                var login_histories = result['data']['user']
                                    ['login_histories'] as List;
                                var token = result['data']['token'];
                                debugPrint('user token ==> $token');
                                debugPrint('user token ==> $userInput');
                                return login_histories.isEmpty
                                    ? ResetPass(result)
                                    : DashboardScreen(result);
                              }), ((route) {
                                return false;
                              }
                            )
                            );
                          }
                        },
                        child: const Text(
                          '  Login  ',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0)),
                          backgroundColor: Color(0xFFF6A03D),
                          // onSurface:
                          //     Colors.transparent,
                          shadowColor: Colors.red.shade300,
                        ),
                      ),
              ),
            ),
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: Text("Forget Password?", style: TextStyle(fontSize: 15)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
