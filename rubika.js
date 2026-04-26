import fetch from "node-fetch";
import FormData from "form-data";
import fs from "fs";

const TOKEN = process.env.RUBIKA_TOKEN;
const API = `https://botapi.rubika.ir/v3/${TOKEN}`;

export async function getUpdates(start_id){

const res = await fetch(`${API}/getUpdates`,{
method:"POST",
headers:{ "Content-Type":"application/json" },
body:JSON.stringify({ start_id })
});

return res.json();
}

export async function sendMessage(chat_id,text,keyboard=null){

const body={
chat_id,
text,
...(keyboard?{inline_keypad:keyboard}:{})
};

const res=await fetch(`${API}/sendMessage`,{
method:"POST",
headers:{ "Content-Type":"application/json" },
body:JSON.stringify(body)
});

return res.json();
}

export async function sendPhoto(chat_id,url,caption){

return sendMessage(chat_id,`${caption}\n${url}`);
}

export async function sendVideo(chat_id,file){

const form=new FormData();
form.append("chat_id",chat_id);
form.append("file",fs.createReadStream(file));

return fetch(`${API}/sendFile`,{
method:"POST",
body:form
});
}
