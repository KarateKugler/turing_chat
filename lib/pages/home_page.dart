import 'package:flutter/material.dart';

import '../widgets/add_friend_button.dart';
import '../widgets/home_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
      appBar: AppBar(title: Text('⌘  t u r i n g . c h a t  ⍜'), centerTitle: true,),
      body: ListView.builder(
        itemBuilder: (context, index) {
          /// The List of Chat Rooms with Friends
          return;
        },
      ),
      floatingActionButton: const AddFriendButton(),
    );
  }
}
