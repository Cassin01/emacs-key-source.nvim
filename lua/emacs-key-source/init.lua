local _local_1_ = require("emacs-key-source.kmp")
local kmp = _local_1_["kmp"]
local vf = vim.fn
local va = vim.api
local uv = vim.loop
local a = require("async")
local function concat_with(d, ...)
  return table.concat({...}, d)
end
local function rt(str)
  return va.nvim_replace_termcodes(str, true, true, true)
end
local function echo(str)
  return va.nvim_echo({{str}}, false, {})
end
local function concat_with0(d, ...)
  return table.concat({...}, d)
end
local function async_f(f)
  local function _2_(...)
    local args = {...}
    local function _3_(callback)
      _G.assert((nil ~= callback), "Missing argument callback on fnl/emacs-key-source/init.fnl:22")
      local async = nil
      local function _4_()
        if (args == nil) then
          f()
        else
          f(unpack(args))
        end
        callback()
        return async:close()
      end
      async = uv.new_async(vim.schedule_wrap(_4_))
      return async:send()
    end
    return _3_
  end
  return _2_
end
local function split_line_at_point()
  local line_text = vf.getline(vf.line("."))
  local col = vf.col(".")
  local text_after = string.sub(line_text, col)
  local text_before
  if (col > 1) then
    text_before = string.sub(line_text, 1, (col - 1))
  else
    text_before = ""
  end
  return text_before, text_after
end
local kill_line2end
local function _7_()
  local text_before, text_after = split_line_at_point()
  if (string.len(text_after) == 0) then
    return vim.cmd("normal! J")
  else
    return vf.setline(vf.line("."), text_before)
  end
end
kill_line2end = _7_
local kill_line2begging
local function _9_()
  local _, text_after = split_line_at_point()
  local indent_text = ""
  for i = 1, vf.indent(".") do
    indent_text = (indent_text .. " ")
  end
  vf.setline(vf.line("."), (indent_text .. text_after))
  return vim.cmd("normal! ^")
end
kill_line2begging = _9_
local goto_line
local function _10_()
  local cu = vim.fn.win_getid()
  local _let_11_ = vim.api.nvim_win_get_cursor(cu)
  local x = _let_11_[1]
  local y = _let_11_[2]
  local n
  local function _12_()
    echo(("Could not cast '" .. tostring(n) .. "' to number.'"))
    return x
  end
  n = math.floor((tonumber(vim.fn.input("Goto line: ")) or _12_()))
  local n0
  if (n > vim.fn.line("$")) then
    n0 = vim.fn.line("$")
  else
    n0 = n
  end
  local n1
  if (n0 < 1) then
    n1 = 1
  else
    n1 = n0
  end
  echo(tostring(vim.fn.line(__fnl_global___24)))
  return vim.api.nvim_win_set_cursor(cu, {n1, y})
end
goto_line = _10_
local function _guard_cursor_position(win)
  local function _15_(line, col)
    _G.assert((nil ~= col), "Missing argument col on fnl/emacs-key-source/init.fnl:74")
    _G.assert((nil ~= line), "Missing argument line on fnl/emacs-key-source/init.fnl:74")
    local _16_
    if (line < 1) then
      _16_ = 1
    elseif (line > vf.line("$", win)) then
      _16_ = vf.line("$", win)
    else
      _16_ = line
    end
    local function _18_()
      if (col < 0) then
        return 0
      elseif (col > vf.col("$")) then
        return vf.col("$")
      else
        return col
      end
    end
    return _16_, _18_()
  end
  return _15_
