/// <reference path="./deno-shim.d.ts" />

import { serve } from "https://deno.land/std/http/server.ts";



serve(async(req)=>{


const body =
await req.json();



const email =
body.email;



const link =
body.link;



console.log(
"Email tujuan:",
email
);



console.log(
"Link:",
link
);



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