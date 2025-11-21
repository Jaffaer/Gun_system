fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jf_jamming'
author 'JF'
version '1.0.0'
description 'Weapon jamming based on durability'

dependencies { 
    'ox_lib', 
    'ox_inventory' 
}

shared_scripts {
	'@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/**/*.lua'
}

server_scripts {
    'server/**/*.lua'
}


files {
    'utils.lua',
    'stream/cxsht_clutching_arm@animation.ycd',
    'stream/cxsht_clutching_back@animation.ycd',
    'stream/cxsht_bp_clutching@animation.ycd',
    'stream/cxsht_clutching_front@animation.ycd'
}

-- Data Files
data_file 'ANIM_DICT' 'stream/cxsht_clutching_arm@animation.ycd'
data_file 'ANIM_DICT' 'stream/cxsht_clutching_back@animation.ycd'
data_file 'ANIM_DICT' 'stream/cxsht_bp_clutching@animation.ycd'
data_file 'ANIM_DICT' 'stream/cxsht_clutching_front@animation.ycd'