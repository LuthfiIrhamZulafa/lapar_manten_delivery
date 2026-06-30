import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class ShareLocationPage extends StatefulWidget{


final String orderId;


const ShareLocationPage({

super.key,

required this.orderId,

});



@override
State<ShareLocationPage> createState()
=> _ShareLocationPageState();

}



class _ShareLocationPageState
extends State<ShareLocationPage>{



bool loading=false;



Future<void> _ambilLokasi() async{


setState((){

loading=true;

});



bool service =
await Geolocator.isLocationServiceEnabled();



if(!service){

return;

}



LocationPermission permission =
await Geolocator.requestPermission();



if(permission ==
LocationPermission.denied){

return;

}



Position position =
await Geolocator.getCurrentPosition(

desiredAccuracy:
LocationAccuracy.high

);



await Supabase.instance.client
    .from('penerima_verifikasi')
    .update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'verified': true,
    })
    .eq('order_id', widget.orderId);

await Supabase.instance.client
    .from('pemesanan')
    .update({'status': 'Pending'})
    .eq('order_id', widget.orderId);



setState((){

loading=false;

});


showDialog(

context:context,

builder:(context)=>AlertDialog(

title:
const Text(
"Berhasil"
),

content:
const Text(
"Lokasi penerima berhasil diverifikasi"
),

)

);


}




@override
Widget build(BuildContext context){


return Scaffold(

appBar:
AppBar(

title:
const Text(
"Verifikasi Lokasi"
),

),


body:
Center(

child:
ElevatedButton(

child:

loading

?

const CircularProgressIndicator()

:

const Text(
"Bagikan Lokasi Saya"
),


onPressed:
_ambilLokasi,


),


),


);

}


}