-- postpone_fullcode.lua
-- 出现重码时，将全码匹配且有简码的「单字」「适当」后置。
-- 目前的实现方式，原理适用于所有使用规则简码的形码方案。
local radstr = '\z
一丁七三上下丌不丑且世丨丬丰丶丿乃之乙乜九也\z
了予二亍亠亡亥亦人亻兀入八其冂冖冫几凵刀刂力\z
勹匕匚十千卅卜卩卯厂厶又口古合向囗土士壬夂夕\z
大夫夭女子宀寸小尚尢尤尸屮山巛川工己已巳巴巾\z
干幺广廴廾弋弓彐彡彳心忄戈戊户手扌攵文斤方日\z
早曰月木未末欠止殳母毛水氵火灬爪爿片牙牛犬犭\z
王瓜瓦生用甫田由甲申疒白皮皿目矢石示礻禺禾穴\z
立竹米糸缶羊而耳肀臣自至臼舌舟艮艹虍虎虫衤西\z
言豕豸走足身辛辰辶酉里金阝隹雨非面革食骨高髟\z
鬼鹿麻黑丂丄丅乀乂乛亅來僉冊卌咼壴戶烏爫牜糹\z
罒見訁貝車釒長門韋風飛飠馬鬥魚鳥鹵黽齒龵𠂉𡗗\z
𥫗㐄𠄏〇'

local function init(env)
    local config = env.engine.schema.config
    local code_rvdb = config:get_string('lua_reverse_db/code')
    env.code_rvdb = ReverseDb('build/' .. code_rvdb .. '.reverse.bin')
    env.delimiter = config:get_string('speller/delimiter')
    env.max_index = config:get_int('postpone_fullcode/lua/max_index') or 4
end

local function get_short(codestr)
    local s = ' ' .. codestr
    for code in s:gmatch('%l+') do
        if s:find(' ' .. code .. '%l+') then return code end
    end
end

local function has_short_and_is_full(cand, env)
    -- completion 和 sentence 类型不属于精确匹配，但要通过 cand:get_genuine() 判
    -- 断，因为 simplifier 会覆盖类型为 simplified。先行判断 type 并非必要，只是
    -- 为了轻微的性能优势。
    local cand_gen = cand:get_genuine()
    if cand_gen.type == 'completion' or cand_gen.type == 'sentence' then
        return false, true
    end
    local input = env.engine.context.input
    local cand_input = input:sub(cand.start + 1, cand._end)
    -- 去掉可能含有的 delimiter。
    cand_input = cand_input:gsub('[' .. env.delimiter .. ']', '')
    -- 字根可能设置了特殊扩展码，不视作全码，不予后置。
    if cand_input:len() > 2 and radstr:find(cand_gen.text, 1, true) then
        return
    end

    local codestr = env.code_rvdb:lookup(cand_gen.text)
    local is_comp = not string.find(' ' .. codestr .. ' ',
                                    ' ' .. cand_input .. ' ', 1, true)
    local short = not is_comp and get_short(codestr)

    -- 注意排除有简码但是输入的是不规则编码的情况
    return short and cand_input:find('^' .. short .. '%l+'), is_comp
end

local function filter(input, env)
    local context = env.engine.context
    if not context:get_option("postpone_fullcode") then
        for cand in input:iter() do yield(cand) end
    else
        -- 具体实现不是后置目标候选，而是前置非目标候选
        local dropped_cands = {}
        local done_drop
        local pos = 1
        -- Todo: 计算 pos 时考虑可能存在的重复候选被 uniquifier 合并的情况。
        for cand in input:iter() do
            if done_drop then
                yield(cand)
            else
                -- 后置不越过 env.max_index 和以下几类候选：
                -- 1) 顶功方案使用 script_translator 导致的匹配部分输入的候选，例如输入
                -- otu 且光标在 u 后时会出现编码为 ot 的候选。不过通过填满码表的三码和
                -- 四码的位置，能消除这类候选。2) 顶功方案的造词翻译器允许出现的
                -- completion 类型候选。3) 顶功方案的补空候选——全角空格（ U+3000）。
                local is_bad_script_cand = cand._end < context.caret_pos
                local drop, is_comp = has_short_and_is_full(cand, env)
                if pos >= env.max_index or is_bad_script_cand or is_comp or
                    cand.text == '　' then
                    for i, cand in ipairs(dropped_cands) do
                        yield(cand)
                    end
                    done_drop = true
                    yield(cand)
                    -- 精确匹配的词组不予后置
                elseif not drop or utf8.len(cand.text) > 1 then
                    yield(cand)
                    pos = pos + 1
                else
                    table.insert(dropped_cands, cand)
                end
            end
        end
        for i, cand in ipairs(dropped_cands) do yield(cand) end
    end
end

return {init = init, func = filter}
