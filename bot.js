import fs from "fs";
import {execSync} from "child_process";
import {getUpdates,sendMessage} from "./rubika.js";

const state=JSON.parse(fs.readFileSync("state.json"));
const pending=JSON.parse(fs.readFileSync("pending.json"));

const updates=await getUpdates(state.start_id);

if(!updates.data) process.exit(0);

for(const u of updates.data){

state.start_id=u.update_id+1;

if(u.type==="NewMessage"){

const text=u.new_message.text;
const chat=u.chat_id;

if(!text) continue;

if(text.includes("youtu")){

const info=JSON.parse(
execSync(`yt-dlp -J "${text}"`).toString()
);

const title=info.title;
const thumb=info.thumbnail;
const dur=info.duration;

const keyboard={
rows:[
[
{ text:"1080p", command:"q1080"},
{ text:"720p", command:"q720"}
],
[
{ text:"480p", command:"q480"},
{ text:"Audio", command:"qaudio"}
]
]
};

pending[chat]=text;

await sendMessage(chat,
`🎬 ${title}

⏱ ${dur} sec

Thumbnail:
${thumb}

کیفیت مورد نظر را انتخاب کنید`,
keyboard
);

}

}

if(u.type==="InlineMessage"){

const chat=u.chat_id;
const btn=u.aux_data.button_id;

if(pending[chat]){

const url=pending[chat];

execSync(`
gh workflow run download.yml \
-f url="${url}" \
-f chat_id="${chat}" \
-f quality="${btn}"
`);

}

}

}

fs.writeFileSync("state.json",JSON.stringify(state,null,2));
fs.writeFileSync("pending.json",JSON.stringify(pending,null,2));
