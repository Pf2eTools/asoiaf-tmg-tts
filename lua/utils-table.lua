local TableUtils = {}

function TableUtils.keys(tbl)
    local keys = {}
    local n = 0

    for k, v in pairs(tbl) do
        n = n + 1
        keys[n] = k
    end
    return keys
end

function TableUtils.sortedKeys(tbl, sortFunc)
    local keys = TableUtils.keys(tbl)
    if sortFunc == nil then
        sortFunc = function(a,b)
            return a < b
        end
    end
    return table.sort(keys, function (a, b)
        return sortFunc(tbl[a], tbl[b])
    end)
end

function TableUtils.last(tbl)
    return tbl[#tbl]
end

function TableUtils.values(tbl)
    local vals = {}
    local n = 0

    for k, v in pairs(tbl) do
        n = n + 1
        vals[n] = v
    end
    return vals
end

function TableUtils.hasValue(tbl, val)
    for k, value in pairs(tbl) do
        if value == val then
            return true
        end
    end

    return false
end

function TableUtils.any(tbl)
    for i, element in ipairs(tbl) do
        return true
    end
    return false
end

function TableUtils.all(tbl, func)
    for i, element in pairs(tbl) do
        if not func(element) then
            return false
        end
    end
    return true
end

function TableUtils.some(tbl, func)
    for i, element in pairs(tbl) do
        if func(element) then
            return true
        end
    end
    return false
end

function TableUtils.len(tbl)
    local count = 0
    for i, element in pairs(tbl) do
        count = count + 1
    end
    return count
end

function TableUtils.count(tbl, func)
    local count = 0
    for i, element in pairs(tbl) do
        if func(element, i) then
            count = count + 1
        end
    end
    return count
end

function TableUtils.getKeyByVal(tbl, val)
    for k, v in pairs(tbl) do
        if v == val then
            return k
        end
    end

    return nil
end

function TableUtils.getIdx(tbl, val)
    for idx, v in ipairs(tbl) do
        if v == val then
            return idx
        end
    end

    return 0
end

function TableUtils.filter(tbl, func)
    local out = {}
    for k, v in pairs(tbl) do
        if func(v, k) then
            table.insert(out, v)
        end
    end
    return out
end

function TableUtils.filterMap(tbl, filter)
    local out = {}
    for k, v in pairs(tbl) do
        if filter(v, k) then
            out[k] = v
        end
    end
    return out
end

function TableUtils.map(table, func)
    local out = {}
    for k, v in pairs(table) do
        out[k] = func(v, k)
    end
    return out
end

function TableUtils.find(table, func)
    for k, v in pairs(table) do
        if func(v) then return v end
    end
    return nil
end

function TableUtils.findIndex(table, func)
    for k, v in pairs(table) do
        if func(v) then return k end
    end
    return nil
end

function TableUtils.reduce(table, func, opts)
    opts = opts or {}
    local acc = opts.acc or 0
    for _, v in pairs(table) do
        acc = func(acc, v)
    end
    return acc
end

function TableUtils.shuffle(tbl)
    for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end

    return tbl
end

function TableUtils.reverse(table)
    local out = {}
    for ix = #table, 1, -1 do
        table.insert(out, table[ix])
    end
    return out
end

function TableUtils.reversePairs(table)
    local out = {}
    local keys = TableUtils.keys(table)
    local len = #keys
    local ix = len + 1
    return function ()
        ix = ix -1
        if ix == 0 then
            return nil
        end
        local key = keys[ix]
        return key, table[key]
    end
end

-- FIXME: THIS CODE DOESNT WORK CORRECTLY
function TableUtils.tableContains(table, value)
    if table == nil then
      return false
    end

    for i, val in ipairs(table) do
      if type(val) == "table" and type(value) == "table" then
          return JSON.encode(val) == JSON.encode(value)
      end

      return val == value
    end

    return false
end


return TableUtils
