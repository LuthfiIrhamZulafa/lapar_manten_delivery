import 'package:flutter/material.dart';
import '../services/otp_service.dart';


class OtpVerificationPage extends StatefulWidget{

  


final String email;


const OtpVerificationPage({
super.key,
required this.email,
});


@override
State<OtpVerificationPage> createState()
=> _OtpVerificationPageState();

}



class _OtpVerificationPageState
extends State<OtpVerificationPage>{

final OtpService otpService = OtpService();
bool loading = false;

final TextEditingController otpController =
TextEditingController();



@override
Widget build(BuildContext context){


return Scaffold(

appBar:
AppBar(
title:
const Text("Verifikasi OTP"),
),


body:
Padding(

padding:
const EdgeInsets.all(20),


child:
Column(

children:[


Text(
"Kode dikirim ke ${widget.email}"
),


TextField(

controller:
otpController,

keyboardType:
TextInputType.number,

decoration:
const InputDecoration(

labelText:
"Masukkan OTP"

),

),



ElevatedButton(

child:
const Text("Verifikasi"),


onPressed:() async{


setState((){

loading=true;

});



final result =
await otpService.verifyOtp(

widget.email,

otpController.text,

);



setState((){

loading=false;

});



if(result){


Navigator.pop(
context,
true
);


}else{


ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

content:
Text(
"OTP salah atau sudah kadaluarsa"
)

),

);


}


},

)


],


),

),

);


}


}