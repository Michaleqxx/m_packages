ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--------------------------------------------
----		  Skrypt na Paczusie		----
----			Wykonane przez			----
----			  Michaleqxx			----
--------------------------------------------

math.randomseed(os.time())

ESX.RegisterServerCallback('kurier:getInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

ESX.RegisterServerCallback('kurier:getPaczki', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local paczusie = {}
	
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE user = @user',
	{
		['@user'] = xPlayer.identifier
	}, function(result)
		if result ~= nil then
			for i=1, #result, 1 do
				table.insert(paczusie, {
					id = result[i].id,
					label = result[i].label,
					items = result[i].items,
					receiver = result[i].receiver
				})
			end
			
			cb(paczusie)
		else
			cb(paczusie)
			print('[^2MICHALEQXX_KURIER^0] Nie znaleziono żadnych paczek dla gracza ' .. _source)
		end
	end)
end)

ESX.RegisterServerCallback('kurier:getSortowniaPaczki', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local paczusie = {}
	
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE state = @state',
	{
		['@state'] = 1
	}, function(result)
		if result ~= nil then
			
			for i=1, #result, 1 do if result[i].receiver ~= nil then
				table.insert(paczusie, {
					id = result[i].id,
					label = result[i].label,
					items = result[i].items,
					receiver = result[i].receiver
				})
			end end
			
			cb(paczusie)
		else
			cb(paczusie)
			print('[^2MICHALEQXX_KURIER^0] Nie znaleziono żadnych paczek w sortowni')
		end
	end)
end)

ESX.RegisterServerCallback('kurier:getSledzionePaczki', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local paczusie = {}
	
	MySQL.Async.fetchAll('SELECT phone_number FROM users WHERE identifier = @identifier',
	{
		['@identifier'] = xPlayer.identifier
	}, function(num_result)
		if num_result ~= nil then
			MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE receiver = @receiver',
			{
				['@receiver'] = num_result[1].phone_number
			}, function(result)
				if result ~= nil then
					for i=1, #result, 1 do
						table.insert(paczusie, {
							id = result[i].id,
							label = result[i].label,
							items = result[i].items,
							receiver = result[i].receiver,
							state = result[i].state,
							code = result[i].code,
							zone = result[i].zone
						})
					end
					
					cb(paczusie)
				else
					cb(paczusie)
					print('[^2MICHALEQXX_KURIER^0] Nie znaleziono żadnych paczek dla gracza ' .. _source)
				end
			end)
		else
			xPlayer.showNotification(Locale[Config.Language].ErrorNumber)
		end
	end)
end)

ESX.RegisterUsableItem('paczka', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeInventoryItem('paczka', 1)
    TriggerClientEvent('kurier:menuC', playerId)
end)

ESX.RegisterUsableItem('etykieta', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('etykieta', 1)
    TriggerClientEvent('kurier:etykietaC', source)
end)

