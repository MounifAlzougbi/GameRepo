

-- t/f if i in range
function range(mn,mx,i)
	if i>=mn
	and i<=mx then
		return true
	else return false end
end

-- rets peeked packet
function peek_packet(address)
--	if address==nil then

	return {
		z_hash=peek4(address),
		score=peek2(address+4),
		depth=peek(address+6),
		flags=peek(address+7)
	}
end

-- @poke packet
--[[ bytes: 
	1-4 z hash, 5-6 best move (6bit per pos) with 2bit heuristic and 2bit capture
	7 signed int score, 8 flags 4bit depth 2bit age 2bit scorebound >,<,=
--]]
function poke_packet(packet,address)
	if range(0x8000,0xffff,address)
	or range(0x4300,0x5600,address) then

		if address<0x5600 then
			poke4(address)
			poke4(address+4)
			-- poke2(address+8)
		elseif address>0x8000 then
			poke4(address)
			poke4(address+4)
		end

		poke4(address,packet.z_hash)
		poke2(address+4,packet.score)
		poke(address+6,packet.depth)
		poke(address+7,packet.flags)
	end
end

-- set to 1
function set_bit(byte,index)
	return bor(byte,1<<index-1)
end

-- set to 0
function clr_bit(byte,index)
	ones=1
	ones=ones<<index-1
	ones=bxor(ones,0xffff.ffff)
	return band(byte,ones)
end

-- bits 1-8 starting from right
function ret_bit(byte,index)
	return band(byte>>index-1,1)
end

--@mouse
mouse={
	x=64,y=98,
	just_pressed=false,
	lock=false,
	pressed=false,
	target=-1,
	tx,ty,
	lx,ly,		--last x-y pos
	p=46,
	
	is_b_col=function(s,b)
		if 	s.x<b.x+b.w 
		and	s.x>b.x
		and s.y>b.y
		and s.y<b.y+b.h then
			return true
		else return false	
		end
	end,
	
	init=function(s)
		poke(0x5f2d, 1)
	end,
	
	update=function(self)
		self.just_pressed=false
		self.x=stat(32)
		self.y=stat(33)
		if (stat(34)==1) then
			self.pressed=true
			self.p=47
			elseif (stat(34)==0) 
			and self.pressed==true then
				self.pressed=false
				self.just_pressed=true
				self.lx=self.x
				self.ly=self.y
				self.p=46
		end
	end,
	
	draw=function(s)
		spr(s.p,mouse.x,mouse.y)
	end
}

state={
	menu=true,
	board=false,
	paused=false
}


-- button stuff


function button_pressed(arg)
	if arg=='start_multi' then
		state.menu=false
		state.board=true
		init_board(-1)--init black 
		init_board(1)--and white!
	end
end

function button_init()
	gb={}	-- global button array

	button={
		cx,cy,	-- center x,y
		str,cstr=6,	-- str clr
		x1,y1,w,h,
		x_off=1,y_off=4,--rrect ofset
		r=2,c1=5,c2=1,c3=1,	--c1 main button clr,c2 outline clr, c3 def clr
		cmo=2,--clr m_over
		px,py, -- print x,y
		br_off=1,	--back rect
		arg,--passed as arg when pressed
		
		new=function(s,tbl)
			tbl=tbl or {}
			setmetatable(tbl,{
			__index=s
			})
			return tbl
		end,
		
		init=function(s)
			s.x1=(s.cx-#s.str*2)-1-s.r
			s.y1=s.cy-s.r-s.y_off
			s.w1=#s.str*4+s.r*2+s.x_off
			s.h1=s.y_off*2+1
			
			s.x=s.x1-s.br_off
			s.y=s.y1-s.br_off
			s.w=s.w1+s.br_off*2
			s.h=s.h1+s.br_off*2
			
			s.py=s.cy-s.y_off
			s.px=s.cx-(#s.str*2)
		end,
		
		update=function(s,mouse)
			local mouse_coll=mouse:is_b_col(s)
			if mouse_coll then
				s.c2=s.cmo
			else
				s.c2=s.c3
			end
			if mouse.just_pressed
			and mouse_coll then
				button_pressed(s.arg)
			end
		end,
		
		draw=function(s)
			rrectfill(s.x,s.y,
			s.w,s.h,s.r,s.c2)
			rrectfill(s.x1,s.y1,
			s.w1,s.h1,s.r,s.c1)
			print(s.str,s.px,s.py,s.cstr)
		end
		
	}
	
	add(gb,button:new({
		cx=64,cy=64,--center x,y
		str='2 player chess',
		arg='start_multi'}))--button use
	
	for button in all(gb) do
		button:init()
	end
	
end

function button_update()
	for button in all(gb) do
		button:update(mouse)
	end
end

function button_draw()
	for button in all(gb) do
		button:draw()
	end
end
