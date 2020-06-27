import 'package:firebase_authentication/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  String actualCode;
  String phone = '+919809802233';
  @override
  Widget build(BuildContext context) {
    onAuthenticationSuccessful() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  title: 'Firebase auth',
                )));
    Future<FirebaseUser> googleLogin() async {
      try {
        final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final FirebaseUser user =
            (await _auth.signInWithCredential(credential)).user;
        print("signed in " + user.displayName);
        onAuthenticationSuccessful();
        return user;
      } catch (e) {
        print(e.toString());
      }
    }

    String status = '';
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        status = '${authException.message}';

        print("Error message: " + status);
        if (authException.message.contains('not authorized'))
          status = 'Something has gone wrong, please try later';
        else if (authException.message.contains('Network'))
          status = 'Please check your internet connection and try again';
        else
          status = 'Something has gone wrong, please try later';
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.actualCode = verificationId;
      setState(() {
        status = "\nAuto retrieval time out";
      });
    };
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      TextEditingController _codeController = TextEditingController();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text("Enter SMS Code"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Done"),
                    textColor: Colors.white,
                    color: Colors.redAccent,  
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;

                      String smsCode = _codeController.text.trim();

                      AuthCredential _credential =
                          PhoneAuthProvider.getCredential(
                              verificationId: verificationId, smsCode: smsCode);
                      auth
                          .signInWithCredential(_credential)
                          .then((AuthResult result) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage(
                                      title: 'Firebase Auth',
                                    )));
                      }).catchError((e) {
                        print(e);
                        Navigator.pop(context);
                      });
                    },
                  )
                ],
              ));
    };
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
      setState(() {
        status = 'Auto retrieving verification code';
      });
      //_authCredential = auth;

      _auth.signInWithCredential(auth).then((AuthResult value) {
        if (value.user != null) {
          setState(() {
            status = 'Authentication successful';
          });
          onAuthenticationSuccessful();
        } else {
          setState(() {
            status = 'Invalid code/invalid authentication';
          });
        }
      }).catchError((error) {
        setState(() {
          status = 'Something has gone wrong, please try later';
        });
      });
    };

    Future<FirebaseUser> phoneLogin() async {
      await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    }

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                // child: Text('Company Logo'),
                child: Image.asset('image/logo.png'),
              ),
            ),
            Flexible(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  color: Color(0xff4c8bf5),
                  child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                    ),
                    onTap: () => googleLogin(),
                    trailing: Icon(Icons.phone, color: Color(0xff4c8bf5)),
                    title: Text(
                      'Google',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  color: Colors.green,
                  child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.phoneAlt,
                      color: Colors.white,
                    ),
                    onTap: () => phoneLogin(),
                    trailing: Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                    title: Text(
                      'Phone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      )),
    );
  }
}
