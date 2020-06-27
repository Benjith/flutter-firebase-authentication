import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication/cart_page.dart';
import 'package:firebase_authentication/login_page.dart';
import 'package:firebase_authentication/restaurant_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Authentication',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: LoginPage(),
      home: MyHomePage(
        title: 'Firebase auth',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  RestaurantModel _model;
  List<CategoryDish> _cartItems = [];
  Future<void> _fetchItems() async {
    try {
      final response =
          await http.get('https://www.mocky.io/v2/5dfccffc310000efc8d2c1ad');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // print(json[0]);
        setState(() {
          _model = RestaurantModel.fromJson(json[0]);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchItems();
      user = await auth.currentUser();
      // print(user.displayName);
      // print(user.uid);
      // print(user.phoneNumber);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return _model == null
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : DefaultTabController(
            length: _model.tableMenuList.length,
            child: Scaffold(
              drawer: Drawer(
                // Add a ListView to the drawer. This ensures the user can scroll
                // through the options in the drawer if there isn't enough vertical
                // space to fit everything.
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    if (user != null)
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0))),
                        child: DrawerHeader(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                radius: 50.0,
                                backgroundColor: Colors.amber,
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl)
                                    : null,
                              ),
                              Text(user.displayName ?? user.phoneNumber),
                              Text('ID : ${user.uid}')
                            ],
                          ),
                        ),
                      ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.signOutAlt),
                      title: Text('log out'),
                      onTap: () async {
                        await auth.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                    ),
                  ],
                ),
              ),
              appBar: AppBar(
                backgroundColor: Colors.white54,
                iconTheme: IconThemeData(color: Colors.black),
                actions: [
                  // IconButton(
                  //     icon: Icon(
                  //       Icons.restore_from_trash,
                  //     ),
                  //     onPressed: _fetchItems),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                          icon: Icon(
                            FontAwesomeIcons.cartPlus,
                          ),
                          onPressed: () async {
                            bool result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(
                                  cartItems: _cartItems,
                                ),
                              ),
                            );
                            if (result) {
                              setState(() {
                                _cartItems.clear();
                              });
                            }
                          }),
                      if (_cartItems.isNotEmpty)
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          minRadius: 8,
                          child: Text(
                            _cartItems.length.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                    ],
                  )
                ],
                bottom: TabBar(
                  isScrollable: true,
                  labelColor: Colors.pink,
                  indicatorColor: Colors.pink,
                  unselectedLabelColor: Colors.black,
                  tabs: _model.tableMenuList
                      .map((e) => Tab(
                            text: e.menuCategory,
                            // child: Expanded(child: Text(e.menuCategory,style: TextStyle(fontSize: 22),)),
                          ))
                      .toList(),
                ),
                // title: Text('Tabs Demo'),
              ),
              body: TabBarView(
                children: _model.tableMenuList
                    .map(
                      (e) => ListView.builder(
                        itemCount: e.categoryDishes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              ListTile(
                                isThreeLine: true,
                                leading: Icon(
                                  Icons.radio_button_checked,
                                  color: e.categoryDishes[index].dishType == 1
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                                title: Text(e.categoryDishes[index].dishName),
                                subtitle: Column(
                                  children: [
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('INR ' +
                                            e.categoryDishes[index].dishPrice
                                                .toString() +
                                            '₹'),
                                        Text(e.categoryDishes[index]
                                                .dishCalories
                                                .toString() +
                                            ' Calories'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(e
                                        .categoryDishes[index].dishDescription),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  for (var item in _cartItems) {
                                                    if (item.dishId ==
                                                        e.categoryDishes[index]
                                                            .dishId) {
                                                      _cartItems.remove(item);
                                                      return;
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          _cartItems.contains(
                                                  e.categoryDishes[index])
                                              ? Text(
                                                  _cartItems
                                                      .where((item) =>
                                                          item.dishId ==
                                                          e
                                                              .categoryDishes[
                                                                  index]
                                                              .dishId)
                                                      .length
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              : Text(
                                                  '0',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                          Expanded(
                                            child: IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  _cartItems.add(
                                                      e.categoryDishes[index]);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    if (e.categoryDishes[index].addonCat
                                        .isNotEmpty)
                                      Text(
                                        'Customization available',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                  ],
                                ),
                                trailing: Image.network(
                                  e.categoryDishes[index].dishImage,
                                  fit: BoxFit.fill,
                                  height: 70,
                                  width: 70,
                                ),
                              ),
                              Divider(
                                color: Colors.black45,
                              ),
                            ],
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          );
  }
}
