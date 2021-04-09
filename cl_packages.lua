ESX = nil
local actualPackage = {}
local sleep = 800

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do Citizen.Wait(100) end

	ESX.PlayerData = ESX.GetPlayerData()
	TriggerServerEvent('kurier:loadPackages')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
	TriggerServerEvent('kurier:loadPackages')
end)

Citizen.CreateThread(function()
	while true do
		Wait(2)
		-- Paczkomaty
		for k,v in pairs(Config.Paczkomaty) do
			if #(GetEntityCoords(PlayerPedId()) - v) <= 19.0 then
				sleep = 2
				local x,y,z = table.unpack(v)
				DrawMarker(1, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
				if #(GetEntityCoords(PlayerPedId()) - v) <= 1.5 then
					ESX.ShowHelpNotification('Naciśnij ~INPUT_CONTEXT~ aby ~y~zarządzać paczkami')
					if IsControlJustReleased(0,38) then
						--OpenPaczkomatMenu(k)
						TriggerServerEvent('kurier:sendPlayerInfo')
						SetNuiFocus(true, true)
						SendNUIMessage({type = 'openGeneral', paczkomat = k})
					end
				end
			else
				sleep = 800
			end
		end
	end
end)

RegisterNetEvent('kurier:menuC')
AddEventHandler('kurier:menuC', function(job)
	OpenPackageMenu()
end)

RegisterNetEvent('kurier:etykietaC')
AddEventHandler('kurier:etykietaC', function()
	ESX.TriggerServerCallback('kurier:getPaczki', function(result)
		local paczki = {}
		
		for i=1, #result, 1 do
			table.insert(paczki, {
				label = result[i].label,
				value = result[i].id
			})
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'etykieta_menu', {
			title    = 'Etykieta : Paczki',
			align    = 'center',
			elements = paczki
		}, function(data, menu)
			menu.close()
			--OpenNui('etykieta', {name = data.current.label, id = data.current.value})
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'xd', {
				title = 'Wpisz numer telefonu na który ma zostać wysłana paczka'
			}, function(data2, menu2)
				if not data2.value then
					ESX.ShowNotification("~r~Nieprawidłowy numer telefonu!")
				else
					TriggerServerEvent('kurier:updatePackageNumber', data.current.value, data2.value)
					menu2.close()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end)

RegisterNetEvent('kurier:gcphone')
AddEventHandler('kurier:gcphone', function(message, phone)
	TriggerServerEvent('gcPhone:sendMessage', phone, message)
end)

RegisterNetEvent('kurier:sendPlayerInfo')
AddEventHandler('kurier:sendPlayerInfo', function(name)
	SendNUIMessage({type = 'nazwa', player = name})
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.Paczkomaty) do
		local x,y,z = table.unpack(v)
		local blip = AddBlipForCoord(x, y, z)
		SetBlipSprite(blip, 414) --357
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.2)
		SetBlipColour(blip, 5)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Paczkomat')
		EndTextCommandSetBlipName(blip)
	end
	
	local x,y,z = table.unpack(vector3(1203.54, -3254.96, 6.07))
	local blip1 = AddBlipForCoord(x, y, z)
	SetBlipSprite(blip1, 357) --357
	SetBlipDisplay(blip1, 4)
	SetBlipScale(blip1, 0.8)
	SetBlipColour(blip1, 5)
	SetBlipAsShortRange(blip1, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Sortownia PostOp')
	EndTextCommandSetBlipName(blip1)
end)

RegisterNUICallback('paczki', function()
	ESX.TriggerServerCallback('kurier:getSledzionePaczki', function(result)
		for i=1, #result, 1 do if result[i].state ~= -1 then SendNUIMessage({type = 'paczki', id = result[i].id, name = result[i].label, state = result[i].state, paczkomat = result[i].zone or 0, code = result[i].code or 0}) end end
	end)
end)

RegisterNUICallback('send_paczki', function()
	ESX.TriggerServerCallback('kurier:getPaczki', function(result)
	for i=1, #result, 1 do SendNUIMessage({type = 'send_paczki', id = result[i].id, number = result[i].receiver or 0, name = result[i].label}) end
	end)
end)

RegisterNUICallback('send_paczka', function(data, cb)
	TriggerServerEvent('kurier:sendPackage', data.id, data.telefon, data.zone)
end)

RegisterNUICallback('odbierz', function(data, cb)
	TriggerServerEvent('kurier:getPackage', data.kod, data.zone)
end)

RegisterNUICallback('NUIFocusOff', function()
	SetNuiFocus(false, false)
	SendNUIMessage({type = 'closeAll'})
end)

function OpenShopMenu()
	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
		title    = 'Sklep',
		align    = 'center',
		elements = {
			{label = 'Pusta paczka - <span style="color: #7cfc00;">$250</span>', value = 'paczka', price = 250},
			{label = 'Etykieta - <span style="color: #7cfc00;">$100</span>', value = 'etykieta', price = 100}
		},
	}, function(data, menu)
		TriggerServerEvent('kurier:buyItem', data.current.value, data.current.price)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenSortowniaMenu()
	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
		title    = 'Magazyn sortowni',
		align    = 'center',
		elements = {
			{label = 'Włóż paczkę', value = 'insert'},
			{label = 'Wyjmij paczkę', value = 'get'}
		},
	}, function(data, menu)
		if data.current.value == 'insert' then
			ESX.UI.Menu.CloseAll()
			ESX.TriggerServerCallback('kurier:getPaczki', function(result)
				local paczki = {}
				
				for i=1, #result, 1 do if result[i].receiver ~= nil then
					table.insert(paczki, {
						label = result[i].label,
						value = result[i].id
					})
				end end
				
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
					title    = 'Magazyn sortowni : Włóż',
					align    = 'center',
					elements = paczki
				}, function(data, menu)
					menu.close()
					TriggerServerEvent('kurier:sendPackageToSortownia', data.current.value)
					Wait(100)
					OpenSortowniaMenu()
				end, function(data, menu)
					menu.close()
				end)
			end)
		elseif data.current.value == 'get' then
			ESX.UI.Menu.CloseAll()
			ESX.TriggerServerCallback('kurier:getSortowniaPaczki', function(result)
				local paczki = {}
				
				for i=1, #result, 1 do
					table.insert(paczki, {
						label = result[i].label .. ' - [<span style="color: #7cfc00;">'..result[i].receiver..'</span>]',
						value = result[i].id,
						receiver = result[i].receiver
					})
				end
				
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
					title    = 'Magazyn sortowni : Wyjmij',
					align    = 'center',
					elements = paczki
				}, function(data, menu)
					menu.close()
					TriggerServerEvent('kurier:getPackageFromSortownia', data.current.value)
					Wait(100)
					OpenSortowniaMenu()
				end, function(data, menu)
					menu.close()
				end)
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenPaczkomatMenu(zone)
	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
		title    = 'Paczkomat ['..zone..']',
		align    = 'center',
		elements = {
			{label = "Nadaj paczkę", value = "nadaj"},
			{label = "Odbierz paczkę", value = "odbierz"},
			{label = "Śledź przesyłkę", value = "sledz"},
		}
	}, function(data, menu)
		if data.current.value == 'sledz' then
			menu.close()
			ESX.TriggerServerCallback('kurier:getSledzionePaczki', function(result)
				local paczki = {}
				
				for i=1, #result, 1 do
					if result[i].state ~= -1 then
						table.insert(paczki, {
							label = result[i].label,
							value = result[i].id,
							receiver = result[i].receiver,
							state = result[i].state
						})
					end
				end
				
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
					title    = 'Paczkomat : Paczka',
					align    = 'center',
					elements = paczki
				}, function(data, menu)
					menu.close()
					local dat = data.current
					
					if dat.state == 0 then ESX.ShowNotification('~y~Paczka: ~w~['..dat.state..'] Paczka oczekuje na nadanie')
					elseif dat.state == 1 then ESX.ShowNotification('~y~Paczka: ~w~['..dat.state..'] Paczka przyjęta w sortowni')
					elseif dat.state == 2 then ESX.ShowNotification('~y~Paczka: ~w~['..dat.state..'] Paczka została umieszczona w paczkomacie')
					elseif dat.state == 3 then ESX.ShowNotification('~y~Paczka: ~w~['..dat.state..'] Paczka została odebrana')
					end
					
				end, function(data, menu)
					menu.close()
				end)
			end)
		elseif data.current.value == 'nadaj' then
			menu.close()
			ESX.TriggerServerCallback('kurier:getPaczki', function(result)
				local paczki = {}
				
				for i=1, #result, 1 do
					table.insert(paczki, {
						label = result[i].label,
						value = result[i].id,
						receiver = result[i].receiver
					})
				end
				
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paczkomat', {
					title    = 'Paczkomat : Paczki',
					align    = 'center',
					elements = paczki
				}, function(data, menu)
					menu.close()
					if data.current.receiver ~= nil then
						TriggerServerEvent('kurier:sendPackage', data.current.value, data.current.receiver, zone)
					else
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'xd', {
							title = 'Wpisz numer telefonu na który ma zostać wysłana paczka'
						}, function(data2, menu2)
							if not data2.value then
								ESX.ShowNotification("~r~Nieprawidłowy numer telefonu!")
							else
								TriggerServerEvent('kurier:sendPackage', data.current.value, data2.value, zone)
								menu2.close()
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					end
				end, function(data, menu)
					menu.close()
				end)
			end)
		else
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'xd', {
				title = 'Wpisz kod odbioru z SMS'
			}, function(data2, menu2)
				if not data2.value then
					ESX.ShowNotification("~r~Nieprawidłowy numer telefonu!")
				else
					TriggerServerEvent('kurier:getPackage', data2.value, zone)
					menu2.close()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenNui(action, data)
	SetNuiFocus(true, true)
	SendNUIMessage({type = action, nui_data = data})
