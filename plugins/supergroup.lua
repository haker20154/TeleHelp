--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "Promote me to admin first!")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = '??',
		  lock_link = "??",
          flood = '??',
		  lock_spam = '??',
		  lock_sticker = '??',
		  member = '??',
		  lock_forward = '??',
		  lock_all = '??',
		  public = '??',
		  lock_rtl = '??',
		  lock_tgservice = '??',
		  lock_contacts = '??',
		  lock_badword = "??",
		  lock_username = "??",
		  lock_tag = "??",
		  strict = '??',
		  Expiretime = '??',

        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = '”ÊÅ—ê—ÊÂ »Â œ? «»?” «÷«›Â ‘œ??'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local text = '”ÊÅ— ê—ÊÂ «“ œ? «»?” Õ–› ‘œ\n«ŒÂ ç—« ÅÊ· ‰„œ?œ òÂ Õ–› »‘„ ????????\n«ŒÂ ç—««««««««««'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("?", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="«ÿ·«⁄«  ê—ÊÂ ["..result.title.."]\n\n"
local admin_num = " ⁄œ«œ «œ„?‰ Â«? ê—ÊÂ: "..result.admins_count.."\n"
local user_num = " ⁄œ«œ ò«—»—«‰ ê—ÊÂ: "..result.participants_count.."\n"
local kicked_num = " ⁄œ«œ ò«—»—«‰ «Œ—«Ã ‘œÂ: "..result.kicked_count.."\n"
local channel_id = "‘‰«”Â ê—ÊÂ: "..result.peer_id.."\n"
if result.username then
	channel_username = "Username: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "Members for "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("?", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "Kicked Members for SuperGroup "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("?", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == '??' then
    return 'ê–«‘ ‰ ·?‰ò œ— ê—ÊÂ „„‰Ê⁄ ‘œ??'
  else
    data[tostring(target)]['settings']['lock_link'] = '??'
    save_data(_config.moderation.data, data)
    return 'ê–«‘ ‰ ·?‰ò œ— ê—ÊÂ „„‰Ê⁄ ‘œ??'
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == '??' then
    return 'ê–«‘ ‰ ·?‰ò œ— ê—ÊÂ «“«œ ‘œ?'
  else
    data[tostring(target)]['settings']['lock_link'] = '??'
    save_data(_config.moderation.data, data)
    return 'ê–«‘ ‰ ·?‰ò œ— ê—ÊÂ «“«œ ‘œ?'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "Owners only!"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == '??' then
    return '«”Å„ œ— ê—ÊÂ „„‰Ê⁄ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_spam'] = '??'
    save_data(_config.moderation.data, data)
    return '«”Å„ œ— ê—ÊÂ „„‰Ê⁄ ‘œ ??'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == '??' then
    return '«”Å„ œ— ê—ÊÂ «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_spam'] = '??'
    save_data(_config.moderation.data, data)
    return '«”Å„ œ— ê—ÊÂ «“«œ ‘œ ?'
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == '??' then
    return 'Õ”«”?  Å?«„ „„‰Ê⁄ ‘œ ??'
  else
    data[tostring(target)]['settings']['flood'] = '??'
    save_data(_config.moderation.data, data)
    return 'Õ”«”?  Å?«„ „„‰Ê⁄ ‘œ ??'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == '??' then
    return 'Õ”«”?  Å?«„ «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['flood'] = '??'
    save_data(_config.moderation.data, data)
    return 'Õ”«”?  Å?«„ «“«œ ‘œ ?'
  end
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == '??' then
    return '⁄—»? „„‰Ê⁄ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_arabic'] = '??'
    save_data(_config.moderation.data, data)
    return '⁄—»? „„‰Ê⁄ ‘œ ??'
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == '??' then
    return '⁄—»? «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_arabic'] = '??'
    save_data(_config.moderation.data, data)
    return '⁄—»? «“«œ ‘œ ?'
  end
end

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == '??' then
    return '⁄÷Ê?  «⁄÷«? Ãœ?œ „„‰Ê⁄ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_member'] = '??'
    save_data(_config.moderation.data, data)
  end
  return '⁄÷Ê?  «⁄÷«? Ãœ?œ „„‰Ê⁄ ‘œ ??'
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == '??' then
    return '⁄÷Ê?  «⁄÷«? Ãœ?œ «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_member'] = '??'
    save_data(_config.moderation.data, data)
    return '⁄÷Ê?  «⁄÷«? Ãœ?œ «“«œ ‘œ ?'
  end
end

