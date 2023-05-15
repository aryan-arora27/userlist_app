import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:user_list_app/model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _db = FirebaseFirestore.instance;
  double currentValue = 200;
  final _searchcontroller = TextEditingController();
  String search = '';

  List<bool> friend = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  Future getUserData() async {
    var response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    var jsonResponse = jsonDecode(response.body);
    List<User> users = [];
    // var collection = FirebaseFirestore.instance.collection('Users');
    // var snapshots = await collection.get();
    // for (var doc in snapshots.docs) {
    //   await doc.reference.delete();
    // }

    for (var u in jsonResponse) {
      int i = 0;
      bool exists = false;
      User user = User(u['name'], u['email'], u['address'], friend[i]);
      users.add(user);
      var collection = FirebaseFirestore.instance.collection('Users');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        if (doc.data()['Name'] == user.name) {
          exists = true;
        }
      }
      if (!exists) {
        createUser(user);
      }

      // createUser(user);

      // var snapshot = await _db.collection('Users').get();
      // for (var b in snapshot.docs) {
      //   if (b.data()['Name'] == user.name) {
      //     exists = true;
      //   }
      //   i++;
      // }
      // if (!exists) {
      //   print(snapshot.docs[i].data()['Name']);
      //   createUser(user);
      // }
    }

    // print(users[1].address['geo']['lat']);
    // print(users.length);
    // print(users);
    return users;
  }

  @override
  Widget build(BuildContext context) {
    Future userlist = getUserData();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0x0f1e1e1e),
      body: Container(
        padding: const EdgeInsets.only(bottom: 19),
        child: Container(
            padding: const EdgeInsets.only(bottom: 19),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1, -0.053),
                end: Alignment(1, -0.053),
                colors: <Color>[Color(0xff050505), Color(0xff00020c)],
                stops: <double>[0, 1],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 26),
              width: double.infinity,
              height: 980,
              child: Stack(
                children: [
                  const Image(image: AssetImage('assets/lines.png')),
                  Positioned(
                    left: 28,
                    top: 72,
                    child: Align(
                      child: SizedBox(
                        width: 77,
                        height: 39,
                        child: Text(
                          'Users',
                          style: GoogleFonts.openSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.3625,
                            color: const Color(0xffffffff),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 158,
                    left: 36,
                    right: 36,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: buildSearchTextFormField()),
                  ),
                  Positioned(
                      top: 220,
                      left: 36,
                      right: 36,
                      child: Slider(
                        min: -200,
                        max: 200,
                        label: "long.<= $currentValue",
                        divisions: 5,
                        value: currentValue,
                        onChanged: (value) {
                          setState(() {
                            currentValue = value;
                          });
                        },
                      )),
                  Container(
                    margin:
                        const EdgeInsets.only(top: 271, left: 24, right: 16),
                    child: Card(
                      color: const Color(0x0f1e1e1e),
                      child: FutureBuilder(
                        future: userlist,
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container();
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, i) {
                                  assignFriend(snapshot.data[i], i);
                                  return buildTiles(snapshot, i);
                                });
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  Container buildTiles(AsyncSnapshot<dynamic> snapshot, int i) {
    if (double.parse(snapshot.data[i].address['geo']['lng']) <= currentValue &&
        (search.isEmpty ||
            search == '' ||
            search == '' ||
            search.toLowerCase() ==
                snapshot.data[i].name.toString().toLowerCase() ||
            snapshot.data[i].name
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase()))) {
      return Container(
          margin: const EdgeInsets.only(top: 17),
          height: 170,
          child: GestureDetector(
            onTap: () {
              setState(() {
                updateUser(snapshot.data[i], i);
                // assignFriend();
                // friend[i] = !friend[i];
              });
              setState(() {});
            },
            child: Card(
              color: Colors.white54,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.5),
                    Colors.amber.withOpacity(0.3),
                    Colors.black54
                  ],
                  radius: 2,
                  center: Alignment.bottomRight,
                )),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 13, left: 20),
                        child: Text(
                          snapshot.data[i].name,
                          style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w700,
                              color: friend[i]
                                  ? Colors.amber
                                  : const Color(0xffeaeaf0),
                              height: 2,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5, left: 20),
                        child: Text(
                          snapshot.data[i].email,
                          style: GoogleFonts.openSans(
                              color: Colors.yellow, fontSize: 11.5),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, left: 20),
                        child: Text(
                          snapshot.data[i].address['street'] +
                              ' - ' +
                              snapshot.data[i].address['suite'],
                          style: GoogleFonts.openSans(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 3, left: 20),
                        child: Text(
                          snapshot.data[i].address['city'] +
                              ' - ' +
                              snapshot.data[i].address['zipcode'],
                          style: GoogleFonts.openSans(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, left: 20),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, left: 5),
                            child: Text(
                              snapshot.data[i].address['geo']['lng'],
                              style: GoogleFonts.openSans(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 114,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: Text(
                              '🕒  ' + snapshot.data[i].address['geo']['lat'],
                              style: GoogleFonts.openSans(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ));
    } else {
      return Container();
    }
  }

  TextFormField buildSearchTextFormField() {
    return TextFormField(
      style: GoogleFonts.openSans(color: const Color(0xFFCCCBCB)),
      controller: _searchcontroller,
      onChanged: (_searchcontroller) {
        setState(() {
          search = _searchcontroller;
        });
      },
      decoration: InputDecoration(
          prefixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: const Color(0xFFCCCBCB),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              _searchcontroller.clear();
              search = _searchcontroller.text;
              setState(() {});
            },
            icon: const Icon(Icons.clear),
            color: const Color(0xFFCCCBCB),
          ),
          filled: true,
          fillColor: const Color(0xFF8D848),
          hintText: "Search for name...",
          hintStyle: GoogleFonts.openSans(color: const Color(0xFFCCCBCB))),
    );
  }

  createUser(User user) async {
    await _db.collection("Users").add(user.toJson());
  }

  updateUser(User user, i) async {
    User newuser = User(user.name, user.email, user.address, !(user.friend));
    var collection = FirebaseFirestore.instance.collection('Users');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      if (doc.data()['Name'] == user.name) {
        await _db.collection("Users").doc(doc.id).update(newuser.toJson());
        friend[i] = !friend[i];
      }
    }
  }

  assignFriend(User user, int i) async {
    var collection = FirebaseFirestore.instance.collection('Users');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      if (doc.data()['Name'] == user.name) {
        friend[i] == doc.data()['friend'];
      }
    }
    print(friend);
  }
}