end

function OpenPackageMenu()
	ESX.UI.Menu.CloseAll()
	ESX.TriggerServerCallback('kurier:getInventory', function(result)
		local items = {}
		
		for i=1, #result.items, 1 do
			local item = result.items[i]

			if item.count > 0 and item.name ~= 'paczka' and item.name ~= 'etykieta' then
				table.insert(items, {
					label = item.count .. 'x ' .. item.label,
					type = 'item_standard',
					count = items.count,
					value = item.name
				})
			end
		end
		
		table.insert(items, {label = '<span style="color: green">Utwórz paczkę</span>', type = 'jebac_disa'})
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'xd', {
			title    = 'Paczka',
			align    = 'center',
			elements = items
		}, function(data, menu)
			if data.current.type == 'item_standard' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'xd', {
					title = 'Ilość'
				}, function(data2, menu2)
					if not data2.value then
						ESX.ShowNotification("~r~Nieprawidłowa ilość!")
					else
						TriggerServerEvent('kurier:removeItem', data.current.value, data2.value)
						table.insert(actualPackage, {count = tonumber(data2.value), name = data.current.value})
						menu2.close()
						Wait(100)
						OpenPackageMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			else
				if actualPackage ~= nil then
					menu.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
						title = 'Nazwa paczki'
					}, function(data2, menu2)
						if not data2.value then
							ESX.ShowNotification("~r~Nieprawidłowa nazwa!")
						else
							TriggerServerEvent('kurier:createPackage', actualPackage, data2.value)
							menu2.close()
							Wait(100)
							TriggerServerEvent('kurier:loadPackages')
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				end
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end