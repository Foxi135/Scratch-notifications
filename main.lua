function love.load()
    utf8 = require"utf8"
    dofile("utf8.lua")
    nativefs = require"nativefs"
    xicon = love.graphics.newImage("x.png")
    readicon = love.graphics.newImage("markasread.png")
    stopicon = love.graphics.newImage("stop.png")
    moreicon = love.graphics.newImage("more.png")
    msgtypeimg = {}
    msgtypecolor = {}
    msgtypehead = {}
    msgtypeimg.addcomment = love.graphics.newImage("comment.png") msgtypecolor.addcomment = {0.3,0.3,0.9,0.2} msgtypehead.addcomment = "Comment"
    msgtypeimg.userfollow = love.graphics.newImage("follow.png") msgtypecolor.userfollow = {0.4,0.4,1,0.2} msgtypehead.userfollow = "Follow"
    msgtypeimg.forumpost = love.graphics.newImage("forum.png") msgtypecolor.forumpost = {0.9,0.4,0.4,0.2} msgtypehead.forumpost = "Forum"
    msgtypeimg.studioactivity = love.graphics.newImage("studio.png") msgtypecolor.studioactivity = {0.4,0.9,0.4,0.2} msgtypehead.studioactivity = "Studio"
    msgtypeimg.loveproject = love.graphics.newImage("love.png") msgtypecolor.loveproject = {0.9,0.5,0.5,0.2} msgtypehead.loveproject = "Heart"
    msgtypeimg.favoriteproject = love.graphics.newImage("fav.png") msgtypecolor.favoriteproject = {0.9,0.9,0.5,0.2} msgtypehead.favoriteproject = "Star"
    font = love.graphics.newFont("Inconsolata-Black.ttf",25)
    love.graphics.setFont(font)
    ww,wh = love.graphics.getDimensions()
    animation = ww
    dw,dh = love.window.getDesktopDimensions()
    love.window.setPosition((dw-ww)-20+animation,20)
    love.graphics.setBackgroundColor(0.1,0.1,0.1)
    bts = {[true]="true",[false]="false"}
    prevminute = -1
    settings = 0
    sttngs = {"username","pswrd","mins",["username"]={"Enter username: ","username"},["pswrd"]={"Enter password: ","----"},["mins"]={"Check in every",3," minutes"}}
    nativefs.write("messages.lua","")
    dofile("settings.lua")
    head,text,img,color = {},{},{},{}
    setupdone = false
