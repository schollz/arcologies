_arc = {}
_arc.device = arc.connect()

function _arc.init()
  _arc.orientation = 0
  _arc.bindings = {}
  _arc.encs = {{},{},{},{}}

  -- each also needs to be setup in config.arc_bindings to make available to paramters.lua!
  _arc:register_all_available_bindings()

  -- bind each encoder to what the user has specified
  for n = 1, 4 do 
    _arc:bind(n, config.arc_bindings[params:get("arc_encoder_" .. n)].id)
  end

  -- -- dev
  -- _arc:bind(3, config.arc_bindings[params:get("arc_encoder_3")].id)
  -- _arc:bind(4, config.arc_bindings[params:get("arc_encoder_2")].id)

  fn.dirty_arc(true)
end



-- bindings



function _arc:register_all_available_bindings()
  _arc:register_binding({
    binding_id = "norns_e1",
    value_getter = function() return page.active_page end,
    value_setter = function(x) page:select(x) end,
    min_getter = function() return 1 end,
    max_getter = function() return page:get_page_count() end
  })
  _arc:register_binding({
    binding_id = "norns_e2",
    value_getter = function() return menu:get_selected_item() end,
    value_setter = function(x) menu:select_item(x) end,
    min_getter = function() return 1 end, -- todo make 0 work
    max_getter = function() return menu:get_item_count() end
  })
  _arc:register_binding({
    binding_id = "norns_e3",
    value_getter = function() return menu:adaptor("value_getter") end,
    value_setter = function(x) menu:adaptor("value_setter", x) end,
    min_getter = function() return menu:adaptor("min") end,
    max_getter = function() return menu:adaptor("max") end,
    sensitivity_getter = function() return menu:adaptor("sensitivity") end
  })
  -- _arc:register_binding({
  --   binding_id = "todo_browse_cells",
  --   value_getter = function() return print("browse cells todo") end,
  --   value_setter = function(x) print("BROWSE CELLS TODO", x) end,
  --   min_getter = function() return print("browse cells todo") end,
  --   max_getter = function() return print("browse cells todo") end
  -- })
  -- _arc:register_binding({
  --   binding_id = "todo_crypt_directory",
  --   value_getter = function() return print("crypt directory todo") end,
  --   value_setter = function(x) print("CRYPT DIRECTORY TODO", x) end,
  --   min_getter = function() return print("crypt directory todo") end,
  --   max_getter = function() return print("crypt directory todo") end
  -- })
  -- _arc:register_binding({
  --   binding_id = "todo_danger_zone_clock_sync",
  --   value_getter = function() return print("danger zone clock sync todo") end,
  --   value_setter = function(x) print("DANGER ZONE CLOCK SYNC TODO", x) end,
  --   min_getter = function() return print("danger zone clock sync todo") end,
  --   max_getter = function() return print("danger zone clock sync todo") end
  -- })
  -- _arc:register_binding({
  --   binding_id = "todo_bpm",
  --   value_getter = function() return print("bpm todo") end,
  --   value_setter = function(x) print("BPM TODO", x) end,
  --   min_getter = function() return print("bpm todo") end,
  --   max_getter = function() return print("bpm todo") end
  -- })
  -- _arc:register_binding({
  --   binding_id = "todo_transpose",
  --   value_getter = function() return print("transpose todo") end,
  --   value_setter = function(x) print("TRANSPOSE TODO", x) end,
  --   min_getter = function() return print("transpose todo") end,
  --   max_getter = function() return print("transpose todo") end
  -- })
end


function _arc:bind(n, binding_id)
  if init_done ~= true then return end -- the rest of arcologies needs to load before _arc.lua
  if binding_id == "norns_e1" then
    self:init_enc({
      enc_id =       n,
      binding_id =   binding_id,
      value =        1,
      min =          self.bindings[binding_id].min_getter, 
      max =          self.bindings[binding_id].max_getter, 
      value_getter = self.bindings[binding_id].value_getter, 
      value_setter = self.bindings[binding_id].value_setter, 
      min_getter =   self.bindings[binding_id].min_getter, 
      max_getter =   self.bindings[binding_id].max_getter, 
      sensitivity =  function() return .01 end, 
      wrap =         false,
      style =        "divided", 
      style_method = function(x) return self:get_divided_ring_segment(x) end,
      style_args = {
        max =     240, 
        offset =  240,
        divisor = self.bindings[binding_id].max_getter,
        snap =    true
      }
    })
  elseif binding_id == "norns_e2" then
    self:init_enc({
      enc_id =       n,
      binding_id =   binding_id,
      value =        1,
      min =          self.bindings[binding_id].min_getter, 
      max =          self.bindings[binding_id].max_getter, 
      value_getter = self.bindings[binding_id].value_getter, 
      value_setter = self.bindings[binding_id].value_setter, 
      min_getter =   self.bindings[binding_id].min_getter, 
      max_getter =   self.bindings[binding_id].max_getter,
      sensitivity =  function() return .05 end, 
      wrap =         false,
      style =        "divided",
      style_method = function(x) return self:get_divided_ring_segment(x) end,
      style_args = {
        max =     240, 
        offset =  240,
        divisor = self.bindings[binding_id].max_getter,
        snap =    true
      }
    })
  elseif binding_id == "norns_e3" then
    self:init_enc({
      enc_id =       n,
      binding_id =   binding_id,
      value =        0,
      min =          self.bindings[binding_id].min_getter, 
      max =          self.bindings[binding_id].max_getter, 
      value_getter = self.bindings[binding_id].value_getter, 
      value_setter = self.bindings[binding_id].value_setter, 
      min_getter =   self.bindings[binding_id].min_getter, 
      max_getter =   self.bindings[binding_id].max_getter, 
      sensitivity =  self.bindings[binding_id].sensitivity_getter, 
      wrap =         false,
      style =        "variable",
      style_method = function(x) return end,
      style_args = {
        max =     360, 
        offset =  0,
        divisor = self.bindings[binding_id].max_getter,
        snap =    false
      }
    })
  end
  fn.dirty_arc(true)
