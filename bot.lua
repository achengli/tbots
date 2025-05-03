local bot = require'api'

if not bot.api_key then
  error('TBOT_API venv not defined')
end

local api = require'telegram-bot-lua.core'.configure(bot.api_key)

local function dump_table(t,f,s, lvl)
  s = s or ''; f = f or io.stdout
  lvl = lvl or 1

  local pwrite = (function()
    if f then return function(str)
        f:write(str)
      end
    else return function(str)
        print(str)
      end
    end
  end)()

  pwrite '{\n'

  for k, e in pairs(t) do
    pwrite(string.format(s .. '[%s] = %s\n',
                        k, (e and (type(e) ~= 'table')) or '{'))
    if type(e) == 'table' then
      if lvl >= 0 then dump_table(t, f, s .. ' ', lvl-1)
      else pwrite('{...}\n')
      end
    end
  end

  pwrite'{'
end

local function tprint(t, s)
  s = s or ''
  for k,e in pairs(t) do
    print(string.format('%s-> [%s] = %s', s, k, (e and (type(e) ~= 'table')) or '{'))
    if type(e) == 'table' then tprint(e, s .. ' ')
    end
  end
end

function api.on_message(message)
  if message.text and message.text:match('ping') then
    if message.message_thread_id then
      api.send_message(
        message.chat.id,
        'pong',
        message.message_thread_id)
    else
      api.send_message(message.chat.id, 'pong')
    end
  else
    local f = io.open('dump.log', 'w')
    if not f then error('Dump file error') end

    tprint(message)
    f:close()
  end
  print(string.format('Message %d processed', message.message_id))
end

api.run()