function GetPlayerPackages(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	local ownedPackages = {}
	
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE user = @user',
	{
		['@user'] = identifier
	}, function(result)
		if result ~= nil then
			for i=1, #result, 1 do
				table.insert(ownedPackages, {
					id = result[i].id,
					label = result[i].label,
					zone = result[i].zone,
					code = result[i].code,
					items = result[i].items
				})
			end
			
			if ownedPackages ~= nil then
				print('[^2MICHALEQXX_KURIER^0] Wczytano ' .. #ownedPackages .. ' paczek dla ' .. src)
			else
				print('[^2MICHALEQXX_KURIER^0] Nie znaleziono żadnych paczek dla gracza ' .. src)
			end
			return ownedPackages
		else
			print('[^2MICHALEQXX_KURIER^0] Nie znaleziono żadnych paczek dla gracza ' .. src)
		end
	end)
end

function ReloadPaczusieForClient(src)
	local paczusie = GetPlayerPackages(src)
	TriggerClientEvent('kurier:getPackages', src, paczusie)
end


RegisterNetEvent('kurier:givePaczka')
AddEventHandler('kurier:givePaczka', function(player, id)
	local _source = source
	local zPlayer = ESX.GetPlayerFromId(player)
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.execute('UPDATE m_packages SET user = @user WHERE id = @id',
	{
		['@user'] = zPlayer.identifier,
		['@id'] = id
	})
	ReloadPaczusieForClient(_source)
	ReloadPaczusieForClient(player)
	
	xPlayer.showNotification(string.format(Locale[Config.Language].SuccessGiving, player))
	zPlayer.showNotification(string.format(Locale[Config.Language].SuccessGetting, xPlayer.source))
end)

RegisterNetEvent('kurier:getPackageFromSortownia')
AddEventHandler('kurier:getPackageFromSortownia', function(id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE id = @id',
	{
		['@id'] = id
	}, function(result)
		if result[1] ~= nil then
			if result[1].state == 1 then
				MySQL.Async.execute('UPDATE m_packages SET `user` = @user, `state` = @state WHERE id = @id',
				{
					['@id'] = id,
					['@state'] = nil,
					['@user'] = xPlayer.identifier,
				})
				
				ReloadPaczusieForClient(_source)
				xPlayer.showNotification(string.format(Locale[Config.Language].SuccessGettingFromLocker, result[1].label))
			else
				xPlayer.showNotification(Locale[Config.Language].ErrorGettingFromSortownia)
			end
		else
			xPlayer.showNotification(Locale[Config.Language].ErrorGettingFromSortownia)
		end
	end)
end)

RegisterNetEvent('kurier:sendPlayerInfo')
AddEventHandler('kurier:sendPlayerInfo', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('kurier:sendPlayerInfo', source, xPlayer.getName())
end)

RegisterNetEvent('kurier:sendPackageToSortownia')
AddEventHandler('kurier:sendPackageToSortownia', function(id)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE id = @id',
	{
		['@id'] = id
	}, function(result)
		if result ~= nil then
			
			MySQL.Async.execute('UPDATE m_packages SET `state` = @state, `sender` = @sender, `user` = @user WHERE id = @id',
			{
				['@id'] = id,
				['@state'] = 1,
				['@sender'] = result[1].sender or xPlayer.identifier,
				['@user'] = nil,
			})
			TriggerClientEvent('kurier:gcphone', _source, string.format(Locale[Config.Language].SortowniaMessageSuccess, result[1].label), result[1].receiver)
			xPlayer.showNotification(Locale[Config.Language].SuccessInsertingSortownia)
			ReloadPaczusieForClient(_source)
		else
			xPlayer.showNotification(Locale[Config.Language].ErrorInsertingSortownia)
		end
	end)
end)

RegisterNetEvent('kurier:wypakuj')
AddEventHandler('kurier:wypakuj', function(id)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE id = @id',
	{
		['@id'] = id
	}, function(result)
		if result ~= nil then
			local pizda = json.decode(result[1].items)
			
			for i=1,#pizda,1 do
				xPlayer.addInventoryItem(pizda[i].name, pizda[i].count)
			end
			xPlayer.showNotification(string.format(Locale[Config.Language].SuccessOpened, result[1].label))
			
			MySQL.Sync.execute("DELETE FROM m_packages WHERE `id` = @id", {
				['@id'] = id,
			})
			ReloadPaczusieForClient(_source)
		else
			print('[^2MICHALEQXX_KURIER^0] Nie znaleziono paczki dla gracza ' .. _source .. ' o numerze ' .. id)
		end
	end)
end)

RegisterNetEvent('kurier:removeItem')
AddEventHandler('kurier:removeItem', function(item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	xPlayer.removeInventoryItem(item, count)
end)

RegisterNetEvent('kurier:loadPackages')
AddEventHandler('kurier:loadPackages', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	ReloadPaczusieForClient(_source)
end)

RegisterNetEvent('kurier:buyItem')
AddEventHandler('kurier:buyItem', function(name, price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if Config.WeightBasedInventory then
		if xPlayer.canCarryItem(name, 1) then
			if xPlayer.getMoney() >= price then
				xPlayer.removeMoney(price)
				xPlayer.addInventoryItem(name, 1)
			else
				xPlayer.showNotification(string.format(Locale[Config.Language].NotEnoughMoney, price - xPlayer.getMoney()))
			end
		else
			xPlayer.showNotification(Locale[Config.Language].CantCarry)
		end
	else
		local item = xPlayer.getInventoryItem(name).limit
		local itemCount = xPlayer.getInventoryItem(name).count
		
		if itemCount + 1 < item then
			if xPlayer.getMoney() >= price then
				xPlayer.removeMoney(price)
				xPlayer.addInventoryItem(name, 1)
			else
				xPlayer.showNotification(string.format(Locale[Config.Language].NotEnoughMoney, price - xPlayer.getMoney()))
			end
		else
			xPlayer.showNotification(Locale[Config.Language].CantCarry)
		end
	end
end)

RegisterNetEvent('kurier:throwPaczka')
AddEventHandler('kurier:throwPaczka', function(id)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local pickupLabel
	MySQL.Async.fetchAll('UPDATE m_packages SET user = NULL WHERE id = @id', { ['@id'] = id })
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE id = @id', { ['@id'] = id }, function(result)
		if result ~= nil then
			pickupLabel = '~b~'..result[1].label
			ESX.CreatePickup('item_package', result[1].items, id, pickupLabel, _source)
		end
	end)
	ReloadPaczusieForClient(_source)
	xPlayer.showNotification(Locale[Config.Language].SuccessThrowing)
end)

RegisterNetEvent('kurier:updatePackageNumber')
AddEventHandler('kurier:updatePackageNumber', function(id, playerNum)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE id = @id',
	{
		['@id'] = id
	}, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute('UPDATE m_packages SET `receiver` = @receiver, `state` = @state, `sender` = @sender WHERE id = @id',
			{
				['@id'] = id,
				['@state'] = 0,
				['@sender'] = xPlayer.identifier,
				['@receiver'] = playerNum,
			})
			
			TriggerClientEvent('kurier:gcphone', _source, string.format(Locale[Config.Language].EtykietaMessageSuccess, result[1].label), playerNum)
			ReloadPaczusieForClient(_source)
			xPlayer.showNotification(string.format(Locale[Config.Language].SuccessChangingEtykieta, result[1].label, playerNum))
		else
			xPlayer.showNotification(Locale[Config.Language].ErrorChangingEtykieta)
		end
	end)
end)