end
local relative_jump
local function _19_()
  local number_3f = "0"
  local done_3f = false
  while not done_3f do
    if vf.getchar(true) then
      local nr = vf.getchar()
      if ((nr >= 48) and (nr <= 57)) then
        number_3f = (number_3f .. vf.nr2char(nr))
      else
        done_3f = true
        local operator = vf.nr2char(nr)
        local times = tonumber(number_3f)
        local g = _guard_cursor_position(va.nvim_get_current_win())
        if (nr == 106) then
          va.nvim_win_set_cursor(0, {g((vf.line(".") + times), vf.col("."))})
        elseif (nr == 107) then
          va.nvim_win_set_cursor(0, {g((vf.line(".") - times), vf.col("."))})
        elseif (nr == 108) then
          va.nvim_win_set_cursor(0, {g(vf.line("."), (vf.col(".") + times))})
        elseif (nr == 104) then
          va.nvim_win_set_cursor(0, {g(vf.line("."), (vf.col(".") - times))})
        elseif (nr == 14) then
          va.nvim_win_set_cursor(0, {g((vf.line(".") + times), vf.col("."))})
        elseif (nr == 16) then
          va.nvim_win_set_cursor(0, {g((vf.line(".") - times), vf.col("."))})
        elseif (nr == 6) then
          va.nvim_win_set_cursor(0, {g(vf.line("."), (vf.col(".") + times))})
        elseif (nr == 2) then
          va.nvim_win_set_cursor(0, {g(vf.line("."), (vf.col(".") - times))})
        else
          echo("operator not matched")
        end
      end
    else
    end
  end
  return nil
end
relative_jump = _19_
local function _win_open(row, height, col)
  local buf = va.nvim_create_buf(false, true)
  local win = va.nvim_open_win(buf, true, {col = col, row = row, relative = "editor", anchor = "NW", style = "minimal", height = height, width = math.floor(((vim.o.columns / 2) - 2)), focusable = false, border = "rounded"})
  va.nvim_win_set_option(win, "winblend", 20)
  return buf, win
