local Keyboard = {}

Keyboard.key_state = {}

-- Hook love keyboard events
function Keyboard.hookevents()
    function love.keypressed(key)
        Keyboard.key_state[key] = true
    end

    function love.keyreleased(key)
        Keyboard.key_state[key] = false
    end
end

-- Return key when is pressed
function Keyboard.press(key)
    return Keyboard.key_state[key]
end

-- Return Key when is released
function Keyboard.release(key)
    return Keyboard.key_state[key] == false
end

-- Return key is down or not
function Keyboard.down(key)
    return love.keyboard.isDown(key)
end

-- Reset key state
function Keyboard.update(dt)
    for k, _ in pairs(Keyboard.key_state) do
        Keyboard.key_state[k] = nil
    end
end


return Keyboard