pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- mouse stuff

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

-->8
-- peice logic

function pokebb(x,y,int)
	poke(8000+x+(y*8),int)
end

function peekbb(x,y)
	return peek(8000+x+(y*8))
end

-- @p step pokes if possible on
function p_step(x,y,dx,dy,i)
	local sx=x+dx
	local sy=y+dy
	local val=peekbb(sx,sy)
	if val!=1 and sx>-1 and sx<8
	and sy>-1 and sy<9 and i<8 then
		pokebb(sx,sy,3)
		if val==2 then i=8
		else
			p_step(sx,sy,dx,dy,i+1)
		end
	end
end

-- @pawn possible
function pawn_possible(i)
	local x1=p[i].x
	local y1=p[i].y-p[i].c
	local y=p[i].y
	local y2=p[i].y-(p[i].c*2)

	if	bb:pos_is(x1,y1)==0 then
		poke(m+y1*8+x1,3)
	end
	
	if x1>0 then
		local lp=bb:what_i(x1-1,y)
		if lp!=nil then
			if p[lp].skipped then
				pokebb(x1-1,y1,3)
			end
		end
	end
	
	if x1<7 then
		local rp=bb:what_i(x1+1,y)
		if rp!=nil then
			if p[rp].skipped then
				pokebb(x1+1,y1,3)
			end
		end
	end
	
-- two peice move and en passunte
	if p[i].init==true then
		poke(m+y2*8+x1,3)
		p[i].skipped=true
	end
	
	if x1>0
	and bb:pos_is(x1-1,y1)==2 then
		poke(m+y1*8+(x1-1),3)
	end
	
	if x1<7
	and bb:pos_is(x1+1,y1)==2 then
		poke(m+y1*8+(x1+1),3)
	end
	
	p[i].init=false
end

-- @bish possible
function bish_possible(i)
	local x=p[i].x
	local y=p[i].y
	p_step(x,y,-1,-1,1)
	p_step(x,y,1,-1,1) 
	p_step(x,y,-1,1,1)
	p_step(x,y,1,1,1)
end

-- @rook possible
function rook_possible(i)
	local x=p[i].x
	local y=p[i].y
	p_step(x,y,0,-1,1)
	p_step(x,y,0,1,1)
	p_step(x,y,-1,0,1)
	p_step(x,y,1,0,1)
end

-- @knite possible
function knite_possible(i)
	local x=p[i].x
	local y=p[i].y
	p_step(x,y,-1,-2,7)
	p_step(x,y,1,-2,7)
	p_step(x,y,-1,2,7)
	p_step(x,y,1,2,7)
	p_step(x,y,2,-1,7)
	p_step(x,y,2,1,7)
	p_step(x,y,-2,-1,7)
	p_step(x,y,-2,1,7)
end

-- @queen possible
function queen_possible(i)
	local x=p[i].x
	local y=p[i].y
	--rook like
	p_step(x,y,0,-1,1)
	p_step(x,y,0,1,1)
	p_step(x,y,-1,0,1)
	p_step(x,y,1,0,1)
	--bish like
	p_step(x,y,-1,-1,1)
	p_step(x,y,1,-1,1) 
	p_step(x,y,-1,1,1)
	p_step(x,y,1,1,1)	
end

-- @king possible
function king_possible(i)
	local x=p[i].x
	local y=p[i].y
	--rook like
	p_step(x,y,0,-1,7)
	p_step(x,y,0,1,7)
	p_step(x,y,-1,0,7)
	p_step(x,y,1,0,7)
	--bish like
	p_step(x,y,-1,-1,7)
	p_step(x,y,1,-1,7) 
	p_step(x,y,-1,1,7)
	p_step(x,y,1,1,7)	
end
-->8
-- chess board & pieces

-- @piece array
p_draw={{--p[1]==black p[2]==white
	pawn=0,knite=2,rook=4,bish=6,
	queen=8,king=10},{
	pawn=32,knite=34,rook=36,bish=38,
	queen=40,king=42}}
--[[pawn=1,knite=2,rook=3,bish=4
king=5,queen=6, white=negative
 @board array
--]]
brd={
	{4,2,6,8,10,6,2,4},
	{0,0,0,0,0,0,0,0},
	{-1,-1,-1,-1,-1,-1,-1,-1},
	{-1,-1,-1,-1,-1,-1,-1,-1},
	{-1,-1,-1,-1,-1,-1,-1,-1},
	{-1,-1,-1,-1,-1,-1,-1,-1},
	{32,32,32,32,32,32,32,32},
	{36,34,38,40,42,38,34,36}}

