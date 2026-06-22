import 'package:flutter/material.dart';
import 'package:gardproject/Onboarding/first.dart';

class Zero extends StatefulWidget {
  const Zero({super.key});

  @override
  State<Zero> createState() => _ZeroState();
}

class _ZeroState extends State<Zero> {
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F4F4),
    body: SafeArea(
      child: Column(
        children: [
          const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 90),
         child:  Center(
            child: Image.asset(
              "images/Logo (1).png",
              width: 500, 
            ),
          ),),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              
              child: Row(
                
                children: [   
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),

                          backgroundColor: const Color(0xFFB5DD47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Onboarding1(),
                                ),
                              );
                        },
                        child: const Text(
                          "English",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB5DD47)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Onboarding1(),
                                ),
                              );},
                        child: const Text(
                          "Arabic",
                          style: TextStyle(color: Color(0xFFB5DD47), fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          );
  }
}