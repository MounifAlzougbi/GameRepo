

possibleMoves={

}

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
		p_step(sx,sy,dx,dy,i+1,tbl)
	end
end

-- returns possible moves for eatch peice in color, rets moves as {from,to}
function botPossibleMoves(color)
	local moves={}

	for i=1,#p do

		if p[i].rank=='pawn' 
		and p[i].c==color then
--	pawn 2 start jump
			if p[i].init then
				local y2=bb:what_i(p[i].x,p[i].y+(2*p[i].c))
				if y2==nil then
					add(moves,{posToInt(p[i].x,p[i].y),posToInt(p[i].x,p[i].y+(2*p[i].c))})
				end
			end
--	pawn one forward
			local y1=bb:what_i(p[i].x,p[i].y+p[i].c)

			if y1==nil then
				add(moves,{posToInt(p[i].x,p[i].y),posToInt(p[i].x,p[i].y+p[i].c)})
			end

		elseif p[i].rank=='knite'
		and p[i].c==color then

		elseif p[i].rank=='rook'
		and p[i].c==color then
			peiceStep(p[i].x,p[i].y,1,0,0,moves)
			peiceStep(p[i].x,p[i].y,-1,0,0,moves)
			peiceStep(p[i].x,p[i].y,0,1,0,moves)
			peiceStep(p[i].x,p[i].y,0,-1,0,moves)
		elseif p[i].rank=='bish'
		and p[i].c==color then

		elseif p[i].rank=='queen'
		and p[i].c==color then

		elseif p[i].rank=='king'
		and p[i].c==color then

		end
	end
	return moves
end