end
function love.update()
    if settings==0 then
        settings = 1
        love.window.setMode(480,360,{borderless=true})
        function love.draw() drawsettings() end
        return
    end
    if settings==1 then
        return
    end
    currentminute = math.floor(love.timer.getTime()/(60*sttngs["mins"][2]))
    if not(currentminute==prevminute) then
        io.write("cheking...\n")
        nativefs.write("markasread.py",
[[
import scratchattach
user = scratchattach.login("]]..sttngs["username"][2]..[[","]]..sttngs["pswrd"][2]..[[")
user.clear_messages()
]])
    local a = [[
import scratchattach
user = scratchattach.login("]]..sttngs["username"][2]..[[","]]..sttngs["pswrd"][2]..[[")
messages = user.messages(limit=5, offset=0)
i = 0
all = []
print(messages)
for i in messages:
    type = i["type"]
    a="none"
    data = []
    if type=="studioactivity":
        a=("New activity in studio "+i["title"])
        data=[i["title"]   ]
    if type=="forumpost":
        a=("new activity by "+i["actor_username"]+" in forum "+i["topic_title"])
        data=[i["topic_title"],i["actor_username"]   ]
    if type=="addcomment":
        if (i["commentee_username"]=="None")or(i["commentee_username"]==None):
            a=("from "+i["actor_username"]+" at profile/project "+i["comment_obj_title"]+": "+i["comment_fragment"])
            data=[i["comment_fragment"],i["comment_obj_title"],i["actor_username"]   ]
        else:
            a=("from "+i["actor_username"]+" at profile/project "+i["comment_obj_title"]+" to "+i["commentee_username"]+": "+i["comment_fragment"])
            data=[i["comment_fragment"],i["comment_obj_title"],i["actor_username"],i["commentee_username"]   ]
    if type=="followuser":
        a=("user " +i["actor_username"]+" is following you")
        data=[i["actor_username"]   ]
    if type=="favoriteproject":
        a=("user " +i["actor_username"]+" added "+i["project_title"]+" (your project) to his/her favorites")
        data=[i["actor_username"],i["project_title"]   ]
    if type=="loveproject":
        a=("user " +i["actor_username"]+" added "+i["title"]+" (your project) to his/her loved")
        data=[i["actor_username"],i["title"]   ]
    if a=="none":
        l("NEW TYPE!: "+type)
    data.insert(0,type)
    data.insert(0,a)
    all.append(data)
def a(l):
    string = "{"
    for v in l:
        if isinstance(v,str):
            string=string+"\""+v.replace("\n","")+"\""+","
        if isinstance(v,int):
            string=string+str(v)+","
        if isinstance(v,list):
            string=string+a(v)+","
    return (string[:-1])+"}"
f = open("messages.lua", "w")
f.write("messages="+a(all))
f.close()
]] nativefs.write("getmessages.py",a)
        local r = io.popen("py \""..nativefs.getWorkingDirectory().."/getmessages.py\"")
        local f = r:read("*a")
        io.write(f.."\n")
        f = nil
        r:close()
        messages = nil
        dofile("messages.lua")
        head,text,img,color = {},{},{},{}
        if (not(prevmessage==serializate(messages))) and (messages~=nil) then
            love.window.setMode(400,100,{borderless=true})
            love.window.requestAttention()
            for k, v in ipairs(messages) do
                head[k] = msgtypehead[messages[k][2]]
                text[k] = messages[k][1]
                img[k] = msgtypeimg[messages[k][2]]
                color[k] = msgtypecolor[messages[k][2]] or {1,1,1,0.1}
            end
            animation = ww
            animation2 = nil
            function love.draw() pop() end
        end
        prevmessage = serializate(messages)
    end
    prevminute = currentminute
