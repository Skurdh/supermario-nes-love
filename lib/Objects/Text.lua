local Object = require('lib.Object')
local Text = Object:extend('Text')

function Text:new(x, y, str, indent)
    self.super.new(self, x, y, 1, 1, nil, nil, 0, 0, 'none', {}, 4)

    self.x, self.y = x, y
    self.text = tostring(str):gsub('\\n', '\n')

    self.indent = indent or 0
end

function Text:update(dt)
end

function Text:render()
    love.graphics.print(self.text, self.x + self.indent, self.y)
end

return Text