import 'package:contact_list/home.screen.dart';
import 'package:contact_list/main.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ContactView extends StatefulWidget {
  final List<Map<String, dynamic>> contact;
  final int contactId;

  const ContactView({super.key, required this.contact, required this.contactId });

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {

  List<Map<String, dynamic>> contacts = [];
  int id = -1;

  static final myContact = Hive.box('contact');

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool loadingBtn = false;
  bool isNameEmpty = false;
  bool isPhoneEmpty = false;
  bool isEmailValid = true;

  IconData favIcon = Icons.star_border_purple500_outlined;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contacts = widget.contact;
    id = widget.contactId;
  }

  void updateFav() async {
   setState(() {
     contacts[id]['fav'] = !contacts[id]['fav'];
   });
   await myContact.put('contact_list', contacts);
  }

  void updateContact() async {
    setState(() {
      loadingBtn = true;
      contacts[id]['name'] = nameController.text;
      contacts[id]['phone'] = phoneController.text;
      contacts[id]['email'] = emailController.text;
    });
    await myContact.put('contact_list', contacts);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) {
                return const MyHomePage(title: 'My Contact');
              },
            ));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Contact View'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black12
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contacts[id]['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Mobile : '),
                        Text(
                          contacts[id]['phone'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17
                          ),
                        ),

                      ],
                    ),
                    contacts[id]['email'] != '' ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Email : '),
                        Text(
                          contacts[id]['email'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17
                          ),
                        ),
                      ],
                    ) : const SizedBox(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNavigator(icon: Icons.star_border_purple500_outlined, title: "Favourites", index: 0),
                    buildNavigator(icon: Icons.edit, title: "Edit", index: 1),
                    // buildNavigator(icon: Icons.delete, title: "Delete", index: 2),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavigator({required IconData icon, required String title, required int index}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            switch (index){
              case 0 : updateFav(); break;
              case 1 : _showEditPopup(); break;
              // case 2 : _showConfirmDelete(context, id); break;
            }
          },
          child: Icon(
            ((index == 0) && contacts[id]['fav']) ? Icons.star : icon,
            size: 25,
            color: ((index == 0) && contacts[id]['fav']) ? Colors.red : Colors.black,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 14
          ),
        )
      ],
    );
  }

  void _showEditPopup() {

    setState(() {
      nameController.text = contacts[id]['name'];
      phoneController.text = contacts[id]['phone'];
      emailController.text = contacts[id]['email'];
    });

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
                        margin: const EdgeInsets.only(top:2),
                        child: TextFormField(
                          controller: nameController,
                          onTap: (){
                            setState((){
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
                      isNameEmpty ? const Text(
                        'Name Can\'t be empty',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ) : const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(top:15,),
                        child: const Text("Phone"),
                      ),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top:2, bottom: 5),
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
                          onTap: (){
                            setState((){
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
                      isPhoneEmpty ? const Text(
                        'Phone Can\'t be empty',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      ) : const SizedBox(),
                      Container(
                        margin: const EdgeInsets.only(top:15,),
                        child: const Text("Email"),
                      ),
                      Container(
                        width: 260,
                        height: 40,
                        margin: const EdgeInsets.only(top:2),
                        child: TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value != null || value != "") {
                              setState((){
                                isEmailValid = false;
                              });
                              // add proper email validation

                              return 'Please enter Email';
                            } else {
                              setState((){
                                isEmailValid = true;
                              });
                              return null;
                            }
                          },
                          onTap: (){
                            setState((){
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
                    height: 40.0,
                    margin: const EdgeInsets.only(left: 0),
                    child: ElevatedButton(
                      onPressed: loadingBtn ? null : () {
                        setState((){
                          if(nameController.text == ''){
                            isNameEmpty = true;
                          }else{
                            isNameEmpty = false;
                          }
                          if(phoneController.text == ''){
                            isPhoneEmpty = true;
                          }else{
                            isPhoneEmpty = false;
                          }
                        });

                        if(!isNameEmpty && !isPhoneEmpty){
                          updateContact();
                          loadingBtn = false;
                          Navigator.pop(context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      child: Visibility(
                        visible: !loadingBtn,
                        replacement: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Update',
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
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.red
                      ),
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

}
