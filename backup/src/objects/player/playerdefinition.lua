local playerDefinition = class({name = "Player Definition"})

function playerDefinition:new(shipName, shipClass, uiShipSprite)
    self.shipName = shipName
    self.shipClass = shipClass
    self.uiShipSprite = uiShipSprite
end

return playerDefinition