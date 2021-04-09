Config = {}

Config.Money = 150

Config.Language = 'pl'
Config.Paczkomaty = {
	['LS001'] = vector3(233.78, -752.9, 33.64),
	['LS002'] = vector3(23.99, -895.94, 29.02),
	['LS003'] = vector3(-328.69, -737.59, 32.96),
	['LS004'] = vector3(-1161.8, -750.95, 18.12),
	['LS005'] = vector3(-1657.34, -953.33, 6.69),
	['LS006'] = vector3(1148.52, -454.94, 65.98),
	['M001'] = vector3(566.09, -1778.12, 28.35),
}

Config.NPCtasks = {
	-- Mirror park
	vector4(1227.42, -725.98, 59.64, 116.66),
	vector4(1268.11, -705.14, 63.61, 240.91),
	vector4(1272.46, -636.11, 67.53, 303.74),
	vector4(1254.95, -600.63, 68.11, 268.23),
	vector4(1002.46, -725.15, 56.49, 307.34),
	vector4(969.2, -547.7, 58.28, 210.09),
	vector4(1207.47, -620.36, 65.44, 276.17),
}

Config.Zones = {
	{
		type = 'cloakroom',
		data = {},
		size = 1.2,
		coords = vector3(1214.09, -3306.12, 4.5),
		help = 'Naciśnij ~INPUT_CONTEXT~ aby ~b~przebrać się',
	},
	{
		type = 'farm',
		data = {
			{
				max = 20,
				min = 1,
				label = 'Paczka',
				value = 1,
				item = 'colis',
				type = 'slider'
			},
			{
				max = 20,
				min = 1,
				label = 'List',
				value = 1,
				item = 'letter',
				type = 'slider'
			},
		},
		size = 6.0,
		coords = vector3(1221.31, -3289.94, 4.5),
		help = 'Naciśnij ~INPUT_CONTEXT~ aby ~y~zbierać paczki',
	},
	{
		type = 'vehicles',
		data = {
			spawn = vector4(1218.99, -3243.83, 5.5, 355.47),
			model = 'Boxville4',
		},
		size = 1.2,
		coords = vector3(1213.94, -3248.97, 4.5),
		help = 'Naciśnij ~INPUT_CONTEXT~ aby ~b~wyjąć pojazd',
	},
	{
		type = 'sortownia',
		data = {},
		size = 1.2,
		coords = vector3(1224.46, -3256.15, 4.5),
		help = 'Naciśnij ~INPUT_CONTEXT~ aby ~y~zarządzać sortownią',
	},
	{
		type = 'del_veh',
		data = {},
		size = 2.2,
		coords = vector3(1218.58, -3245.09, 4.5),
		help = 'Naciśnij ~INPUT_CONTEXT~ aby ~y~schować pojazd',
	},
	{
		type = 'shop',
		data = {},
		size = 1.2,
		coords = vector3(1203.54, -3254.96, 6.07),
		help = 'Naciśnij ~INPUT_CONTEXT~ aby ~g~wejść do sklepu',
	},
}