p={}

g=_ENV

game={
	turn=1,
	held=0,
	last_turn=0
}

-- @init objects
function init_obj()

-- allow for global.var
	class=setmetatable({
		new=function(self,tbl)
			tbl=setmetatable(tbl or {},{
				__index=function(self,key)
			local raw=rawget(self,key)
					if raw!=nil then return raw end
			local class=self.class[key]
					or class[key]
			if class!=nil then return class end
			return _ENV[key]	
				end
			})
			return tbl
		end,
	
--	if tbl.update then
--		tbl.__index
--	end,
	
		init=function()end
	},{__index=_ENV})

	piece=class:new({
		_class = class,
		x=64,
		y=64,
		c,	n, -- c=color, n=print clr
		rank,
		init=true,	
		held=false,
		index=0,
		visible=true,
		skipped=false,--en passsunte
			
		new=function(s,tbl)
			tbl=tbl or {}
			tbl._class=s._class
			setmetatable(tbl,{
				__index=s
			})
		 return tbl
	 end,
	 
	 update=function(s)
	 	if s.rank=='pawn'
	 	and s.skipped==true
	 	and game.last_turn==s.c then
--	 		s.skipped=false
	  elseif mouse.pressed 
	  and bx==s.x 
	  and by==s.y
	  and game.turn==s.c 
	  and mouse.target==-1 then
	  	mouse.target=s.index
	  	s.visible=false
	  	bb:change_all(0)
				bb:my_col(game.turn,1)
				bb:my_col(game.turn*-1,2)
				bb:mask_possible(s.index)
	  elseif mouse.target==s.index
	  and mouse.just_pressed 
	  and bb:is_move(bx,by)	then
				s.visible=true
				mouse.target=-1
				if bx!=s.x or by!=s.y then
					local i=bb:what_i(bx,by)
					local i2=bb:what_i(bx,by+s.c)
-- en passunte
					if i2!=nil then
						if p[i2].skipped then
							p[i2].visible=false
							p[i2].x=200
							p[i2].y=200
						end
					end
					
					if i!=nil then
						p[i].visible=false
						p[i].x=200
						p[i].y=200
					end
					s.x=bx
					s.y=by
					swap_turn()
				end
			elseif s.rank=='pawn' 
			and s.y==0 and s.c==1
			or s.rank=='pawn' and
			s.y==7 and s.c==-1 then
				s.rank='queen'
				if s.c==-1 then s.n=8
				else s.n=40 end
				flag[2]=100
			elseif s.rank=='king'
			and s.visible==false then
				if s.c==-1 then
					game.winner='white'
					else
					game.winner='black'
				end
	  end
	 end,
	 
	 draw=function(s)
	 	if s.visible==true then
	 		spr_2x2(s.n,s.x,s.y)
	 	end
	 end	
	})
	
	--[[	@num state
	#0==empty coordinate,
	#1==freindly peice,
	#2==enemy peice,
	#3==current peice can place				possible move
	
	@byte board	--]]
	
	m=8000 --	memory offset
	
	bb=class:new({	-- bb=byte board
		_class = class,
		mem_strt=8000,--address (0,0)		top left
		mem_end=8064,--	address (7,7)			bottom right
		tc=0, --	target color
		fp=1, --	freindly peice, cant move there
		
-- returns i value of p x,y
		what_i=function(s,x,y)
			for i=1,#p do
				if p[i].x==x 
				and p[i].y==y then
				return	i end end
		end,
		
-- returns state of x,y
		pos_is=function(s,x,y)
			return peek(m+x+(y*8))
		end,
		
--[[ returns true or false
if peice can move
to pos x,y	--]]
		is_move=function(s,x,y)
			local x1=x
			local y1=y*8
			if peek(m+x1+y1)==3 then
			return true
			else return false end
		end,
		
-- change all pos to int
		change_all=function(s,int)
			for i=1,64 do
				poke(i+m,int)
			end
		end,
		
-- marks frendly and enemy peice
		my_col=function(s,c,int)
			for i=1,#p do
				if p[i].c==c then
				poke(m+(p[i].y*8)+(p[i].x),int)

				end
			end
		end,
		
--show possible moves per rank
		mask_possible=function(s,i)
			pokebb(p[i].x,p[i].y,3)
			if p[i].rank=='pawn' then
				pawn_possible(i)
			elseif p[i].rank=='bish' then
				bish_possible(i)
			elseif p[i].rank=='rook' then
				rook_possible(i)
			elseif p[i].rank=='knite' then
				knite_possible(i)
			elseif p[i].rank=='queen' then
				queen_possible(i)
			elseif p[i].rank=='king' then
				king_possible(i)
			end
		end,
		
--draw possible moves
		draw_possible=function(s)
			for i=1,64 do
				if peek(m+i)==3 then
					local y=flr(i/8)
					local x=i%8
					spr_2x2(14,x,y)
				end
			end
		end
	
	})
	
