local function _dump(o, depth)
  if (type(o) == "table") then
    local s = {"{\n"}
    for k, v in pairs(o) do
      table.insert(s, (depth .. "  [" .. tostring(k) .. "] = " .. _dump(v, (depth .. "  ")) .. ",\n"))
    end
    table.insert(s, (depth .. "} "))
    return table.concat(s, "")
  else
    return tostring(o)
  end
end
local function dump(o)
  return print(_dump(o, ""))
end
local function _escaper(str)
  if (str == "\\") then
    return "\\\\"
  else
    return str
  end
end
local function _vim_eq(pat, txt, ignorecase)
  local function _3_()
    if ignorecase then
      return "\" == \""
    else
      return "\" ==# \""
    end
  end
  return (1 == vim.api.nvim_eval(("\"" .. _escaper(pat) .. _3_() .. _escaper(txt) .. "\"")))
end
local function kmp_list(pat, m)
  local lps = {1}
  local i = 2
  local len = 1
  while (i <= m) do
    if (pat[i] == pat[len]) then
      len = (len + 1)
      do end (lps)[i] = len
      i = (i + 1)
    else
      if (len ~= 1) then
        len = lps[(len - 1)]
      else
        lps[i] = 1
        i = (i + 1)
      end
    end
  end
  return lps
end
local function kmp_search(pat, txt, m, n, lps, ignorecase)
  local j = 1
  local i = 1
  local res = {}
  while (i <= n) do
    if _vim_eq(pat[j], txt[i], ignorecase) then
      i = (i + 1)
      j = (j + 1)
    else
    end
    if (j == (m + 1)) then
      table.insert(res, (i - m))
      j = lps[(j - 1)]
    elseif ((i <= n) and not _vim_eq(pat[j], txt[i], ignorecase)) then
      if (j ~= 1) then
        j = lps[(j - 1)]
      else
        i = (i + 1)
      end
    else
    end
  end
  return res
end
local function str2list(str)
  local list = {}
  local len = 0
  for i = 1, string.len(str) do
    len = (len + 1)
    do end (list)[i] = string.sub(str, i, i)
  end
  return list, len
end
local function kmp(pattern, text, ignorecase)
  local pat, m = str2list(pattern)
  local txt, n = str2list(text)
  return kmp_search(pat, txt, m, n, kmp_list(pat, m), ignorecase)
end
return {kmp = kmp}
