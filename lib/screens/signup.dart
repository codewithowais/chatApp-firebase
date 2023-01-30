import 'package:chatapp/helper/stoarage_helper.dart';
import 'package:chatapp/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

TextEditingController emailcontroller = TextEditingController();
TextEditingController passwordcontroller = TextEditingController();
TextEditingController usernamecontroller = TextEditingController();

FirebaseAuth auth = FirebaseAuth.instance;
var results;

Future signup1(context) async {
  if (results != null &&
      emailcontroller.text != "" &&
      usernamecontroller.text != "" &&
      passwordcontroller.text != "") {
    var folder = emailcontroller.text;
    Storage storageobj = Storage();
    var filename = results.files.single.name;
    var pathname = results.files.single.path;
    storageobj.uploadFile(pathname, folder, filename);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailcontroller.text, password: passwordcontroller.text);
      await FirebaseFirestore.instance.collection("user_detail").add({
        'email': emailcontroller.text,
        'username': usernamecontroller.text,
        'password': passwordcontroller.text,
        'profile': "profile/" + folder + "/" + results.files.single.name
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
      emailcontroller.clear();
      usernamecontroller.clear();
      passwordcontroller.clear();
      results = null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}

class _SignupState extends State<Signup> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.purple,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: const AssetImage(
                  "assets/images/logo.png",
                ),
                height: 150,
                width: MediaQuery.of(context).size.width,
              ),
              const Text(
                "Join the Baatcheet",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Stack(alignment: Alignment.bottomRight, children: [
                if (results != null)
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.12,
                    backgroundImage: FileImage(
                      File(results.files.single.path),
                    ),
                  ),
                InkWell(
                  onTap: () async {
                    results = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowMultiple: false,
                        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg']);
                    setState(() {
                      results = results;
                    });
                    if (results == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("content"),
                        ),
                      );
                    }
                    var pathname = results.files.single.path;
                  },
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.add,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ]),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    "Email",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    fillColor: Colors.purpleAccent,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(3)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  controller: emailcontroller,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    "Username",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    fillColor: Colors.purpleAccent,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(3)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  controller: usernamecontroller,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    "Password",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  obscureText: _isObscure,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    fillColor: Colors.purpleAccent,
                    filled: true,
                    suffixIcon: IconButton(
                        icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(3)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  controller: passwordcontroller,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.08,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: () {
                    signup1(context);
                  },
                  child: Text(
                    "Signup",
                    style: TextStyle(color: Colors.purple),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already hava an account ?",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          emailcontroller.clear();
                          usernamecontroller.clear();
                          passwordcontroller.clear();
                          results = null;
                        },
                        child: const Text(
                          " login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
