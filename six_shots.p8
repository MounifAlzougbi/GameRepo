pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- data types

game={
	state='menu',
	coll_tbl={}
}

function data_type_init()
-- @bullet
	bullet={
		pos,
		angle,
		mx,my,	-- mouse offset
		speed=10,
		speedint=10,
		visible=true,
		
		new=function(s,tbl)
			tbl=tbl or {}
			setmetatable(tbl,{
				__index=s
			})
			return tbl
		end,
		
		init=function(s)
			local mag=s.mpos.x*s.mpos.x+s.mpos.y*s.mpos.y
			mag=sqrt(mag)
--			s.mx=s.mx/mag
--			s.my=s.my/mag
			s.dir=vec(s.mpos.x/mag,s.mpos.y/mag)
--			s.pos=s.x
--			s.spos=s.pos
			s.speed=vec(s.speed,s.speed)
		end,
		
		update=function(s)
-- need to normalize vector
-- for constant speed
-- m^2=x^2+y^2 (magnitude)
			if map_collision(s,2,false)!=true 
			and s.pos.x>-5
			and s.pos.x<130
			and s.pos.y>-5
			and s.pos.y<130 then
--				s.x+=s.mx*s.speed
--				s.y+=s.my*s.speed
--				s.lx=s.x
--				s.ly=s.y
				s.pos+=s.dir*s.speed
			else
				s.visible=false
			end
			
			if s.visible!=true 
			and map_collision(s,2,false) then
				sfx(2)
			
			
				add(p,particle:new({
				x=s.pos.x,y=s.pos.y,
				r=rnd(2),
				vx=rnd(1),
				vy=rnd(1)
				}))
				
				add(p,particle:new({
				x=s.pos.x,y=s.pos.y,
				r=rnd(2),
				vx=rnd(1)*-1,
				vy=rnd(1)
				}))
				
				add(p,particle:new({
				x=s.pos.x,y=s.pos.y,
				r=rnd(2),
				vx=rnd(2)*-1,
				vy=rnd(1)
				}))
				
			end
		end,
		
		draw=function(s)
			if s.visible then
				spr(112,s.pos.x-4,s.pos.y-4)
			end
		end
	}

-- @bullet array
	b={}
	
-- @vec

	
	end

-- @pos
	pos={	-- can be a vect w mag
	x=0,y=0,
	
	new=function(s,tbl)
		tbl=tbl or {}
		setmetatable(tbl,{
			__index=s,
			__add=function(a,b)
				if b.x and b.y then
					return vec(a.x+b.x,a.y+b.y)
				else
					return vec(a.x+b,a.y+b)
				end
			end,
			__tostring=function(a)
				return "("..a.x..","..a.y..")"
			end,
			__sub=function(a,b)
			if b.x and b.y then
					return vec(a.x-b.x,a.y-b.y)
				else
					return vec(a.x-b,a.y-b)
				end
			end,
			__mul=function(a,b)
				if b.x and b.y then
					return vec(a.x*b.x,a.y*b.y)
				else
					return vec(a*b,a*b)
				end
			end,
			__eq=function(a,b)
				if b.x and b.y then
					return a.x==b.x and a.y==b.y
				else
					return a.x==b and a.y==b
				end
			end,
			__div=function(a,b)
				if b.x and b.y then
					return vec(a.x/b.x,a.y/b.y)
				else
					return vec(a.x/b,a.y/b)
				end
			end
			
			})
		return tbl
	end
	
	}

-- returns vec/pos obj
function vec(x1,y1)
	if y1==nil then
		y1=x1
	end
	return pos:new({x=x1 or 0,
	y=y1 or 0})
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

function ret_i(tbl,val)
	for i=1,#tbl do
		if tbl[i]==val then
			return i end
	end
end

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
-->8
-- mouse stuff/map stuff
mflg={}
flg={
	map_col
}

