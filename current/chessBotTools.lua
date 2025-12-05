
function evalBoard()

end

function posToInt(x,y)
	if x>8 or y>8 or y<0
	or x<0 then return false end
	return x+y*8
end

-- 'steps' possible peice moves by delta x,y - rets tbl of {from,to}
function peiceStep(x,y,dx,dy,i,tbl)
	local sx=x+dx
	local sy=y+dy
	local val=bb:what_i(sx,sy)

	if val!=nil then i=8 end


	if val==nil and sx>-1 and sx<8
	and sy>-1 and sy<9 and i<8 then
		add(tbl,{posToInt(x,y),posToInt(sx,sy)})
		peiceStep(sx,sy,dx,dy,i+1,tbl)
	end
end

-- returns possible moves for eatch peice in color, rets moves as {from,to}		this is NOT performant must be updated with arr
function botPossibleMoves(color)
	local moves={}

	for i=1,#p do

		local x=p[i].x
		local y=p[i].y

		if p[i].rank=='pawn' 
		and p[i].c==color then
--	pawn 2 start jump (clr logic)
			if p[i].c==-1
			and y==1
			or p[i].c==1
			and y==6 then
				local y2=bb:what_i(x,y+(2*p[i].c))
				if y2==nil then
					add(moves,{posToInt(x,y),posToInt(x,y-(2*p[i].c))})
				end
			end
--	pawn one forward
			y1=bb:what_i(x,y-p[i].c)

			if y1==nil then
				add(moves,{posToInt(x,y),posToInt(x,y-p[i].c)})
			end

		elseif p[i].rank=='knite'
		and p[i].c==color then
			peiceStep(x,y,-1,-2,7,moves)
			peiceStep(x,y,1,-2,7,moves)
			peiceStep(x,y,-1,2,7,moves)
			peiceStep(x,y,1,2,7,moves)
			peiceStep(x,y,2,-1,7,moves)
			peiceStep(x,y,2,1,7,moves)
			peiceStep(x,y,-2,-1,7,moves)
			peiceStep(x,y,-2,1,7,moves)
		elseif p[i].rank=='rook'
		and p[i].c==color then
			peiceStep(x,y,1,0,1,moves)
			peiceStep(x,y,-1,0,1,moves)
			peiceStep(x,y,0,1,1,moves)
			peiceStep(x,y,0,-1,1,moves)
		elseif p[i].rank=='bish'
		and p[i].c==color then
			peiceStep(x,y,1,1,1,moves)
			peiceStep(x,y,-1,1,1,moves)
			peiceStep(x,y,1,-1,1,moves)
			peiceStep(x,y,-1,-1,1,moves)
		elseif p[i].rank=='queen'
		and p[i].c==color then
			peiceStep(x,y,1,1,1,moves)
			peiceStep(x,y,-1,1,1,moves)
			peiceStep(x,y,1,-1,1,moves)
			peiceStep(x,y,-1,-1,1,moves)
			peiceStep(x,y,1,0,1,moves)
			peiceStep(x,y,-1,0,1,moves)
			peiceStep(x,y,0,1,1,moves)
			peiceStep(x,y,0,-1,1,moves)
		elseif p[i].rank=='king'
		and p[i].c==color then
			--rook like
			peiceStep(x,y,0,-1,7,moves)
			peiceStep(x,y,0,1,7,moves)
			peiceStep(x,y,-1,0,7,moves)
			peiceStep(x,y,1,0,7,moves)
			--bish like
			peiceStep(x,y,-1,-1,7,moves)
			peiceStep(x,y,1,-1,7,moves) 
			peiceStep(x,y,-1,1,7,moves)
			peiceStep(x,y,1,1,7,moves)
		end
	end
	return moves
end