end
function drawsettings()
    ww,wh = love.graphics.getDimensions()
    mx,my = love.mouse.getPosition()
    love.graphics.setColor(1,1,1,0.1)
    if (mx>(ww-20)) and (my<20) and love.window.hasMouseFocus() then
        love.graphics.setColor(1,1,1,0.7)
    end
    love.graphics.rectangle("fill",ww-20,0,20,20)
    love.graphics.setColor(1,1,1,0.1)
    if (mx>(ww-40)) and (mx<(ww-20)) and (my<20) and love.window.hasMouseFocus() then
        love.graphics.setColor(1,1,1,0.7)
    end
    love.graphics.rectangle("fill",ww-40,0,20,20)
    love.graphics.setColor(1,1,1,0.7)
    love.graphics.draw(xicon,ww-20)
    love.graphics.draw(stopicon,ww-40)
    local fh = font:getHeight()
    local shift = 40
    local size = 0.75
    table.insert(sttngs,"save")
    sttngs["save"] = {"Save changes",function() table.remove(sttngs,#sttngs) nativefs.write("settings.lua","sttngs="..serializate(sttngs)) table.insert(sttngs,"save") end}
    for l, w in ipairs(sttngs) do
        local k = w
        local v = sttngs[k]
        love.graphics.setColor(1,1,1)
        love.graphics.print(v[1],2,shift,nil,size)
        if type(v[2])=="string" then
            love.graphics.print(v[2]..(v[3] or ""),ww-font:getWidth(v[2]..(v[3] or ""))*size-2,shift,nil,0.75)
            if (my<(shift+fh)) and (my>shift) then
                love.graphics.setColor(1,1,1,0.5)
                if (not clicked) and love.mouse.isDown(1) then
                    txt={["x"]=0,["y"]=shift,["hold"]={k},["txt"]=v[2],["done"]=function(txt,hold) sttngs[hold[1]][2] = txt end}
                end
                love.graphics.rectangle("fill",0,shift,ww,fh*size)
            end
        end
        if type(v[2])=="number" then
            local w = tostring(v[2])
            love.graphics.print(w..(v[3] or ""),ww-font:getWidth(w..(v[3] or ""))*size,shift,nil,0.75)
            if (my<(shift+fh)) and (my>shift) then
                love.graphics.setColor(1,1,1,0.5)
                if (not clicked) and love.mouse.isDown(1) then
                    txt={["x"]=0,["y"]=shift,["hold"]={k},["txt"]=w,["done"]=function(txt,hold) sttngs[hold[1]][2] = tonumber(txt) end}
                end
                love.graphics.rectangle("fill",0,shift,ww,fh*size)
            end
        end
        if type(v[2])=="bool" then
            local w = bts[v[2]]
            love.graphics.print(w,ww-font:getWidth(w)*size,shift,nil,0.75)
            if (my<(shift+fh)) and (my>shift) then
                love.graphics.setColor(1,1,1,0.5)
                if (not clicked) and love.mouse.isDown(1) then
                    settings[k][2] = not v[2]
                end
                love.graphics.rectangle("fill",0,shift,ww,fh*size)
            end
        end
        if type(v[2])=="function" then
            local w = v[3] or ""
            love.graphics.print(w,ww-font:getWidth(w)*size,shift,nil,0.75)
            if (my<(shift+fh)) and (my>shift) then
                love.graphics.setColor(1,1,1,0.5)
                if (not clicked) and love.mouse.isDown(1) then
                    v[2]()
                end
                love.graphics.rectangle("fill",0,shift,ww,fh*size)
            end
        end
        shift = shift+fh*size
    end
    table.remove(sttngs,#sttngs)
    if (not clicked) and love.mouse.isDown(1) then
        if (mx>(ww-20)) and (my<20) then
            settings = false
            clicked = true
            love.window.setMode(400,100,{borderless=true})
            local ww,wh = love.graphics.getDimensions()
            local shift = 10
            local size = (ww-10*7)/600
            local shifty = 15
            for k, v in pairs(msgtypeimg) do
                local c = msgtypecolor[k]
                c[4] = 0.5
                love.graphics.setColor(c)
                love.graphics.draw(v,shift,shifty,nil,size)
                shift = shift+100*size+10
            end
            local t = "Loading"
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(t,(ww-font:getWidth(t))/2,(wh-font:getHeight())/2)
            nativefs.write("messages.lua","")
            love.window.requestAttention()
            if setupdone then
                table.insert(head,1,"Settings")
                table.insert(text,1,"Settings closed")
            else
                table.insert(head,1,"Setup is done")
                table.insert(text,1,"Setup for SN is done")
            end
            table.insert(img,1,nil)
            table.insert(color,1,{1,1,1,1})
            animation = ww
            animation2 = nil
            setupdone = true
            function love.draw() pop() end
        elseif (mx>(ww-40)) and (mx<(ww-20)) and (my<20) then
            love.event.quit()
        end
    end
    clicked = love.mouse.isDown(1)
    if txt then
        love.graphics.setColor(0.9,0.9,0.9)
        love.graphics.rectangle("fill",txt.x-2.5,txt.y,font:getWidth(txt.txt)*0.75+5,fh*0.75)
        love.graphics.setColor(0,0,0)
        love.graphics.print(txt.txt,txt.x,txt.y,nil,0.75)
        function love.textinput(t)
            txt.txt = txt.txt..t
        end
    end
    
end
function love.keypressed(key)
    if txt then
        if key=="return" then
            txt.done(txt.txt,txt.hold)
            txt = nil
            function love.textinput()
            end
        end
        if key=="backspace" then
            txt.txt = string.utf8sub(txt.txt,1,string.utf8len(txt.txt)-1)
        end
    end
end
function pop()
    ww,wh = love.graphics.getDimensions()
    mx,my = love.mouse.getPosition()
    x,y = (dw-ww)-20+animation,20

    love.window.setPosition(x+(animation2 or 0),y)
    animation = animation/1.2
    local shift = scroll or 0
    for k, v in ipairs(head) do        
        love.graphics.setColor(color[k])
        if img[k] then
            love.graphics.draw(img[k],10,shift)
        end
        love.graphics.setColor(1,1,1)
        love.graphics.print(head[k] or bts[love.window.hasFocus()],10,shift)
        love.graphics.printf(text[k] or "none",10,26+shift,ww/0.5-20,nil,nil,0.5)
        shift = shift+100
    end
    shift = 0
    if animation2 then
        if animation2>(dw-ww-20) then
            animation2 = nil
            love.system.openURL("https://scratch.mit.edu/messages")
            function love.draw() end
            love.window.close()
            scroll = 0
        end
        animation2 = (animation2 or 1)*2
    end
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.rectangle("fill",ww-80,0,80,20)
    love.graphics.setColor(1,1,1,0.1)
    if (mx>(ww-20)) and (my<20) and love.window.hasMouseFocus() then
        love.graphics.setColor(1,1,1,0.7)
    end
    love.graphics.rectangle("fill",ww-20,0,20,20)
    love.graphics.setColor(1,1,1,0.1)
    if (mx>(ww-40)) and (mx<(ww-20)) and (my<20) and love.window.hasMouseFocus() then
        love.graphics.setColor(1,1,1,0.7)
        if love.mouse.isDown(1) then
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill",0,0,ww,wh)
        end
    end
    love.graphics.rectangle("fill",ww-40,0,20,20)
    love.graphics.setColor(1,1,1,0.1)
    if (mx>(ww-60)) and (mx<(ww-40)) and (my<20) and love.window.hasMouseFocus() then
        love.graphics.setColor(1,1,1,0.7)
    end
    love.graphics.rectangle("fill",ww-60,0,20,20)
    love.graphics.setColor(1,1,1,0.1)
    if (mx>(ww-80)) and (mx<(ww-60)) and (my<20) and love.window.hasMouseFocus() then
        love.graphics.setColor(1,1,1,0.7)
    end
    love.graphics.rectangle("fill",ww-80,0,20,20)
    love.graphics.setColor(1,1,1,0.7)
    love.graphics.draw(xicon,ww-20)
    love.graphics.draw(readicon,ww-40)
    love.graphics.draw(stopicon,ww-60)
    love.graphics.draw(moreicon,ww-80)
    if (not clicked) and love.mouse.isDown(1) then
        if (mx>(ww-20)) and (my<20) then
            function love.draw() end
            love.window.close()
            scroll = 0
        elseif (mx>(ww-40)) and (mx<(ww-20)) and (my<20) then
            os.execute("py \""..nativefs.getWorkingDirectory().."/markasread.py\"")
        elseif (mx>(ww-60)) and (mx<(ww-40)) and (my<20) then
            love.event.quit()
            scroll = 0
        elseif (mx>(ww-80)) and (mx<(ww-60)) and (my<20) then
            settings = 0
            scroll = 0
        else
            animation2 = 20
        end
    end
    clicked = love.mouse.isDown(1)
end
function serializate(t,filename)
    local c = "{"
    if filename then
        c = "data={"
    end
    level = level or 0
    for k, v in pairs(t or {}) do
        local index = ""
        if type(k)=="string" then
            index = "[\""..k.."\"]="
        end
        if type(k)=="table" then
            assert(k,"index of serializated table returned table value type")
         end
         if type(v)=="string" then
            c=c..index.."\""..v.."\""..","
        end
        if type(v)=="number" then
            c=c..tostring(index..v)..","
        end
        if type(v)=="table" then
            c=c..index..serializate(v)..","
        end
        if type(v)=="function" then
            assert(v,"value of table at index "..k.." returned value type function (we dont support that yet)")
        end
    end
    return (string.sub(c,1,#c-1).."}")
end
function love.wheelmoved(x,y)
    scroll=(scroll or 0)+y*25
    if scroll<-400 then
        scroll = -400
    end
    if scroll>0 then
        scroll=0
    end
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg) --https://love2d.org/wiki/love.errorhandler base
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")
    local box = love.window.showMessageBox("Error",p,{"Restart SN","Copy","Ok"})
    if box==2 then
        
    elseif box==1 then
        if love.filesystem.isFused() then
            if nativefs.getInfo("SN.exe") then
                os.execute("start \"\" \""..nativefs.getWorkingDirectory().."\\SN.exe\"")
            elseif nativefs.getInfo("SN.love") then
                os.execute("start \"\" \""..nativefs.getWorkingDirectory().."\\SN.love\"")
            else
                love.window.showMessageBox("Renamed","This app was renamed,\n cannot restart automaticaly")
            end
        else
            love.window.showMessageBox("Not fused","This app is not fused,\n cannot restart automaticaly")
        end
    end
end