end


-- initialize an encoder to a specific binding
function _arc:init_enc(args)
  self.encs[args.enc_id] = {
    enc_id =         args.enc_id,
    binding_id =     args.binding_id,
    value =          args.value,
    min =            args.min,
    max =            args.max,
    value_getter =   args.value_getter,
    value_setter =   args.value_setter,
    min_getter =     args.min_getter,
    max_getter =     args.max_getter,
    sensitivity =    args.sensitivity,
    wrap =           args.wrap,
    style =          args.style,
    style_method =   args.style_method,
    style_args =     args.style_args,
    takeover =       false,
    takeover_clock = nil
  }
end

-- make available a binding
function _arc:register_binding(args)
  self.bindings[args.binding_id] = {
    binding_id = args.binding_id,
    value_getter = args.value_getter,
    value_setter = args.value_setter,
    min_getter = args.min_getter,
    max_getter = args.max_getter,
    sensitivity_getter = args.sensitivity_getter
  }
end



-- arc redefined: _arc ~= arc !!



function arc.delta(n, delta)
  -- this only works after the rest of arcologies loads
  if not init_done then return end

  -- which enc are we operating on
  local this_enc = _arc.encs[n]

  -- end the clock for this encoder
  if this_enc.takeover_clock ~= nil then
    this_enc.takeover = false
    clock.cancel(this_enc.takeover_clock)
    this_enc.takeover_clock = nil
  end

  -- run the deltas
  _arc:run_delta(this_enc, delta)

  -- duplicate bindings are possible
  _arc:refresh_duplicate_bindings(this_enc)

  -- things done changed
  fn.dirty_arc(true)
  screen.ping()

  -- start the clock for this encoder
    if this_enc.takeover_clock == nil then
      _arc.encs[n].takeover = true
      this_enc.takeover_clock = clock.run(_arc.enc_wait, n)
    end
end




-- _arc proper !!



function _arc.enc_wait(n)
  clock.sleep(.1)
  _arc.encs[n].takeover = false
end

function _arc.arc_redraw_clock()
  while true do
    if fn.dirty_arc() then
      _arc:refresh_values()
      _arc:arc_redraw()
      _arc.device:refresh()
      fn.dirty_arc(false)
    end
    clock.sleep(1/30)
  end
end

function _arc:refresh_values()
  for n = 1, 3 do
    if not _arc.encs[n].takeover then
      _arc.encs[n].value = _arc.encs[n].value_getter()
    end
  end
end

function _arc:arc_redraw()
  for n = 1, 4 do
    _arc:draw(self.encs[n])
  end
end

function _arc:draw(enc)
  if enc.style == "divided" then
    self:draw_segment(enc)
  elseif enc.style == "scaled" then
    self:draw_segment(enc)
  elseif enc.style == "variable" and enc.binding_id == "norns_e3" then
    if menu:adaptor("style") == "sweet_sixteen_centipede" then
      self:draw_sweet_sixteen_centipede(enc.enc_id, menu:adaptor("value_getter"), 33)
    elseif menu:adaptor("style") == "variable_segment" then
      self:draw_variable_segment(enc.enc_id, menu:adaptor("value_getter"), menu:adaptor("max"), 33)
    end
  end
end


function _arc:draw_sweet_sixteen_centipede(n, value, offset)
  self:clear_ring(n)
  for i = 1, value do
    local from =  fn.round(fn.over_cycle(offset + (4 * (i - 1)), 1, 64))
    local to = fn.round(from + 3)
    for x = from, to do
      local l = x == to and 3 or math.random(10, 15)
      _arc.device:led(n, x, l)
    end
  end
end

