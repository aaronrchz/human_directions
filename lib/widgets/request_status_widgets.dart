import 'package:flutter/material.dart';

/*Status waiting for user input*/
class WaitingForUserInput extends StatelessWidget{
  const WaitingForUserInput({super.key});
  @override
  Widget build(BuildContext context){
    return const Text('Waiting For User input');
  }
}
/*Waiting for request result */
class WaitingRequestResult extends StatefulWidget{
  const WaitingRequestResult({required this.statusMessage,super.key});
  final String statusMessage;
  @override
  State<WaitingRequestResult> createState() => _WaitingRequestResultState();
}

class _WaitingRequestResultState extends State<WaitingRequestResult>{
  @override
  Widget build(BuildContext context){
    return  Column(
    children: [
      Text(widget.statusMessage), 
      const CircularProgressIndicator(),
    ],
  );
  }
}