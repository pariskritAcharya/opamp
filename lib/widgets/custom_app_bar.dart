import 'package:flutter/material.dart';
import '../pages/homescreen.dart';

class CustomOpAmpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomOpAmpAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // Hides the default back arrow
      actions: [Container()], // Hides the default hamburger icon so we can use our custom text
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
                child: const Text("OP AMP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
          Row(
            children: [
              // Builder is required here so Scaffold.of() can find the Scaffold that owns this AppBar
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: const Text("Index", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.black)),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
                child: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Required when implementing PreferredSizeWidget for custom AppBars
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}