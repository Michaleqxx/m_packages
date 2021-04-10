# m_packages
Zajebisty skrypcik na paczusie do FiveM, w pełni autorski prócz HTMLa, jest on tylko przerobiony na potrzeby skryptu.
Jeżeli ktoś mi napisze że nie umie albo coś mu nie działa, to nie pomagam z góry pisze i jak chcecie go przerobić
droga wolna, tylko nie sprzedawajcie dzięki <3

A i trochę sie readme rozjechało także podstawa lua wymagana żebyście to ogarnęli 

SHOWOFF: https://youtu.be/-mIns-hcBlc

P.S. Wszystkie notyfikacje (xPlayer.showPopupNotification i ESX.ShowPopupNotification) musicie pozmieniać na te standardowe z ESX'a

# Credity borze

- Dziękuje dla NewWayRP za fajny wygląd bankomatów, sobie pożyczyłem i przerobiłem pod siebie: https://github.com/NewWayRP/new_banking
- Autor to ja cześ

** BAZA DANYCH **

Plik macie razem ze skryptem jedyne co musicie dodać to do tabeli items, itemki:
etykieta - Item który może wykorzystać firma i od razu przypisać numer do paczki
paczka - Pusta paczka w którą można zapakować itemy

** ES_EXTENDED / SERVER / MAIN.LUA **

`Dodajecie to na końcu pliku, z resztą dajcie to gdzie chcecie wywalone`

RegisterServerEvent('kurier:getPackages')
AddEventHandler('kurier:getPackages', function()
	local _source = source
	local paczki = {}
	local xPlayer = ESX.GetPlayerFromId(source)
	
	paczki = MySQL.Sync.fetchAll('SELECT * FROM m_packages WHERE user = @identifier', {
		['@identifier'] = xPlayer.identifier,
	})
	
	TriggerClientEvent("esx:getPackages", _source, paczki)
end)

** ES_EXTENDED / CLIENT / FUNCTIONS.LUA **

`Dodajce to nad eq [ESX.ShowInventory = function()]:`

local packages = {}

RegisterNetEvent('esx:getPackages')
AddEventHandler('esx:getPackages', function(result)
	packages = result
end)

RegisterNetEvent('kurier:getPackages')
AddEventHandler('kurier:getPackages', function()
	TriggerServerEvent('kurier:getPackages')
end)

`Dodajcie to w eq, pod pętlą z gotówką, jak wiecie to robicie to możecie se kolejność zmienić:`

if packages ~= nil then
	for _, paczka in ipairs(packages) do
		table.insert(elements, {
			label = paczka.label,
			number = paczka.id,
			count = 1,
			type = 'item_paczka',
			value = 'paczka',
			usable = true,
			rare = false,
			canRemove = true
		})	
	end
end

`Tam gdzie jest lokalna zmienna z item i type podmiencie na (jest to drugie menu w menu eq idk jak mam to napisac):`
https://imgur.com/a/SgUBJUr

local item, type, number = data1.current.value, data1.current.type, data1.current.number

`Tam gdzie jest if z type == 'item_weapon', to dodajecie pod tym:`

elseif type == 'item_paczka' then
	menu1.close()
	menu2.close()
	TriggerServerEvent('kurier:givePaczka', selectedPlayerId, number)

`Tam gdzie jest data1.current.action == 'remove' dodajecie:`

elseif type == 'item_paczka' then
	menu1.close()
	Citizen.Wait(1000)
	TriggerServerEvent('kurier:throwPaczka', number)

`Tam gdzie jest data1.current.action == 'use' dodajecie:`

elseif type == 'item_paczka' then
	TriggerServerEvent("kurier:wypakuj", number)
	menu1.close()

Zajebiście jak mamy już to wszystko za sobą to skrypcik funkiel powinien działać, jeżeli jest jakiś 
problem z instalacją to poradniki do lua i nauki angielskiego są na necie pozderki <3
