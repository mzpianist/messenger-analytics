*____ x margaret text messages bash
clear
cd "/Users/margaretzheng/Desktop/messenger_search_project/cleaner_data"
*CHANGE THIS
*import excel "[insert_something]",  firstrow 


*Step 1: more preliminary clean

drop A content share timestamp_ms sticker

gen num_photos  = length(photo) - length(subinstr(photo, "{", "", .))
gen num_videos  = length(video) - length(subinstr(video, "{", "", .))
sum num_photos num_videos
drop if is_unsent==1
drop photo video is_unsent

*time in string version
rename time time_str
*generate real time (mdy) variable
gen time = mdy(month, day, year)
format time %td

*some cleaning up for human understanding

replace message_str = subinstr(message_str,"â","'",.)

gen reaction_only =1 if strpos(message_str, "Reacted")>0 & strpos(message_str, " to your message")>0
replace reaction_only=0 if mi(reaction_only)
*this actually gives a count of how many messages were reacted!


*cleaning up reactions... which will be absolute pain but. maybe worth it

*this is the clean reaction list
gen reaction = ""
replace reaction = "heart" if strpos(reactions,"â\x9d¤")>0
replace reaction = "thumb up" if strpos(reactions,"ð\x9f\x91\x8d")>0
replace reaction = "laugh" if strpos(reactions,"ð\x9f\x98\x86")>0
replace reaction = "pleading face" if strpos(reactions,"ð\x9f¥º")>0
replace reaction = "starry eye face" if strpos(reactions,"ð\x9f¤©")>0
replace reaction = "surprise face" if strpos(reactions,"ð\x9f\x98®")>0
replace reaction = "sad face" if strpos(reactions,"ð\x9f\x98¢")>0
replace reaction = "pleading happy cry" if strpos(reactions,"ð\x9f¥¹")>0
replace reaction = "clown" if strpos(reactions,"ð\x9f¤¡")>0
replace reaction = "crying face" if strpos(reactions,"ð\x9f\x98\xad")>0
replace reaction = "purple heart" if strpos(reactions,"ð\x9f\x92\x85")>0
replace reaction = "eyes" if strpos(reactions,"ð\x9f\x91\x80")>0
replace reaction = "heart eyes" if strpos(reactions,"ð\x9f\x98\x8d")>0
replace reaction = "crying laughing face" if strpos(reactions,"ð\x9f\x92\x9c")>0
replace reaction = "thumb down" if strpos(reactions,"ð\x9f\x91\x8e")>0
replace reaction = "smile cry awkward" if strpos(reactions,"ð\x9f¥²")>0
replace reaction = "earth" if strpos(reactions,"ð\x9f\x8c\x8f")>0
replace reaction = "sprout" if strpos(reactions,"ð\x9f\x8c±")>0
replace reaction = "vampire" if strpos(reactions,"ð\x9f§\x9bâ\x80\x8dâ\x99\x82ï¸\x8f")>0

gen reactor = ""
replace reactor ="Margaret Zheng"  if strpos(reactions,"Margaret Zheng")>0
replace reactor ="Prajna Nair" if strpos(reactions,"Prajna Nair")>0
drop reactions
*Step 2: fun stats


sort(sender_name)
by sender_name:sum message_length

twoway scatter message_length time||lfit message_length time,by(sender_name, legend(off)) title("Message Length over Time") ytitle("message word count") msize(vsmall) mcolor(purple) mlabsize(small)

save clean_data.dta,replace


*entering chaotic reshapes

*Step 3: the plot thickens
gen message_count = 1 if message_length != 0
preserve 
collapse (sum) message_length message_count, by(time sender_name)
*line message_length time,by(sender_name)
gen avg_msg_len = message_length/message_count
encode sender_name, gen(enc_sender)
drop sender_name

drop message_length avg_msg_len
reshape wide message_count, i(time) j(enc_sender)
line message_count* time, title("Prajna x Margaret - message count") legend( label(1 "Margaret")  label(2 "Prajna") )
restore

preserve 
collapse (sum) message_length message_count, by(time sender_name)
*line message_length time,by(sender_name)
gen avg_msg_len = message_length/message_count
encode sender_name, gen(enc_sender)
drop sender_name
drop message_length message_count
reshape wide avg_msg_len, i(time) j(enc_sender)
line avg_msg_len* time, title("Prajna x Margaret - average message length") legend( label(1 "Margaret")  label(2 "Prajna") )
restore

preserve 
collapse (sum) message_length message_count, by(time sender_name)
*line message_length time,by(sender_name)
gen avg_msg_len = message_length/message_count
encode sender_name, gen(enc_sender)
drop sender_name
drop message_count avg_msg_len
reshape wide message_length, i(time) j(enc_sender)
line message_length* time, title("Prajna x Margaret - message_length") legend( label(1 "Margaret")  label(2 "Prajna") )
restore


*Step 4: reaction data????? uh...
gen heart_reacc =1 if reaction =="heart"
gen purple_heart_reacc =1 if reaction =="purple_heart"
gen laugh_reacc =1 if reaction == "laugh"| reaction =="crying laughing face"
gen sad_reacc =1 if reaction == "sad face"| reaction =="crying face"
gen pleading = 1 if reaction == "pleading face"|reaction =="pleading happy cry"

preserve
collapse (sum) *_reacc message_length message_count, by (time sender_name)
*scatter *_reacc message_* time, title("Prajna x Margaret Reaction Count") 
scatter *_reacc time, title("Prajna x Margaret Reaction Count") 
restore
