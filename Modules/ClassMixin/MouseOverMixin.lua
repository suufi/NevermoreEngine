--- Mouse over mixin for general utility button mouse over effects
-- @module MouseOverMixin

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Maid = require("Maid")

local module = {}

function module:Add(class)
	assert(class)
	assert(not class.GetMouseOverColor)

	class.GetMouseOverColor = self.GetMouseOverColor
	class.GetMouseOverBoolValue = self.GetMouseOverBoolValue
	class.AddMouseOverEffect = self.AddMouseOverEffect
	class._getMouseOverTweenProperties = self._getMouseOverTweenProperties
end

---
-- @tparam Color3 originalColor
-- @tparam[opt=1] number factor
function module:GetMouseOverColor(originalColor, factor)
	factor = factor or 1
	local h, s, v = Color3.toHSV(originalColor)
	return Color3.fromHSV(h, s, v-0.05*factor)
end

function module:GetMouseOverBoolValue(gui)
	local maid = Maid.new()

	local boolValue = Instance.new("BoolValue")
	boolValue.Value = false
	maid:GiveTask(boolValue)

	maid:GiveTask(gui.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			boolValue.Value = true
		end
	end))

	maid:GiveTask(gui.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			boolValue.Value = false
		end
	end))

	return maid, boolValue
end

function module:_getMouseOverTweenProperties(gui)
	if gui:IsA("ImageButton") then
		return {
			ImageColor3 = self:GetMouseOverColor(gui.ImageColor3);
			BackgroundColor3 = self:GetMouseOverColor(gui.BackgroundColor3);
		}
	else
		return {
			BackgroundColor3 = self:GetMouseOverColor(gui.BackgroundColor3);
		}
	end
end

function module:AddMouseOverEffect(gui, tweenProperties)
	tweenProperties = tweenProperties or self:_getMouseOverTweenProperties(gui)

	if gui:IsA("GuiButton") then
		gui.AutoButtonColor = false
	end

	local maid, boolValue = self:GetMouseOverBoolValue(gui)
	local original = {}
	for property, _ in pairs(tweenProperties) do
		original[property] = gui[property]
	end

	local function update()
		for property, Value in pairs(boolValue.Value and tweenProperties or original) do
			gui[property] = Value
		end
	end
	update()
	maid:GiveTask(boolValue.Changed:Connect(update))

	self._maid[boolValue] = maid

	return boolValue
end

return module
