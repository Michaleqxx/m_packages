resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Skrypt na paczusie dla społeczności ode me, a i dziękuje dla pana z new_banking za nui, przerobione pode mnie może dla mnie nie pozwie Sadge'

author 'Michaleqxx'

client_scripts { 
	'cl_packages.lua',
	'locales/pl.lua',
	'config.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'sv_packages.lua',
	'locales/pl.lua',
	'config.lua',
}

ui_page('html/UI.html')

files {
	'html/UI.html',
    'html/style.css',
    'html/media/font/Bariol_Regular.otf',
    'html/media/font/Vision-Black.otf',
    'html/media/font/Vision-Bold.otf',
    'html/media/font/Vision-Heavy.otf',
    'html/media/img/bg.png',
    'html/media/img/circle.png',
    'html/media/img/curve.png',
    'html/media/img/fingerprint.png',
    'html/media/img/fingerprint.jpg',
    'html/media/img/graph.png',
    'html/media/img/logo-big.png',
    'html/media/img/logo-top.png'
}