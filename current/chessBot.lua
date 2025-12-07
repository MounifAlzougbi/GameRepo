
bot={
	think=false,
	turnCount=0,
	lastTurn=0,

	draw=function(s)
		if s.think then
			print('peeking into the futures...',12,36,8)
		end
	end
}

-- t/f if game is over
function gameOver(board)
	return false -- idk how to eval yet
end

-- set/undo set of zHash and board xor toggle for quick board changes
function setMove(board,hash,move,color)
	local to,from=move[2]+1,move[1]+1
--   pos to/from

	if board[to]!=0 then
		hash=bxor(hash,keys[to][color*-1][board[to].rank])	--	get rid of enemy in capture slot
		hash=bxor(hash,keys[from][color][board[from].rank]) --  get rid of freindly original pos
		hash=bxor(hash,keys[to][color][board[from].rank])	--  set pos in to

		board[to].rank=board[from].rank
		board[to].c=board[from].c
		board[from]=0
	else
		hash=bxor(hash,keys[from][color][board[from].rank]) --  get rid of freindly original pos
		hash=bxor(hash,keys[to][color][board[from].rank])	--  set freindly in new pos

		board[to]={
			rank=board[from].rank,
			c=board[from].c
		}
		board[from]=0
	end
end

function undoMove(board,hash,move,color)

end

-- this IS the search, needs to be connected with TT for real performance
function minimax(board,depth,alpha,beta,maxingPlayer)
	if depth==0 or gameOver(board) then 
		return evalBoard(board) 
	end

	local maxEval,minEval,color,moves,eval,newBoard,hash

	if maxingPlayer then
		color=1
	else
		color=-1
	end

	if maxingPlayer then	--		minimizing bot
		maxEval=-32000
		moves=possibleMoves(board,color)
		for i=1,#moves-1 do
			hash=retZhash()
		-- if hash is in TT and truthy skip eval and use stored data
			setMove(board,hash,move[i],color)

			undoMove(board,hash,move[i],color)
		end
	else					-- 		minimizing player   /   maximizing bot
		minEval=32000
	end
end

-- main bot update
function botUpdate()
	local turn=game.turn
	if turn!=bot.lastTurn then
		botBoard=performantBoard() 
		botEval=evalBoard(botBoard)
	end

-- its my turn!
	if turn==-1 then
		bot.think=true
		bot.turnCount+=1
		if bot.turnCount>90 then -- 3 seconds, 30fps


			bot.turnCount=0
			bot.think=false
			swapTurn()

		end
	end

	bot.lastTurn=turn
end