import 'package:ankleromapp/util/my_button.dart';
import 'package:ankleromapp/util/my_textfield.dart';
import 'package:ankleromapp/util/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();
  //sign user Up method
  Future<void>  signUserUp() async {

    //show loading circle
    showDialog(context: context, builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },);

    //try creating the user
    try{
      //check if password is confirmed
      if(passwordController.text == confirmedPasswordController.text){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context);
      }else{
        //show error messange, passwords do no match
        //Pop the circle
        Navigator.pop(context);
        showErrorMessage("Passwords don't match");
      }

    } on FirebaseAuthException catch (e){
      //Pop the circle
      Navigator.pop(context);
      showErrorMessage(e.code);
    }


  }

  //Wrong email message popup
  void showErrorMessage(String message){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(message,
              style: const TextStyle(color: Colors.white),
            ),
          )
      );
    },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[700],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50,),
                //Logo
                const Icon(Icons.lock,
                  size: 50,
                  color: Colors.black,),

                const SizedBox(height: 50,
                ),
                //Welcome back, You've been missed!

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lets Get You Started With An \n Account',
                      style: TextStyle(color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25,
                ),

                //Email textfield
                MyTextfield(
                  controller:emailController ,
                  hintText: 'Email Address',
                  obscurceText: false,
                ),

                const SizedBox(height: 10,
                ),

                //Password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscurceText: true,
                ),

                const SizedBox(height: 10),

                //Confirm Password textfield
                MyTextfield(
                  controller: confirmedPasswordController,
                  hintText: 'Confirm Password',
                  obscurceText: true,
                ),

                const SizedBox(height: 25,),
                //Sign Up Button
                MyButton(onTap: signUserUp, text: 'Sign Up',),

                const SizedBox(height: 50,),

                //Or Continue
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Or continue with',
                        style: TextStyle(color: Colors.white,
                            fontSize: 16),),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50,),
                //Google Sign In Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    //google
                    SquareTile(imagePath: 'lib/images/google.png'),

                    const SizedBox(width: 25),

                    //apple Id
                    SquareTile(imagePath: 'lib/images/apple.png')
                  ],),
                const SizedBox(height: 50),

                //Already have an account? Log in now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(fontSize: 16,
                        color: Colors.white),),
                    const SizedBox(width: 4,),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Login now', style: TextStyle(fontSize: 16,
                          color: Colors.black, fontWeight: FontWeight.bold),),
                    )
                  ],
                ),


              ],),
          ),
        )
    );
  }
}
