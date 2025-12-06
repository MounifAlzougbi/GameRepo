
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

end

-- this IS the search, needs to be connected with TT for real performance
function minimax(board,depth,alpha,beta,maxingPlayer)
	if depth==0 or gameOver(board) then 
		return evalBoard(board) 
	end

	if maxingPlayer then	--		minimizing bot

	else					-- 		minimizing player   /   maximizing bot

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
			swap_turn()

		end
	end

	bot.lastTurn=turn
end