end
local function add_matches(win, group, line_num, kmp_res, width, shift)
  local wininfo = vf.getwininfo(win)
  if (#wininfo ~= 0) then
    local wininfo0 = vf.getwininfo(win)[1]
    local topline = (wininfo0).topline
    local botline = (wininfo0).botline
    if ((line_num >= topline) and (line_num <= botline)) then
      local res = {}
      for _, col in ipairs(kmp_res) do
        if (width > 0) then
          table.insert(res, vf.matchaddpos(group, {{line_num, (shift + col), width}}, 0, -1, {window = win}))
        else
        end
      end
      return res
    else
      return {}
    end
  else
    return nil
  end
end
local function fill_spaces(str, width)
  local len = vf.strdisplaywidth(str)
  if (len < width) then
    return (string.rep(" ", (width - len)) .. str)
  else
    return str
  end
end
local function update_pos(nr, pos)
  if (nr == 18) then
    return (pos[1] - 1), pos[2]
  elseif (nr == 19) then
    return (pos[1] + 1), pos[2]
  else
    return pos[1], pos[2]
  end
end
local function keys_ignored(nr)
  return ((nr == 18) or (nr == 19) or (nr == 15) or (nr == 13) or (nr == 6) or (nr == 7) or (nr == rt("<c-5>")))
end
local function gen_res(target, line)
  if (target == "") then
    return {}
  else
    local function _28_()
      if vim.o.smartcase then
        return (target == target:lower())
      else
        return true
      end
    end
    return kmp(target, line, _28_())
  end
end
local function match_exist(win, id)
  local ret = false
  do
    local list = vf.getmatches(win)
    for _, v in ipairs(list) do
      if (v.id == id) then
        ret = true
      else
      end
    end
  end
  return ret
end
local function marge(a0, b)
  if (nil == b) then
    return a0
  elseif (type(b) == "table") then
    for _, v in ipairs(b) do
      table.insert(a0, v)
    end
    return a0
  else
    table.insert(a0, b)
    return a0
  end
end
local function _hi_cpos(group, win, pos, width)
  return vf.matchaddpos(group, {{pos[1], (pos[2] + 1), width}}, 9, -1, {window = win})
end
local function del_matches(ids, win)
  if not (ids == nil) then
    for _, id in ipairs(ids) do
      vf.matchdelete(id, win)
    end
    return nil
  else
    return nil
  end
end
local function draw_summary(win, hi_w_summary, l, res, target_width, shift)
  add_matches(win, hi_w_summary, l, res, target_width, shift)
  return vf.matchaddpos("LineNr", {{l, 1, shift}}, 1, -1, {window = win})
end
local function draw_found(find_pos, c_win, win, target_width, shift, hi_w_summary)
  local id_cpos = nil
  for l, ik in ipairs(find_pos) do
    local i = ik[1]
    local res = ik[2]
    local lnums = fill_spaces(tostring(i), vf.strdisplaywidth(tostring(vf.line("$", c_win))))
    local status, result = pcall(draw_summary, win, hi_w_summary, l, res, target_width, shift)
  end
  return id_cpos
end
local task_draw
local function _33_(file_pos, c_win, win, target_width, shift, hi_w_summary)
  _G.assert((nil ~= hi_w_summary), "Missing argument hi-w-summary on fnl/emacs-key-source/init.fnl:217")
  _G.assert((nil ~= shift), "Missing argument shift on fnl/emacs-key-source/init.fnl:217")
  _G.assert((nil ~= target_width), "Missing argument target-width on fnl/emacs-key-source/init.fnl:217")
  _G.assert((nil ~= win), "Missing argument win on fnl/emacs-key-source/init.fnl:217")
  _G.assert((nil ~= c_win), "Missing argument c-win on fnl/emacs-key-source/init.fnl:217")
  _G.assert((nil ~= file_pos), "Missing argument file-pos on fnl/emacs-key-source/init.fnl:217")
  local args = {file_pos, c_win, win, target_width, shift, hi_w_summary}
  local function _34_()
    local async_draw = async_f(draw_found)
    a.wait(a.wrap(async_draw(unpack(args)))())
    return vim.cmd("redraw!")
  end
  return a.sync(_34_)
end
task_draw = _33_
local function _ender(win, buf, showmode, c_win, c_ids, preview)
  preview:del()
  va.nvim_win_close(win, true)
  va.nvim_buf_delete(buf, {force = true})
  va.nvim_set_option("showmode", showmode)
  return del_matches(c_ids, c_win)
end
local function get_first_pos(find_pos, pos)
  if (#find_pos ~= 0) then
    return {(find_pos[pos[1]])[1], (((find_pos[pos[1]])[2])[1] - 1)}
  else
    return nil
  end
end
local function guard_cursor_position(win)
  local function _36_(line, col)
    _G.assert((nil ~= col), "Missing argument col on fnl/emacs-key-source/init.fnl:239")
    _G.assert((nil ~= line), "Missing argument line on fnl/emacs-key-source/init.fnl:239")
    local l
    if (line < 1) then
      l = 1
    elseif (line > vf.line("$", win)) then
      l = vf.line("$", win)
    else
      l = line
    end
    va.nvim_win_set_cursor(win, {l, 0})
    local function _38_()
      if (col < 0) then
        return 0
      elseif (col > vf.col("$")) then
        return vf.col("$")
      else
        return col
      end
    end
    return l, _38_()
  end
  return _36_
end
local Preview
local function _39_(self, c_buf, c_win, height)
  do
    local buf, win = _win_open((vim.o.lines - height), height, math.floor((vim.o.columns / 2)))
    do end (self)["buf"] = buf
    self["win"] = win
  end
  va.nvim_buf_set_option(self.buf, "filetype", va.nvim_buf_get_option(c_buf, "filetype"))
  va.nvim_buf_set_lines(self.buf, 0, -1, true, va.nvim_buf_get_lines(c_buf, 0, vf.line("$", c_win), true))
  va.nvim_win_set_option(self.win, "scrolloff", 999)
  va.nvim_win_set_option(self.win, "foldenable", false)
  va.nvim_win_set_option(self.win, "number", true)
  return self
end
local function _40_(self, find_pos, pos, target_width, hi)
  vf.clearmatches(self.win)
  do
    local pos0 = get_first_pos(find_pos, pos)
    if not (pos0 == nil) then
      va.nvim_win_set_cursor(self.win, pos0)
      _hi_cpos(hi, self.win, pos0, target_width)
    else
    end
  end
  for _, _42_ in ipairs(find_pos) do
    local _each_43_ = _42_
    local i = _each_43_[1]
    local res = _each_43_[2]
    add_matches(self.win, "Search", i, res, target_width, 0)
  end
  return nil
end
local function _44_(self)
  va.nvim_win_close(self.win, true)
  return va.nvim_buf_delete(self.buf, {force = true})
end
Preview = {new = _39_, update = _40_, del = _44_, buf = nil, win = nil}
local Summary
local function _45_(self, c_buf, c_win, height)
  do
    local buf, win = _win_open((vim.o.lines - height), height, 0)
    do end (self)["buf"] = buf
    self["win"] = win
    va.nvim_win_set_option(win, "foldenable", false)
    va.nvim_win_set_option(win, "scrolloff", 999)
  end
  vf.win_execute(win, "set winhighlight=Normal:Comment")
  return self
end
local function _46_(self, showmode, c_win, c_ids, preview)
  return _ender(self.win, self.buf, showmode, c_win, c_ids, preview)
end
local function _47_(self, view_lines)
  return va.nvim_buf_set_lines(self.buf, 0, -1, true, view_lines)
end
Summary = {new = _45_, del = _46_, update = _47_, win = nil, buf = nil}
local inc_search
local function _48_()
  local c_buf = va.nvim_get_current_buf()
  local c_win = va.nvim_get_current_win()
  local lines = va.nvim_buf_get_lines(c_buf, 0, vf.line("$", c_win), true)
  local c_pos = va.nvim_win_get_cursor(c_win)
  local summary = Summary:new(c_buf, c_win, (vim.o.lines - 4))
  local preview = Preview:new(c_buf, c_win, (vim.o.lines - 4))
  local showmode
  do
    local showmode0 = vim.o.showmode
    if (showmode0 ~= nil) then
      showmode = showmode0
    else
      showmode = true
    end
  end
  vim.o["showmode"] = false
  local hi_c_jump = "IncSearch"
  local hi_w_summary = "Substitute"
  local pos = {0, 0}
  local done_3f = false
  local target = ""
  local id_cpos = nil
  local find_pos = {}
  local view_lines = {}
  while not done_3f do
    echo(concat_with0(", ", ("input: " .. target), ("line: " .. pos[1] .. "/" .. vf.line("$", summary.win))))
    if vf.getchar(true) then
      local nr = vf.getchar()
      vf.clearmatches(win)
      vf.clearmatches(summary.win)
      if not (id_cpos == nil) then
        del_matches(id_cpos, c_win)
        id_cpos = nil
      else
      end
      pos = {guard_cursor_position(summary.win)(update_pos(nr, pos))}
      vf.matchaddpos("PmenuSel", {{pos[1], 0}}, 0, -1, {window = summary.win})
      local shift = (vf.strdisplaywidth(vf.line("$", c_win)) + 1)
      vf.matchaddpos("CursorLineNr", {{pos[1], 1, shift}}, 2, -1, {window = summary.win})
      if keys_ignored(nr) then
        target = target
      elseif ((nr == 8) or (nr == rt("<Del>"))) then
        target = string.sub(target, 1, -2)
      else
        target = (target .. vf.nr2char(nr))
      end
      local target_width = vf.strdisplaywidth(target)
      if not keys_ignored(nr) then
        local find_pos0 = {}
        local view_lines0 = {}
        for i, line in ipairs(lines) do
          local kmp_res = gen_res(target, line)
          if (#kmp_res ~= 0) then
            table.insert(find_pos0, {i, kmp_res})
            local lnums = fill_spaces(tostring(i), vf.strdisplaywidth(tostring(vf.line("$", c_win))))
            table.insert(view_lines0, (lnums .. " " .. line))
          else
          end
        end
        find_pos, view_lines = find_pos0, view_lines0
      else
      end
      summary:update(view_lines)
      task_draw(find_pos, c_win, summary.win, target_width, shift, hi_w_summary)()
      preview:update(find_pos, pos, target_width, hi_c_jump)
      do
        local pos0 = get_first_pos(find_pos, pos)
        if not (pos0 == nil) then
          if (id_cpos == nil) then
            id_cpos = marge({}, _hi_cpos(hi_c_jump, c_win, pos0, target_width))
          else
            id_cpos = marge(id_cpos, _hi_cpos(hi_c_jump, c_win, pos0, target_width))
          end
        else
        end
      end
      if (nr == 13) then
        done_3f = true
        summary:del(showmode, c_win, id_cpos, preview)
        local pos0 = get_first_pos(find_pos, pos)
        if not (pos0 == nil) then
          va.nvim_win_set_cursor(c_win, pos0)
          va.nvim_set_current_win(c_win)
        else
        end
      else
      end
      if (nr == 27) then
        done_3f = true
        summary:del(showmode, c_win, id_cpos, preview)
        va.nvim_win_set_cursor(c_win, c_pos)
        va.nvim_set_current_win(c_win)
      else
      end
      if (nr == 6) then
        if not (#find_pos == 0) then
          local pos0 = {(find_pos[pos[1]])[1], (((find_pos[pos[1]])[2])[1] - 1)}
          if (id_cpos == nil) then
            id_cpos = marge({}, _hi_cpos(hi_c_jump, c_win, pos0, target_width))
          else
            id_cpos = marge(id_cpos, _hi_cpos(hi_c_jump, c_win, pos0, target_width))
          end
          va.nvim_win_set_cursor(c_win, pos0)
          vim.cmd("normal! zz")
          task_draw(find_pos, c_win, summary.win, target_width, shift, hi_w_summary)()
        else
        end
      else
      end
      if (nr == 15) then
        if (id_cpos == nil) then
          id_cpos = marge({}, _hi_cpos("Cursor", c_win, c_pos, target_width))
        else
          id_cpos = marge(id_cpos, _hi_cpos("Cursor", c_win, c_pos, target_width))
        end
        va.nvim_win_set_cursor(c_win, c_pos)
        vim.cmd("normal! zz")
        task_draw(find_pos, c_win, summary.win, target_width, shift, hi_w_summary)()
      else
      end
      if (nr == 7) then
        if not (#find_pos == 0) then
          local len = #find_pos
          local num = tonumber(vim.fn.input(("1 ~ " .. tostring(len) .. ": ")))
          if ((num ~= nil) and (num <= len)) then
            pos = {guard_cursor_position(summary.win)(num, pos[2])}
            va.nvim_win_set_cursor(summary.win, pos)
            vf.clearmatches(summary.win)
            vf.matchaddpos("CursorLineNr", {{pos[1], 1, shift}}, 2, -1, {window = summary.win})
            vf.matchaddpos("PmenuSel", {{pos[1], 0}}, 0, -1, {window = summary.win})
            preview:update(find_pos, pos, target_width, hi_c_jump)
            task_draw(find_pos, c_win, summary.win, target_width, shift, hi_w_summary)()
          else
          end
        else
        end
      else
      end
      if (nr == rt("<c-5>")) then
        done_3f = true
        local alt = vim.fn.input(("Query replace " .. target .. " with: "))
        summary:del(showmode, c_win, id_cpos, preview)
        if ((#alt ~= 0) and (va.nvim_get_current_buf() == c_buf)) then
          local function _replace_escape_char(str)
            return str:gsub("/", "\\/")
          end
          vim.cmd(("%s/" .. _replace_escape_char(target) .. "/" .. _replace_escape_char(alt) .. "/g"))
          print("replaced ", target, " with ", alt)
        else
          print("Err: the replacement failed")
        end
        va.nvim_win_set_cursor(c_win, c_pos)
        va.nvim_set_current_win(c_win)
      else
      end
      vim.cmd("redraw!")
      if not done_3f then
        vim.fn.win_execute(summary.win, "redraw!")
      else
      end
    else
    end
  end
  return nil
end
inc_search = _48_
return {["goto-line"] = goto_line, ["relative-jump"] = relative_jump, ["inc-search"] = inc_search, ["kill-line2end"] = kill_line2end, kill_line2begging = kill_line2begging}
