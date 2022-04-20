local Flags = 0
local Whitelist = {}
local Webhook = "" -- put ur webhook url

local HTTP = game:GetService("HttpService")

local wsDetect = 14

local logKicks = true


local function CharacterThread(Chr)	
	wait()
	--//Main
	coroutine.resume(coroutine.create(function()
		--//Vars
		local Hum = Chr:WaitForChild("Humanoid")
		local Root = Chr:WaitForChild("HumanoidRootPart")
		--
		if not Hum or not Root then return end

		--//Logic Vars
		local lastSpeedChange = 0
		local LastCFrame = Root.CFrame

		--//Hooks
		Hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			lastSpeedChange = tick()
		end)

		--//Function
		local function Check()
			local ThisPosition = Vector3.new(Root.Position.X,0,Root.Position.Z)
			local LastPosition = Vector3.new(LastCFrame.Position.X,0,LastCFrame.Position.Z)
			local Distance = (ThisPosition - LastPosition).Magnitude
			local WalkSpeed = Hum.WalkSpeed
			--
			if Distance > (WalkSpeed + wsDetect) and not table.find(Whitelist, game.Players:GetPlayerFromCharacter(Chr).UserId) then
				if Flags >= 5 then
					game.Players:GetPlayerFromCharacter(Chr):Kick("Anti Cheat: Speed/Teleporting Detected")
					local Msg = "Anti Cheat: " .. game.Players:GetPlayerFromCharacter(Chr).Name .. " Was Kicked For Cheating"
					
					local player = game.Players:GetPlayerFromCharacter(Chr)
					local Reason = "Speed/Teleporting"
					local data = {
						["embeds"] = {{

							["author"] = {
								["name"] = player.Name,
								["icon_url"] = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username="..player.Name
							},
							["description"] = "Kicked For Speed/Teleporting",
							["color"] = tonumber(0xFFFAFA),
							["fields"] = {
								{
									["name"] = "Account Age",
									["value"] = player.AccountAge.. " days",
									["inline"] = true
								},
								{
									["name"] = "User ID",
									["value"] = player.UserId,
									["inline"] = true
								}
							}
						}},

					}
					local finaldata = HTTP:JSONEncode(data)
					if logKicks then
						HTTP:PostAsync(Webhook, finaldata)
						end
				else
					if not table.find(Whitelist, game.Players:GetPlayerFromCharacter(Chr).UserId)  then
						Root.CFrame = LastCFrame
						Flags += 1 
					end

				end

			end
		end
		while true do
			LastCFrame = Root.CFrame
			wait(1)
			if tick() - lastSpeedChange >= 1 then
				Check()
			end
		end

	end))

end

--//Hooks
local DB = false
game.Players.PlayerAdded:Connect(function(Plr)
	Plr.CharacterAdded:Connect(function(Chr)
		CharacterThread(Chr)
		Chr.Humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.StrafingNoPhysics and not table.find(Whitelist, Plr.UserId) then
				Plr:Kick("Anti Cheat: Noclip Detected")
				if not DB then
					DB = true

					local player = Plr
					local data = {
						["embeds"] = {{

							["author"] = {
								["name"] = player.Name,
								["icon_url"] = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username="..player.Name
							},
							["description"] = "Kicked For StrafingNoPhysics",
							["color"] = tonumber(0xFFFAFA),
							["fields"] = {
								{
									["name"] = "Account Age",
									["value"] = player.AccountAge.. " days",
									["inline"] = true
								},
								{
									["name"] = "User ID",
									["value"] = player.UserId,
									["inline"] = true
								}
							}
						}},

					}
					local finaldata = HTTP:JSONEncode(data)
					if logKicks then
						HTTP:PostAsync(Webhook, finaldata)
						end
					wait(5)
					DB = false
				end
			end
		end)
	end)
end)
