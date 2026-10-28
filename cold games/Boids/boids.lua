

function boidInit()

	speed=1.5 -- arbitrary
	boidAmnt=40
	boidTbl={}

	tempX,tempY,tempDX,tempDY,tempDir=0,0,0,0,0

	for i=1,boidAmnt do
		tempX=flr(rnd(128))
		tempY=flr(rnd(128))

		tempDir=rnd(1)

		boidTbl[i]={
			x=tempX,
			y=tempY,
			dir=tempDir

		}
	end

end


function boidUpdate()

end


function boidDraw()
	for i=1,boidAmnt do
		pset(boidTbl[i].x,boidTbl[i].y,1)
	end
	print(boidTbl[1].dir)
	print(abs(cos(boidTbl[1].dir))+abs(sin(boidTbl[1].dir)))
	--print(sin(boidTbl[1].dir))
end