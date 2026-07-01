import { serve } from "https://deno.land/std/http/server.ts";
import { Resend } from "npm:resend";


const resend = new Resend(
Deno.env.get("RESEND_API_KEY")
);



serve(async (req)=>{


const body =
await req.json();



const email =
body.email;


const otp =
body.otp;



await resend.emails.send({


from:
"Lapar Manten <onboarding@resend.dev>",


to:[
email
],


subject:
"Kode Verifikasi Lapar Manten",


html:

`

<h2>Lapar Manten</h2>

<p>Kode OTP kamu:</p>


<h1>${otp}</h1>


<p>Masukkan kode ini ke aplikasi.</p>


`

});



return new Response(

JSON.stringify({

success:true

}),

{

headers:{
"Content-Type":
"application/json"

}

}

);



});