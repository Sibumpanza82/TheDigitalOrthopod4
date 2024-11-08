import 'package:ankleromapp/util/my_button.dart';
import 'package:ankleromapp/util/my_textfield.dart';
import 'package:ankleromapp/util/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final Function()? onTap;
   const Login({
     super.key,
   required this.onTap
   });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
   Future<void>  signUserIn() async {

     //show loading circle
     showDialog(context: context, builder: (context) {
       return const Center(
         child: CircularProgressIndicator(),
       );
     },);
     try{
       await FirebaseAuth.instance.signInWithEmailAndPassword(
           email: emailController.text,
           password: passwordController.text,
       );

       //Pop the circle
       Navigator.pop(context);

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
            size: 100,
            color: Colors.black,),

            const SizedBox(height: 50,
            ),
            //Welcome back, You've been missed!

              Text('Welcome Back',
              style: TextStyle(color: Colors.white,
              fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
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

              //Forgot Password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Forgot Password?',
                    style: TextStyle(color: Colors.white,
                    fontSize: 16,),
                    ),
                  ],
                ),
              ),

          const SizedBox(height: 25,),
            //Sign In Button
            MyButton(onTap: signUserIn, text: 'Sign In',),

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
            //Not a member? Register Now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Not a member?', style: TextStyle(fontSize: 16,
                color: Colors.white),),
                const SizedBox(width: 4,),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text('Register now', style: TextStyle(fontSize: 16,
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
