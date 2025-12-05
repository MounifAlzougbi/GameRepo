
function evalBoard()

end

-- 64i array
function performantBoard()
	board={}

	for i=1,64 do
		add(board,{})
	end

	for i=1,#p do
		local bi=posToInt(p[i].x,p[i].y)+1

		add(board,{rank=p[i].rank,c=p[i].c},bi)
	end

	for i=1,32 do
		deli(board,#board)
	end

	return board
end

function posToInt(x,y)
	if x>8 or y>8 or y<0
	or x<0 then return false end
	return x+y*8
end


-- 'steps' possible peice moves by delta x,y - sets tbl of {from,to} 
--returns true if end of move loop takes enemy peice
function peiceStep(x,y,dx,dy,i,tbl,board,color)
	local x1=x
	local y1=y
	for o=i,8 do
		local sx=x1+dx
		local sy=y1+dy
		local val=board[posToInt(sx,sy)]

		if sx>8 or sx<0
		or sy>8 or sx<0 then
			return false
		end

		if val!=nil
		and val.c==color then
			return false
		elseif val!=nil
		and val.c!=color then
			add(tbl,{posToInt(x,y),posToInt(sx,sy)})
			return true
		elseif val==nil then
			add(tbl,{posToInt(x,y),posToInt(sx,sy)})
		end


		x1=sx
		y1=sy
	end
end

kingMoves={1,-1,8,-8,9,-9,7,-7}
kniteMoves={6,-6,10,-10,15,-15,17,-17}

-- returns possible moves for eatch peice in color, rets moves as {from,to}	
-- this is NOT performant must be updated with arr
function botPossibleMoves(color,board)
	local moves={}

	for i=1,#p do

		local x=p[i].x
		local y=p[i].y
		local pos=posToInt(x,y)

		if p[i].rank=='pawn' 
		and p[i].c==color then
--	pawn 2 start jump (clr logic)
			if p[i].c==-1
			and y==1
			or p[i].c==1
			and y==6 then
				local y2=pos-(16*color)
				if #board[y2]<2 then
					add(moves,{pos,y2})
				end
			end
--	pawn one forward
			local y1=pos-(8*color)

			if #board[y1]<2 then
				add(moves,{pos,y1})
			end

--	capture oppurtunity	, diagonal 1-2
			
			local d1=y1-1
			local d2=y1+1

			if #board[d1]>2
			and board[d1].c!=color then
				add(moves,{pos,d1,true})
			end

			if #board[d2]>2
			and board[d2].c!=color then
				add(moves,{pos,d2,true})
			end


		elseif p[i].rank=='knite'
		and p[i].c==color then

			for o=1,8 do
				if pos+kniteMoves[o]>64
				or pos+kniteMoves[o]<1 then
					-- @break should skip to next loop/index
					break
				end

				if #board[pos+kniteMoves[o]]<2 then
					add(moves,{pos,pos+kniteMoves[o]})
				elseif board[pos+kniteMoves[o]].c!=color then
					add(moves,{pos,pos+kniteMoves[o],true})
				end
			end

		elseif p[i].rank=='rook'
		and p[i].c==color then
			peiceStep(x,y,1,0,1,moves,board,color)
			peiceStep(x,y,-1,0,1,moves,board,color)
			peiceStep(x,y,0,1,1,moves,board,color)
			peiceStep(x,y,0,-1,1,moves,board,olor)
		elseif p[i].rank=='bish'
		and p[i].c==color then
			peiceStep(x,y,1,1,1,moves,board,color)
			peiceStep(x,y,-1,1,1,moves,board,color)
			peiceStep(x,y,1,-1,1,moves,board,color)
			peiceStep(x,y,-1,-1,1,moves,board,color)
		elseif p[i].rank=='queen'
		and p[i].c==color then
			peiceStep(x,y,1,1,1,moves,board,color)
			peiceStep(x,y,-1,1,1,moves,board,color)
			peiceStep(x,y,1,-1,1,moves,board,color)
			peiceStep(x,y,-1,-1,1,moves,board,color)
			peiceStep(x,y,1,0,1,moves,board,color)
			peiceStep(x,y,-1,0,1,moves,board,color)
			peiceStep(x,y,0,1,1,moves,board,color)
			peiceStep(x,y,0,-1,1,moves,board,color)
		elseif p[i].rank=='king'
		and p[i].c==color then
			for o=1,8 do

				if pos+kingMoves[o]>64
				or pos+kingMoves[o]<1 then
					break
				end

				if #board[pos+kingMoves[o]]<2 then
					add(moves,{pos,pos+kingMoves[o]})
				elseif #board[pos+kingMoves[o]].c!=color then
					add(moves,{pos,pos+kingMoves[o],true})
				end
			end
		end
	end
	return moves
end