end

-- @swap turn
function swap_turn()
	if game.turn==-1 then
		game.turn=1
	else game.turn=-1 end
	game.last_turn=game.turn*-1
end

-- @add piece
function add_p(prank,px,py,pc,pn)
	add(p,piece:new({
		rank=prank,x=px,y=py,
		c=pc,n=pn,
		index=#p+1
		}))
end

-- @init board
function init_board(clr)
	local ryl_y=0
	local pwn_y=1
	local c=1 -- 1=black print
	if clr==1 then -- 1 = white
		ryl_y=7 -- -1 = black
		pwn_y=6
		c=2 -- 2=white print
	end
	
	for x=1,8 do-- pawns
		add_p('pawn',x-1,pwn_y,clr,p_draw[c].pawn)
	end
	
	add_p('rook',0,ryl_y,clr,p_draw[c].rook)
	add_p('knite',1,ryl_y,clr,p_draw[c].knite)
	add_p('bish',2,ryl_y,clr,p_draw[c].bish)
	add_p('queen',3,ryl_y,clr,p_draw[c].queen)
	add_p('king',4,ryl_y,clr,p_draw[c].king)
	add_p('bish',5,ryl_y,clr,p_draw[c].bish)
	add_p('knite',6,ryl_y,clr,p_draw[c].knite)
	add_p('rook',7,ryl_y,clr,p_draw[c].rook)

end
p_pos=false

-- @update board
function update_board()
	bx=flr(mouse.x/16)
	by=flr(mouse.y/16)
	lx=flr(mouse.lx/16)
	ly=flr(mouse.ly/16)
	px=bx+1
	py=by+1

	if game.winner==nil then
		for piece in all(p) do
			piece:update()
		end
	end
end

-- @get rank
function get_rank(i)
	return p[i].rank
end

-- @draw suggestion
function draw_sug(x,y,rank)
	if x>0 or x<8 then x*=16 end
	if y>0 or y<8 then y*=16 end
	local t=mouse.target
	if	rank=='pawn' then
		rectfill(x+6,y+6,x+9,y+9,13)
	end
end

-- @draw pieces
function draw_pieces()
	for i=1,#p do
		p[i]:draw()
	end
	if game.winner!=nil then
		rectfill(44,58,88,67,2)
		print(game.winner,46,60,9)
		print(' wins!',66,60,9)

	end
end

-- @spr 2x2
function spr_2x2(i,x,y)
	if x>0 or x<8 then x*=16 end
	if y>0 or y<8 then y*=16 end
	spr(i,x,y)
	spr(i+1,x+8,y)
	spr(i+16,x,y+8)
	spr(i+17,x+8,y+8)
end

function smap(mx,my,mxs,mys,x,y,xs,ys)
	-- mx = section of map to draw top left corner x in tiles
	-- my = section of map to draw top left corner y in tiles
	-- mxs = width of map section to draw in tiles
	-- mys = height of map section to draw in tiles
	-- x = screen position top left corner x in pixels
	-- y = screen position top left corner y in pixels
	-- xs = how wide to draw section in pixels
	-- ys = how tall to draw section in pixels
	
	local yo=((mys*8-1)/ys)/8
	for i=1,ys+1 do
		tline(x,y-1+i,x+xs,y-1+i,mx,my-yo+i*yo,((mxs*8-1)/xs)/8)
	end
end
-->8
-- button stuff

flags={
	tbl={
	['score>255']=false,
	['y2']=0
	},
	
	draw=function(s)
		local y=0
		local x=0
		for f,s in pairs(s.tbl) do
			if s==true then
				print(f.." = "..tostr(s),x,y)
				y-=8
			end
		end
	end
}

function button_pressed(arg)
	if arg=='start_multi' then
		state.menu=false
		state.board=true
		init_board(-1)--init black PEAC
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
-->8
-- game loop

function _init()
	button_init()
	init_obj()
	poke(0x5f2d, 1)
	bb:change_all(2)
end

function _update()
	mouse:update()
	if state.menu then
		button_update()
	elseif state.board then
		update_board()
	end
end

