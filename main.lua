-- Formatting time
local function TimerFormat(seconds)
  seconds = math.max(0, math.floor(seconds))
  local hours = math.floor(seconds / 3600)
  local mins = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60

  return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- Timer popup

local function openPasswordPopup()
  popup.open = true
  popup.password = ""
  popup.message = ""
  love.keyboard.setTextInput(true)
end

local function closePasswordPopup()
  popup.open = false
  love.keyboard.setTextInput(false)
  DisplayedTime = TimerFormat(time)
end

-- Events
local function RandomEvent()
  local chance = math.random(1, 100)
  if Bee:isPlaying() then
    love.audio.stop(Bee)
    love.audio.setVolume(1.0)
  end

  if chance <= 5 then
    event = "adds a second"
    time = time + 1
  elseif chance <= 10 then
    event = "freezes for 5 variable seconds"
    freezeTimer = CurrentSecondSecond * 5
  elseif chance <= 11 then
    event = "adds a minute"
    time = time + 60
  elseif chance <= 12 then
    event = "drops a minute"
    time = math.max(0, time - 60)
  elseif chance <= 13 then
    event = "time doubles"
    time = time * 2
  elseif chance <= 14 then
    event = "time halves"
    time = time / 2
  elseif chance <= 15 then
    event = "minutes and seconds swap"
    local hours = math.floor(time / 3600)
    local mins = math.floor((time % 3600) / 60)
    local secs = math.floor(time % 60)
    time = hours * 3600 + secs * 60 + mins
  elseif chance <= 16 then
    event = "time rounds to the nearest minute"
    time = math.floor((time + 30) / 60) * 60
  elseif chance <= 17 then
    event = "move to a random spot on the screen"
    CenterPosX = math.random(0, love.graphics.getWidth())
    CenterPosY = math.random(0, love.graphics.getHeight())
  elseif chance <= 18 then
    event = "variable second is doubled"
    CurrentSecondSecond = CurrentSecondSecond * 2
  elseif chance <= 19 then
    event = "variable second is halved"
    CurrentSecondSecond = CurrentSecondSecond / 2
  elseif chance <= 20 then
    event = "play a loud bee sound for one variable second"
    love.audio.setVolume(5.0)
    love.audio.play(Bee)
  else
    event = "drop a second (normal)"
    time = time - 1
  end
end

-- Actual logic
function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  font = love.graphics.newFont("JetBrainsMonoNerdFontMono-Medium.ttf", 30)
  love.graphics.setFont(font)
  love.audio.setVolume(1.0)
  love.window.setIcon(love.image.newImageData("Icon.png"))

  popup = {
    open = false,
    password = "",
    message = ""
  }


  Bee = love.audio.newSource("Bee.mp3", "static")
  Finish = love.audio.newSource("Finish.mp3", "static")
  time = 0
  CurrentSecondSecond = 1
  SecondSecond = CurrentSecondSecond
  DisplayedTime = TimerFormat(time)
  isOn = false
  event = ""
  freezeTimer = 0

  Scale = love.window.getDPIScale() + 2
  CenterPosX = love.graphics.getWidth() / 2
  CenterPosY = love.graphics.getHeight() / 2
end

