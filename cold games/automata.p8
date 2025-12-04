pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- mouse stuff/global data types

-- num to tbl
function num_tbl(num)
	tbl={}
	temp={}
	while num>0 do
		add(temp,num%10)
		num=flr(num/10)
	end
	
	for i=#temp,1,-1 do
		add(tbl,temp[i])
	end
	
	return tbl
end

-- returns min val in tbl
function ret_min(tbl)
	local least=tbl[1]
	for i=1,#tbl do
		if tbl[i]<least then
			least=tbl[i]
		end
	end
	return least
end

-- rets index of value in tbl
function ret_i(tbl,val)
	for i=1,#tbl do
		if tbl[i]==val then
			return i end
	end
end

-- lerps between two points
function lerp(a,b,t)
	local ax=a.x
	local ay=a.y
	local bx=b.x
	local by=b.y
	
	local x=(1-t)*a.x+b.x*t
	local y=(1-t)*a.y+b.y*t

	return vec(x,y)
end

-- returns dist inbetween two obj
function dist(a,b)
	local dx=b.pos.x-a.pos.x
	local dy=b.pos.y-a.pos.y
	local csqr=dx*dx+dy*dy
	
	csqr=sqrt(csqr)
	
	return csqr
end

mouse={
	x=-64,y=-98,
	just_pressed=false,
	lock=false,
	pressed=false,
	target=-1,
	tx,ty,
	lx,ly,		--last x-y pos
	p=64,
	
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
			self.p=65
			elseif (stat(34)==0) 
			and self.pressed==true then
				self.pressed=false
				self.just_pressed=true
				self.lx=self.x
				self.ly=self.y
				self.p=64
		end
	end,
	
	draw=function(s)
		spr(s.p,mouse.x,mouse.y)
	end
}

-->8


-->8
-- automata funcs


function is_dead(level)
	local dead=true
	for x=1,128 do
		if pget(x,level)==1 then
			dead=false
		end
	end
	
	return dead
	
end


function init_state(int)
	for i=1,int do
		local rand=flr(rnd(128))
		pset(rand,0,2)
	end
end

function shift_up()
	for y=1,127 do
		for x=0,127 do
			pset(x,y-1,pget(x,y))
		end
	end
end
-->8
-- automata loops

function automata_init()
	
	cool_rules={18,22,26,30,45,54,57,60,73,90,102,105,106,110,122,126,129,150,153,184,1,2,8,16,32,64,128,255,1}
	playlist=false-- automata playlist
	
	rule_mem=8000 

	rule=3 -- any int 1-256
	
	rands=8 -- starting points
	
--	init_state(rands)
	
	total=0
	y=0
	speed=0.05

	
end

-- rets new layer from y
function new_layer(y)
	
	for x=0,127 do
		if x==0 then
			left=pget(127,y)
			right=pget(x+1,y)
		elseif x==127 then
			left=pget(x-1,y)
			right=pget(0,y)
		else
			left=pget(x-1,y)
			right=pget(x+1,y)
		end
		
		local center=pget(x,y)
		
		local bstr=left<<2|center<<1|right
		
		next_val=(rule>>bstr)&1
		
		pset(x,y+1,next_val)
		
	end
	
end