mouse={
	pos=vec(64,64),
	just_pressed=false,
	clicked=false,--[[ need to make
	clicked true at beggining of 
	button press but only on first
	click not holding (opposite of 
	just_pressed)
	--]]
	lock=false,
	pressed=false,
	target=-1,
	lpos=vec(),
	tx,ty,
	lpos=vec(),		--last x-y pos
	p=64,
	
	is_b_col=function(s,b)
		if 	s.pos.x<b.x+b.w 
		and	s.pos.x>b.x
		and s.pos.y>b.y
		and s.pos.y<b.y+b.h then
			return true
		else return false	
		end
	end,
	
	init=function(s)
		poke(0x5f2d, 1)
	end,
	
	update=function(self)
		self.just_pressed=false
		self.clicked=false
		self.pos.x=stat(32)
		self.pos.y=stat(33)
		
		if band(stat(34),1)==1 then
			self.pressed=true
			self.p=65
			if self.last!=1 then
				self.clicked=true
			else
				self.clicked=false
			end
		elseif (stat(34)==0) 
		and self.pressed==true then
			self.pressed=false
			self.just_pressed=true
			self.lpos=self.pos
			self.p=64
		elseif stat(34)==2 then
			self.dline=true
		else
			self.dline=false
		end
		self.last=stat(34)
	end,
	
	draw=function(s)
		if game.state=='menu'
		or game.state=='a star' then
			spr(s.p,mouse.pos.x,mouse.pos.y)
		elseif game.state=='playing_six' then
			spr(80,s.pos.x-4,s.pos.y-4)
			if s.dline then
				line(player.pos.x,player.pos.y,
				mouse.pos.x,mouse.pos.y,8)
				
			end
		end
	end
}

function map_collision(obj,flg,mcoord)
	local mc=1	--	8 if mapcoords
	if mcoord==false then
		mc=8
	end
	
	local x=obj.pos and obj.pos.x or obj.x
	local y=obj.pos and obj.pos.y or obj.y
	
	x/=mc
	y/=mc
	x=flr(x)
	y=flr(y)
	
--	add(mflg,vec(x,y))
	
	if fget(mget(x,y))==flg then
		return true
	else return false end
end

function in_tbl(tbl,obj)
	for i=1,#tbl do
		if tbl[i]==obj then
		return true
		end
	end
	return false
end

function in_tbl_i_sp(tbl,obj)
	for i=1,#tbl do
		if tbl[i].selfp==obj then
			return i
		end
	end
end

function in_range(int,mn,mx)
	if int>mn and int<mx then
		return true else return false
end end
-->8
-- pathfinding

-- @init
function a_star_init()
	
	n_off={
	 {1,0},{-1,0},{0,1},{0,-1},
  {1,-1},{-1,-1},{-1,1},{1,1}
	}
	
-- @get neighbors
	function get_n(pos)
		local n={}
		
		for i=1,#n_off do
			local off=n_off[i]
			add(n,vec(pos.x+off[1],
													pos.y+off[2]))
			end
		return n
	end


-- @node
	node={
		parent,
		selfp, -- self pos
		startp,	-- start pos
		targetp,	--	target pos
		g,	-- dist to strt node
		h,	-- min dist to target
		f,	-- g+h
	
		magnitude=function(s,t)
			return sqrt(t.x*t.x+t.y*t.y)
		end,
	
		new=function(s,tbl)
			tbl=tbl or {}
			setmetatable(tbl,{
			__index=s
			})
			return tbl
		end,
	
		init=function(s)
-- delta pos
--		local smag=s.startp-s.selfp
--		s.g=s:magnitude(smag)

	 	local tmag=s.targetp-s.pos
			s.h=s:magnitude(tmag)
		
			if parent==nil then
				s.g=0
			end
		
			s.f=s.g+s.h
	end
	
	}
	
	tnode=node:new({
	pos=vec(2,2),
	targetp=vec(player.x,player.y),
	startp=vec(1,1)
	})
	
	tnode:init()
	
