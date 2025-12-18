

-- @init
function electronInit()
	bodys={}	--	global objects

	electron={  --	shows as a point
		x=0,y=0,	--	pos
		vx=0,vy=0,	--	velocity
		ax=0,ay=0,	--	acceleration
		spin,
		charge=false,
		radius=0.5
	}

	positron={  --	shows as a point
		x=0,y=0,	--	pos
		vy=0,vy=0,	--	velocity
		ax=0,ay=0,	--	acceleration
		spin,
		charge=true,
		radius=0.5
	}

	local e1=electron

	e1.x=30
	e1.y=30
	e1.vx=10
	e1.vy=2

	bodys[1]=e1

end

function distanceTo(a,b)
	local dx,dy,distance

	dx=b.x-a.x
	dy=b.y-a.y

	distance=sqrt((dx*dx)(dy*dy))

	return distance
end

function applyElectroMagneticForce(electron,index)
	local distance
	for i=1,#bodys do
		if i!=index then
			distance=distanceTo(electron,bodys[i])
			distance-=1
		end
	end
end

-- @update
function electronUpdate(deltaTime)
	local electron
	for i=1,#bodys do
		electron=bodys[i]

		electron.vx+=electron.ax*deltaTime
		electron.vy+=electron.ay*deltaTime

		electron.x+=electron.vx*deltaTime
		electron.y+=electron.vy*deltaTime

		if electron.x<0
		or electron.x>127 then
			electron.vx*=-1
			electron.ax*=-1
		end

		if electron.y<0
		or electron.y>127 then
			electron.vy*=-1
			electron.ay*=-1
		end

		applyElectroMagneticForce(electron,i)

		bodys[i]=electron
	end
end

-- @draw
function electronDraw()
	-- print
	for i=1,#bodys do
		pset(bodys[i].x-0.5,bodys[i].y-0.5,12)
	end
end