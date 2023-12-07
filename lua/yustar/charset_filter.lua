local function read_charset() return require('yustar/charset') end

local function init(env) env.charsets = read_charset() end

local function get_charset_option(env)
    return env.engine.context:get_option('charset_filter')
end

local function get_charset(env, option)
    if option then return env.charsets end
    return nil
end

local function is_in_charset(char, charset) return charset[char] end

local function filter_charset(string, charset)
    if not charset then return true end
    for index, code in utf8.codes(string) do
        if not is_in_charset(utf8.char(code), charset) then return false end
    end
    return true
end

local function charset_filter(input, env)
    local charset_option = get_charset_option(env)
    local charset = get_charset(env, charset_option)
    for cand in input:iter() do
        local cand_gen = cand:get_genuine()
        if filter_charset(cand_gen.text, charset) then
            yield(cand)
        end
    end
end

return { init = init, func = charset_filter }