-- @create path
	function create_path(tbl)
		local rpath={}
		local node=tbl[#tbl]

		while node do
			add(rpath,node)
			node=node.parent
		end
		
		local path={}
		
		for i=1,#rpath do
			local il=#rpath+1-i
			local b=vec(8,8)
			add(path,rpath[il].pos*b)
--			add(flg,rpath[il].pos*b)
			
		end
		return path
	end
	
-- @find path
	function find_path(start,target)
	
		local o={}	--	open nodes
		local c={}	-- closed nodes
		local complete=false
	
		add(o,node:new({
			pos=start,
			parent=nil,
			g=0,
			startp=start,
			targetp=target
			}))
					
			o[1]:init()
	
		while complete==false do
			if #o>200 then
				print('a* out of mem',20,20,9)
				return nil
			end
			local current=1
			for i=1,#o do
				if o[i].f<o[current].f 
				or o[i].f==o[current].f
			and o[i].h<o[current].h then
					current=i
				end
			end
			
			add(c,o[current])
			deli(o,current)
			
			if c[#c].pos==target then
				return create_path(c)	
			end	-- sucsess!
			
			local ntbl=get_n(c[#c].pos)
			
			for i=1,#ntbl do
				if map_collision(ntbl[i],2,true) 
			or in_tbl(c,ntbl[i]) then
					goto continue
				end--[[ for neighbors that
				are walkable and not already
				evaluated/in c tbl --]]
				
				local dg=1	-- g cost
				if ntbl[i].x!=c[#c].x
				and ntbl[i].y!=c[#c].y then
					dg=1.4	--potential t
				end
				
				local pg=c[#c].g+dg	--potential t
				local rg=in_tbl_i_sp(o,ntbl[i])	--recorded g
				
				if rg and pg <o[rg].g then
					
						o[rg].g=pg
						o[rg].f=o[rg].g+o[rg].h
						o[rg].parent=c[#c]
					
				end					
					if not in_tbl(o,ntbl[i]) then
						
						add(o,node:new({
						pos=vec(ntbl[i].x,
						ntbl[i].y ),
						parent=c[#c],
						g=c[#c].g+pg,
						startp=start,
						targetp=target
						}))
					
						o[#o]:init()
					
					end
				
				::continue::
			end
		end -- while
	end
	
end

-- @update
function a_star_update()
	
end

-- @draw
function a_star_draw()
--	print(tnode.h,20,20,9)
end
-->8
-- enemy

-- @init
function enemy_init()

--[[ @enemy states
		''		idle - moving - shooting
--]]
	enemy={
		r=4, -- radius for circ coll
		state='idle',	-- state machine?
-- idle walking shooting
		pos=vec(),
		weapon,-- pistol or hands?
		angle,
		dir=8,
		ammo=6,
		ptbl=vec(), -- pathfinding nodes
		pcool=60,	-- path cooldown
		pstep=1,
		visible=true,
		speed=0.02,
		t=0, -- lerp value
		ct, -- collision index
		
			__tostring=function(a)
				return "("..s.ptbl..","..#s.ptbl..")"
			end,
		
		new=function(s,tbl)
			local tbl=tbl or {}
			setmetatable(tbl,{
			__index=s
			})
			return tbl
		end,

-- updates path to player
		update_path=function(s)
			local t=vec(flr(player.pos.x/8),flr(player.pos.y/8))
			local pos=vec(flr(s.pos.x/8),flr(s.pos.y/8))

			s.ptbl=find_path(pos,t)
			
			s.pstep=1
--			s.pos=s.ptbl[1]
			s.t=0
			
		end,
		
-- steps path
		step_path=function(s)			
--				local off=vec(4,4)
--				s.pos=s.ptbl[s.pstep]+off
--			s.pos=s.ptbl[s.pstep]
			s.pstep+=1
			s.t=0
		
		end,
		
		path_radius=function(s,r)
			if s.pcool<1 
			and #s.ptbl>1 then
				s.pcool=80
				local d=#s.ptbl
				local tbl={
				pos=vec(s.ptbl[d].x,
				s.ptbl[d].y)}
				if dist(player,tbl)>r then
					s:update_path()
				end
			end
			
			s.pcool-=1
			
		end,
		
-- line of sight to player
		los=function(s,obj)
			
		end,
		
		state_machine=function(s)
		
			if dist(player,s)>20
			and #s.ptbl>3 then
				s.state='walking'
			end
		
		end,
		
		update=function(s)				
			
			s:state_machine()
			s:path_radius(30)
			
			if s.pstep<#s.ptbl 
			and s.state=='walking' then

--  dpos = b-a in lerp
				dpos=s.ptbl[s.pstep+1]-s.ptbl[s.pstep]
				
-- set lerp pos
				local four=vec(4)
				s.pos=lerp(s.ptbl[s.pstep]+four,s.ptbl[s.pstep+1]+four,s.t)
				
--				s.pos+=s.tpos-s.pos
								
				s.t+=s.speed
				
				if s.t>=1 then
					s:step_path()
				end
				
				if dpos.x==0
				and dpos.y==-8 then
					s.dir=8
				elseif	dpos.x==8
				and dpos.y==-8 then
					s.dir=9
				elseif dpos.y==0
				and dpos.x==8 then
					s.dir=10
				elseif	dpos.y==8
				and dpos.x==8 then
					s.dir=11
				elseif dpos.x==0
				and dpos.y==8 then
					s.dir=12
				elseif	dpos.x==-8
				and dpos.y==8 then
					s.dir=13
				elseif dpos.y==0
				and dpos.x==-8 then
					s.dir=14
				elseif	dpos.y==-8
				and dpos.x==-8 then
					s.dir=15
				end
			else
			
				s:update_path()
				
			end
		end,
		
		draw=function(s)
		if s.visible then
			spr(s.dir,s.pos.x-4,s.pos.y-4)
		else
			player.kills+=1
		end
--			for i=1,#s.ptbl do
--				spr(60,s.ptbl[i].x,s.ptbl[i].y)
--			end
		end
		
	}

	etbl={}	--tbl of all enemy

	add(etbl,enemy:new{
		pos=vec(36,68)
	})
	
--	etbl[1]:update_path()

end

function spawn_wave(amnt)
	for i=1,amnt do
		add(etbl,enemy:new{
		pos=vec(rnd(110)+10,rnd(108)+20)
		})
	end
end

-- update collision tbl pos
function coll_check(tbl,i,gtbl)
		
	if tbl[i].ckey==nil then
		local coord={
		pos=vec(tbl[i].pos.x,tbl[i].pos.y),
		r=4
		}
		local lrnd=rnd(4)
		local key=i*8+lrnd
		
		gtbl[key]=coord
		
		tbl[i].ckey=key
		
	else
	
		local coll_tbl=gtbl[tbl[i].ckey]
		
		coll_tbl.pos.x=tbl[i].pos.x
		coll_tbl.pos.y=tbl[i].pos.y
		
	end
	
end

-- @update
function enemy_update()
	
	if #etbl<1 then
		spawn_wave(4)
	end
	
	for i=#etbl,1,-1 do
			
		if etbl[i].visible==false then
			deli(etbl,i)
			player.kills+=1
		else
			etbl[i]:update()
			coll_check(etbl,i,game.coll_tbl)
		end
	end
end

-- @draw
function enemy_draw()
	for i=1,#etbl do
		etbl[i]:draw()
	end
end


-->8
-- enemy spawn/game play loop
-->8
-- player/six shots

-- @init
function six_init()
	
-- @particle array
	p={}
	
	particle={
		x,y,
		vx,vy,
		r,lx,ly,
		t=25,
		visible=true,
	
		new=function(s,tbl)
			tbl=tbl or {}
			setmetatable(tbl,{
			__index=s
			})
			return tbl
		end,
	
		update=function(s)
--apply forces
			if s.t>0 then
				s.x+=s.vx*0.4
				s.y-=s.vy*0.4
				s.vx*=0.97
				s.vy-=0.05
				else
				s.visible=false
				
			end
		
			s.t-=1
	end,
	
	draw=function(s)
		circfill(s.x,s.y,s.r,7)
	end
	
	}
	
-- @player
	player={
		r=3,	--	radius for circ coll
		health=100,
		stamina=100,
		pos=vec(64,64),
		lpos=vec(0,0),
		dspeed=0.18,
		speed=0.18,
		sprnt=1.5,
		angle,
		dir=0,
		ammo=6,
		ammo_cap=6,
		shoot_delay=0,
		rcount=1,
		kills=0,
		
		update=function(s)

-- sprint
			if btn(❎) 
			and s.stamina>0 then
				s.speed=s.dspeed*s.sprnt
				s.stamina-=0.5
			else
				if s.stamina<100 then
					s.stamina+=0.4
				end
				s.speed=s.dspeed
			end

-- input	
			if btn(⬅️) and s.pos.x>5 then
				s.pos.x-=s.speed	end
			if btn(➡️) and s.pos.x<123 then
				s.pos.x+=s.speed	end
			if btn(⬆️) and s.pos.y>5 then
				s.pos.y-=s.speed	end
			if btn(⬇️) and s.pos.y<123 then
				s.pos.y+=s.speed	end
				
			local dpos=mouse.pos-s.pos
			
			local l=0.0625--half of 1/8
			s.angle=atan2(dpos.x,dpos.y)
			if s.angle>0.25-l 
			and s.angle<0.25+l then
				s.dir=0
			elseif s.angle>0.375-l
			and s.angle<0.375+l then
				s.dir=7
			elseif s.angle>0.5-l
			and s.angle<0.5+l then
				s.dir=6
			elseif s.angle>0.625-l
			and s.angle<0.625+l then
				s.dir=5
			elseif s.angle>0.75-l
			and s.angle<0.75+l then
				s.dir=4
			elseif s.angle>0.875-l
			and s.angle<0.875+l then
				s.dir=3
			elseif s.angle>0.875+l
			or s.angle<0+l then
				s.dir=2
			elseif s.angle>0.125-l
			and s.angle<0.125+l then
				s.dir=1
			end
			

-- reload
			if btn(🅾️)==false then
				s.lr=false
			end

			if btn(🅾️) 
			and s.lr==false then
				s.rcount+=1
				s.lr=true
			end

			if s.rcount%2==0
			and s.ammo<s.ammo_cap then
				s.ammo+=0.075
			elseif s.ammo>=s.ammo_cap then
				s.rcount+=1
			end
			
-- shooting
			if mouse.clicked 
			and s.ammo>=1 
			and s.shoot_delay<0 
			and btn(🅾️)!=true then
				sfx(1)
				s.ammo-=1
				if s.rcount%2==0 then
					s.rcount+=1
				end
				add(b,bullet:new({
				pos=vec(s.pos.x,s.pos.y),
				angle=s.angle,
				mpos=dpos
				}))
			
				b[#b]:init()
			
				s.shoot_delay=25
			elseif mouse.clicked
			and s.ammo<1
			and s.shoot_delay<0
			and btn(🅾️)!=true then
				sfx(3)
				s.shoot_delay=25
			end
			
			s.shoot_delay-=1
--			flg.map_col=map_collision(player,2,false)
			
			is_coll=map_collision(player,2,false)
			
			if is_coll==true then
--				local x1,x2=s.pos.x,s.lpos.x
--				local y1,y2=s.pos.y,s.lpos.y
--				
--				if x1!=x2 then
					s.pos.x=s.lpos.x
--	
--				end
--				
--				isx_coll=map_collision(player,2,false)
--				
--				if isx_coll then
--					s.pos.x=s.lpos.x
--				end
--				
--				if y1!=y2 then
					s.pos.y=s.lpos.y
--				end
--				
--				isy_coll=map_collision(player,2,false)
--				
--				if isy_coll then
--					s.pos.y=s.lpos.y
--				end
--			else
--				s.lpos.x=s.pos.x
--				s.lpos.y=s.pos.y
--			end

			elseif is_coll==false then
				s.lpos.x=s.pos.x
				s.lpos.y=s.pos.y
			end
			
		end,
		
		draw=function(s)
--			print(s.angle,0,0,9)
			spr(s.dir,s.pos.x-4,s.pos.y-4)
			
-- hud stuff
			local t=97
			for i=1,6 do
				if i<=s.ammo then
					t=96
				else
					t=97
				end
				spr(t,-6+(i*8),3)
			end
			
			rectfill(53,1,126,6,5)
			for x=1,9 do
				if x<s.health/9 then
					spr(62,46+x*8)
				end
			end
			
			rectfill(53,8,126,13,5)
			for x=1,9 do
				if x<s.stamina/9 then
					spr(61,46+x*8,7)
				end
			
			print(player.kills,4,118,7)
			
			end
			
		end
	}
		
	for v=1,18 do
		local y=v-1
		for h=1,18 do
			local x=h-1
			
			local coord={
				pos=vec(x,y),
				r=4.1
				}
			
			if map_collision(coord,2,true) then
				local lrnd=rnd(5)*rnd(5)
				game.coll_tbl[lrnd]=coord
			end
		end
	end
	
end
-- @end init

-- returns tbl distane to enemys
function	distance(bi,t)
	local ttbl=t or {}
	local tbl={}
	for ei=1,#ttbl do
		mpos=vec()
		mpos.x=b[bi].pos.x-ttbl[ei].pos.x
		mpos.y=b[bi].pos.y-ttbl[ei].pos.y
		local mag=mpos.x*mpos.x+mpos.y*mpos.y
		mag=sqrt(mag)
		mag-=ttbl[ei].r
		add(tbl,mag)
	end
	return tbl
end

-- rets tbl of colls in range
function colls_in_range()
end

--[[

need 'unified' collision tbl,
points and radius's of colls, in
a certain range from the ray
in the dir of travel

enemys and tile-walls are circ
collisions 

get objs in front of ray
func ⬆️

need global collision array


--]]
-- @collision update
function collision_update()
	for bi=1,#b do
	
		local dist_tbl=distance(bi,e)
		if #dist_tbl>1 then
			local mdist=ret_min(dist_tbl)
		else
			goto continue
		end
		
		local col=nil
		local iteration=0
		local delta_pos=0
		local start_pos=b[bi].pos
		
		while col==nil do
			if iteration>40 
			or mdist>10
			or delta_pos>=b[bi].speedint then
				col=false
			end
			
			if mdist<=0 then
				local hit=ret_i(dist_tbl,mdist)
				etbl[hit].visible=false
				col=true
			end
			
-- march ray/bullet
			dvec=vec(mdist)
			b[bi].pos+=b[bi].dir*dvec
			delta_pos+=mdist
			
			dist_tbl=distance(bi,e)
			mdist=ret_min(dist_tbl)
			
			iteration+=1
		end
		
		if col==false then
			b[bi].pos=start_pos
		elseif col==true then
			local hit=ret_i(dist_tbl,mdist)
			etbl[hit].visible=false
		end
	end
	::continue::
end

-- @bullet update
function bullet_update()
	for i=#b,1,-1 do
		b[i]:update()
		if b[i].visible!=true then
			deli(b,i)
		end
	end
end

function particle_update()
	for i=#p,1,-1 do
		p[i]:update()
		if p[i].visible==false then
			deli(p,i)
		end
	end

end

-- @update
function six_update()	
-- enemy pathfinding
	a_star_update()
	
	particle_update()
	
	if #etbl>0 then
		collision_update()
	end
	
	bullet_update()
	
	enemy_update()
	
	player:update()
	
end

-- @draw
function six_draw()

	enemy_draw()
	
-- bullet draw
	for i=1,#b do
		b[i]:draw()
	end
	
-- particle draw
	for i=1,#p do
		p[i]:draw()
	end
-- emeny pathfinding
--	a_star_draw()
	player:draw()
end
-->8
-- button & state

function button_pressed(arg)
	if arg=='playing_six' then
		game.state=arg
	elseif arg=='a star' then
		game.state=arg
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
		str='start game',
		arg='playing_six'}))--button use

--	add(gb,button:new({
--		cx=64,cy=78,--center x,y
--		str='a star',
--		arg='a star'}))--button use

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
	mouse:init()
	six_init()
	a_star_init()
	enemy_init()
	data_type_init()
--	sfx(0)
end

function _update()
	if game.state=='menu' then
		button_update()
	elseif	game.state=='playing_six' then
		six_update()
	elseif game.state=='a star' then
		a_star_update()
	end
	mouse:update()
end

function _draw()
	cls()
	if game.state=='menu' then
		button_draw()
		mouse:draw()
	elseif	game.state=='playing_six' then
		map()
		six_draw()
		mouse:draw()
	elseif game.state=='a star' then
		a_star_draw()
		mouse:draw()
	end
	
--	print(is_coll,20,13,9)
--	print(map_collision(player,2,false),20,25,6)
	i=0
	for k,v in pairs(game.coll_tbl) do
		i+=1
	end
	
	print(i,30,30,2)
	print("memory: "..stat(0), 0, 0, 7)
 print("cpu: "..stat(1).."%", 0, 8, 7)

end
__gfx__
00011000000001100000000000000000000110000000000000000000011000000008800000000880000000000000000000088000000000000000000008800000
00155100000115510011100000111000001551000001110000011100155110000085580000088558008880000088800000855800000888000008880085588000
00155100001555510155511001555100015555100015551001155510155551000085580000855558085558800855580008555580008555800885558085555800
01555510015555101555555101555510015555100155551015555551015555100855558008555580855555580855558008555580085555808555555808555580
01555510015555101555555101555510015555100155551015555551015555100855558008555580855555580855558008555580085555808555555808555580
01555510015551000155511000155551001551001555510001155510001555100855558008555800085558800085555800855800855558000885558000855580
00155100001110000011100000011551001551001551100000011100000111000085580000888000008880000008855800855800855880000008880000088800
00011000000000000000000000000110000110000110000000000000000000000008800000000000000000000000088000088000088000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0066600000066600000000b33b00000000000050000000000b300000000000000000000000000000000000000000000000000000000000000000000000000000
06777600006777600000b3bb33bb00000000005000000000b3b30000000000000000000000000000000000000000000000000000000000000000000006777770
67eee760067eee7600033b33b33b3000000006500b30000033bb0000000000000000000000000000000000000000000000000000000000000000000006700070
67eee760067eee760003b7777773b0000000675633bb00005b300000000000000000000000000000000000000000000000000000000000000000000067777777
67eee766667eee760000675775760000000b3756b333600005760000000000000000000000000000000000000000000000000000000000000000000067778777
06777777777777600000675775760000003b3b5003b7760006560000000000000000000000000000000000000000000000000000000000000000000067788877
0067766776677600000067777776000000b333000055555500650000000000000000000000000000000000000000000000000000000000000000000067778777
00677657765776000000067ee76000000003b0000006600000005000000000000000000000000000000000000000000000000000000000000000000006777777
00677667766776000000676a96760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666
00677777777776000006777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
0006777227776000006777777777760000000000000000000000000000000000000000000000000000000000000000000006600011111111bbbbbbbb66666666
0006777777776000067767777776776000000000000000000000000000000000000000000000000000000000000000000061160011111111bbbbbbbb66666666
0006777777776000556007777770065500000000000000000000000000000000000000000000000000000000000000000061160011111111bbbbbbbb66666666
0006776666776000550007766770005500000000000000000000000000000000000000000000000000000000000000000006600011111111bbbbbbbb66666666
00067700007760000000077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666
00005500005500000000055005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000000000000003999993333555533000000000000000000000000000000000000000000000000000000003333999933333b33
575000000d0000000000000000000000000000003999993335555553000000000000000000000000000000000000000000000000000000003333999933333333
577500000dd000000000000000000000000000003399999335566553000000000000000000000000000000000000000000000000000000003333944933333333
577750000ddd00000000000000000000000000003399999335566553000000000000000000000000000000000000000000000000000000003b33994433333333
577775000dddd00000000000000000000000000033999993356556530000000000000000000000000000000000000000000000000000000033b3999999999999
577550000dd0000000000000000000000000000033999993355555530000000000000000000000000000000000000000000000000000000033b3999999499949
05570000000d00000000000000000000000000003999993335555553000000000000000000000000000000000000000000000000000000003333994499449944
00000000000000000000000000000000000000003999993335555553000000000000000000000000000000000000000000000000000000003333944999949994
00000000000000000000000000000000000000003999993333333333000000000000000000000000000000000000000000000000000000003663333333111133
000dd000000000000000000000000000000000003999999999333399000000000000000000000000000000000000000000000000000000003553333331333313
0070070000600600000000000000000000000000999999999999999900000000000000000000000000000000000000000000000000000000333333331b333331
0d0000d0000660000000000000000000000000009999999999999999000000000000000000000000000000000000000000000000000000003333666313b33331
0d0000d0000660000000000000000000000000009999999999999999000000000000000000000000000000000000000000000000000000003336666313333b31
0070070000600600000000000000000000000000999999999999999900000000000000000000000000000000000000000000000000000000336665531333b331
000dd000000000000000000000000000000000003999999333999933000000000000000000000000000000000000000000000000000000003355533331333313
00000000000000000000000000000000000000003999993333333333000000000000000000000000000000000000000000000000000000003333333333111133
0005500000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333b333394449999
00599500005005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333b33344999999
00599500005005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333b33399999999
0599995005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b333333399994449
05999950050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b33333399944999
05999950050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b3333b399999999
059999500500005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333b3399999444
005555000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333b3399994499
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333300000000
__gff__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e5556565656565656565656555656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e455f7e7e7e7e7e7e7e7e6e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e4646467e46465e467e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e7e7e7e7e7e7e7e7e6e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e6e465f46467e46465f457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e7e7e7e7e7e6e7e7e7e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e467e4646467e46467e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e455e7e7e7e7e7e7e7e7e7e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e456e46467e464646465e5f457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e7e7e7e7e7e7e7e7e7e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e4646466e464646467e455656565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e5556565656565656565656557e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e7e7e7e7e7e7e7e7e7e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7e7e7e457e7e7e7e7e7e7e7e7e7e457e7e7e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004500000000000000000000450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
003a00201e0101e110220102411028010291102c0102b1102b010291102801025110220101e1101e1101d0101d0101b1101b11018010180101711017110140101401018110181101b0101b010241102301021110
0002000028550235501e5501a55015550105500a55006550015500055000500005000150001500015000250002500025000150000500005000050000500005000050000500005000050000500005000050000500
000100002a3601d650122501a64012240114300e2300a4300c2300642004620004001920000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f2203e6203f2203e62000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 43424344

