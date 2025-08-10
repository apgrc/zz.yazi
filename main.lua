---@class (exact) Context
---@field window_size integer
---@field file_count integer
---@field cursor integer
---@field offset integer
---@field scrolloff integer

---@class (exact) JumpData
---@field position integer
---@field target integer
---@field jump integer
---@field step integer

---@class (exact) zz
---@field sleep_time integer
---@field get_scrolloff fun():integer
---@field get_context fun(): Context
---@field get_jump_center fun(context: Context): JumpData
---@field get_jump_top fun(context: Context): JumpData
---@field get_jump_bottom fun(context: Context): JumpData
---@field validate_jump_data fun(context: Context, jump_data: JumpData): JumpData
---@field jump fun(jump_data: JumpData)
---@field go_center fun()
---@field go_top fun()
---@field go_bottom fun()
local zz = {}

zz.sleep_time = 0.001

function zz.get_scrolloff()
  return rt.mgr.scrolloff
end

zz.get_context = ya.sync(function()
  ---@type Context
  return {
    window_size = #(cx.active.current.window),
    file_count = #(cx.active.current.files),
    cursor = cx.active.current.cursor + 1,
    offset = cx.active.current.offset,
    scrolloff = zz.get_scrolloff()
  }
end)

---@param context Context
---@return JumpData
function zz.get_jump_center(context)
  local target = math.floor(context.window_size / 2 + (context.window_size % 2))
  local position = context.cursor - context.offset
  local jump_data = {
    position = position,
    target = target,
    jump = math.floor(context.window_size / 2) - context.scrolloff,
    step = 1,
  }

  jump_data = zz.validate_jump_data(context, jump_data)
  return jump_data
end

function zz.get_jump_top(context)
  local target = context.scrolloff + 1
  local position = context.cursor - context.offset
  local jump_data = {
    position = position,
    target = target,
    jump = context.window_size - context.scrolloff,
    step = 1,
  }

  jump_data = zz.validate_jump_data(context, jump_data)
  return jump_data
end

function zz.get_jump_bottom(context)
  local target = context.window_size - context.scrolloff
  local position = context.cursor - context.offset
  local jump_data = {
    position = position,
    target = target,
    jump = context.window_size - context.scrolloff,
    step = 1,
  }

  jump_data = zz.validate_jump_data(context, jump_data)
  return jump_data
end

function zz.validate_jump_data(context, jump_data)
  if jump_data.position < jump_data.target then
    jump_data.step = -1
    -- offset for window with even line count and when scrolling view up
    jump_data.jump = jump_data.jump - 1 + (context.window_size % 2)
  end

  if jump_data.position == jump_data.target then
    jump_data.jump = 0
  end

  -- is there enough space to jump down?
  if jump_data.position > jump_data.target and jump_data.jump > (context.file_count - context.cursor) then
    jump_data.jump = 0
  end

  -- is there enough space to jump up?
  if jump_data.position < jump_data.target and jump_data.jump > context.offset then
    jump_data.jump = 0
  end

  return jump_data
end

--@return nil
function zz.jump(jump_data)
  -- for some reason making the jump step by step is
  -- more consistent than making the complete jump
  for _ = 1, jump_data.jump do
    ya.manager_emit("arrow", { jump_data.step })
    ya.sleep(zz.sleep_time)
  end

  for _ = 1, jump_data.jump do
    ya.manager_emit("arrow", { -jump_data.step })
    ya.sleep(zz.sleep_time)
  end
end

function zz.go_center()
  local context = zz.get_context()
  ya.dbg(context)
  local jump_data = zz.get_jump_center(context)
  ya.dbg(jump_data)
  zz.jump(jump_data)
end

function zz.go_top()
  local context = zz.get_context()
  ya.dbg(context)
  local jump_data = zz.get_jump_top(context)
  ya.dbg(jump_data)
  zz.jump(jump_data)
end

function zz.go_bottom()
  local context = zz.get_context()
  ya.dbg(context)
  local jump_data = zz.get_jump_bottom(context)
  ya.dbg(jump_data)
  zz.jump(jump_data)
end

return {
  entry = function(_, job)
    local action = job.args[1]
    if not action then
      return
    end

    if action == "center" then
      zz:go_center()
      return
    end

    if action == "top" then
      zz:go_top()
      return
    end

    if action == "bottom" then
      zz:go_bottom()
      return
    end
  end,
  -- for testing
  module = zz,
}
