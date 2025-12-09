
game={
	turnCount=0,
	turn=1,
	lastTurn=0,
	board={},
	turnMoves={}
}

function swapTurn()
	if game.turn==-1 then
		game.turn=1
	else game.turn=-1 end
	game.lastTurn=game.turn*-1
	game.board=performantBoard()
	game.turnMoves=clrPossibleMoves(game.turn,game.board)
	game.turnCount+=1
end

function chessInit()
	p={}

	local rylY=7
	local x=0
	local drawIndex={
		pawnIndex=32,
		kniteIndex=34,
		rookIndex=36,
		bishIndex=38,
		queenIndex=40,
		kingIndex=42
	}

	for color=1,2 do
		x=0
		if color==2 then -- if black
			color=-1
			rylY=0

			drawIndex.pawnIndex-=32
			drawIndex.kniteIndex-=32
			drawIndex.rookIndex-=32
			drawIndex.bishIndex-=32
			drawIndex.queenIndex-=32
			drawIndex.kingIndex-=32
		end

		for pX=1,8 do
			pX-=1
			add(p,{
				x=pX,
				y=rylY-color,
				c=color,
				rank='pawn',
				sprIndex=drawIndex.pawnIndex,
				visible=true
			})
		end

		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='rook',
			sprIndex=drawIndex.rookIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='knite',
			sprIndex=drawIndex.kniteIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='bish',
			sprIndex=drawIndex.bishIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='queen',
			sprIndex=drawIndex.queenIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='king',
			sprIndex=drawIndex.kingIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='bish',
			sprIndex=drawIndex.bishIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='knite',
			sprIndex=drawIndex.kniteIndex,
			visible=true
		})
		x+=1
		add(p,{
			x=x,
			y=rylY,
			c=color,
			rank='rook',
			sprIndex=drawIndex.rookIndex,
			visible=true
		})
	end

	game.board=performantBoard()
	game.turnMoves=clrPossibleMoves(1,game.board)

end

function deletePeicePos(pos)
	for i=1,#p do
		if p[i].x+p[i].y*8==pos then
			deli(p,i)
			return true
		end
	end
end

function chessUpdate()
	local pos,moves
	for i=1,#p do

		if p[i]==nil then goto skipLoop end

		pos=p[i].x+p[i].y*8
		p[i].pos=pos

		if mouse.target==i
 		and mouse.pressed then
			mouse.target=-1
			p[i].visible=true
			moves=game.turnMoves

			for t=1,#moves-1 do
				if moves[t]
				and moves[t][1]==pos
				and moves[t][2]==mouse.pos 
				and game.turn==p[i].c then
					deletePeicePos(moves[t][2])
					p[i].x,p[i].y=intToPos(moves[t][2]+1)
					swapTurn()
				end
			end
		end

		if mouse.pos==pos
		and mouse.justPressed
		and mouse.target==-1 
		and p[i].c==game.turn then
			mouse.target=i
			p[i].visible=false
		end
	end
	::skipLoop::
end

function spr2x2(i,x,y)
	spr(i,x,y)
	spr(i+1,x+8,y)
	spr(i+16,x,y+8)
	spr(i+17,x+8,y+8)
end

function boardSpr2x2(i,x,y)
	if x>0 and x<8 then x*=16 end
	if y>0 and y<8 then y*=16 end
	spr(i,x,y)
	spr(i+1,x+8,y)
	spr(i+16,x,y+8)
	spr(i+17,x+8,y+8)
end

function chessDraw()
	for i=1,#p do
		if p[i].visible then
			boardSpr2x2(p[i].sprIndex,p[i].x,p[i].y)
		end
	end

	if mouse.target!=-1 then
		for i=1,#game.turnMoves-1 do
			if game.turnMoves[i][1]==p[mouse.target].pos then
				x,y=intToPos(game.turnMoves[i][2]+1)
				boardSpr2x2(14,x,y)
			end
		end
	end
end