local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tag']
  if group_tag_lock == '??' then
    return '«—”«·  ê „„‰Ê⁄ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_tag'] = '??'
    save_data(_config.moderation.data, data)
    return '«—”«·  ê „„‰Ê⁄ ‘œ ??'
  end
end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tag']
  if group_rtl_lock == '??' then
    return '«— ”«·  ê «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_tag'] = '??'
    save_data(_config.moderation.data, data)
    return '«— ”«·  ê «“«œ ‘œ ?'
  end
end

local function lock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['lock_all']
  if group_all_lock == '??' then
    return 'Â„Â  ‰Ÿ?„«  ﬁ›· ‘œ‰œ??'
  else
    data[tostring(target)]['settings']['lock_all'] = '??'
    save_data(_config.moderation.data, data)
    return 'Â„Â  ‰Ÿ?„«  ﬁ›· ‘œ‰œ??'
  end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['lock_tag']
  if group_all_lock == '??' then
    return 'ﬁ›· Â„Â  ‰Ÿ?„«  »—œ«‘ Â ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_all'] = '??'
    save_data(_config.moderation.data, data)
    return 'ﬁ›· Â„Â  ‰Ÿ?„«  »—œ«‘ Â ‘œ ?'
  end
end

local function lock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['lock_username']
  if group_username_lock == '??' then
    return '«—”«· ?Ê“— ‰?„ „„‰Ê⁄ ‘œ??'
  else
    data[tostring(target)]['settings']['lock_username'] = '??'
    save_data(_config.moderation.data, data)
    return '«—”«· ?Ê“— ‰?„ „„‰Ê⁄ ‘œ??'
  end
end

local function unlock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['lock_username']
  if group_rtl_lock == '??' then
    return '«— ”«· ?Ê“—‰?„ «“«œ ‘œ?'
  else
    data[tostring(target)]['settings']['lock_username'] = '??'
    save_data(_config.moderation.data, data)
    return '«— ”«· ?Ê“—‰?„ «“«œ ‘œ?'
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == '??' then
    return 'Å?€«„ Ê—Êœ Ê Œ—ÊÃ «“ «?‰ »Â »⁄œ Å«ò ŒÊ«Âœ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = '??'
    save_data(_config.moderation.data, data)
    return 'Å?€«„ Ê—Êœ Ê Œ—ÊÃ «“ «?‰ »Â »⁄œ Å«ò ŒÊ«Âœ ‘œ ??'
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == '??' then
    return 'Å?€«„ Ê—Êœ Ê Œ—ÊÃ «“ «?‰ »Â »⁄œ Å«ò ‰ŒÊ«Âœ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = '??'
    save_data(_config.moderation.data, data)
    return 'Å?€«„ Ê—Êœ Ê Œ—ÊÃ «“ «?‰ »Â »⁄œ Å«ò ‰ŒÊ«Âœ ‘œ ??'
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == '??' then
    return '«” ?ò— „„‰Ê⁄ ‘œ ??'
  else
    data[tostring(target)]['settings']['lock_sticker'] = '??'
    save_data(_config.moderation.data, data)
    return '«” ?ò— „„‰Ê⁄ ‘œ ??'
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == '??' then
    return '«” ?ò— «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_sticker'] = '??'
    save_data(_config.moderation.data, data)
    return '«” ?ò— «“«œ ‘œ ?'
  end
end