function love.update(dt)
  CenterPosX = love.graphics.getWidth() / 2
  CenterPosY = love.graphics.getHeight() / 2


  if time <= 0 and not popup.open then
    openPasswordPopup()
    return
  end

  if not isOn then return end

    if time <= 0 then
      love.audio.play(Finish)
      isOn = false
      openPasswordPopup()
      return
    end


  if freezeTimer > 0 then
    freezeTimer = math.max(0, freezeTimer - dt)
    return
  end


  SecondSecond = SecondSecond - dt
  if SecondSecond <= 0 then
    RandomEvent()
    DisplayedTime = TimerFormat(time)
    SecondSecond = CurrentSecondSecond
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  -- Actual timer
  love.graphics.setFont(love.graphics.newFont("JetBrainsMonoNerdFontMono-Medium.ttf", 90))
  local textWidth = love.graphics.getFont():getWidth(DisplayedTime)
  local textHeight = love.graphics.getFont():getHeight()

  love.graphics.print(DisplayedTime, CenterPosX - textWidth / 2, CenterPosY - textHeight / 2)

  -- Start button
  love.graphics.setFont(font)

  if isOn then
    love.graphics.setColor(0.870588235, 0.93, 0, 0.5)
  else
    love.graphics.setColor(0.870588235, 0.93, 0)
  end
  ButtonWidth = 100
  ButtonHeight = 50
  ButtonX = CenterPosX - (ButtonWidth / 2)
  ButtonY = ((CenterPosY - (ButtonHeight / 2)) + (textHeight / 2)) + 50
  love.graphics.rectangle("fill", ButtonX, ButtonY, ButtonWidth, ButtonHeight, 5, 5)

  if isOn then
    love.graphics.print({{0, 0, 0, 0.5}, "Start"}, ButtonX, ButtonY)
  else
    love.graphics.print({{0, 0, 0}, "Start"}, ButtonX, ButtonY)
  end    

  -- Current event
  love.graphics.setColor(1, 1, 1)
  textWidth = love.graphics.getFont():getWidth(event)
  textHeight = love.graphics.getFont():getHeight()
  love.graphics.print("Current event: " .. event, ButtonX - (textWidth / 2), (ButtonY - (textHeight / 2)) + 75)

  -- Variable second
  love.graphics.print("1s = " .. CurrentSecondSecond .. "s", ButtonX, ButtonY + 100)

  -- Popup panel
  if not popup.open then
    return
  end

  -- Dim the background
  love.graphics.setColor(0, 0, 0, 0.65)
  love.graphics.rectangle(
      "fill", 0, 0,
      love.graphics.getWidth(),
      love.graphics.getHeight()
  )

  love.graphics.setFont(love.graphics.newFont("JetBrainsMonoNerdFontMono-Medium.ttf", 18))

  love.graphics.setColor(0.20, 0.22, 0.28)
  love.graphics.rectangle("fill", CenterPosX - 150, CenterPosY - 80, 300, 160, 10, 10)

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Enter amount of time in seconds", CenterPosX - 140, CenterPosY - 60, 280, "center")

  -- Input field
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", CenterPosX - 120, CenterPosY - 10, 240, 35, 5, 5)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(popup.password, CenterPosX - 120, CenterPosY - 10)

  -- Submit button
  love.graphics.setColor(0.870588235, 0.933333333, 0)
  love.graphics.rectangle("fill", CenterPosX - 110, CenterPosY + 55, 80, 40, 5, 5)

  love.graphics.setColor(0, 0, 0)
  love.graphics.printf("Submit", CenterPosX - 110, CenterPosY + 65, 80, "center")
end

function love.mousepressed(x, y, button)
  if button == 1 and x >= ButtonX and x <= ButtonX + ButtonWidth and y >= ButtonY and y <= ButtonY + ButtonHeight then
    isOn = true
  end

  if not popup.open or button ~= 1 then
    return
  end

  -- Submit button
  if x >= CenterPosX - 110 and x <= CenterPosX - 30 and y >= CenterPosY + 55 and y <= CenterPosY + 95 then
    time = tonumber(popup.password)
    closePasswordPopup()
  end
end

function love.textinput(text)
  if popup.open then
    popup.password = popup.password .. text
  end
end

function love.keypressed(key)
  if key == "backspace" then
    local byteoffset = utf8.offset(popup.password, -1)
    if byteoffset then
      popup.password = popup.password:sub(1, byteoffset - 1)
    end
  elseif key == "return" or key == "kpenter" then
    time = tonumber(popup.password)
    closePasswordPopup()
  end
end
