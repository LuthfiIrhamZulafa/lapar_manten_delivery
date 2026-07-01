import 'package:supabase_flutter/supabase_flutter.dart';


class EmailService {


final supabase =
Supabase.instance.client;



Future<void> kirimLinkLokasi({

required String email,

required String orderId,


}) async {


String link =

"https://laparmanten.com/location/$orderId";



await supabase.functions.invoke(

'send-location-email',

body: {


'email': email,


'link': link,


},

);


}


}