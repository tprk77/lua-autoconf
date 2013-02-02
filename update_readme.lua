#!/usr/bin/lua5.1

local fin = assert(io.open('ax_lua.m4', 'r'))
local fout = assert(io.open('README', 'w'))

for line in fin:lines() do
  if string.match(line, '^#%s?') then
    line = string.gsub(line, '^#%s?', '')
    fout:write(line .. '\n')
    print(line)
  else
    break
  end
end

fin:close()
fout:close()
