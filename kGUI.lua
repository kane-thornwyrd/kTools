if not oop then os.loadAPI('oop') end
if not term then os.loadAPI('term') end
if not colors and term.isColour() 
  then os.loadAPI('colors')
  else colors = {
    white = 1,
    orange = 2,
    magenta = 4,
    lightBlue = 8,
    yellow = 16,
    lime = 32,
    pink = 64,
    gray = 128,
    lightGray = 256,
    cyan = 512,
    purple = 1024,
    blue = 2048,
    brown = 4096,
    green = 8192,
    red = 16384,
    black = 32768,
  }
end

---CLASS: Pixel
--[[--

--]]--
Pixel = oop.inheritsFrom( nil,
{
  character = ' ',
  colors = {
    front = colors.purple,
    back = colors.black,
  },
  events = {},
  out = function(self, screen)
    screen:setColors(
      self.colors.front,self.colors.back
    )
    screen.outputPeripheral.write(self.character)
    screen:setColors()
  end,
})

---CLASS: Screen
--[[--

--]]--
Screen = oop.inheritsFrom( nil,
{
  outputPeripheral = term,
  width, height = term.getSize(),
  backgroundColor = colors.black,
  foregroundColor = colors.lightGray,
  childs = {},
  pixels = {},

  ---Function: addChild
  --[[--
    Params:
      - child: guiBaseElement
    Return: self
  --]]--
  addChild = function(self, childE)
    table.insert(self.childs, childE)
    return self
  end,

  ---Function: addChilds
  --[[--
    Params:
      - child: guiBaseElement
    Return: self
  --]]--
  addChilds = function(self, childs)
    for k, child in pairs(childs) do
      self:addChild(child)
    end
    return self
  end,

  ---Function: setSizes
  --[[--
    Params:
      - w: guiBaseElement
    Return: self
  --]]--
  setSizes = function(self, w, h)
    device_w, device_h 
      = self.outputPeripheral.getSize()
    w = w or device_w
    h = h or device_h
    self.width, self.height = w, h
    return self
  end,

  ---Function: cleanReset
  --[[--
    Params: void
    Return: self
  --]]--
  cleanReset = function(self)
    self.outputPeripheral.clear()
    self.outputPeripheral.setCursorPos(1, 1)
    return self
  end,

  ---Function: setColors
  --[[--
    Params:
      - foreground: the fgd color.
      - background: the bgd color.
    Return: self
  --]]--
  setColors = function(self, foreground, background)
    if self.outputPeripheral.isColour() then
      foreground = foreground 
        or Screen.foregroundColor
      background = background
        or Screen.backgroundColor
      self.outputPeripheral.setTextColor(foreground)
      self.outputPeripheral.setBackgroundColor(background)
    end
    return self
  end,

  ---Function: render
  --[[--
    Params: void
    Return: self
  --]]--
  render = function(self)
    for k, child in ipairs(self.childs) do
      child:constructRendering(self)
    end

    for x, v in pairs(self.pixels) do
      if type(self.pixels[x]) ~= 'table' 
        then return end
      for y, d in pairs(self.pixels[x]) do
        self.outputPeripheral.setCursorPos(x,y)
        for k, pxl in pairs(d) do
          pxl:out(self)
        end
      end
    end

    self.outputPeripheral.setCursorPos(1, self.height)
    
    
    return self
  end,

})


---CLASS: guiBaseElement
--[[--

--]]--
guiBaseElement = oop.inheritsFrom( nil,
{
  width = 0,
  height = 0,
  childs = {},
  positionX = 1,
  positionY = 1,
  backgroundColor = colors.black,
  foregroundColor = colors.lightGray,
  screen = nil,

  getRenderedPosition = function(self)
    local screenX, screenY 
      = self.screen.width, self.screen.height
    local x, y = 0, 0

    if type(self.width) == 'boolean' then
      self.width = self.screen.width
    end
    if type(self.height) == 'boolean' then
      self.height = self.screen.height
    end
    if type(self.positionX) == 'boolean' then
      if self.positionX then
        self.positionX = self.screen.width
      else
        self.positionX = 0
      end
    end
    if type(self.positionY) == 'boolean' then
      if self.positionY then
        self.positionY = self.screen.height
      else
        self.positionY = 0
      end
    end

    if self.width + self.positionX < screenX then
      x = self.positionX
    else
      x = screenX - self.width
    end

    if self.height + self.positionY  < screenY then
      y = self.positionY
    else
      y = screenY - self.height
    end

    if x < 0 then x = 0 end
    if y < 0 then y = 0 end

    return x, y

  end,


  setRenderOutput = function()
    

  end,

  constructRendering = function(self, screen)
    self.screen = screen
    self.positionX, self.positionY 
      = self:getRenderedPosition()
    --print('x: ',self.positionX,' | y: ',self.positionY)


    for pw=1,self.width do
      x = pw + self.positionX
    for ph=1,self.height do
      y = ph + self.positionY
      if type(self.screen.pixels[x]) ~= 'table' 
        then self.screen.pixels[x] = {} end
      if type(self.screen.pixels[x][y]) ~= 'table'
        then self.screen.pixels[x][y] = {} end
      table.insert(self.screen.pixels[x][y], Pixel:create())
    end
    end
  end,
})


---CLASS: textElement
--[[--

--]]--
textElement = oop.inheritsFrom(guiBaseElement, 
{
  textPosX = false,
  textPosY = false,
  text = '',
})



---CLASS: button
--[[--

--]]--
button = oop.inheritsFrom(textElement,{
  constructRendering = function(self, screen)
    self.screen = screen
    self.positionX, self.positionY 
      = self:getRenderedPosition()
    --print('x: ',self.positionX,' | y: ',self.positionY)

    text_len = self.text:len()
    txtIncr = 1
    for pw=1,self.width do
      x = pw + self.positionX
     if txtIncr < text_len then 
        pxl_content = 
          self.text:sub(txtIncr, txtIncr+1)
        txtIncr = txtIncr +1
     else
       pxl_content = ''
     end
    for ph=1,self.height do
      y = ph + self.positionY
      if type(self.screen.pixels[x]) ~= 'table' 
        then self.screen.pixels[x] = {} end
      if type(self.screen.pixels[x][y]) ~= 'table'
        then self.screen.pixels[x][y] = {} end

     

      pixel = Pixel:create(
      {
        character = pxl_content,
        colors = {
          front = self.foregroundColor, 
          back = self.backgroundColor
        },
      })
      table.insert(self.screen.pixels[x][y], pixel)
    end
    end
  end,
})

peripheral = peripheral.wrap("right")
--peripheral = term

init = true
refresh = false

while init or refresh do
  Screen
  :create({outputPeripheral = peripheral})
  :cleanReset()
  :setSizes()
  :addChilds({
    button_1 = button
      :create({
      text = 'Menu',
      width = 15,
      height = 1,
      positionX = 35,
      positionY = 0,
      backgroundColor = colors.blue,
      foregroundColor = colors.blue,
      }),
    button_2 = button
      :create({
      text = 'Mon Bouton 2',
      width = true,
      height = 3,
      positionX = 20,
      positionY = 10,
      backgroundColor = colors.red,
      foregroundColor = colors.white,
      }),
    button_3 = button
      :create({
      text = 'Mon Bouton',
      width = 10,
      height = 5,
      positionX = 5,
      positionY = 9,
      backgroundColor = colors.grey,
      foregroundColor = colors.lightGray,
      }),
  })
  :render()
  init = false
end

local a,b,c = os.pullEvent('key')
os.reboot()