function reset_automata()
	local rand=flr(rnd(#cool_rules-1))+1
	rule=cool_rules[rand]
	y=0
	cls()
	init_state(rand/2)
	speed=0.05
end

function automata_update()
	
	last_t=last_t or 0
	t=time()
	delta_t=t-last_t
	
	total+=delta_t
		
	if total>speed then
		new_layer(y)
		y+=1
		total=0
	end
	
	if y>126
	and playlist
	or btn(🅾️) then
		reset_automata()
	elseif y>126 
	and playlist!=true then
		shift_up()
		y=126
	end
	
	last_t=time()
	
end
-->8

function draw_init()
	if mouse.y<32
	and mouse.x>-1
	and mouse.x<128
	and mouse.pressed then
--		flg1=true
		pset(mouse.x,0,8)
	else
--		flg1=false
	end
end
-->8
-- button stuff

state=1
-- state 1=menu, 2=in automata

function button_pressed(arg,i)
	if arg=='start_automata' then
		
		cls()
		
		y=0
		state=2
		output_num=tonum(gb[1].str)
		init_amnt=tonum(gb[2].str)
		
		if output_num
		and output_num>0
		and output_num<256 then
			rule=output_num
		else
			local rand=flr(rnd(#cool_rules-1))+1
			rule=cool_rules[rand]
		end
		
		if init_amnt
		and init_amnt>0
		and init_amnt<128 then
			init_state(init_amnt)
		else
			init_state(8)
		end
		
		
		
	elseif arg=='toggle_playlist' then
		if playlist then
			gb[i].toggle=false
			playlist=false
		else
			gb[i].toggle=true
			playlist=true
		end
	end
end

function button_init()
	gb={}	-- global button array
	
	-- text/int field is just button
	
	-- @number field
	num_field={
	
		clicked=false,
		max_int=255,
		min_int=0,
		input=0,
		output=0,
	
		new=function(s,tbl)
			tbl=tbl or {}
			setmetatable(tbl,{
			__index=s
			})
			return tbl
		end,
	
		init=function(s)
		
		end,
	
		update=function(s)
			
			if s.input!=nil then
				if tonum(s.input)==nil then
					d=1
				else
					d=10
				end
				s.output=s.output*d+(tonum(s.input) or 0)
			end
		
			s.input=nil
		
			if s.output>s.max_int
			or s.output<s.min_int then
				s.output=0
			end
		end
	
	}
	
-- @button
	button={
		toggle, -- toggle button?
		cx,cy,	-- center x,y
		str,lstr,--last str
		cstr=6,	-- str clr
		x1,y1,w,h,
		x_off=1,y_off=4,--rrect ofset
		r=2,c1=5,c2=1,c3=1,	--c1 main button clr,c2 outline clr, c3 def clr
		cmo=2,--clr m_over
		px,py, -- print x,y
		br_off=1,	--back rect
		arg,--passed as arg when pressed
		init_bool=true,
		
		new=function(s,tbl)
			tbl=tbl or {}
			setmetatable(tbl,{
			__index=s
			})
			return tbl
		end,
		
		init=function(s)
			local strl=#tostr(s.str)
			if s.init_bool then
				s.og_str=s.str
			end
			s.init_bool=false
			s.x1=(s.cx-strl*2)-1-s.r
			s.y1=s.cy-s.r-s.y_off
			s.w1=strl*4+s.r*2+s.x_off
			s.h1=s.y_off*2+1
			
			s.x=s.x1-s.br_off
			s.y=s.y1-s.br_off
			s.w=s.w1+s.br_off*2
			s.h=s.h1+s.br_off*2
			
			s.py=s.cy-s.y_off
			s.px=s.cx-(strl*2)
		end,
		
		update=function(s,mouse)
			
			if s.toggle then
				s.c1=s.cmo
			else
				s.c1=5
			end
			
			local mouse_coll=mouse:is_b_col(s)
			
			if mouse_coll then
				s.c2=s.cmo
			else
				s.c2=s.c3
			end
			if mouse.just_pressed
			and mouse_coll then
				button_pressed(s.arg,s.index)
				if s.field then
					s.field.clicked=true
				end	
			elseif mouse.just_pressed
			and mouse_coll!=true 
			and s.field then
				s.field.clicked=false
				if tonum(s.str)==0 then
					s.str=s.og_str
				end
			end
			
			if s.field then
				if s.lstr!=s.str then
					s:init()
				end
			end
			
			s.lstr=s.str
		end,
		
		draw=function(s)
			rrectfill(s.x,s.y,
			s.w,s.h,s.r,s.c2)
			rrectfill(s.x1,s.y1,
			s.w1,s.h1,s.r,s.c1)
			print(s.str,s.px,s.py,s.cstr)
		end
		
	}
	
-- @init gui

-- keep ⬇️ as 1 index! num field
	add(gb,button:new({
		cx=64,cy=45,
		str='rule? (1-255)',
		field=num_field:new(),
		index=#gb+1
	}))
	
	add(gb,button:new({
		cx=64,cy=60,
		str='starting points? (1-127)',
		field=num_field:new(),
		index=#gb+1
	}))
	
--	add(gb,button:new({
--		cx=64,cy=40,
--		str='speed? (default 50)',
--		field=num_field:new(),
--		index=#gb+1
--	}))
--	gb[#gb].field.output=50
	
	add(gb,button:new({
		cx=64,cy=85,
		str='toggle playlist',
		arg='toggle_playlist',
		index=#gb+1
	}))
	
	add(gb,button:new({
		cx=64,cy=100,--center x,y
		str='begin automata',
		arg='start_automata',
		index=#gb+1
	}))--button use
	
--	add(gb,button:new({
--		cx=64,cy=90,
--		str='enter int 1-255',
--		arg='user int'}))
	
	for button in all(gb) do
		button:init()
	end
	
end

function button_update()
	for button in all(gb) do
		button:update(mouse)
		if button.field then
			if button.field.clicked then
				button.field.input=stat(31)
				button.str=button.field.output
			end
			button.field:update()
		end
	end
end

function button_draw()
	for button in all(gb) do
		button:draw()
	end
end
-->8
-- game loop

function _init()
	cls()
	button_init()
	mouse:init()
	automata_init()
end

function _update60()
	if btn(❎) then
		state=1
	end

	if state==1 then
		mouse:update()
		button_update()
	elseif state==2 then
		automata_update()
	end
end

function _draw()
	if state==1 then
		cls()
		button_draw()
		mouse:draw()
	end
--	print(flg,0,0,9)

end
-- game loop

function _init()
	button_init()
	mouse:init()
	automata_init()
end

function _update60()
	if btn(❎) then
		state=1
	end

	if state==1 then
		draw_init()
		
		mouse:update()
		button_update()
	elseif state==2 then
		automata_update()
	end
end

function _draw()
	if state==1 then
		cls(1)
		cls(7)
		cls(5)
		cls(2)
		cls(0)
		button_draw()
		mouse:draw()
	elseif state==2 
	and y>32 
	and y<125 then
		print(rule,60,0,13)
	end 
--	print(mouse.y)
--	print(mouse.x)
--	print(flg1)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
575000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
577500000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
577750000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
577775000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
577550000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05570000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
