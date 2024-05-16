local playerDefinition = class{
    shipName = "",
    shipClass,
    uiShipSprite,

    init = function(self, shipName, shipClass, uiShipSprite)
        self.shipName = shipName
        self.shipClass = shipClass
        self.uiShipSprite = uiShipSprite
    end
}

return playerDefinition