RegisterNetEvent('kurier:getPackage')
AddEventHandler('kurier:getPackage', function(code, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE code = @code',
	{
		['@code'] = code
	}, function(result)
		if result[1] ~= nil then
			if result[1].zone == zone then
				MySQL.Async.execute('UPDATE m_packages SET `zone` = @zone, `state` = @state, `sender` = @sender, `code` = @code, `user` = @user WHERE id = @id',
				{
					['@id'] = result[1].id,
					['@zone'] = nil,
					['@state'] = 3,
					['@sender'] = nil,
					['@code'] = nil,
					['@user'] = xPlayer.identifier,
				})
				
				TriggerClientEvent('kurier:gcphone', _source, string.format(Locale[Config.Language].PackageMessageSuccess, result[1].zone, result[1].label), result[1].receiver)
				ReloadPaczusieForClient(_source)
				xPlayer.showNotification(string.format(Locale[Config.Language].SuccessGettingFromLocker, result[1].label, result[1].receiver))
			else
				xPlayer.showNotification(string.format(Locale[Config.Language].ErrorGetting, code))
			end
		else
			xPlayer.showNotification(string.format(Locale[Config.Language].ErrorGetting, code))
		end
	end)
end)

RegisterNetEvent('kurier:sendPackage')
AddEventHandler('kurier:sendPackage', function(id, playerNum, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local _source = source
	MySQL.Async.fetchAll('SELECT * FROM m_packages WHERE id = @id',
	{
		['@id'] = id
	}, function(result)
		if result ~= nil then
			local code = math.random(10000, 99999)
			local label = result[1].label
			print('[^2MICHALEQXX_KURIER^0] Dodano nową paczkę: kod: ' .. code .. ' numer: ' .. playerNum)
			MySQL.Async.execute('UPDATE m_packages SET `zone` = @zone, `state` = @state, `sender` = @sender, `receiver` = @receiver, `code` = @code, `user` = @user WHERE id = @id',
			{
				['@id'] = id,
				['@zone'] = zone,
				['@state'] = 2,
				['@sender'] = result[1].sender or xPlayer.identifier,
				['@receiver'] = playerNum,
				['@code'] = code,
				['@user'] = nil,
			})
			TriggerClientEvent('kurier:gcphone', _source, string.format(Locale[Config.Language].PackageMessage, label, zone, code), playerNum)
			xPlayer.showNotification(Locale[Config.Language].SuccessInserting)
			ReloadPaczusieForClient(_source)
		else
			xPlayer.showNotification(Locale[Config.Language].ErrorInserting)
		end
	end)
end)

RegisterNetEvent('kurier:createPackage')
AddEventHandler('kurier:createPackage', function(items, label)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local endLabel = label .. ' #' .. math.random(100000, 999999)
	print('[^2MICHALEQXX_KURIER^0] Zrobiono nową paczkę ' .. endLabel)
	MySQL.Async.execute('INSERT INTO m_packages (`zone`, `items`, `sender`, `receiver`, `user`, `code`, `label`) VALUES (@zone, @items, @sender, @receiver, @user, @code, @label)',
	{ 
		['@zone'] = nil,
		['@items'] = json.encode(items) or json.encode({}),
		['@sender'] = nil,
		['@receiver'] = nil,
		['@code'] = nil,
		['@user'] = xPlayer.identifier,
		['@label'] = endLabel
	})
	
	ReloadPaczusieForClient(_source)
	xPlayer.showNotification(string.format(Locale[Config.Language].SuccessCreating, endLabel))
end)