function run(msg, matches)
if msg.to.type == 'user' and not is_sudo(msg) then
return [[
اینجا پیوی رباته لطفا اگه کاری دارید پیام خودتونو ارسال کنید تا مدیران ربات به شما جواب بدهند.
با تشکر Dragon Team
]]
end
end
return {
patterns = { 
"(.*)$",
},
run = run
}
