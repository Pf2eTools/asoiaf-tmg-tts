local TableUtils = require("lua.utils-table")

local Grid = {}
Grid.__index = Grid

setmetatable(Grid, {
    __index = Grid,
    __call = function(cls, opts)
        opts = opts or {}
        local this = setmetatable({}, Grid)
        this._ix = 0
        this.origin = opts.origin
        this.columns = opts.columns
        this.rows = opts.rows
        this.rowOffset = opts.rowOffset
        this.columnOffset = opts.columnOffset
        return this
    end
})

function Grid:getNextPos()
    --TODO: Out of bounds warning
    local pos = self:posFromIx(self._ix)
    self._ix  = self._ix + 1
    return pos
end

function Grid:posFromIx(ix)
    local column = ix % self.columns
    local row = (ix - column) / self.columns

    return self.origin + row * self.rowOffset + column * self.columnOffset
end

function Grid:clear()
    for idx = 0, self._ix - 1 do
        local pos = self:posFromIx(idx)
        local size = 0.5 * Vector(-0.4, 5, -0.4) + Vector.max(self.rowOffset, -1* self.rowOffset) + Vector.max(self.columnOffset, -1* self.columnOffset)
        local cast = Physics.cast({
            origin = pos + Vector(0, -0.5, 0),
            type = 3, --box
            size = size,
            direction = {0 , 1, 0},
            max_distance = 2,
            -- debug = true,
        })
        for _, entry in ipairs(cast) do
            if TableUtils.hasValue({"Deck", "Card"}, entry.hit_object.type) then
                entry.hit_object.destruct()
            elseif entry.hit_object.hasTag(GenericUnitTray.unitTrayTag) or entry.hit_object.hasTag(GenericUnitTray.unitModelTag) or entry.hit_object.hasTag("NCU") or entry.hit_object.hasTag("Token") then
                entry.hit_object.destruct()
            end
        end
    end
end

return Grid