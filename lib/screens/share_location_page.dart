import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ShareLocationPage extends StatefulWidget {


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



bool loading = false;



Future<void> _ambilLokasi() async{


setState((){

loading=true;

});



try{


bool service =
await Geolocator.isLocationServiceEnabled();



if(!service){

throw "GPS harus diaktifkan";

}



LocationPermission permission =
await Geolocator.checkPermission();



if(permission ==
LocationPermission.denied){


permission =
await Geolocator.requestPermission();


}



if(permission ==
LocationPermission.denied){

throw "Izin lokasi ditolak";

}



Position position =
await Geolocator.getCurrentPosition(

desiredAccuracy:
LocationAccuracy.high

);




// SIMPAN LOKASI PENERIMA

await Supabase.instance.client

.from('penerima_verifikasi')

.update({


'latitude':
position.latitude,


'longitude':
position.longitude,


'accuracy':
position.accuracy,


'verified':
true,


'verified_at':
DateTime.now()
.toIso8601String(),


})

.eq(

'order_id',

widget.orderId

);




// UBAH STATUS ORDER

await Supabase.instance.client

.from('pemesanan')

.update({

'status':
'Pending'

})

.eq(

'order_id',

widget.orderId

);



setState((){

loading=false;

});



showDialog(

context:context,

builder:(context)=>

AlertDialog(

title:
const Text(
"Berhasil"
),


content:
const Text(
"Lokasi penerima berhasil diverifikasi."
),


actions:[


TextButton(

onPressed:(){

Navigator.pop(context);


},

child:
const Text(
"OK"
)

)


]


)

);



}

catch(e){


setState((){

loading=false;

});


ScaffoldMessenger.of(context)
.showSnackBar(

SnackBar(

content:
Text(
e.toString()
),

backgroundColor:
Colors.red,

)

);


}


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

Column(

mainAxisAlignment:
MainAxisAlignment.center,


children:[


const Icon(

Icons.location_on,

size:70,

color:Colors.red,

),


const SizedBox(height:20),



Text(

"Order ID:\n${widget.orderId}",

textAlign:
TextAlign.center,

),



const SizedBox(height:20),



ElevatedButton(


onPressed:
loading
?
null
:
_ambilLokasi,


child:

loading

?

const SizedBox(

height:20,

width:20,

child:
CircularProgressIndicator(

color:Colors.white,

)

)

:

const Text(

"Bagikan Lokasi Saya"

),


)


]


)


)


);


}


}