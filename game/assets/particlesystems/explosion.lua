--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = {x=-922.06724266726, y=19.091883092037}

local image1 = LG.newImage("circle.png")
image1:setFilter("linear", "linear")
local image2 = LG.newImage("ring.png")
image2:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 9)
ps:setColors(1, 1, 1, 1)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(512)
ps:setEmitterLifetime(0.014950134791434)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.019761353731155, 0.73312985897064)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(1.7186850309372, 0)
ps:setSizeVariation(0)
ps:setSpeed(269.98336791992, 891.73107910156)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=0, y=0})

local ps = LG.newParticleSystem(image1, 1)
ps:setColors(1, 1, 1, 1)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(0)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.31618165969849, 0.31618165969849)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(3.3383769989014, 0)
ps:setSizeVariation(0)
ps:setSpeed(0, 0)
ps:setSpin(0, 0.012826885096729)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=1, blendMode="add", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=0, y=0})

local ps = LG.newParticleSystem(image2, 1)
ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(0)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.31618165969849, 0.31618165969849)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0, 4.8344612121582)
ps:setSizeVariation(0)
ps:setSpeed(0, 0)
ps:setSpin(0, 0.012826885096729)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=1, blendMode="add", shader=nil, texturePath="ring.png", texturePreset="ring", shaderPath="", shaderFilename="", x=0, y=0})

return particles
