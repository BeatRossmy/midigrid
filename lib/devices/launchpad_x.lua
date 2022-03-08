local launchpad = include('midigrid/lib/devices/launchpad_rgb')

--Put the device into programmers mode
-- launchpad.init_device_msg = { 0xf0,0x0,0x20,0x29,0x02,0x0D,0x00,0x7F,0xf7 }
launchpad.init_device_msg = { 0xF0,0x0,0x20,0x29,0x02,0x0C,0x00,0x7F,0xF7 }

launchpad.aux.col = {
  {'cc', 89, 0},
  {'cc', 79, 0},
  {'cc', 69, 0},
  {'cc', 59, 0},
  {'cc', 49, 0},
  {'cc', 39, 0},
  {'cc', 29, 0},
  {'cc', 19, 0}
}

launchpad.aux.row = {
  {'cc', 91, 0},
  {'cc', 92, 0},
  {'cc', 93, 0},
  {'cc', 94, 0},
  {'cc', 95, 0},
  {'cc', 96, 0},
  {'cc', 97, 0},
  {'cc', 98, 0}
}

local each_with = function (self,device,callback)
  local msg = {0xF0,0x00,0x20,0x29,0x02,0x0C,0x03}
  for x = 1,self.width do
    for y = 1,self.height do
      local m = device:get_led(x,y,self.buffer[x][y])
      for _,b in pairs(m) do table.insert(msg,b) end
    end
  end
  table.insert(msg, 0xF7)
  if midi.devices[device.midi_id] then midi.devices[device.midi_id]:send(msg) end
end

local updates_with = function (self,device,callback)
  if self.frozen_update and self.frozen_update.update_count > 0 then
    local msg = {0xF0,0x00,0x20,0x29,0x02,0x0C,0x03}
    for u = 1,self.frozen_update.update_count do
      local x = self.frozen_update.updates_x[u]
      local y = self.frozen_update.updates_y[u]
      -- callback(device,x,y,self.buffer[x][y])
      local m = device:get_led(x,y,self.buffer[x][y])
      for _,b in pairs(m) do table.insert(msg,b) end
    end
    table.insert(msg, 0xF7)
    if midi.devices[device.midi_id] then midi.devices[device.midi_id]:send(msg) end
  end
end

launchpad.refresh = function (self,quad)
  if quad.id == self.current_quad then
    if self.refresh_counter > 9 then
      self.force_full_refresh = true
      self.refresh_counter = 0
    end
    if self.force_full_refresh then
      --quad.each_with(quad,self,self._update_led)
      each_with(quad,self,self._update_led)
      self.force_full_refresh = false
    else
      --quad.updates_with(quad,self,self._update_led)
      updates_with(quad,self,self._update_led)
      self.refresh_counter=self.refresh_counter+1
    end
  end
  self:update_aux()
end

launchpad.get_l
