
colors={1,-1}

peiceWeights={
	['pawn']=100,
	['knite']=320,
	['bish']=330,
	['rook']=500,
	['queen']=900,
	['king']=10000
}

function evalBoard(board,gameState)
	local gameState=gameState or 'earlyGame'
	local total=0

	if gameState=='earlyGame' then
		for i=1,64 do
			if board[i]==0 then
				goto skipIteration
			end
			local pos=i
			local color=board[i].c

			if color==1 then
				pos=65-i
			end

			local rank=board[i].rank

			total+=peiceWeights[rank]*color+PSTS[rank][pos]*color -- either -1 for black or 1 for white

			::skipIteration::
		end
	end
	return total
end

-- turns x,y to 0-63 
function posToInt(x,y)
	return x+y*8
end

-- turns tbl i position to x,y
function intToPos(i)
	return (i-1)%8, flr((i-1)/8)
end

-- 64i array
function performantBoard()
	board={}

	for i=1,64 do
		board[i]=0
	end

	for i=1,#p do
		local bi=posToInt(p[i].x,p[i].y)
		board[bi+1]={rank=p[i].rank,c=p[i].c}
	end

	return board
end

--MVVLVA score		| 	not needed as everything goes in order
-- function captureWeight(victim,attacker)
-- 	return (peiceWeights[victim]*10)-peiceWeights[attacker]
-- end

-- 'steps' possible peice moves by delta x,y - sets tbl of {from,to} 
-- returns true if end of move loop takes enemy peice
function peiceStep(x,y,dx,dy,i,tbl,board,color)
	local x1=x
	local y1=y
	local sx,sy,val

	for o=i,8 do
		sx=x1+dx
		sy=y1+dy
		if sx>7 or sx<0
		or sy>7 or sy<0 then
			return false
		end

		val=board[posToInt(sx,sy)+1]

		if val!=0
		and val.c==color then
			return false
		elseif val!=0
		and val.c!=color
		and val.rank=='king' then
			tbl[1][#tbl[1]+1]={posToInt(x,y),posToInt(sx,sy)}
		elseif val!=0
		and val.c!=color then
			tbl[2][#tbl[2]+1]={posToInt(x,y),posToInt(sx,sy)}
			return true
		elseif val==0 then
			tbl[3][#tbl[3]+1]={posToInt(x,y),posToInt(sx,sy)}
		end


		x1=sx
		y1=sy
	end
end

-- returns possible moves for eatch peice in color, rets moves as {from,to}	
function clrPossibleMoves(color,board)
	local moves={{},{},{}}
	-- moves[1]={}	-- check tbl, any move that produces check
	-- moves[2]={} -- capture tbl, if move results in a capture
	-- moves[3]={}	-- moving to empty square

	local y1,x,y,pos,rank,d1,d2,l,kingPos

	for i=1,64 do

		if board[i]==0 or board[i].c!=color then goto skipIteration end

		x,y=intToPos(i)
		pos=i-1
		rank=board[i].rank

		if rank=='pawn' then
			--	pawn one forward
			y1=pos-(8*color)

			if board[y1+1]==0 then
				moves[3][#moves[3]+1]={pos,y1}
	--	pawn 2 start jump (clr logic)
				if color==-1
				and y==1
				or color==1
				and y==6 then
					local y2=pos-(16*color)
					if board[y2+1]==0 then
						moves[3][#moves[3]+1]={pos,y2}
					end
				end
			end
	--	capture oppurtunity	, diagonal 1-2

			if color>0 then
				d1=pos-7*color
				d2=pos-9*color
			else
				d1=pos-9*color
				d2=pos-7*color
			end

			d1+=1
			d2+=1
			l=2

			if board[d1]!=0
			and board[d1].c!=color 
			and x<7 then
				if board[d1].rank=='king' then l=3 else l=2 end
				moves[l][#moves[l]+1]={pos,d1-1}
			end

			if board[d2]!=0
			and board[d2].c!=color 
			and x>0 then
				if board[d2].rank=='king' then l=3 else l=2 end
				moves[l][#moves[l]+1]={pos,d2-1}
			end

		elseif rank=='knite' then
			peiceStep(x,y,-1,-2,8,moves,board,color)
			peiceStep(x,y,1,-2,8,moves,board,color)
			peiceStep(x,y,-1,2,8,moves,board,color)
			peiceStep(x,y,1,2,8,moves,board,color)
			peiceStep(x,y,2,-1,8,moves,board,color)
			peiceStep(x,y,2,1,8,moves,board,color)
			peiceStep(x,y,-2,-1,8,moves,board,color)
			peiceStep(x,y,-2,1,8,moves,board,color)
		elseif rank=='bish' then
			peiceStep(x,y,1,1,1,moves,board,color)
			peiceStep(x,y,-1,1,1,moves,board,color)
			peiceStep(x,y,1,-1,1,moves,board,color)
			peiceStep(x,y,-1,-1,1,moves,board,color)
		elseif rank=='rook' then
			peiceStep(x,y,1,0,1,moves,board,color)
			peiceStep(x,y,-1,0,1,moves,board,color)
			peiceStep(x,y,0,1,1,moves,board,color)
			peiceStep(x,y,0,-1,1,moves,board,olor)
		elseif rank=='queen' then
			peiceStep(x,y,1,1,1,moves,board,color)
			peiceStep(x,y,-1,1,1,moves,board,color)
			peiceStep(x,y,1,-1,1,moves,board,color)
			peiceStep(x,y,-1,-1,1,moves,board,color)
			peiceStep(x,y,1,0,1,moves,board,color)
			peiceStep(x,y,-1,0,1,moves,board,color)
			peiceStep(x,y,0,1,1,moves,board,color)
			peiceStep(x,y,0,-1,1,moves,board,color)
		elseif rank=='king' then
			kingPos=pos
			peiceStep(x,y,1,1,8,moves,board,color)
			peiceStep(x,y,-1,1,8,moves,board,color)
			peiceStep(x,y,1,-1,8,moves,board,color)
			peiceStep(x,y,-1,-1,8,moves,board,color)
			peiceStep(x,y,1,0,8,moves,board,color)
			peiceStep(x,y,-1,0,8,moves,board,color)
			peiceStep(x,y,0,1,8,moves,board,color)
			peiceStep(x,y,0,-1,8,moves,board,color)
		end

		::skipIteration::

	end

-- order moves best to worse for better pruning
	
	local orderedMoves={}

	for i=1,#moves do
		for o=1,#moves[i] do
			orderedMoves[#orderedMoves+1]=moves[i][o]
		end
	end

	orderedMoves[#orderedMoves+1]=kingPos

	return orderedMoves
end

-- finds how king is being attacked, rets legal possible moves
function attackDetection()

end

function possibleMoves(board,color)
	local myMoves=clrPossibleMoves(color,board)
	local enemyMoves=clrPossibleMoves(color*-1,board)

--  if enemy most important move is myMoves king then check=true
	if enemyMoves[1][2]==myMoves[#myMoves] then
		check=true
	else
		return myMoves
	end
end