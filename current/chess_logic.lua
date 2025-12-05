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
	

	
-- two peice move and en passunte
	if p[i].init==true then
		poke(m+y2*8+x1,3)
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
				if s.rank=='pawn' then
					if s.c==1 
					and s.y==6 then
						s.init=true
					elseif s.c==-1
					and s.y==1 then
						s.init=true
					else
						s.init=false
					end
				end
	  elseif mouse.target==s.index
	  and mouse.just_pressed 
	  and bb:is_move(bx,by)	then
				s.visible=true
				mouse.target=-1
				if bx!=s.x or by!=s.y then
					local i=bb:what_i(bx,by)
					local i2=bb:what_i(bx,by+s.c)
					
					if i!=nil then
						p[i].visible=false
						p[i].x=200
						p[i].y=200
						deli()
					end
					s.x=bx
					s.y=by
					swap_turn()
					s.init=false
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
			and s.visible==false 
			and s.x>128 then
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
				return i end end
			return nil
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
	local c=1 
	
	if clr==1 then -- 1 = white
		ryl_y=7
		pwn_y=6
		c=2 -- 2=black
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
