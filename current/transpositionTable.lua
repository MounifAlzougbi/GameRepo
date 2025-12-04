-- zobrist / mem

addys={ -- memory addresses
	main_start=0x8000+96, -- free
	main_size=4084, -- slots
	main_pack_size=8, -- bytes
--[[
extra mem space is for 
collision/linked lists addition
seperate to maximize var space
]]--
	extra_start=0x4300, -- user def
	extra_size=486, -- slots
	extra_pack_size=10, -- bytes
}

-- rets hash-mem-address
-- currently rets 
function hash_address(key,col)
	if col==nil then col=false end
	
	local base,p_size,size

	if col then
		base=addys.extra_start
		p_size=addys.extra_pack_size
		size=addys.extra_size	
	elseif col==false then
		base=addys.main_start
		p_size=addys.main_pack_size
		size=addys.main_size	
	end
	
--	address=base+((hash&(size-1))<<p_size)
	local address=base+(key%size)*p_size

	return address
end

-- @read from dyn mem
function read(key)
	local	addr=hash_address(key)
	local packet=peek_packet(addr)
	
	if packet.z_hash!=key then
		addr=hash_address(key,true)
		local count=0

		while peek4(addr)!=key 
		and addr<0x5600
		and addr>0x3400
		and count<200 do
			count+=1
			addr=peek2(addr+8)
		end

		if peek4(addr)!=key then
			return false end
		packet=peek_packet(addr)
	end
	
	return packet
end

function find_empty_addr()
	for i=0x4300,0x5600,10 do
		if peek4(i)==0 then
			return i
		end
	end
	return nil
end

-- @insert collision
function insert_collision(packet)
	
	local current=hash_address(packet.z_hash,true)
	local last=current
	local count=0

	if peek4(current)==0 then
		poke_packet(packet,current)
		poke2(current+8,0)
		return current
	end

-- while pointer != 0 and in range
	while peek2(current+8)!=0 
	and current<0x5600
	and current>0x4300
	and count<200 do
		if peek4(current)==packet.z_hash then
			poke_packet(packet,current)
			return current
		end
		count+=1
		last=current
		current=peek2(current+8)
	end

	if peek4(current)==packet.z_hash then
		poke_packet(packet,current)
		return current
	end

-- empty addr
	addr=find_empty_addr()
	
	if addr==nil then
		return false end
	
-- poke packet

	poke_packet(packet,addr)

-- make sure no self pointing
	if current+8!=addr+8 then
		poke2(current+8,addr)
	end

	return addr
	
end

-- @insert packet
function insert(packet)
	local address=hash_address(packet.z_hash)
	
-- if address is not taken
	if peek4(address)==0 then
		poke_packet(packet,address)
		return address
	else
-- if hash matches updated
		if peek4(address)==packet.z_hash then
			delete(packet.z_hash)
			poke_packet(packet,address)
			return 'main mem update'
		else
			local check=insert_collision(packet)
	--	rets t/f on check
			if check then return check
			else return false end
		end
	end
end

-- @delete z_key instance
function delete(key)
	local addr=hash_address(key)
	
	if peek4(addr)==key then
		poke4(addr,0)
		poke4(addr+4,0)
		return true
	end
	
-- collision
	addr=hash_address(key,true)

	if peek4(addr)==key then
		poke4(addr,0)
		poke4(addr+4,0)
		local pointer=peek2(addr+8)

		if pointer==0 
		or pointer<0x4300
		or pointer>0x5600 then poke2(addr+8,0) return true end

		poke2(addr+8,0)

		poke4(addr,peek4(pointer))
		poke4(addr+4,peek4(pointer+4))
	--poke pointer 'pull chain up'
		poke2(addr+8,peek2(pointer+8))
		return true
	end

	local last=addr
	local count=0
	while peek4(addr)!=key
	and addr<0x5600 
	and addr!=0
	and count<200 do
		count+=1
		last=addr
		addr=peek2(addr+8)
	end
	
	if addr==0 
	or peek4(addr)!=key then
		return false end

	poke2(last+8,peek2(addr+8))
	
	poke4(addr,0)
	poke4(addr+4,0)
	poke2(addr+8,0)
	return true
	
end

-- inits all zobrist hash values
function zobrist_prng()
	
	keys={}
		
	for i=1,63 do
-- position
		keys[i]={}
		for c=1,2 do
-- color
			keys[i][c]={}
			for p=1,6 do
-- peice?
				local rndint=rnd(0x7fff.ffff)
				poke4(8000,rndint)
				keys[i][c][p]=peek4(8000)
--				print(rndint)
			end
		end
	end
	poke(8000,0)
end

--returns zobrist hash of board
function ret_zhash()
	local hash=0
	
	for i=1,#p do
		if 	p[i].x<128
		and p[i].y<128 then
		
			local pos=p[i].y*8+p[i].x+1
				-- always ret 0?  ⬆️
		
			local col=p[i].c
			-- correct, trust
			if col==1 then
				col=2
			else
				col=1
			end
			
			local rank=0
			
			if p[i].rank=='pawn' then
				rank=1
			elseif p[i].rank=='rook' then
				rank=2
			elseif p[i].rank=='bish' then
				rank=3
			elseif p[i].rank=='knite' then
				rank=4
			elseif p[i].rank=='queen' then
				rank=5
			elseif p[i].rank=='king' then
				rank=6
			end
			
--			print(pos,20,20,8)
			if keys[pos]
			and keys[pos][col]
			and keys[pos][col][rank] then
				local key=keys[pos][col][rank]
				hash=bxor(hash,key)
			else

			end
		

		end
	end
	
	return hash
	
end

-- @mem inits
function mem_init()
	for addr=0x8000,0xffff,4 do
		poke4(addr,0)
	end

	for addr=0x4300,0x5600,4 do
		poke4(addr,0)
	end
end
