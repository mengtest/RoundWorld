Client = Class{}

socket = require("socket")

function Client:init(host, port)
	self.host = host
	self.port = port
	self.tcp = assert(socket.tcp())

	
	self.tcp:settimeout(0)

	self.data = {}
	self.last = 'none'
	
	print('test')
	
	self.receive = coroutine.create(function()
		local i = 0
		while true do
			--get data
			local s, status, partial = self.tcp:receive()
			if status == "closed" then 
				--if closed, disconnect
				self.connected = false
				self.tcp:close()
				coroutine.yield()
				break
			end
			
			--make sure it exisits
			if s then 
				print("got: " .. s)
				table.insert(self.data, s) 
				self.last = s
			end
			
			if partial and partial ~= '' then
				print("got: " .. partial)
				table.insert(self.data, partial) 
				self.last = partial
			end
			
	
			

			coroutine.yield()
			
			
		end
		

	end)
	
end

function Client:connect(pName)
	
	self.tcp:connect(self.host, self.port)
	print("SHIPPP")
	self.connected = true
	coroutine.resume(self.receive)
	--self.last = coroutine.status(self.receive)

end

function Client:update()
	if self.connected then
		coroutine.resume(self.receive)
		
		
	end
end

function Client:send(s)
	self.tcp:send(s .. '\n')

end

function Client:conntest()
	local host, port = "127.0.0.1", 7777
	local tcp = assert(socket.tcp())

	tcp:connect(host, port);
	--note the newline below
	tcp:send("hello world\n");

	
	tcp:close()
end

--greedy gets remove data that doesn't match
function Client:getCommand(id, greedy)
		
	--check for relevent data
	
	if self.data[1] then
		local jData = json.decode(self.data[1])
		if jData['id'] == id then
			table.remove(self.data, 1)
			return jData
		elseif greedy then
			table.remove(self.data, 1)
		end
		--TODO and chat limit
	end
	

end

function Client:sendChat(message)
	print("Sending Chat message")
	print(message)
	local jData = {}
	jData['id'] = 'chat'
	jData['message'] = message
	self:send(json.encode(jData))
end

function Client:sendPlayerConnect()	
	local jData = {}
	jData['id'] = 'playerConnect'
	jData['PID'] = PID
	self:send(json.encode(jData))
end

function Client:sendMPPosUpdate(pid, x, y, vx, vy, a)
	local jData = {}
	jData['id'] = 'MPPU'
	jData['x'] = math.floor(x)
	jData['y'] = math.floor(y)
	jData['vx'] = vx
	jData['vy'] = vy
	jData['a'] = a
	jData['PID'] = pid

	self:send(json.encode(jData))
end



function Client:sendHB()
	local jData = {}
	jData['id'] = 'hb'
	self:send(json.encode(jData))
end

function Client:sendKeyDown(key)
	local jData = {}
	jData['id'] = 'keydown'
	jData['key'] = key
	self:send(json.encode(jData))
end

function Client:sendKeyUp(key)
	local jData = {}
	jData['id'] = 'keyup'
	jData['key'] = key
	self:send(json.encode(jData))
end

function Client:sendActionStart(id)
	local jData = {}
	jData['id'] = 'actS'
	jData['aid'] = id
	jData['PID'] = PID
	self:send(json.encode(jData))
end

function Client:sendActionEnd(id)
	local jData = {}
	jData['id'] = 'actE'
	jData['aid'] = id
	jData['PID'] = PID
	self:send(json.encode(jData))
end

function Client:sendPos()
	local jData = {}
	jData['id'] = 'pos'
	jData['x'] = PLAYER.body:getX()
	jData['y'] = PLAYER.body:getY()
	jData['PID'] = PID
	self:send(json.encode(jData))
end


