pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--[[ prnt and sutch 
	flr()		chops to whole num
 rnd(5) returns num 0-4.999
	combine for randint flr(rnd(int)

 array for each suit
 deckarray={club_ar[14],heart_ar[14],spade_ar[14],dia_ar[14]}
0=discarded 1=in deck 2=in hand 
3=mouse hover 4=selected for play
5=m over selected, 6=mouse drag
--]]

deck={{suit=1,number=1,x=0,y=0,state=1},{suit=1,number=2,x=0,y=0,state=1},{suit=1,number=3,x=0,y=0,state=1},{suit=1,number=4,x=0,y=0,state=1},{suit=1,number=5,x=0,y=0,state=1},{suit=1,number=6,x=0,y=0,state=1},{suit=1,number=7,x=0,y=0,state=1},{suit=1,number=8,x=0,y=0,state=1},{suit=1,number=9,x=0,y=0,state=1},{suit=1,number=10,x=0,y=0,state=1},{suit=1,number=11,x=0,y=0,state=1},{suit=1,number=12,x=0,y=0,state=1},{suit=1,number=13,x=0,y=0,state=1},{suit=2,number=1,x=0,y=0,state=1},{suit=2,number=2,x=0,y=0,state=1},{suit=2,number=3,x=0,y=0,state=1},{suit=2,number=4,x=0,y=0,state=1},{suit=2,number=5,x=0,y=0,state=1},{suit=2,number=6,x=0,y=0,state=1},{suit=2,number=7,x=0,y=0,state=1},{suit=2,number=8,x=0,y=0,state=1},{suit=2,number=9,x=0,y=0,state=1},{suit=2,number=10,x=0,y=0,state=1},{suit=2,number=11,x=0,y=0,state=1},{suit=2,number=12,x=0,y=0,state=1},{suit=2,number=13,x=0,y=0,state=1},{suit=3,number=1,x=0,y=0,state=1},{suit=3,number=2,x=0,y=0,state=1},{suit=3,number=3,x=0,y=0,state=1},{suit=3,number=4,x=0,y=0,state=1},{suit=3,number=5,x=0,y=0,state=1},{suit=3,number=6,x=0,y=0,state=1},{suit=3,number=7,x=0,y=0,state=1},{suit=3,number=8,x=0,y=0,state=1},{suit=3,number=9,x=0,y=0,state=1},{suit=3,number=10,x=0,y=0,state=1},{suit=3,number=11,x=0,y=0,state=1},{suit=3,number=12,x=0,y=0,state=1},{suit=3,number=13,x=0,y=0,state=1},{suit=4,number=1,x=0,y=0,state=1},{suit=4,number=2,x=0,y=0,state=1},{suit=4,number=3,x=0,y=0,state=1},{suit=4,number=4,x=0,y=0,state=1},{suit=4,number=5,x=0,y=0,state=1},{suit=4,number=6,x=0,y=0,state=1},{suit=4,number=7,x=0,y=0,state=1},{suit=4,number=8,x=0,y=0,state=1},{suit=4,number=9,x=0,y=0,state=1},{suit=4,number=10,x=0,y=0,state=1},{suit=4,number=11,x=0,y=0,state=1},{suit=4,number=12,x=0,y=0,state=1},{suit=4,number=13,x=0,y=0,state=1},{suit=1,number=20,x=0,y=90,state=0}}
deck_size=#deck//suit*number

hand_size=7
initflag=false

mouse={
	x=64,y=64,
	just_pressed=false,
	lock=false,//lock mouse untill release/just_pressed
	pressed=false,
	delta_x=0,
	delta_y=0,
	last_x=0,
	last_y=0,
	target=0//index of crd dragging	
	}

crd_w=8
crd_h=16
mo_offset=4 --mouse over offset
sel_crd=0
s4_y=55
s2_y=80//state y values
crd_2=0-- how many crds = 2
crd_4_x=((150-((sel_crd+crd_2)*12))/2)
crd_2_x=((150-(hand_size*12))/2)
crd_start_y=104
what_hand_crd=1// ?, not what you wanna see i know
click_dwn=false

flag={
	swap_called=false,
	state6=false,
 straight=false,
 straight_int=0
 }

--⬇️ needs to be updated asap⬇️ - this has my personal mults from balatro
game={sort=0,mult=5,chips=1,hands=100,discards=100,
 sf_ch=100,sf_mlt=8,four_ch=60,
 four_mlt=7,full_ch=40,full_mlt=4,
 flush_ch=35,flush_mlt=4,straight_ch=30,
 straight_mlt=4,three_ch=30,three_mlt=3,
 two_ch=20,two_mlt=2,pair_ch=15,
 pair_mlt=2,high_ch=5,high_mlt=2}
// sf_ch=chips for striaght flush
// returns how many crds in state
// includes mouse over crds

--@draw ui
function draw_ui()
	print("chips:",0,0,12)
	print(game.chips,0,6,12)
	print("hands:",0,12,5)
	print(game.hands,0,18,5)
	print("disc:",0,24,8)
	print(game.discards,0,30,8)
end
function state_count(t_state)
	cnt=0
	for i=1,deck_size do
		if deck[i].state==t_state 
		or deck[i].state==t_state+1 then
		 cnt+=1
		end
	end
	return cnt
end

// sets pos of all crds = state
function set_pos(states,y)
 crds=state_count(states)
	crd_x=(150-(crds*12))/2
	for i=1,deck_size do
		if deck[i].state==states then
			deck[i].x=crd_x
			deck[i].y=y
			crd_x+=12
		end
	end
end

// sets amnt of crd to state
duplicate=0//randint same int 
function change_state(state,amnt,errors)
	if duplicate>=1 then
		amnt=duplicate
	end// if recurse only fail amnt
	for i=1,amnt do// gets changed
		rand_int=flr(rnd(deck_size-1))+1
		if deck[rand_int].state==state
		and deck[rand_int].state!=1 then
			duplicate+=1
			change_state(state,amnt,duplicate)
		else
			deck[rand_int].state=state
		end
	end
end

function crdprnt(s,n,x,y)
	spr(n+3,x,y)
	spr(s-1,x,y+8)
	//print("test func",30,30,12)
end

function prnt_crds()
--[[	prrnt all crds on screen
ensures even layout of cards 
depending on how many in state
]]//
	for i=1,deck_size do
		if deck[i].state>=2 then
--			print(deck[i].x,x,y-16)
--			print(deck[i].y,x,y-8)
--			print(i,deck[i].x,deck[i].y-8)
			spr(deck[i].number+3,deck[i].x,deck[i].y)
			spr(deck[i].suit-1,deck[i].x,deck[i].y+8)
		end
	end
end

function check_coll(crd_index,table)
	i=crd_index
	if table==deck then
		if mouse.x < deck[i].x+crd_w and
				mouse.x > deck[i].x and
				mouse.y < deck[i].y+crd_h and
				mouse.y > deck[i].y then
			return true
		else
			return false
		end
	else
		if mouse.x<table[i].x+table[i].w
		 and mouse.x>table[i].x
		 and mouse.y<table[i].y+table[i].h
		 and mouse.y>table[i].y then
		 	return true
		 else
		 	return false
		 end
	end
end

// swaps index of target crd
// with crd sharing x value
// called after drag and drop
// or swapped with b if >0
function swap_card(t,b)
	for i=1,deck_size do
		if deck[t].x+4<=deck[i].x+crd_w
		and deck[t].x+4>=deck[i].x 
		and deck[i].y<s2_y
		and b==0 then
			local t_s=deck[t].suit
			local t_n=deck[t].number
			local t_x=deck[t].x
			local t_y=deck[t].y
			deck[t].x=deck[i].x
			deck[t].y=deck[i].y
			deck[t].suit=deck[i].suit
			deck[t].number=deck[i].number
			deck[i].suit=t_s
			deck[i].number=t_n
			deck[i].x=t_x
			deck[i].y=t_y
--			deck[i],deck[t]=deck[t],deck[i]
		elseif b==52 then
			deck[i],deck[t]=deck[t],deck[i]

--			local a=t
--			local a_s=deck[a].suit
--			local a_n=deck[a].number
--			local a_x=deck[a].x
--			local a_y=deck[a].y
--			local a_st=deck[a].state
--			deck[a].state=deck[b].state
--			deck[a].x=deck[b].x
--			deck[a].y=deck[b].y
--			deck[a].suit=deck[b].suit
--			deck[a].number=deck[b].number
--			deck[b].suit=a_s
--			deck[b].number=a_n
--			deck[b].x=a_x
--			deck[b].y=a_y
--			deck[b].state=a_st
--			flag.swap_called=true
		end
	end
end

// updates crd depending on mouse
function crd_update()
// returns starting point x val
	crd_4_x=((150-(sel_crd*12))/2)
	if mouse.target!=0 then
		mouse.drag=true
	elseif mouse.just_pressed 
	or mouse.y<s2_y then
		mouse.drag=false
	end
	for i=1,deck_size do
// in hand to mouse over
		if deck[i].state==2
		and check_coll(i,deck)
		and mouse.drag==false then
			deck[i].y-=4
			deck[i].state=3
			crd_h=20// to disable flicker
// mouse over to in hand
		elseif deck[i].state==3
		and check_coll(i,deck)==false
		and mouse.drag==false then
			deck[i].y+=4
			deck[i].state=2
			crd_h=16
// mouse over to selected
		elseif deck[i].state==3
		and mouse.just_pressed==true 
		and sel_crd<=4
		and mouse.drag==false then
			sel_crd+=1
			deck[i].state=4
			set_pos(4,s4_y)
			set_pos(2,s2_y)
// selected mouse over
		elseif deck[i].state==4
		and check_coll(i,deck)
		and mouse.drag==false then
			deck[i].y-=4
			deck[i].state=5
			crd_h=20
// m over selected to selected
		elseif deck[i].state==5
		and check_coll(i,deck)==false 
		and mouse.drag==false then
			deck[i].y+=4
			deck[i].state=4
			crd_h=16
// selected to bottom row
		elseif deck[i].state==6
		and mouse.y>s2_y then
--		and i==mouse.target then
			deck[i].state=2
			sel_crd-=1
			mouse.target=0
			set_pos(2,s2_y)
			set_pos(4,s4_y)
// activate drag
		elseif deck[i].state==5
		and check_coll(i,deck)
		and mouse.pressed
		and mouse.target==0 then
			deck[i].state=6
--			swap_card(i,52)//turn 52 4 prnt
			mouse.target=i
// lock card to mouse transform
		elseif deck[i].state==6
		and mouse.pressed
		and mouse.target==i then
		 deck[i].x=mouse.x-crd_w/2
		 deck[i].y=mouse.y-crd_h/4
// unlock crd/mouse
		elseif deck[i].state==6
		and mouse.pressed==false
		and i==mouse.target then
			flag.state6=true
			swap_card(i,0)
			deck[i].state=4
			mouse.target=0
			set_pos(4,s4_y)
		end
	end
end
// changes all that are too,to in the index var
function change_all(that_are,to)
	for i=1,deck_size do
		if deck[i].state==that_are then
			deck[i].state=to
		end
	end
end




-->8
--[[ play hand
--]]

--@sort deck
function sort_deck(sort_type)
	if sort_type=='rank' then
		for i=1,deck_size do
			for t=i+1,deck_size-1 do
				if deck[i].number<deck[t].number then
--					deck[i].number,deck[t].number=deck[t].number,deck[i].number
--					deck[i].suit,deck[t].suit=deck[t].suit,deck[i].suit
							deck[i],deck[t]=deck[t],deck[i]
			end end end
	else
		for i=1,deck_size do
			for t=i+1,deck_size-1 do
				if deck[i].suit<deck[t].suit then
--					deck[i].suit,deck[t].suit=deck[t].suit,deck[i].suit
--					deck[i].number,deck[t].number=deck[t].number,deck[i].number
							deck[i],deck[t]=deck[t],deck[i]
			end end end end
	set_pos(2,s2_y)
end

-- @straight flush
function straight_flush()
	local numbers={0,0,0,0,0}
	local suits={0,0,0,0,0}
	local s=true
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			suits[t]=deck[i].suit
			numbers[t]=deck[i].number
		end 
	end
	if t!=5 then return false end
	for i=1,4 do
  for j=i+1,5 do
   if numbers[i] < numbers[j] then
 		 numbers[i], numbers[j] = numbers[j], numbers[i]
   end end end
	for i=1,4 do
		if numbers[i]!=numbers[i+1]+1 then
			n=false end end
	for i=1,4 do
		if suits[i]!=suits[i+1] then
			s=false end end
	return n and s
end

--@four of a kind
function four_ofa_kind()
	local numbers={0,0,0,0,0}
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			numbers[t]=deck[i].number
		end end
	if t<4 then return false end
 for i=2,4 do
 	if numbers[1]!=numbers[i] then
 		n=false end end
 return n
end

--@full house
function full_house()
	local numbers={0,0,0,0,0}
	local t=0//tracker
	local n=true
	local n2=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			numbers[t]=deck[i].number
		end end
	if t!=5 then return false end
	for i=2,3 do
		if numbers[1]!=numbers[i] then
			n=false end end
	if numbers[4]!=numbers[5] then
		n2=false end
	return n and n2
end

--@flush
function flush()
	local suits={0,0,0,0,0}
	local t=0//tracker
	local s=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			suits[t]=deck[i].suit
		end 
	end
	if t!=5 then return false end
	for i=2,5 do
		if suits[1]!=suits[i] then
			s=false
		end
	end
	return s
end

--@straight
function straight()
	local numbers={0,0,0,0,0}
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			numbers[t]=deck[i].number
		end end
	if t!=5 then return false end
--	for i=1,4 do
--  for j=i+1,5 do
--   if numbers[i] < numbers[j] then
-- 		 numbers[i], numbers[j] = numbers[j], numbers[i]
--   end end end
	for i=1,4 do
		if numbers[i]!=numbers[i+1]+1 then
			n=false end end
	return n
end

--@three of a kind
function three_ofa_kind()
	local numbers={0,0,0,0,0}
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			numbers[t]=deck[i].number
		end end
	if t<3 then return false end
	for i=2,3 do
		if numbers[1]!=numbers[i] then
			n=false end end
	return n
end

--@two pair
function two_pair()
	local numbers={0,0,0,0,0}
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			numbers[t]=deck[i].number
		end end
	if t<4 then return false end
	if numbers[1]!=numbers[2] then
		n=false return false end
	if numbers[3]!=numbers[4] then
		n=false end
	return n
end

--@pair
function pair()
	local numbers={0,0,0,0,0}
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			numbers[t]=deck[i].number
		end end
	if t<2 then return false end
	if numbers[1]!=numbers[2] then
		n=false end
	return n
end

--@high card
function high_card()
	local number=0
	local t=0//tracker
	local n=true
	for i=1,deck_size do
		if deck[i].state==-1 then
			t+=1
			number=deck[i].number
		end end
	if t<1 or t>1 then return false end
	high_ch=deck[i].number
	return n
end

--@play hand
// plays selected cards
function play_hand()
	
	if straight_flush() then
		game.chips+=game.sf_ch*game.sf_mlt
	end
	if four_ofa_kind() then
		game.chips+=game.four_ch*game.four_mlt
	end
	if full_house() then
		game.chips+=game.full_ch*game.full_mlt
	end
	if flush() then
		game.chips+=game.flush_ch*game.flush_mlt
	end	
	if straight() then
		game.chips+=game.straight_ch*game.straight_mlt
	end
	if three_ofa_kind() then
		game.chips+=game.three_ch*game.three_mlt
 end
 if two_pair() then
 	game.chips+=game.two_ch*game.two_mlt
	end
	if pair() then
	 game.chips+=game.pair_ch*game.pair_mlt

	elseif high_card() then
	 game.chips+=game.high_ch*game.high_mlt
	end
		
 for i=1,deck_size do
		if deck[i].state==-1 then
			deck[i].state=-2
		end 
	end
 
end

// w=width, counted 8x8 tiles 3 = 24, 3*8
//index 1 = play selected crds
// =1st index is decorative rect, iterate by twos
b={{x=29,y=107,w=26,h=18,c=1},
{c=5,x_off=5,y_off=3,str="play\nhand",x=30,y=108,w=24,h=16,m_over=false,pressed=false},
{x=84,y=109,w=31,h=14,c=1},
{c=5,x_off=1,y_off=4,str="discard",x=85,y=110,w=29,h=12,m_over=false,pressed=false},
{x=60,y=109,w=18,h=10,c=1},
{c=5,x_off=1,y_off=2,str="sort",x=61,y=110,w=16,h=8,m_over=false,pressed=false},
{x=0,y=121,w=23,h=6,c=1},
{x=1,y=122,w=21,h=4,c=5,x_off=3,y_off=0,str="high",m_over=false,pressed=false},
{x=0,y=114,w=23,h=6,c=1},
{x=1,y=115,w=21,h=4,c=5,x_off=3,y_off=0,str="pair",m_over=false,pressed=false},
{x=0,y=107,w=23,h=6,c=1},
{x=1,y=108,w=21,h=4,c=5,x_off=1,y_off=0,str="2pair",m_over=false,pressed=false},
{x=0,y=100,w=23,h=6,c=1},
{x=1,y=101,w=21,h=4,c=5,x_off=1,y_off=0,str="three",m_over=false,pressed=false},
{x=0,y=93,w=23,h=6,c=1},
{x=1,y=94,w=21,h=4,c=5,x_off=1,y_off=0,str="str-8",m_over=false,pressed=false},
{x=0,y=86,w=23,h=6,c=1},
{x=1,y=87,w=21,h=4,c=5,x_off=1,y_off=0,str="flush",m_over=false,pressed=false},
{x=0,y=79,w=23,h=6,c=1},
{x=1,y=80,w=21,h=4,c=5,x_off=3,y_off=0,str="full",m_over=false,pressed=false},
{x=0,y=72,w=23,h=6,c=1},
{x=1,y=73,w=21,h=4,c=5,x_off=3,y_off=0,str="four",m_over=false,pressed=false},
{x=0,y=59,w=23,h=12,c=1},
{x=1,y=60,w=21,h=10,c=5,x_off=1,y_off=0,str="str-8\nflush",m_over=false,pressed=false},

}

b_size=#b
// b = buttons

function button_update()
	for i=1,b_size do
		if i%2==0 and i>1
		and check_coll(i,b) then
			b[i-1].c=2
		elseif i%2==1 and 
		check_coll(i,b)==false then
			b[i].c=1
		end
	end
//play selected cards button
	if b[2].pressed 
	and game.hands>0 
	and sel_crd>=1 then
		//func that goes through hands
//discard button
		change_all(4,-1)//played crds
		play_hand()
		game.hands-=1
		change_state(2,sel_crd,0)
		set_pos(2,s2_y)
		sel_crd=0
	elseif b[4].pressed 
	and game.discards>0 
	and sel_crd>1 then
		change_all(4,-20)
		game.discards-=1
		change_state(2,sel_crd,0)
		set_pos(2,s2_y)
		sel_crd=0
	elseif b[6].pressed then
		game.sort+=1
		if game.sort%2==0 then
			sort_deck('suit')
		else
			sort_deck('rank')
		end
	end
end

function prnt_buttons()
	for i=2,b_size do
// =1st index is decorative rect, iterate by twos
		b[i].pressed=false
		b[i].m_over=false
		if i%2==0
		and check_coll(i,b)
		and mouse.just_pressed then
			b[i].pressed=true
		elseif check_coll(i,b) then
			b[i].m_over=true
		end
	end// change this logic for only the backround button 1 index not 2
	for i=1,b_size do
 	rectfill(b[i].x,b[i].y,b[i].x+b[i].w,b[i].y+b[i].h,b[i].c)
		if i%2==0 then
			print(b[i].str,b[i].x+b[i].x_off,b[i].y+b[i].y_off,7)
		end
	end
	for i=8,#b do
		if i%2==0 and b[i].m_over then
			rectfill(b[i].w+3,b[i].y+1+b[i].h,b[i].w+53,b[i].y-11,2)
			if i==8 then
				crdprnt(2,13,b[i].w+14,b[i].y-11)
			elseif i==10 then
				crdprnt(4,1,b[i].w+6,b[i].y-11)
				crdprnt(2,1,b[i].w+17,b[i].y-11)
			elseif i==12 then
				crdprnt(3,5,b[i].w+4,b[i].y-11)
				crdprnt(2,5,b[i].w+13,b[i].y-11)
				crdprnt(1,11,b[i].w+22,b[i].y-11)
				crdprnt(4,11,b[i].w+31,b[i].y-11)
			elseif i==14 then
				crdprnt(2,9,b[i].w+13,b[i].y-11)
				crdprnt(1,9,b[i].w+22,b[i].y-11)
				crdprnt(4,9,b[i].w+31,b[i].y-11)
			elseif i==16 then
				crdprnt(3,4,b[i].w+4,b[i].y-11)
				crdprnt(2,5,b[i].w+13,b[i].y-11)
				crdprnt(1,6,b[i].w+22,b[i].y-11)
				crdprnt(4,7,b[i].w+31,b[i].y-11)
				crdprnt(3,8,b[i].w+40,b[i].y-11)
			elseif i==18 then
				crdprnt(3,2,b[i].w+4,b[i].y-11)
				crdprnt(3,1,b[i].w+13,b[i].y-11)
				crdprnt(3,13,b[i].w+22,b[i].y-11)
				crdprnt(3,10,b[i].w+31,b[i].y-11)
				crdprnt(3,8,b[i].w+40,b[i].y-11)
			elseif i==20 then
				crdprnt(3,4,b[i].w+4,b[i].y-11)
				crdprnt(2,4,b[i].w+13,b[i].y-11)
				crdprnt(1,4,b[i].w+22,b[i].y-11)
				crdprnt(4,9,b[i].w+31,b[i].y-11)
				crdprnt(3,9,b[i].w+40,b[i].y-11)
			elseif i==22 then
				crdprnt(3,10,b[i].w+4,b[i].y-11)
				crdprnt(2,10,b[i].w+13,b[i].y-11)
				crdprnt(1,10,b[i].w+22,b[i].y-11)
				crdprnt(4,10,b[i].w+31,b[i].y-11)
			elseif i==24 then
				crdprnt(2,12,b[i].w+4,b[i].y-11)
				crdprnt(2,11,b[i].w+13,b[i].y-11)
				crdprnt(2,10,b[i].w+22,b[i].y-11)
				crdprnt(2,9,b[i].w+31,b[i].y-11)
				crdprnt(2,8,b[i].w+40,b[i].y-11)

			end
		end
	end
end
-->8
--[[ game loop

--]]
function _init()
	change_state(2,hand_size,0)

	set_pos(2,s2_y)
	poke(0x5f2d, 1)
--	poke(0x5f2d, 2)
end

function _update()
	mouse.just_pressed=false
	mouse.x=stat(32)
	mouse.y=stat(33)
	mouse.delta_x=mouse.x-mouse.last_x
	mouse.delta_y=mouse.y-mouse.last_y
	if (stat(34)==1) then
		mouse.pressed=true
		elseif (stat(34)==0) 
		and mouse.pressed==true then
			mouse.pressed=false
			mouse.just_pressed=true
	end
	crd_update()
	button_update()
	mouse.last_x=mouse.x
	mouse.last_y=mouse.y
end

function _draw()
	cls()
	map(0,0)
	prnt_crds()
	prnt_buttons()
	if mouse.target!=0 then
		crdprnt(deck[mouse.target].suit,
		deck[mouse.target].number,
		deck[mouse.target].x,
		deck[mouse.target].y)
	end
	spr(54,mouse.x,mouse.y)
	draw_ui()
--	print(mouse.x,0,0)
--	print(mouse.y,0,8)
--	print(mouse.target,0,0,8)
--	print(mouse.just_pressed)
--	print(flag.sf_func)
--	print(flag.straight)
end
__gfx__
77777777777777777777777777777777777777557777775577777755777777557777775577777755777777557777775577777755777777557777775577777755
777ccc77777878777777177777779777777555757775557577755575777575757775557577755575777555757775557577755575755775757775557577775775
777ccc77778888877771117777799977777575777777757777777577777575777775777777757777777775777775757777757577775757577777577777757577
77cc7cc7778888877711111777999997777555777775557777755577777555777775557777755577777775777775557777755577775757577777577777757577
77cc7cc7777888777711111777799977777575777775777777777577777775777777757777757577777775777775757777777577775757577777577777755777
7777c777777787777777177777779777777575777775557777755577777775777775557777755577777775777775557777777577755575777775577777775577
57777777577777775777777757777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
55777777557777775577777755777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777755777777550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777575757877d7750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77757577778d88770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7775577777888d770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777575777788d7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77757577788788770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777778770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999555555551111999911119999999911119999111105000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999555555551111999911119999999911119999111157500000000000000000000000000000000000000000000000000000000000000000000000000000
99999999555555551111999911119999999911119999111157750000000000000000000000000000000000000000000000000000000000000000000000000000
99999999555555551111999911119999999911119999111157775000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555551111111111119999999911111111111157777500000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555551111111111119999999911111111111157755000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555551111111111119999999911111111111105570000000000000000000000000000000000000000000000000000000000000000000000000000
11111111555555551111111111119999999911111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121213331313131313131313131313420200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121213331313131313131313131313420200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121213331313131313131313131313420200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121213230303030303030303030303520200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002b0502b0502a050290501a5501a5501a5501955019550195501955026550285502a550245501455000000000000000000000000000000000000000000000000000000000000000000000000000000000
