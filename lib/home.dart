import 'package:flutter/material.dart';
import 'package:qwixo/auth.dart';
import 'package:qwixo/screens/localstorage.dart';
import 'package:qwixo/screens/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showLogout = false;

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
          if (scrollInfo.metrics.pixels > 100 && !_showLogout) {
            setState(() => _showLogout = true);
          } else if (scrollInfo.metrics.pixels <= 100 && _showLogout) {
            setState(() => _showLogout = false);
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
                    title: Align(
                      // duration: const Duration(milliseconds: 100),
                      alignment: collapseRatio > 0.5
                          ? Alignment.bottomCenter
                          : Alignment.bottomLeft,
                      child: Text(
                        'Chats',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                return Container(
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
