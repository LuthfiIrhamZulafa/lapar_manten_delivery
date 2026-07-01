import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';


class OtpService {


final supabase =
Supabase.instance.client;



Future<void> sendOtp(String email) async {



final otp =
(100000 + Random().nextInt(900000))
.toString();



await supabase
.from('otp_verification')
.insert({

'email': email,

'otp': otp,

'created_at':
DateTime.now().toIso8601String(),

});



await supabase.functions.invoke(

'send-otp-email',

body: {

'email': email,

'otp': otp,

}

);



}



Future<bool> verifyOtp(

String email,

String token

) async {



final response = await supabase

.from('otp_verification')

.select()

.eq('email', email)

.eq('otp', token)

.maybeSingle();



if(response != null){


await supabase

.from('otp_verification')

.update({

'verified': true

})

.eq('email', email)

.eq('otp', token);



return true;


}


return false;


}


}