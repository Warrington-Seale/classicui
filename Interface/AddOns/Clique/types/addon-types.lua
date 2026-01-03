---@alias EventHandler
---| string 
---| fun(...: any)
---| nil


---@class AddonCore
---@field RegisterEvent fun(self: AddonCore, event: string, handler: EventHandler)
---@field UnregisterEvent fun(self: AddonCore, event: string, handler: EventHandler) 
---@field APIIsTrue fun(self:AddonCore, val: any): boolean
---@field ProjectIsRetail fun(self: AddonCore): boolean
---@field ProjectIsClassic fun(self: AddonCore): boolean
---@field ProjectIsBCC fun(self: AddonCore): boolean
---@field ProjectIsWrath fun(self: AddonCore): boolean
---@field ProjectIsCataclysm fun(self: AddonCore): boolean
---@field ProjectIsMists fun(self: AddonCore): boolean
---@field ProjectIsDragonflight fun(self: AddonCore): boolean
---@field ProjectIsWarWithin fun(self: AddonCore): boolean
---@field ProjectIsMidnight fun(self: AddonCore): boolean
---@field Printf fun(self: AddonCore, msg: string, ...: any)
---@field version string
---@field RegisterModule fun(self: AddonCore, module: table, name: string)
---@field RegisterMessage fun(self: AddonCore, name: string, handler: EventHandler) 
---@field UnregisterMessage fun(self: AddonCore, name: string)
---@field FireMessage fun(self: AddonCore, name: string, ...: any)
---@field Defer fun(self: AddonCore, ...:any)
---@field L table<string,string>
---@field RegisterLocale fun(self: AddonCore, locale: string, tbl: table<string,string>)





