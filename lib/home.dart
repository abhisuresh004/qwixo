import 'package:flutter/material.dart';
import 'package:qwixo/auth.dart';
import 'package:qwixo/localstorage.dart';
import 'package:qwixo/screens/chat.dart';
import 'package:qwixo/screens/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showLogout = false;
  bool _showusername = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhoto = '';

  // logout
  void showlogoutdialoug(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await Authservices().Signout();
              await Localstorage.cleardata();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  //load usedata

  Future<void> loaduserdata() async {
    final userData = await Localstorage.getuser();
    setState(() {
      _userName = userData['name'] ?? '';
      _userEmail = userData['email'] ?? '';
      _userPhoto = userData['photourl'] ?? '';
    });
  }

  void initState() {
    super.initState();
    loaduserdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,

      // appBar: AppBar(
      //   title: Center(
      //     child: Text('Chats', style: TextStyle(color: Colors.white)),
      //   ),
      //   backgroundColor: Colors.deepPurple,
      // ),
      // body: Container(
      //   decoration: BoxDecoration(
      //     color: Colors.
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(30),
      //       topRight: Radius.circular(30),
      //     ),
      //   ),
      //   height: double.infinity,
      //   width: double.infinity,
      //   child: ListView.builder(
      //     itemCount: 10,
      //     itemBuilder: (context, index) {
      //       return ListTile(
      //         hoverColor: Colors.white,
      //         leading: CircleAvatar(),
      //         title: Text('Name'),
      //         subtitle: Text('data'),
      //       );
      //     },
      //   ),
      // ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          // When scrolled enough, show logout button
          if (scrollInfo.metrics.pixels > 100 &&
              !_showLogout &&
              !_showusername) {
            setState(() => _showLogout = true);
            setState(() => _showusername = true);
          } else if (scrollInfo.metrics.pixels <= 100 &&
              _showLogout &&
              _showusername) {
            setState(() => _showLogout = false);
            setState(() => _showusername = false);
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.deepPurple,

              pinned: true,
              floating: true,
              snap: true,
              centerTitle: true,
              stretch: true,
              expandedHeight: 200,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final collapseRatio =
                      (constraints.maxHeight - kToolbarHeight) /
                      (200 - kToolbarHeight);
                  return FlexibleSpaceBar(
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _userPhoto.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(_userPhoto),
                                  radius: 18,
                                )
                              : const CircleAvatar(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10,),
                          AnimatedOpacity(
                            opacity: _showusername ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 300),
                            child: Text(_userName,style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     _userPhoto.isNotEmpty
                      //         ? CircleAvatar(
                      //             backgroundImage: NetworkImage(_userPhoto),
                      //             radius: 18,
                      //           )
                      //         : const CircleAvatar(
                      //             child: Icon(
                      //               Icons.person,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //     // ✅ User profile photo
                      //     Text(
                      //       'Chats',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    
                    centerTitle: true,
                  );
                },
              ),
              // bottom: PreferredSize(
              //   preferredSize: Size.fromHeight(60),
              //   child: Container(
              //     padding: EdgeInsets.all(3),
              //     height: 50,
              //     child: TextFormField(
              //       decoration: InputDecoration(
              //         labelText: "Search...",
              //         prefixIcon: Icon(Icons.search),
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              actions: [
                AnimatedOpacity(
                  opacity: _showLogout ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => showlogoutdialoug(context),
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  },
                  child: Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.only(
                    //     topLeft: Radius.circular(30),
                    //     topRight: Radius.circular(30),
                    //   ),
                    // ),
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(),
                      title: Text('name'),
                      subtitle: Text('mesage'),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
