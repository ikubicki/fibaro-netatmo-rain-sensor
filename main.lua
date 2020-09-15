--[[
Netatmo Rain Sensor
@author ikubicki
]]

function QuickApp:onInit()
    self.config = Config:new(self)
    self.auth = Auth:new(self.config)
    self.http = HTTPClient:new({
        baseUrl = 'https://api.netatmo.com/api'
    })
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace('Netatmo rain sensor')
    self:trace('User:', self.config:getUsername())
    self:updateProperty('manufacturer', 'Netatmo')
    self:updateProperty('manufacturer', 'Rain sensor')
    self:run()
    self:updateView("button3_1", "text", self.i18n:get('Now'))
    self:updateView("button3_2", "text", self.i18n:get('Last Hour')) 
    self:updateView("button3_3", "text", self.i18n:get('Today'))
    self.data = {["0"] = 0, ["1"] = 0, ["24"] = 0}
end

function QuickApp:run()
    self:pullNetatmoData()
    local interval = self.config:getTimeoutInterval()
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullNetatmoData()
    local url = '/getstationsdata'
    self:updateView("button1", "text", self.i18n:get('please-wait'))
    if string.len(self.config:getDeviceID()) > 3 then
        -- QuickApp:debug('Pulling data for device ' .. self.config:getDeviceID())
        url = url .. '?device_id=' .. self.config:getDeviceID()
    else
        -- QuickApp:debug('Pulling data')
    end
    local callback = function(response)
        local data = json.decode(response.data)
        if data.error and data.error.message then
            QuickApp:error(data.error.message)
            return false
        end

        local device = data.body.devices[1]
        local module = nil

        for _, deviceModule in pairs(device.modules) do
            if deviceModule.type == "NAModule3" then
                if string.len(self.config:getModuleID()) < 4 or self.config:getModuleID() == deviceModule["_id"] then
                    module = deviceModule
                end
            end
        end

        if module ~= nil then
            if self.config:getDataType() == "1" or self.config:getDataType() == "hour" then
                self:updateProperty("value", module.dashboard_data.sum_rain_1)
            elseif self.config:getDataType() == "24" or self.config:getDataType() == "today" then
                self:updateProperty("value", module.dashboard_data.sum_rain_24)
            else 
                self:updateProperty("value", module.dashboard_data.Rain)
            end

            self:updateProperty("unit", "mm")

            self.data = {
                ["0"] = module.dashboard_data.Rain,
                ["1"] = module.dashboard_data.sum_rain_1,
                ["24"] = module.dashboard_data.sum_rain_24
            }

            self:trace('Module ' .. module["_id"] .. ' updated')
            self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
            self:updateView("button1", "text", self.i18n:get('refresh'))
            
            if string.len(self.config:getDeviceID()) < 4 then
                self.config:setDeviceID(device["_id"])
            end
            if string.len(self.config:getModuleID()) < 4 then
                self.config:setModuleID(module["_id"])
            end
        else
            self:error('Unable to retrieve module data')
        end
    end
    
    self.http:get(url, callback, nil, self.auth:getHeaders({}))
    
    return {}
end

function QuickApp:button1Event()
    self:pullNetatmoData()
end

function QuickApp:showRain()
    self:updateView("button3_1", "text", self.data["0"] .. " mm")
    fibaro.setTimeout(5000, function() 
        self:updateView("button3_1", "text", self.i18n:get('Now')) 
    end)
end

function QuickApp:showHourRain()
    self:updateView("button3_2", "text", self.data["1"] .. " mm")
    fibaro.setTimeout(5000, function() 
        self:updateView("button3_2", "text", self.i18n:get('Last Hour')) 
    end)
end

function QuickApp:showTodayRain()
    self:updateView("button3_3", "text", self.data["24"] .. " mm")
    fibaro.setTimeout(5000, function() 
        self:updateView("button3_3", "text", self.i18n:get('Today')) 
    end)
end