local function lock_group_forward(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_forward_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_forward_lock == '??' then
    return ''
  else
    data[tostring(target)]['settings']['lock_forward'] = '??'
    save_data(_config.moderation.data, data)
    return ''
  end
end

local function unlock_group_forward(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_forward_lock = data[tostring(target)]['settings']['lock_forward']
  if group_forward == '??' then
    return ''
  else
    data[tostring(target)]['settings']['lock_forward'] = '??'
    save_data(_config.moderation.data, data)
    return ''
  end
end

local function lock_group_badword(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_badword_lock = data[tostring(target)]['settings']['lock_badword']
  if group_badword_lock == '??' then
    return '›Õ‘ œ«œ‰ œ— ê—ÊÂ „„‰Ê⁄ ‘œ??'
  else
    data[tostring(target)]['settings']['lock_badword'] = '??'
    save_data(_config.moderation.data, data)
    return '›Õ‘ œ«œ‰ œ— ê—ÊÂ „„‰Ê⁄ ‘œ??'
  end
end

local function unlock_group_badword(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_badword_lock = data[tostring(target)]['settings']['lock_badword']
  if group_badword_lock == '??' then
    return '›Õ‘ œ«œ‰ «“«œ ‘œ ?'
  else
    data[tostring(target)]['settings']['lock_badword'] = '??'
    save_data(_config.moderation.data, data)
    return '›Õ‘ œ«œ‰ «“«œ ‘œ ?'
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == '??' then
    return 'Õ”«”?   ‰Ÿ?„«  »?‘ — ‘œ ?'
  else
    data[tostring(target)]['settings']['strict'] = '??'
    save_data(_config.moderation.data, data)
    return 'Õ”«”?   ‰Ÿ?„«  »?‘ — ‘œ ?'
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == '??' then
    return 'Õ”«”?   ‰Ÿ?„«  ò„ — ‘œ ?'
  else
    data[tostring(target)]['settings']['strict'] = '??'
    save_data(_config.moderation.data, data)
    return 'Õ”«”?   ‰Ÿ?„«  ò„ — ‘œ ?'
  end
end
--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'ﬁÊ«‰?‰ À»  ‘œ'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return '«ŒÂ ç—« Êﬁ ? ê—ÊÂ ﬁÊ«‰?‰ ‰œ«—Â Â? „?‰Ê?”? ﬁÊ«‰?‰ ﬁÊ«‰?‰ «ŒÂ ç—«««««««««««««'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' ﬁÊ«‰?‰ ò—ÊÂ:\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "For moderators only!"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == '??' then
    return 'ê—ÊÂ ⁄„Ê„? ‘œ'
  else
    data[tostring(target)]['settings']['public'] = '??'
    save_data(_config.moderation.data, data)
  end
  return 'ê—ÊÂ ⁄„Ê„? ‘œ'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == '??' then
    return 'ê—ÊÂ „Œ›?«‰Â ‘œ'
  else
    data[tostring(target)]['settings']['public'] = '??'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return 'ê—ÊÂ „Œ›?«‰Â ‘œ'
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = '??'
		end
end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_all'] then
			data[tostring(target)]['settings']['lock_all'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_forward'] then
			data[tostring(target)]['settings']['lock_forward'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_text'] then
			data[tostring(target)]['settings']['mute_text'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_all'] then
			data[tostring(target)]['settings']['mute_all'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_video'] then
			data[tostring(target)]['settings']['mute_video'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_doc'] then
			data[tostring(target)]['settings']['mute_doc'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_photo'] then
			data[tostring(target)]['settings']['mute_photo'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_gif'] then
			data[tostring(target)]['settings']['mute_gif'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_Expiretime'] then
			data[tostring(target)]['settings']['mute_Expiretime'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['mute_audio'] then
			data[tostring(target)]['settings']['mute_audio'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_badword'] then
			data[tostring(target)]['settings']['lock_badword'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tag'] then
			data[tostring(target)]['settings']['lock_tag'] = '??'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_username'] then
			data[tostring(target)]['settings']['lock_username'] = '??'
		end
	end
	 local expiretime = redis:hget('expiretime', get_receiver(msg))
    local expire = ''
  if not expiretime then
  expire = expire..' «—?Œ ”  ‰‘œÂ «” '
  else
   local now = tonumber(os.time())
   expire =  expire..math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
 end
 

  local settings = data[tostring(target)]['settings']
  local text = "? ‰Ÿ?„«  «’·? —Ê»«   ·Â «”Å?œ???".."\n"
  .."????Ê÷⁄?  ÷œ ·?‰ò: "..settings.lock_link.."\n"
  .."????Ê÷⁄?  Õ”«”?  Å?«„: "..settings.flood.."\n"
  .."????Ê÷⁄?  „ﬁœ«— Õ”«”?  Å?«„(›·Êœ): "..NUM_MSG_MAX.."\n"
  .."????Ê÷⁄?  Â—“‰«„Â: "..settings.lock_spam.."\n"
  .."????Ê÷⁄?  “»«‰ ⁄—»?: "..settings.lock_arabic.."\n"
  .."????Ê÷⁄?  Ê—Êœ«⁄÷«: "..settings.lock_member.."\n"
  .."????Ê÷⁄?   ê ”—Ê?”:"..settings.lock_tgservice.."\n"
  .."????Ê÷⁄?  Å«»·?ò(ÃÂ«‰?): "..settings.public.."\n"
  .."????Ê÷⁄?  Õ”«”?   ‰Ÿ?„«  ê—ÊÂ: "..settings.strict.."\n"
  .."??????????????".."\n"
  .."?? ‰Ÿ?„«  „Ê—œ ‰?«“  ·Â «”Å?œ ??".."\n"
  .."????Ê÷⁄?   ê(#): "..settings.lock_tag.."\n"
  .."????Ê÷⁄?  ?Ê“—‰?„(@): "..settings.lock_username.."\n"
  .."????Ê÷⁄?  ›Õ‘: "..settings.lock_badword.."\n"
  .."????Ê÷⁄?  ›Ê—Ê«—œ: "..settings.lock_forward.."\n"
  .."????Ê÷⁄?  «” ?ò—: "..settings.lock_sticker.."\n"
  .."??????????????".."\n"
  .."?? ‰Ÿ?„«  ·?”  „„‰Ê⁄?   ·Â «”Å?œ??".."\n"
  .."????›?·„: "..settings.mute_video.."\n"
  .."????ç : "..settings.mute_all.."\n"
  .."????ê?›: "..settings.mute_gif.."\n"
  .."????’œ«: "..settings.mute_audio.."\n"
  .."????›«?·: "..settings.mute_doc.."\n"
  .."????„ ‰: "..settings.mute_text.."\n"
  .."????⁄ò”: "..settings.mute_photo.."\n"
  .."??????????????".."\n"
  .."????ﬁ›· Â„Â  ‰Ÿ?„« : "..settings.lock_all.."\n"
  .." «—?Œ «‰ﬁ÷«? ê—ÊÂ: "..expire.."—Ê“ œ?ê—".."\n"
  .."??????????????".."\n"
  .."ç‰·  ?„  ·Â «”Å?œ: ????????????????".."\n"
  .."@Telespeedtg ??".."\n"
  .."Å‘ ?»«‰? —Ê»« :".."\n"
  .."@Telespeed_pvbot ??".."\n"
  .."#„Ê›ﬁ »«‘?œ"
  return text
end

--[[local function set_expiretime(msg, data, target)
      if not is_sudo(msg) then
        return "‘„« «œ„?‰ —»«  ‰?” ?œ!"
      end
  local data_cat = 'expire'
  data[tostring(target)][data_cat] = expired
  save_data(_config.moderation.data, data)
  return 
end
]]
local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, '”ÊÅ— ê—ÊÂ ›⁄«· ‰?”  »—«? ›⁄«· ‘œ‰ »Â «?œ?\n@poker_soft\nÅ?«„ œÂ?œ')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' „œ?— Ãœ?œ «÷«›Â ‘œ')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, '”ÊÅ— ê—ÊÂ ›⁄«· ‰?”  »—«? ›⁄«· ‘œ‰ »Â «?œ?\n@poker_soft\nÅ?«„ œÂ?œ')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' «“ „œ?—?  »—ò‰«— ‘œ')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'SuperGroup is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return '„œ?—? „ÊÃÊœ ‰?” '
  end
  local i = 1
  local message = '\n·?”  „œ?—«‰ ê—ÊÂ ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("?", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "‘„« œ” —”? ‰œ«œ—?œ(„œ?—« Ê—) —« «Œ—«Ã ò‰?œ")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "‘„« œ” —”? ‰œ«œ—?œ(„œ?—« Ê—) —«  «Œ—«Ã ò‰?œ")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "«œ„?‰" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.."«œ„?‰ Ãœ?œ «÷«›Â ‘œ"
		else
			text = "[ "..user_id.." ]«œ„?‰ Ãœ?œ «÷«›Â ‘œ"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "Õ–› «œ„?‰" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." «œ„?‰ Õ–› ‘œ"
		else
			text = "[ "..user_id.." ] «œ„?‰ Õ–› ‘œ"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "’«Õ»" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) and not is_vip(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] ’«Õ» Ãœ?œ ê—ÊÂ À»  ‘œ"
			else
				text = "[ "..result.from.peer_id.." ] ’«Õ» Ãœ?œ ê—ÊÂ À»  ‘œ"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "„œ?—" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("?", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "Õ–› „œ?—" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("?", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] —›⁄ ”òÊ  ‘œ")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."]  ”òÊ  ‘œ")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "«œ„?‰" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "Õ–› «œ„?‰" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "You can't demote global admins!")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." «œ„?‰ Õ–› ‘œ"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] «œ„?‰ Õ–› ‘œ"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "„œ?—" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "Õ–› „œ?—" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "«œ„?‰" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "’«Õ»" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "„œ?—" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "Õ–› „œ?—" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "Õ–› «œ„?‰" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." «œ„?‰ Õ–› ‘œ"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." «œ„?‰ Õ–› ‘œ"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] —›⁄ ”òÊ  ‘œ")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] ”òÊ  ‘œ")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("?", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = '@'..member..'\nò«—»—? »« «?‰ „‘Œ’«  Å?œ« ‰‘œ'
  else
    text = '['..memberid..']\nò«—»—? »« «?‰ „‘Œ’«  ?«›  ‰‘œ'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "«œ„?‰" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] «œ„?‰ ‘œ"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == '’«Õ»' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.." ["..v.peer_id.."] ’«Õ» Ãœ?œ À»  ‘œ"
				else
					text = "["..v.peer_id.."] ’«Õ» Ãœ?œ À»  ‘œ"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				text = "["..memberid.."]’«Õ» Ãœ?œ À»  ‘œ"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == ' »œ?·' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1] == ' »œ?·' then
			if not is_admin1(msg) then
				return
			end
			return "«?‰Ã« ”ÊÅ— ê—ÊÂ »ÊœÂ\n„Õ„œ ›«“  ç?Â ‰«„Ê”‰"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local vip_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("?", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == '«›“Êœ‰' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) and not is_vip(vip_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '—»«  «“ ﬁ»· ›⁄«· »ÊœÂ', ok_cb, false)
			end
			print("”ÊÅ— ê—ÊÂ "..msg.to.print_name.."("..msg.to.id..") »Â œ? «?” «÷«›⁄ ‘œÂ »Êœ")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] ”ÊÅ— ê—ÊÂ »Â œ? «»?” «÷«›Â ‘œÂ »Êœ")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1] == 'Õ–›' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, '”ÊÅ— ê—ÊÂ Â‰Ê“ ›⁄«· ‰‘œÂ', ok_cb, false)
			end
			print("”ÊÅ— ê—ÊÂ "..msg.to.print_name.."("..msg.to.id..") «“ œ? « »” Õ–› ‘œ??????\n«ŒÂ ç—« ÅÊ· ‰„?œ?œ „‰ Õ–› „?‘„\n«ŒÂ ç—««««««")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "„‘Œ’«  ê—ÊÂ" then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "·?”  «œ„?‰" then
			if not is_owner(msg) and not is_support(msg.from.id) and not is_vip(msg.from.id) then
				return
			end
			member_type = '·?”  «œ„?‰ Â«?? òÂ œ— ê—ÊÂ Õ÷Ê— œ«—‰œ'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "«?œ? ’«Õ»" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "»—«? ê—ÊÂ ’«Õ»? À»  ‰‘œÂ ò”? òÂ ê—ÊÂ —Ê ”«Œ Â\n”—?⁄⁄⁄⁄⁄⁄⁄⁄⁄⁄⁄⁄⁄⁄\n»Â Å‘ ?»«‰? «⁄·«„ ò‰Â\n@TeleSpeedTG"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "«?œ? ’«Õ» ê—ÊÂ ["..group_owner..']'
		end

		if matches[1] == "·?”  „œ?—«‰" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] „œ?—«‰ ê—ÊÂ")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "·?”  —»« " and is_momod(msg) then
			member_type = '·?”  —»«  Â«?? òÂ œ— ê—ÊÂ Õ÷Ê— œ«—‰œ'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] ·?”  —»«  Â«?? òÂ œ— ê—ÊÂ Õ÷Ê— œ«—‰œ")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "çÂ ò”?" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "ò?ò" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'Å«ò ò‰' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == '«Œ—«Ã' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == '«Œ—«Ã' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local get_cmd = 'channel_block'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == "«Œ—«Ã" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == '«?œ?' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				return "«ÿ·«⁄«  ê—ÊÂ" ..string.gsub(msg.to.print_name, "_", " ").. ":\n\n"..msg.to.id
			end
		end
		if matches[1] == 'kickme' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == '·?‰ò Ãœ?œ' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver,'·?‰ò? ?«›  ‰‘œ çÊ‰ —»«  »Â ê—ÊÂ «›“ÊœÂ ‘œÂ «”  »—«? «›“Êœ‰ ·?‰ò œ” Ê—\nﬁ—«—œ«œ‰ ·?‰ò\n—Ê »‰Ê?”?œ')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "·?‰ò Ãœ?œ ”«Œ Â ‘œ")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'ﬁ—«—œ«œ‰ ·?‰ò' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return '·ÿ›« ·?‰ò —« «—”«· ò‰?œ'
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return "·?‰ò Ãœ?œ ”«Œ Â ‘œ."
			end
		end

		if matches[1] == '·?‰ò' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return "·?‰ò ”«Œ Â ‰‘œÂ »—«? ”«Œ  ·?‰ò œ” Ê—\n·?‰ò Ãœ?œ Ê »‰Ê?”?œ"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return "·?‰ò ê—ÊÂ ‘„«:\n"..group_link
		end

		if matches[1] == "invite" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'res' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'kick' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == '«œ„?‰' then
				if not is_support(msg.from.id) and not is_owner(msg) and not is_vip(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = '«œ„?‰',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == '«œ„?‰' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = '«œ„?‰'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = '«œ„?‰'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == '«œ„?‰' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = '«œ„?‰'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = '«œ„?‰'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'Õ–› «œ„?‰' then
			if not is_support(msg.from.id) and not is_owner(msg) and not is_vip(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'Õ–› «œ„?‰',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'Õ–› «œ„?‰' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'Õ–› «œ„?‰'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'Õ–› «œ„?‰' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'Õ–› «œ„?‰'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == '’«Õ»' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = '’«Õ»',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == '’«Õ»' and matches[2] and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = '’«Õ»'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == '’«Õ»' and matches[2] and not string.match(matches[2], '^%d+$') then
				local	get_cmd = '’«Õ»'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == '„œ?—' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = '„œ?—',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == '„œ?—' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = '„œ?—'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == '„œ?—' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = '„œ?—',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1] == 'Õ–› „œ?—' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/support/admin/vip can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'Õ–› „œ?—',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'Õ–› „œ?—' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'Õ–› „œ?—'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'Õ–› „œ?—' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'Õ–› „œ?—'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "ﬁ—«—œ«œ‰ «”„" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "ﬁ—«—œ«œ‰ „Ê÷Ê⁄" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return " Ê÷?Õ«  ﬁ—«—œ«œÂ ‘œ"
		end

		--[[if matches[1] == "setusername" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "SuperGroup username Set.\n\nSelect the chat again to see the changes.")
				elseif success == 0 then
					send_large_msg(receiver, "Failed to set SuperGroup username.\nUsername may already be taken.\n\nNote: Username can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end
]]
--[[if matches[1]:lower() == 'uexpiretime' and not matches[3] then
	local hash = 'usecommands:'..msg.from.id..':'..msg.to.id
    redis:incr(hash)
        expired = 'Unlimited'
        local target = msg.to.id
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group expire time to [unlimited]")
        return set_expiretime(msg, data, target)
    end
	if matches[1]:lower() == ' «—?Œ «‰ﬁ÷«' then
	local hash = 'usecommands:'..msg.from.id..':'..msg.to.id
    redis:incr(hash)
	  if tonumber(matches[2]) < 0 or tonumber(matches[2]) > 99999999999999999999999999999999999999999999999999 then
	  return 
      end
        expired = matches[2]
        local target = msg.to.id
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group expire time to ["..matches[2].."]")
        return set_expiretime(msg, data, target)
    end]]
		if matches[1] == 'ﬁ—«—œ«œ‰ ﬁÊ«‰?‰' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] ﬁÊ«‰?‰ Ãœ?œ À»  ‘œ ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'ﬁ—«—œ«œ‰ ⁄ò”' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return '·ÿ›« ⁄ò” —« Ê«—œ ò‰?œ'
		end

		if matches[1] == 'Å«ò ”«“?' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "›ﬁÿ ’«Õ» œ” —”? œ«—Â"
			end
			if matches[2] == 'modlist' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return '„œ?—? ÊÃÊœ ‰œ«—œ'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return 'Â„Â „œ?—«‰ Å«ò ‘œ‰œ'
			end
			if matches[2] == 'ﬁÊ«‰?‰' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "ﬁÊ«‰?‰? ÊÃÊœ ‰œ«—œ"
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return 'ﬁÊ«‰?‰ Å«ò ‘œ'
			end
			if matches[2] == '„Ê÷Ê⁄' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return ' Ê÷?Õ« ? ÊÃÊœ ‰œ«—œ'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return " Ê÷?Õ«  Å«ò ‘œ"
			end
			if matches[2] == '·?”  ”òÊ ' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "ò”«‰? òÂ ”òÊ  »Êœ‰œ Å«ò ‘œ‰œ"
			end
			if matches[2] == 'username' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "SuperGroup username cleaned.")
					elseif success == 0 then
						send_large_msg(receiver, "Failed to clean SuperGroup username.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
			if matches[2] == "—»« " and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
				return "—»«  Â« «“ ê—ÊÂ Å«ò ‘œ‰œ"
			end
		end

		if matches[1] == 'ﬁ›·' and is_momod(msg) then
		local target = msg.to.id
			     if matches[2] == 'Â„Â' then
				 local telespeeed ={
				 lock_group_links(msg, data, target),
				 lock_group_spam(msg, data, target),
				 lock_group_flood(msg, data, target),
				 lock_group_arabic(msg, data, target),
				 lock_group_membermod(msg, data, target),
				 lock_group_tgservice(msg, data, target),
				 lock_group_tag(msg, data, target),
				 lock_group_username(msg, data, target),
				 lock_group_sticker(msg, data, target),
				 lock_group_badword(msg, data, target),
				 lock_group_forward(msg, data, target),
				 enable_strict_rules(msg, data, target),
				 }
				 return lock_group_all(msg, data, target), telespeed
			end	 
			local target = msg.to.id
			if matches[2] == '·?‰ò' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == '«”Å„' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'Õ”«”? ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == '⁄—»?' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2] == '„„»—' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end
			if matches[2] == 'Ê—Êœ Ê Œ—ÊÃ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == ' ê' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tag(msg, data, target)
			end
			if matches[2] == '?Ê“—‰?„' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_username(msg, data, target)
			end
			if matches[2] == '«” ?ò—' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == '›Õ‘' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_badword(msg, data, target)
			end
			if matches[2] == '›—Ê«—œ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_forward(msg, data, target)
			end
			if matches[2] == 'Õ”«”?   ‰Ÿ?„« ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == '»«“ò—œ‰' and is_momod(msg) then
		local target = msg.to.id
		if matches[2] == 'Â„Â' then
		local telespeedtg ={
		unlock_group_links(msg, data, target),
		unlock_group_spam(msg, data, target),
		unlock_group_flood(msg, data, target),
		unlock_group_arabic(msg, data, target),
		unlock_group_membermod(msg, data, target),
		unlock_group_tgservice(msg, data, target),
		unlock_group_sticker(msg, data, target),
		unlock_group_badword(msg, data, target),
		unlock_group_forward(msg, data, target),
		disable_strict_rules(msg, data, target),
		}
		return unlock_group_all(msg, data, target), telespeedtg
			end
			local target = msg.to.id
			if matches[2] == '·?‰ò' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == '«”Å„' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'Õ”«”? ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == '⁄—»?' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == '„„»—' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
				if matches[2] == 'Ê—Êœ Ê Œ—ÊÃ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == '«” ?ò—' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == '›Õ‘' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_badword(msg, data, target)
			end
			if matches[2] == ' ê' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_tag(msg, data, target)
			end
			if matches[2] == '›—Ê«—œ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_forward(msg, data, target)
			end
			if matches[2] == 'Õ”«”?   ‰Ÿ?„« ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == '›Ê·Êœ' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 1 or tonumber(matches[2]) > 50 then
				return "«“ «⁄œ«œ 1  « 50 «” ›«œÂ ò‰?œ"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return 'Õ”«”?   ‰Ÿ?„ ‘œ »Â '..matches[2]
		end
		if matches[1] == 'public' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == '??' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == '??' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == '›⁄«· ò—œ‰' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == '’œ«' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_audio'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
			if matches[2] == '⁄ò”' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_photo'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
			if matches[2] == '›?·„' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_video'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
			if matches[2] == 'ê?›' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_gif'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
			if matches[2] == '›«?·' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_doc'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
			if matches[2] == '‰Ê‘ Â' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_text'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
			if matches[2] == '.....' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_all'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.."»?’œ« ‘œ"
				else
					return msg_type.."»?’œ« ‘œ"
				end
			end
		end
		if matches[1] == '€?—›⁄«· ò—œ‰' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == '’œ«' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_audio'] = '??'
                    save_data(_config.moderation.data, data)
				     return msg_type.."»«’œ« ‘œ"
				else
				     return msg_type.."»«’œ« ‘œ"
				end
			end
			if matches[2] == '⁄ò”' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_photo'] = '??'
                    save_data(_config.moderation.data, data)
				     return msg_type.."»«’œ« ‘œ"
				else
				     return msg_type.."»«’œ« ‘œ"
				end
			end
			if matches[2] == '›?·„' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_video'] = '??'
                    save_data(_config.moderation.data, data)
				     return msg_type.."»«’œ« ‘œ"
				else
				     return msg_type.."»«’œ« ‘œ"
				end
			end
			if matches[2] == 'ê?›' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_gif'] = '??'
                    save_data(_config.moderation.data, data)
					return msg_type.." ê?› »«“ ‘œ"
				else
					return "«“ ﬁ»· "..msg_type.."»«“ »ÊœÂ «” "
				end
			end
			if matches[2] == '›«?·' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_doc'] = '??'
                    save_data(_config.moderation.data, data)
				     return msg_type.."»«’œ« ‘œ"
				else
				     return msg_type.."»«’œ« ‘œ"
				end
			end
			if matches[2] == '‰Ê‘ Â' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_text'] = '??'
                    save_data(_config.moderation.data, data)
				     return msg_type.."»«’œ« ‘œ"
				else
				     return msg_type.."»«’œ« ‘œ"
				end
			end
			if matches[2] == '......' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					data[tostring(msg.to.id)]['settings']['mute_all'] = '??'
                    save_data(_config.moderation.data, data)
				     return msg_type.."»«’œ« ‘œ"
				else
				     return msg_type.."»«’œ« ‘œ"
				end
			end
		end


		if matches[1] == "”òÊ " and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "”òÊ " and matches[2] and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."] «“ ·?”  ”òÊ  Å«ò ‘œ"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] «?‰ ò«—»— œ?ê— ‰„? Ê«‰œ ç  ò‰œ"
				end
			elseif matches[1] == "”òÊ " and matches[2] and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "muteslist" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "·?”  ”òÊ " and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1] == ' ‰Ÿ?„« ' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'ﬁÊ«‰?‰' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == '—«Â‰„«' and not is_owner(msg) then
			text = "»—«? œ—?«›  —«Â‰„« »Â Å? Ê? —»«  „—«Ã⁄Â ò‰?œ"
			reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1] == '—«Â‰„«' and is_owner(msg) then
			local name_log = user_print_name(msg.from)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()
		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) and  is_vip(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) and is_vip(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^(«›“Êœ‰)$",
	"^(Õ–›)$",
	--"^[#!/]([Mm]ove) (.*)$",
	"^(„‘Œ’«  ê—ÊÂ)$",
	"^(·?”  «œ„?‰)$",
	"^(«?œ? ’«Õ»)$",
	"^(·?”  „œ?—«‰)$",
	"^(·?”  —»« )$",
	"^(çÂ ò”?)$",
	"^(ò?ò)$",
    "^(«Œ—«Ã) (.*)",
	"^(«Œ—«Ã)",
	"^( »œ?·)$",
	"^(«?œ?)$",
	"^(«?œ?) (.*)$",
	"^(ò?ò) (.*)$",
	"^(·?‰ò Ãœ?œ)$",
	"^(ﬁ—«—œ«œ‰ ·?‰ò)$",
	"^(·?‰ò)$",
	"^(—”) (.*)$",
	"^(«œ„?‰) (.*)$",
	"^(«œ„?‰)",
	"^(Õ–› «œ„?‰) (.*)$",
	"^(Õ–› «œ„?‰)",
	"^(’«Õ») (.*)$",
	"^(’«Õ»)$",
	"^(„œ?—) (.*)$",
	"^(„œ?—)",
	"^(Õ–› „œ?—) (.*)$",
	"^(Õ–› „œ?—)",
	"^(ﬁ—«—œ«œ‰ «”„) (.*)$",
	"^(ﬁ—«—œ«œ‰ „Ê÷Ê⁄) (.*)$",
	"^(ﬁ—«—œ«œ‰ ﬁÊ«‰?‰) (.*)$",
	"^(ﬁ—«—œ«œ‰ ⁄ò”)$",
	--"^[#!/]([Ss]etusername) (.*)$",
	"^(Å«ò ò—œ‰)$",
	"^(ﬁ›·) (.*)$",
	"^(»«“ò—œ‰) (.*)$",
	"^(›⁄«· ò—œ‰) ([^%s]+)$",
	"^(€?—›⁄«· ò—œ‰) ([^%s]+)$",
	"^(”òÊ )$",
	"^(”òÊ ) (.*)$",
	"^( ‰Ÿ?„« )$",
	"^(ﬁÊ«‰?‰)$",
	"^(›Ê·Êœ) (%d+)$",
	"^(Å«ò ”«“?) (.*)$",
	"^(.....)$",
	"^(·?”  ”òÊ )$",
    --"^( «—?Œ «‰ﬁ÷«) (.*)$",
	"^(Å«ò ò‰)$",
    "^(https://telegram.me/joinchat/%S+)$",
	"msg.to.peer_id",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--End supergrpup.lua
