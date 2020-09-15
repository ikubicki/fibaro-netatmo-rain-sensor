--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['refresh'] = 'Odśwież',
        ['last-update'] = 'Ostatnia aktualizacja: %s',
        ['please-wait'] = 'Proszę czekać...',
        ['Now'] = 'Aktualnie',
        ['Last Hour'] = 'Ostatnia godzina',
        ['Today'] = 'Dzisiaj',
    },
    en = {
        ['refresh'] = 'Refresh',
        ['last-update'] = 'Last update at %s',
        ['please-wait'] = 'Please wait...',
        ['Now'] = 'Now',
        ['Last Hour'] = 'Last Hour',
        ['Today'] = 'Today',
    },
    de = {
        ['refresh'] = 'Aktualisieren',
        ['last-update'] = 'Letztes update: %s',
        ['please-wait'] = 'Ein moment bitte...',
        ['Now'] = 'Jetzt',
        ['Last Hour'] = 'Letzte stunde',
        ['Today'] = 'Heute',
    }
}