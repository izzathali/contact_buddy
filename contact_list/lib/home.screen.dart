import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:contact_list/contact_view.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loadingBtn = false;
  bool loading = true;
  bool isNameEmpty = false;
  bool isPhoneEmpty = false;
  bool isEmailValid = true;

  static final myContact = Hive.box('contact');
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContacts();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    final PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
    } else {}
  }

  void addContact() async {
    setState(() {
      loadingBtn = true;
    });
    var tempContacts = await myContact.get('contact_list');

    Map<String, dynamic> value = {
      "name": nameController.text,
      "phone": phoneController.text,
      "email": emailController.text,
      "fav": false,
    };

    tempContacts.add(value);
    await myContact.put('contact_list', tempContacts);
    getContacts();

    nameController.text = '';
    phoneController.text = '';
    emailController.text = '';
  }

  void getContacts() async {
    setState(() {
      loading = true;
    });
    var tempContacts = await myContact.get('contact_list');

    setState(() {
      contacts = List<Map<String, dynamic>>.from(
        tempContacts.map((dynamic element) {
          return Map<String, dynamic>.from(element);
        }),
      );
    });

    setState(() {
      loading = false;
    });
  }

  String getShortName(String name) {
    List<String> result = name.split(" ");
    String shortName = "N/A";

    if (result.length >= 2) {
      shortName = "${result[0][0]}${result[1][0]}";
    } else if (result.length == 1) {
      shortName = result[0][0];
    }

    return shortName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(contacts: contacts));
            },
            icon: const Icon(
              Icons.search,
              size: 30,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Visibility(
          visible: !loading,
          replacement: const Center(child: CircularProgressIndicator()),
          child: contacts.isEmpty
              ? const Center(
                  child: Text(
                    "No Contacts to Display!",
                    style: TextStyle(fontSize: 15),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 350,
                          child: ListView.builder(
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                // print("at list view builder");
                                // print(contacts.length);
                                return buildTile(
                                    id: index, name: contacts[index]['name']);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNewTeam();
        },
        tooltip: 'Add new',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNewTeam() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add New Contact",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      nameController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close)),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Name"),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top: 2),
                        child: TextFormField(
                          controller: nameController,
                          onTap: () {
                            setState(() {
                              isNameEmpty = false;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            hintText: 'Name',
                            filled: true,
                            fillColor: Color.fromRGBO(228, 226, 226, 0.6),
                            contentPadding: EdgeInsets.all(5),
                          ),
                        ),
                      ),
                      isNameEmpty
                          ? const Text(
                              'Name Can\'t be empty',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                            )
                          : const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: const Text("Phone"),
                      ),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top: 2, bottom: 5),
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Phone';
                            } else {
                              return null;
                            }
                          },
                          onTap: () {
                            setState(() {
                              // nameExists = false;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            hintText: 'Phone',
                            filled: true,
                            fillColor: Color.fromRGBO(228, 226, 226, 0.6),
                            contentPadding: EdgeInsets.all(5),
                            // errorText: nameExists ? 'Name Already Exists': '',
                          ),
                        ),
                      ),
                      isPhoneEmpty
                          ? const Text(
                              'Phone Can\'t be empty',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                            )
                          : const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: const Text("Email"),
                      ),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top: 2),
                        child: TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value != null || value != "") {
                              setState(() {
                                isEmailValid = false;
                              });
                              // add proper email validation

                              return 'Please enter Email';
                            } else {
                              setState(() {
                                isEmailValid = true;
                              });
                              return null;
                            }
                          },
                          onTap: () {
                            setState(() {
                              // nameExists = false;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            hintText: 'Email',
                            filled: true,
                            fillColor: Color.fromRGBO(228, 226, 226, 0.6),
                            contentPadding: EdgeInsets.all(5),
                            // errorText: nameExists ? 'Name Already Exists': '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.0,
                    height: 40.0,
                    margin: const EdgeInsets.only(left: 0),
                    child: ElevatedButton(
                      onPressed: loadingBtn
                          ? null
                          : () {
                              setState(() {
                                if (nameController.text == '') {
                                  isNameEmpty = true;
                                } else {
                                  isNameEmpty = false;
                                }
                                if (phoneController.text == '') {
                                  isPhoneEmpty = true;
                                } else {
                                  isPhoneEmpty = false;
                                }
                              });

                              if (!isNameEmpty && !isPhoneEmpty) {
                                addContact();
                                loadingBtn = false;
                                Navigator.of(context).pop();
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.orange),
                      ),
                      child: Visibility(
                        visible: !loadingBtn,
                        replacement: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      nameController.text = "";
                      phoneController.text = "";
                      emailController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  Widget buildTile({required int id, required name}) {
    Color randomColor = getRandomColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) {
              return ContactView(contactId: id, contact: contacts);
            },
          ));
        },
        onLongPress: () {
          _showConfirmDelete(context, id);
        },
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: -4, vertical: 4),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: Colors.black12,
          contentPadding: const EdgeInsets.only(
              left: 2.0, right: 8.0, top: 0.0, bottom: 0.0),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  width: 1.5,
                  color: Colors.black54,
                ),
                color: randomColor),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              getShortName(name),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 17),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
          ),
          trailing: contacts[id]['fav']
              ? const SizedBox(
                  width: 35,
                  child: Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 20,
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  Color getRandomColor() {
    // Generate random values for RGB
    final Random random = Random();
    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);

    // Return a Color object with the generated values
    return Color.fromARGB(255, red, green, blue);
  }

  void _showConfirmDelete(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Are you sure you want to delete ${contacts[index]['name']}?',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        contacts.removeAt(index);
                      });
                      await myContact.put('contact_list', contacts);
                      Navigator.pop(context);
                    },
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> contacts;
  List<String> searchContact = [];

  CustomSearchDelegate({required this.contacts});

// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> matchQuery2 = [];
    List<int> contactId = [];

    for (var i = 0; i < contacts.length; i++) {
      if ((contacts[i]['name'].toLowerCase().contains(query.toLowerCase())) ||
          (contacts[i]['phone'].toLowerCase().contains(query.toLowerCase()))) {
        matchQuery2.add(contacts[i]);
        contactId.add(i);
      }
    }
    return ListView.builder(
      itemCount: matchQuery2.length,
      itemBuilder: (context, index) {
        var result = matchQuery2[index];
        var id = contactId[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) {
                return ContactView(contactId: id, contact: contacts);
              },
            ));
          },
          child: ListTile(
            title: Text(result['name']),
            subtitle: Text(result['phone']),
          ),
        );
      },
    );
  }

// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery2 = [];
    List<int> contactId = [];

    for (var i = 0; i < contacts.length; i++) {
      if ((contacts[i]['name'].toLowerCase().contains(query.toLowerCase())) ||
          (contacts[i]['phone'].toLowerCase().contains(query.toLowerCase()))) {
        matchQuery2.add(contacts[i]);
        contactId.add(i);
      }
    }
    return ListView.builder(
      itemCount: matchQuery2.length > 5 ? 5 : matchQuery2.length,
      itemBuilder: (context, index) {
        var result = matchQuery2[index];
        var id = contactId[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) {
                return ContactView(contactId: id, contact: contacts);
              },
            ));
          },
          child: ListTile(
            title: Text(result['name']),
            subtitle: Text(result['phone']),
          ),
        );
      },
    );
  }
}