function _arc:draw_variable_segment(n, value, total_chunks, offset)
  self:clear_ring(n)
  local segment_size = 64 / total_chunks
  local segments = {}
  for i = 1, value do    
    local from = fn.round(fn.over_cycle(offset + (segment_size * (i - 1)), 1, 64))
    local to = fn.round(from + segment_size)
    for x = from, to do
      _arc.device:led(n, x, math.random(10, 15))
    end
  end
end


function _arc:clear_ring(n)
  for i = 1, 64 do
    _arc.device:led(n, i, 0)
  end
end

function _arc:draw_segment(enc)
  local segment = enc.style_method(enc)
  if segment.valid then
    _arc.device:segment(enc.enc_id, segment.from, segment.to, 15)
  end
end

--[[
  if, for whatever reason, a user wants to bind the same value to multiple
  encoders we need to manually update these as the takeovers will
  prevent their values from being updated
]]
function _arc:refresh_duplicate_bindings(enc)
  local duplicates = {}
  for n = 1, 4 do
    duplicates[n] = self.encs[n].binding_id == enc.binding_id and n ~= enc.enc_id
    for k, v in pairs(duplicates) do
      if v then
        _arc.encs[k].value = _arc.encs[n].value
      end
    end
  end
end 

-- for chunks
function _arc:get_divided_ring_segment(enc)
  local segment_size = enc.style_args.max / enc.style_args.divisor()
  local segments = {}
  for i = 1, enc.style_args.divisor() do
    local from_raw = enc.style_args.offset + (segment_size * (i - 1))
    local from = self:cycle_degrees(from_raw)
    local to =  self:cycle_degrees(from_raw + segment_size)
    segments[i] = {}
    segments[i].from = self:degs_to_rads(from, enc.style_args.snap)
    segments[i].to = self:degs_to_rads(to, enc.style_args.snap)
  end
  return self:validate_segment(segments[self:map_to_segment(enc)])
end

-- for creating a linear scale
function _arc:get_scaled_ring_segment(enc)
  local max = (enc.style_args.max == 360) and 359.9 or enc.style_args.max -- compensate for circles, 0 == 360, etc.
  local from = enc.style_args.offset
  local to = self:cycle_degrees(util.linlin(0, 360, 0, enc.style_args.max, self:scale_to_degrees(enc)) + enc.style_args.offset)
  local segments = {}
  segments.from = self:degs_to_rads(from, enc.style_args.snap)
  segments.to = self:degs_to_rads(to, enc.style_args.snap)
  return self:validate_segment(segments)
end

-- guard against race conditions
function _arc:validate_segment(segment)
  if segment ~= nil and segment.from ~= nil and segment.to ~= nil then
    segment.valid = true
    return segment
  else
    return { valid = false }
  end
end

function _arc:map_to_segment(enc)
  local segment_size = 360 / enc.style_args.divisor()
  local test = util.linlin(enc.min(), enc.max(), 0, 360, enc.value)
  if enc.value == 0 and enc.min() == 0 then
    return 0
  elseif test == 360 then -- compensate for circles, 0 == 360, etc.
    return enc.style_args.divisor()
  else
    local match = 1
    for i = 1, enc.style_args.divisor() do
        if (test >= segment_size * (i - 1)) and (test < segment_size * i) then
        match = i
      end
    end
    return match
  end
end

function _arc:run_delta(enc, delta)
  local value = 0
  if enc.style == "variable" then
    value = enc.value + (enc.sensitivity() * delta)
    self.encs[enc.enc_id].value = util.clamp(value, enc.min(), enc.max())
    enc.value_setter(_arc:map_to_segment(enc))
  else
    if enc.wrap then
      value = fn.cycle(enc.value + (enc.sensitivity() * delta), enc.min(), enc.max())
    else
      value = enc.value + (enc.sensitivity() * delta)
    end
    self.encs[enc.enc_id].value = util.clamp(value, enc.min(), enc.max())
    -- actually update the value
    enc.value_setter(_arc:map_to_segment(enc))
  end
end

-- todo
function _arc:set_orientation(i)
  self.orietnation = i
end

function _arc:scale_to_radians(enc)
  return self:degs_to_rads(self:scale_to_degrees(enc), false)
end

function _arc:scale_to_degrees(enc)
  return util.linlin(enc.min(), enc.max(), 0, 360, enc.value)
end

function _arc:degs_to_rads(d, snap)
    if snap then
      d = self:snap_degrees_to_leds(d)
    end
    return d * (3.14 / 180)
end

-- to stop arc anti-aliasing
function _arc:snap_degrees_to_leds(d)
  return util.linlin(0, 64, 0, 360, math.ceil(util.linlin(0, 360, 0, 64, d)))
end

function _arc:cycle_degrees(d)
  if d > 360 then
    return self:cycle_degrees(d - 360)
  elseif d < 0 then
    return self:cycle_degrees(360 - d)
  else
    return d
  end
end

return _arc