function _draw()
	cls()

	if state.menu then
		button_draw()
	elseif state.board then
		map()
		draw_pieces()
	end

	if mouse.target>-1 then
		local t=mouse.target 
		bb:draw_possible()
		spr_2x2(p[t].n,(mouse.x/16)-0.5,(mouse.y/16)-0.5)
	end
	flags:draw()
	mouse:draw()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000d0000000000000000000000000000000ddd00000000000000000000000000000dd000000000000000000000000000000000000000
0000000dd00000000000000ddd0000000000dd0dd0dd0000000000d55d00000000d0000dd0000d00000000d9ad00000000000000000000000000000000000000
000000d55d00000000000ddd55d00000000d55d55d55d00000000d5575d0000000dd00d88d00dd0000000d999ad0000000000000000000000000000000000000
00000d5555d000000000d557555d0000000d55555555d00000000d5755d0000000d5d00dd00d5d00000dd5dddd5dd00000000000000000000000000000000000
00000d5555d00000000d55565555d0000000dddddddd0000000000d55d00000000d55dd55dd55d0000d555d55d555d0000000000000000000000000000000000
000000d55d00000000d555555555d0000000d555555d00000000000dd000000000d5555555555d0000d55d5555d55d0000000000000000000000000000000000
0000000dd000000000d55ddd5555d0000000d555555d00000000000dd000000000d5555555555d0000d5d0d55d0d5d0000000000000000000000000dd0000000
000000d55d000000000dd0d55555d0000000d555555d0000000000d55d000000000d55555555d000000d5d5555d5d00000000000000000000000000dd0000000
000000d55d000000000000d5555d00000000dddddddd0000000000d55d000000000d55555555d0000000d555555d000000000000000000000000000000000000
00000d5555d0000000000d5555d00000000d55555555d00000000d5555d000000000dddddddd000000000dddddd0000000000000000000000000000000000000
00000d5555d0000000000dddddd00000000dddddddddd00000000dddddd00000000d55555555d0000000d555555d000000000000000000000000000000000000
0000dddddddd00000000d555555d000000d5555555555d000000d555555d000000d5555555555d00000d55555555d00000000000000000000000000000000000
0000d555555d0000000d55555555d00000d5555555555d000000d555555d000000d5555555555d00000d55555555d00000000000000000000000000000000000
0000dddddddd0000000dddddddddd00000dddddddddddd000000dddddddd000000dddddddddddd00000dddddddddd00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000
00000000000000000000000d0000000000000000000000000000000ddd00000000000000000000000000000dd000000000000000000000005750000005000000
0000000dd00000000000000ddd0000000000dd0dd0dd0000000000d77d00000000d0000dd0000d00000000d9ad00000000000000000000005775000005500000
000000d77d00000000000ddd77d00000000d77d77d77d00000000d7757d0000000dd00d88d00dd0000000d999ad0000000000000000000005777500005550000
00000d7777d000000000d775777d0000000d77777777d00000000d7577d0000000d7d00dd00d7d00000dd7dddd7dd00000000000000000005777750005555000
00000d7777d00000000d77767777d0000000dddddddd0000000000d77d00000000d77dd77dd77d0000d777d77d777d0000000000000000005775500005500000
000000d77d00000000d777777777d0000000d777777d00000000000dd000000000d7777777777d0000d77d7777d77d0000000000000000000557000000050000
0000000dd000000000d77ddd7777d0000000d777777d00000000000dd000000000d7777777777d0000d7d0d77d0d7d0000000000000000000000000000000000
000000d77d000000000dd0d77777d0000000d777777d0000000000d77d000000000d77777777d000000d7d7777d7d00000000000000000003333333366666666
000000d77d000000000000d7777d00000000dddddddd0000000000d77d000000000d77777777d0000000d777777d000000000000000000003333333366666666
00000d7777d0000000000d7777d00000000d77777777d00000000d7777d000000000dddddddd000000000dddddd0000000000000000000003333333366666666
00000d7777d0000000000dddddd00000000dddddddddd00000000dddddd00000000d77777777d0000000d777777d000000000000000000003333333366666666
0000dddddddd00000000d777777d000000d7777777777d000000d777777d000000d7777777777d00000d77777777d00000000000000000003333333366666666
0000d777777d0000000d77777777d00000d7777777777d000000d777777d000000d7777777777d00000d77777777d00000000000000000003333333366666666
0000dddddddd0000000dddddddddd00000dddddddddddd000000dddddddd000000dddddddddddd00000dddddddddd00000000000000000003333333366666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333366666666
__map__
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3e3e3f3f3e3e3f3f3e3e3f3f3e3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3f3f3e3e3f3f3e3e3f3f3e3e3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
