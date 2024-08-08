local wanderer = require "src.objects.enemy.wanderer"
local charger = require "src.objects.enemy.charger"
local drone = require "src.objects.enemy.drone"
local shielder = require "src.objects.enemy.shielder"
local orbiter = require "src.objects.enemy.orbiter"
local heater = require "src.objects.enemy.heater"
local crisscross = require "src.objects.enemy.crisscross"
local ram = require "src.objects.enemy.crisscross"
local exploder = require "src.objects.enemy.exploder"
local snake = require "src.objects.enemy.snake"

local boss1 = require "src.objects.enemy.boss.boss1.boss1"
local boss2 = require "src.objects.enemy.boss.boss2.boss2"

local enemyDefinitions =
{
    ["wanderer"] = {enemyClass = wanderer, spriteName = "wanderer"},
    ["charger"] = {enemyClass = charger, spriteName = "charger"},
    ["drone"] = {enemyClass = drone, spriteName = "drone"},
    ["shielder"] = {enemyClass = shielder, overrideSprite = game.resourceManager:getAsset("Enemy Assets"):get("shielder"):get("warningSprite")},
    ["orbiter"] = {enemyClass = orbiter, spriteName = "orbiter"},
    ["heater"] = {enemyClass = heater, spriteName = "wanderer"},
    ["exploder"] = {enemyClass = exploder, spriteName = "exploder"},
    ["denier"] = {enemyClass = exploder, spriteName = "denier"},
    ["crisscross"] = {enemyClass = crisscross, spriteName = "crisscross"},
    ["ram"] = {enemyClass = wanderer, spriteName = "wanderer"},
    ["snake"] = {enemyClass = snake, spriteName = "snake"},
    
    ["boss1"] = {enemyClass = boss1},
    ["boss2"] = {enemyClass = boss2}
}

return enemyDefinitions