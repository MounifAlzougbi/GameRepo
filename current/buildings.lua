-- this file, covers buildings and city streets (blocks)
-- map will be 1024*1024 px top left corner 0,0
-- 4x4 chunks, 256 * 256 will store into an 2d array for future pathfinding

--  city map tbl values - 0 = street/sidewalk 1 = building, 

cityMap = {}

function initCityMapTbl()

	for y = 1,256 do
		cityMap[y] = {}
		for x = 1,256 do
			if (x % 10 == 0) then 
				cityMap[y][x] = 1
			else
				cityMap[y][x] = 0
			end
		end 
	end

end

function initBuildings()



end

function updateBuildings()

end

function drawBuildings()

end