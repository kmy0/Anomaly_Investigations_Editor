local monsters = json.load_file('Anomaly Investigations Editor/monsters.json')

if not monsters then return end

local version = '1.4.0'

local create_random_mystery_quest = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('CreateRandomMysteryQuest')
local random_mystery_quest_auth = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('checkRandomMysteryQuestOrderBan')

local singletons = {}
local main_window = {
	flags=0,
	pos=Vector2f.new(50, 50),
	pivot=Vector2f.new(0, 0),
	size=Vector2f.new(560, 890),
	condition=1 << 3,
	is_opened=false
}
local sub_window = {
	flags=32,
	pos=nil,
	pivot=Vector2f.new(0, 0),
	size=Vector2f.new(1000, 480),
	condition=1 << 3,
	is_opened=false
}
local mass_window = {
	flags=1,
	pos=nil,
	pivot=Vector2f.new(0, 0),
	size=Vector2f.new(560, 890),
	condition=1 << 3,
	is_opened=false
}
local table_1 = {
	name='1',
	flags=1 << 9|1 << 8|1 << 7|1 << 0|1 << 10,
	col_count=10,
	row_count=9,
	data={
		{'Stars', '1', '1-4', '1-5', '2-6', '3-7', '4-8', '5-8', '6-8', '7-8'},
		{'1', 100, 25, 10, 0, 0, 0, 0, 0, 0},
		{'2', 0, 43, 25, 10, 0, 0, 0, 0, 0},
		{'3', 0, 27, 37, 25, 15, 0, 0, 0, 0},
		{'4', 0, 5, 23, 37, 30, 15, 0, 0, 0},
		{'5', 0, 0, 5, 23, 37, 30, 21, 0, 0},
		{'6', 0, 0, 0, 5, 15, 37, 35, 23, 0},
		{'7', 0, 0, 0, 0, 3, 15, 33, 40, 42},
		{'8', 0, 0, 0, 0, 0, 3, 11, 37, 58},
	}
}
local table_2 = {
	name='2',
	flags=1 << 9|1 << 8|1 << 7|1 << 0|1 << 10,
	col_count=8,
	row_count=11,
	data={
		{'Quest Level', 'Main Target Mystery Rank', 'Sub Target Mystery Rank', 'Extra Target Mystery Rank', 'Target Num', 'Quest Life', 'Time Limit', 'Hunter Num'},
		{'1 - 10', '0', ' - ', '0 - 1', '1', '3 - 5, 9', '50', '4'},
		{'11 - 20', '0 - 1', ' - ', '0 - 2', '1', '3 - 5, 9', '50', '4'},
		{'21 - 30', '0 - 2', '0 - 3, 11(Apex)', '0 - 3', '1 - 2', '3 - 5', '30, 35, 50', '4'},
		{'31 - 40', '0 - 3', '0 - 5, 11(Apex)', '0 - 5', '1 - 2', '3 - 5', '30, 35, 50', '4'},
		{'41 - 50', '0 - 3', '0 - 5, 11', '0 - 5, 11(ED)', '1 - 3', '2 - 5', '25, 30, 35, 50', '4'},
		{'51 - 60', '0 - 4', '0 - 5, 11', '0 - 5, 11(ED)', '1 - 3', '2 - 5', '25, 30, 35, 50', '4'},
		{'61 - 70', '0 - 4', '0 - 6, 11', '0 - 6, 11(ED)', '1 - 3', '2 - 5', '25, 30, 35, 50', '4'},
		{'71 - 90', '0 - 5', '0 - 6, 11', '0 - 6, 11(ED)', '1 - 3', '2 - 5', '25, 30, 35, 50', '2, 4'},
		{'91 - 110', '0 - 6', '0 - 7, 11', '0 - 7, 11(ED)', '1 - 3', '1 - 4', '25, 30, 35, 50', '2, 4'},
		{'111 - 220', '0 - 7', '0 - 7, 11', '0 - 7, 11(ED)', '1 - 3', '1 - 4', '25, 30, 35, 50', '2, 4'}
	}
}
local table_3 = {
	name='3',
	flags=1 << 9|1 << 8|1 << 7|1 << 0|1 << 10,
	col_count=2,
	row_count=4,
	data={
		{'Target Num','Time Limit'},
		{'1', '25, 30, 35, 50'},
		{'2', '30, 35, 50'},
		{'3', '50'}
	}
}
local monsters = {
	data=monsters,
	id_table={}
}
local monster_arrays = {
	main={
		map_valid={},
		current={}
	},
	extra={
		map_valid={},
		current={}
	},
	intruder={
		map_valid={},
		current={}
	}
}
local maps = {
	data={
	    Citadel=13,
	    ["Flooded Forest"]=3,
	    ["Frost Islands"]=4,
	    Jungle=12,
	    ["Lava Caverns"]=5,
	    ["Sandy Plains"]=2,
	    ["Shrine Ruins"]=1,
		["Infernal Springs"]=9,
		["Arena"]=10,
		["Forlorn Arena"]=14
	},
	invalid={
		["Infernal Springs"]=9,
		["Arena"]=10,
		["Forlorn Arena"]=14
	},
	array={},
	id_table={}
}
local mystery_quests = {
	data={},
	names={},
	names_filtered={},
	dumped=false,
	count=1
}
local rand_rank = {
	data={
		['1']=0,
		['1-4']=107,
		['1-5']=19,
		['2-6']=1,
		['3-7']=349,
		['4-8']=351,
		['5-8']=350,
		['6-8']=1303,
		['7-8']=2073
	},
	array={}
}
local tod = {
	data={
		Default=0,
		Day=1,
		Night=2
	},
	array={
		'Default',
		'Day',
		'Night'
	}
}
local user_input = {
	map=1,
	quest_lvl=1,
	quest_life=3,
	time_limit=50,
	hunter_num=4,
	tod=1,
	target_num=1,
	rand=0,
	quest_pick=1,
	filter='',
	filter_mode=1,
	amount_to_generate=1,
	monster0={
		pick=1,
		id=nil
	},
	monster1={
		pick=2,
		id=nil
	},
	monster2={
		pick=3,
		id=nil
	},
	monster5={
		pick=1,
		id=nil
	}
}
local game_state = {
	current=0,
	previous=0
}
local changed = {
	filter=true,
	map=false,
	quest=false,
	target_num=false
}
local quest_pick = {
	quest=nil,
	name=nil,
	sort=nil
}
local authorization = {
	data={
		[0]='Pass',
		[1]='Fail',
		[2]='Quest Level Too High',
		[3]='Research Level Too Low',
		[4]='Invalid Monsters',
		[5]='Quest Level Too Low',
		[6]='Invalid Quest Conditions',
		[-1]='Invalid Map'
	},
	status=0,
	force_pass=false,
	force_check=false,
	check=true
}
local colors = {
	bad=0xff1947ff,
	good=0xff47ff59,
	info=0xff27f3f5,
	info_warn=0xff2787FF,
}
local aie = {
	reload=true,
	quest_counter_open=false,
	target_num_cap=3,
	max_quest_count=120,
	max_quest_level=220,
	max_quest_life=9,
	max_quest_time_limit=50,
	max_quest_hunter_num=4,
	filter_modes={
		'OR',
		'AND'
	},
}
local mass = {
	edit_quest_lvl=false,
	keep_valid=false,
	edit_quest_life=false,
	edit_time_limit=false,
	edit_hunter_num=false,
	edit_tod=false,
	show=1,
	selection={},
	selection_count=0
}


for id, data in pairs(monsters.data) do
	if id ~= "0" then
		for _, map_id in pairs(maps.invalid) do
			monsters.data[id].maps[tostring(map_id)] = true
		end
	end
	monsters.id_table[ data.name..' - '..data.mystery_rank ] = id
end

for name, id in pairs(maps.data) do
	maps.id_table[id] = name
	table.insert(maps.array, name)
end
table.sort(maps.array)

for name, _ in pairs(rand_rank.data) do
	table.insert(rand_rank.array, name)
end
table.sort(rand_rank.array)


local function get_questman()
    if not singletons.questman then
        singletons.questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return singletons.questman
end

local function get_spacewatcher()
    if not singletons.spacewatcher then
        singletons.spacewatcher = sdk.get_managed_singleton('snow.wwise.WwiseChangeSpaceWatcher')
    end
    return singletons.spacewatcher
end

local function get_progman()
    if not singletons.progman then
        singletons.progman = sdk.get_managed_singleton('snow.progress.ProgressManager')
    end
    return singletons.progman
end

local function index_of(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function get_free_quest_no()
	local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData')
	local mystery_quest_no = get_questman():call('getFreeMysteryQuestNo')
	local quest_idx_list = get_questman():call('getFreeSpaceMysteryQuestIDXList', mystery_quest_data, mystery_quest_no, 1, true)
	local free_mystery_idx_list = get_questman():call('getFreeMysteryQuestDataIdx2IndexList', quest_idx_list)
	local mystery_idx = free_mystery_idx_list:call('get_Item', 0)
	return mystery_quest_no + 700000, mystery_idx
end

local function get_quest_count()
	return aie.max_quest_count - get_questman():call('getFreeMysteryQuestDataIndexList', aie.max_quest_count):call('get_Count')
end

local function quest_check(mystery_data)
	authorization.force_check = true
	authorization.status = random_mystery_quest_auth:call(get_questman(), mystery_data, false)

	if authorization.status == 4 and maps.invalid[ maps.id_table[ mystery_data:get_field('_MapNo') ] ] then
		authorization.status = -1
	end

	authorization.force_check = false
	authorization.check = false
	return authorization.status
end

local function get_mystery_quest_data_table()
    local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData')
    mystery_quests.names = {}
    mystery_quests.data = {}
    for i=0, mystery_quest_data:call('get_Count')-1 do
    	local quest = {}
    	quest.data = mystery_quest_data:call('get_Item', i)
    	quest.no = quest.data:get_field('_QuestNo')
        if quest.no ~= -1 then
        	quest.map = quest.data:get_field('_MapNo')

        	if not maps.id_table[quest.map] then goto continue end

        	quest.monsters = quest.data:get_field('_BossEmType')

        	for _, idx in pairs({0, 1, 2, 5}) do

        		quest['monster'..idx] = quest.monsters:call('get_Item', idx)

        		if not monsters.data[ tostring(quest['monster'..idx]) ] then goto continue end
        	end

        	quest.lvl = quest.data:get_field('_QuestLv')
            quest.key = monsters.data[ tostring(quest.monster0) ].name .. '  -  '.. quest.lvl .. '  -  ' .. maps.id_table[quest.map] .. '  -  ' .. quest.no

            table.insert(mystery_quests.names, quest.key)

            mystery_quests.data[ quest.key ] = {
				_QuestNo=quest.no,
				sort=quest.data:get_field('_Idx'),
				name=quest.key,
				index=i,
                _QuestLv=quest.lvl,
                _IsLock=quest.data:get_field('_IsLock'),
                _QuestType=quest.data:get_field('_QuestType'),
                _MapNo=quest.map,
                _BaseTime=quest.data:get_field('_BaseTime'),
                _HuntTargetNum=quest.data:get_field('_HuntTargetNum'),
                monster0=quest.monster0,
                monster1=quest.monster1,
                monster2=quest.monster2,
                monster5=quest.monster5,
                _TimeLimit=quest.data:get_field('_TimeLimit'),
                _QuestLife=quest.data:get_field('_QuestLife'),
                _StartTime=quest.data:get_field('_StartTime'),
                _QuestOrderNum=quest.data:get_field('_QuestOrderNum'),
                data=quest.data,
                selected=mass.selection[quest.no],
                auth=quest_check(quest.data)
			}

			::continue::
        end
    end

    mass.selection = {}
    for k, v in pairs(mystery_quests.data) do
    	if v.selected then
    		mass.selection[v._QuestNo] = k
    	end
    end

    table.sort(mystery_quests.names, function(x, y) return mystery_quests.data[x].sort > mystery_quests.data[y].sort end)
    mystery_quests.dumped = true
end

local function reset_data(reset_quest_pick)
	if not reset_quest_pick then
		quest_pick.name = mystery_quests.names[ user_input.quest_pick ]
	else
		quest_pick.name = nil
		quest_pick.quest = nil
	end

	if quest_pick.name then quest_pick.sort = mystery_quests.data[ quest_pick.name ].sort end

	get_mystery_quest_data_table()
	mystery_quests.count = get_quest_count()
	changed.filter = true
	authorization.check = true
	mass.selection_count = 0
	aie_autoquest_reload = true
end

local function generate_random(id)
	if mystery_quests.count == aie.max_quest_count then return end

	local mystery_data = sdk.create_instance('snow.quest.RandomMysteryQuestData')
	local mystery_quest_no, mystery_index = get_free_quest_no()

	if not mystery_quest_no then
		reset_data()
	 	return
	end

	mystery_data:set_field('_QuestLv', aie.max_quest_level + 1)
	mystery_data:get_field('_BossEmType'):call('set_Item', 0, id)

	create_random_mystery_quest:call(get_questman(), mystery_data, 1, mystery_index, mystery_quest_no, true)

	user_input.quest_pick = 1
	reset_data(true)
end

local function get_valid_level(r_max,current,mystery_data)
	local em_types = mystery_data._BossEmType
	local mons = {}
	local min = 1
	local max = aie.max_quest_level
	local target_num = mystery_data._HuntTargetNum
	local valid_time_limit = {
		[25]={41,aie.max_quest_level},
		[30]={21,aie.max_quest_level},
		[35]={21,aie.max_quest_level},
		[50]={1,aie.max_quest_level},
	}
	local valid_target_num = {
		[3]={41,aie.max_quest_level},
		[2]={21,aie.max_quest_level},
		[1]={1,aie.max_quest_level},
	}
	local valid_quest_life = {
		[9]={1,20},
		[5]={1,90},
		[4]={1,aie.max_quest_level},
		[3]={1,aie.max_quest_level},
		[2]={41,aie.max_quest_level},
		[1]={91,aie.max_quest_level},
	}
	local valid_hunter_num = {
		[4]={1,aie.max_quest_level},
		[2]={71,aie.max_quest_level}
	}
	local valid_time_limit_target_num = {
		[1]={
			[25]=true,
			[30]=true,
			[35]=true,
			[50]=true,
		},
		[2]={
			[30]=true,
			[35]=true,
			[50]=true,
		},
		[3]={
			[50]=true,
		}
	}

	local v1 = valid_time_limit[mystery_data._TimeLimit]
	local v2 = valid_target_num[target_num]
	local v3 = valid_quest_life[mystery_data._QuestLife]
	local v4 = valid_hunter_num[mystery_data._QuestOrderNum]
	local v5 = valid_time_limit_target_num[target_num][mystery_data._TimeLimit]
	if v1 and v2 and v3 and v4 and v5 then
		local vals = {v1, v2, v3, v4}
		for i, val in pairs(vals) do
			if val[1] > min then
				min = val[1]
			end
			if val[2] < max then
				max = val[2]
			end
		end
	else
		return current
	end

	table.insert(mons,get_questman():getRandomMysteryAppearanceMainEmLevel(em_types:get_Item(0)))
	if target_num > 1 then
		for i=1,target_num-1 do
			local mon = em_types:get_Item(i)
			if mon > 0 then
				table.insert(mons,get_questman():getRandomMysteryAppearanceSubEmLevel(mon))
			end
		end
	end
	local mon_min = math.max(table.unpack(mons))
	if mon_min > min then
		min = mon_min
	end

	if min > r_max or min > max then
		return current
	elseif current < min then
		return min
	elseif current > max then
		return max
	else
		return current
	end
end

local function edit_quest()
	if mystery_quests.count == 1 then return end

	local mystery_data_array = {}
	if user_input.mode == 1 then
		if quest_pick.quest.data:get_field('_IsLock') then return end
		mystery_data_array = {quest_pick.quest.data}
	else
		for _,v in pairs(mystery_quests.data) do
			if v.selected and not v._IsLock then
				table.insert(mystery_data_array,v.data)
			end
		end
	end

	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local max = get_progman():get_MysteryResearchLevel()
	local data = {}
	local default = {
		[1]={
			mon0_cond=1,
			mon1_cond=14,
			mon2_cond=14,
			mon5_cond=15,
		},
		[2]={
			mon0_cond=1,
			mon1_cond=1,
			mon2_cond=14,
			mon5_cond=15,
		},
		[3]={
			mon0_cond=3,
			mon1_cond=1,
			mon2_cond=1,
			mon5_cond=0,
		},
		quest_type=2,
	}

	for _,mystery_data in pairs(mystery_data_array) do
		if not mystery_data then
			reset_data()
			return
		end

		data.seed = get_questman():call('getRandomQuestSeedFromQuestNo', mystery_data:get_field('_QuestNo'))
		data.seed_index = mystery_seeds:call('IndexOf', data.seed)

		if not data.seed or not data.seed_index then return end

		if user_input.mode == 1 then
			if user_input.target_num == 2 and monsters.data[user_input.monster1.id].capture
			or user_input.target_num == 3 and (monsters.data[user_input.monster1.id].capture or monsters.data[user_input.monster2.id].capture) then
				default.quest_type = 1
			end

			mystery_data:set_field('_QuestType', default.quest_type)
			mystery_data:set_field('_MapNo', maps.data[ maps.array[ user_input.map ] ])
			mystery_data:set_field('_HuntTargetNum', user_input.target_num)

			data.em_types = mystery_data:get_field('_BossEmType')
			data.em_types:call('set_Item', 0, tonumber(user_input.monster0.id))
			data.em_types:call('set_Item', 1, tonumber(user_input.monster1.id))
			data.em_types:call('set_Item', 2, tonumber(user_input.monster2.id))
			data.em_types:call('set_Item', 5, tonumber(user_input.monster5.id))

			if user_input.monster1.id == 0 then default[user_input.target_num].mon1_cond = 0 end
			if user_input.monster2.id == 0 then default[user_input.target_num].mon2_cond = 0 end
			if user_input.monster5.id == 0 then default[user_input.target_num].mon5_cond = 0 end

			data.em_cond = mystery_data:get_field('_BossSetCondition')
			data.em_cond:call('set_Item', 0, default[user_input.target_num].mon0_cond)
			data.em_cond:call('set_Item', 1, default[user_input.target_num].mon1_cond)
			data.em_cond:call('set_Item', 2, default[user_input.target_num].mon2_cond)
			data.em_cond:call('set_Item', 5, default[user_input.target_num].mon5_cond)

			data.swap_cond = mystery_data:get_field('_SwapSetCondition')
			data.swap_param = mystery_data:get_field('_SwapSetParam')

			if user_input.monster5.id == 0 then
				data.swap_cond:call('set_Item', 0, 0)
				data.swap_param:call('set_Item', 0, 0)
				mystery_data:set_field('_SwapStopType', 0)
				mystery_data:set_field('_SwapExecType', 0)
			else
				data.swap_cond:call('set_Item', 0, 1)
				data.swap_param:call('set_Item', 0, 12)
				mystery_data:set_field('_SwapStopType', 1)
				mystery_data:set_field('_SwapExecType', 1)
			end

			mystery_data:set_field('_MainTargetMysteryRank', monsters.data[user_input.monster0.id].mystery_rank)
			data.seed:set_field('_HuntTargetNum', user_input.target_num)
			data.seed:set_field('_MapNo', maps.data[ maps.array[ user_input.map ] ])
			data.seed:set_field('_QuestType', default.quest_type)
			data.seed:call('setEnemyTypes', data.em_types)
		end

		if user_input.mode == 1 or user_input.mode == 2 and mass.edit_time_limit then
			mystery_data:set_field('_TimeLimit', user_input.time_limit)
			data.seed:set_field('_TimeLimit', user_input.time_limit)
		end
		if user_input.mode == 1 or user_input.mode == 2 and mass.edit_quest_life then
			mystery_data:set_field('_QuestLife', user_input.quest_life)
			data.seed:set_field('_QuestLife', user_input.quest_life)
		end
		if user_input.mode == 1 or user_input.mode == 2 and mass.edit_hunter_num then
			mystery_data:set_field('_QuestOrderNum', user_input.hunter_num)
			data.seed:set_field('_QuestOrderNum', user_input.hunter_num)
		end
		if user_input.mode == 1 or user_input.mode == 2 and mass.edit_tod then
			mystery_data:set_field('_StartTime', tod.data[ tod.array[ user_input.tod ] ])
			data.seed:set_field('_StartTime', tod.data[ tod.array[ user_input.tod ] ])
		end
		if user_input.mode == 1 or user_input.mode == 2 and mass.edit_quest_lvl then
			local level = user_input.quest_lvl
			if user_input.mode == 2 and mass.keep_valid then
				level = get_valid_level(max,level,mystery_data)
			end
			mystery_data:set_field('_QuestLv', level)
			data.seed:set_field('_QuestLv', level)
		end

		mystery_data:set_field('_IsNewFlag', true)
		mystery_data:set_field('_OriginQuestLv', 0)
		data.seed:set_field('_MysteryLv', aie.max_quest_level)
		data.seed:set_field('_OriginQuestLv', 0)
		mystery_seeds:call('set_Item', data.seed_index, data.seed)
	end

	reset_data()
end

local function get_arrays()
	local map_id = tostring( maps.data[ maps.array[ user_input.map ] ] )

	monster_arrays.main.current = {}
	monster_arrays.extra.current = {}
	monster_arrays.intruder.current = {}
	monster_arrays.main.map_valid = {}
	monster_arrays.extra.map_valid = {}
	monster_arrays.intruder.map_valid = {}

	user_input.monster0.pick = 1
	user_input.monster1.pick = 2
	user_input.monster2.pick = 3
	user_input.monster5.pick = 1

	for name, id in pairs(monsters.id_table) do
		if monsters.data[id].maps[map_id] then
			if monsters.data[id].main then
				table.insert(monster_arrays.main.map_valid, name)
			end
			table.insert(monster_arrays.extra.map_valid, name)
			table.insert(monster_arrays.intruder.map_valid, name)
		end
	end

	table.insert(monster_arrays.intruder.map_valid, 'None - 0')
	table.insert(monster_arrays.extra.map_valid, 'None - 0')

	table.sort(monster_arrays.main.map_valid)
	table.sort(monster_arrays.extra.map_valid)
	table.sort(monster_arrays.intruder.map_valid)

	monster_arrays.main.current = monster_arrays.main.map_valid
	monster_arrays.extra.current = monster_arrays.extra.map_valid
	monster_arrays.intruder.current = monster_arrays.intruder.map_valid

end

local function split_str(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^/"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function starts_with(str, pattern)
   return string.sub(str, 1, string.len(pattern)) == pattern
end

local function get_operator(str)
	local ops = {
		['!=']=function(x, y) return x ~= y end,
		['>=']=function(x, y) return x >= y end,
		['<=']=function(x, y) return x <= y end,
		['<']=function(x, y) return x < y end,
		['>']=function(x, y) return x > y end,
		['=']=function(x, y) return x == y end
	}

	for op, func in pairs(ops) do
		if starts_with(str,op) then
			local t = split_str(str,op)
			if t and #t == 1 then
				local number = tonumber(t[1])
				if number then
					return ops[op], number
				end
			end
		end
	end
end

local function filter_names()
	mystery_quests.names_filtered = {}
	user_input.quest_pick = nil
	local query = split_str(user_input.filter,';')
	for _, name in ipairs(mystery_quests.names) do
		if #query > 0 then
			for _, q in pairs(query) do
				if q == '(' or starts_with(q,'[') then goto next end
				local func, number = get_operator(q)

				if (
					func
					and func(mystery_quests.data[name]._QuestLv,number)
					or (
					    not func
					    and string.find(name:lower(), q:lower())
					)
				) then
					if user_input.filter_mode == 1 then
						table.insert(mystery_quests.names_filtered, name)
						goto continue
					end
				else
					if user_input.filter_mode == 2 then goto continue end
				end

				::next::
			end

			if user_input.filter_mode == 2 then
				table.insert(mystery_quests.names_filtered, name)
			end
		else
			table.insert(mystery_quests.names_filtered, name)
		end
		::continue::
	end

	if #mystery_quests.names_filtered > 0 and quest_pick.name then
		user_input.quest_pick = index_of(mystery_quests.names_filtered, quest_pick.name)
		if not user_input.quest_pick then
			for _, quest in pairs(mystery_quests.data) do
				if quest.sort == quest_pick.sort then
					user_input.quest_pick = index_of(mystery_quests.names_filtered, quest.name)
					break
				end
			end
		end
	end

	if not user_input.quest_pick then
		user_input.quest_pick = 1
		aie.reload = true
		authorization.check = true
	end
end

local function get_monster_pick(array, monster_id)
	local monster = {
		name=monsters.data[ tostring(monster_id) ].name,
		rank=monsters.data[ tostring(monster_id) ].mystery_rank
	}
	return index_of(array, monster.name..' - '..monster.rank)
end

local function reset_input()
	user_input.map = index_of(maps.array, maps.id_table[ quest_pick.quest._MapNo ])
	get_arrays()

	user_input.tod = quest_pick.quest._StartTime + 1
	user_input.quest_lvl = quest_pick.quest._QuestLv
	user_input.target_num = quest_pick.quest._HuntTargetNum
	user_input.quest_life = quest_pick.quest._QuestLife
	user_input.time_limit = quest_pick.quest._TimeLimit
	user_input.hunter_num = quest_pick.quest._QuestOrderNum
	aie.target_num_cap = 3

	if maps.invalid[ maps.id_table[ quest_pick.quest._MapNo ] ] then
		monster_arrays.extra.current = {'None - 0'}
		monster_arrays.intruder.current = {'None - 0'}
		aie.target_num_cap = 1
	elseif user_input.target_num == 3 then
		monster_arrays.intruder.current = {'None - 0'}
	end

	user_input.monster0.pick = get_monster_pick(monster_arrays.main.current, quest_pick.quest.monster0)
	user_input.monster1.pick = get_monster_pick(monster_arrays.extra.current, quest_pick.quest.monster1)
	user_input.monster2.pick = get_monster_pick(monster_arrays.extra.current, quest_pick.quest.monster2)
	user_input.monster5.pick = get_monster_pick(monster_arrays.intruder.current, quest_pick.quest.monster5)

	aie.reload = false
end

local function wipe()
	local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData'):get_elements()
	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local data = {}

	data.newest_quest_no = mystery_quests.data[ mystery_quests.names[1] ]._QuestNo

	for _, quest in ipairs(mystery_quest_data) do
		data.no = quest:get_field('_QuestNo')
		if not quest:get_field('_IsLock') and data.no ~= -1 and data.no ~= data.newest_quest_no then
			data.seed = get_questman():call('getRandomQuestSeedFromQuestNo', data.no)
			data.seed_index = mystery_seeds:call('IndexOf', data.seed)
			quest:call('clear')
			data.seed:call('clear')
			mystery_seeds:call('set_Item', data.seed_index, data.seed)
		end
	end
	reset_data(true)
end

local function lock_unlock_quest()
	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local mystery_data_array = {}

	if user_input.mode == 1 then
		mystery_data_array = {quest_pick.quest}
	else
		mystery_data_array = {}
		for _,v in pairs(mystery_quests.data) do
			if v.selected then
				table.insert(mystery_data_array,v)
			end
		end
	end
	for _,quest in pairs(mystery_data_array) do
		local seed = get_questman():call('getRandomQuestSeedFromQuestNo', quest.data._QuestNo)
		local seed_index = mystery_seeds:call('IndexOf', seed)
		quest.data._IsLock = not quest.data._IsLock
		quest._IsLock = not quest._IsLock
		seed:set_field('_IsLock', quest._IsLock)
		mystery_seeds:call('set_Item', seed_index, seed)
	end
end

local function create_table(tbl)
	if imgui.begin_table(tbl.name, tbl.col_count, tbl.flags) then
		for row=0, tbl.row_count-1 do

			if row == 0 then
				imgui.table_next_row(1)
			else
				imgui.table_next_row()
			end

			for col=0, tbl.col_count-1 do
				imgui.table_set_column_index(col)
				imgui.text(tbl.data[row+1][col+1])
			end

		end
		imgui.end_table()
	end
end

local function get_sub_window_pos()
	local main_window_pos = imgui.get_window_pos()
	local main_window_size = imgui.get_window_size()
	return Vector2f.new(main_window_pos.x + main_window_size.x, main_window_pos.y)
end

local function filter_button()
	imgui.same_line()
	if imgui.button(aie.filter_modes[user_input.filter_mode]) then
		user_input.filter_mode = user_input.filter_mode + 1
		if user_input.filter_mode > #aie.filter_modes then
			user_input.filter_mode = 1
		end
		filter_names()
	end
	imgui.same_line()
	imgui.text('(?)')
    if imgui.is_item_hovered() then
        imgui.set_tooltip(
			'Delimiter:   ;\n\n' ..
			'e.g.\n' ..
			'Lagombi - 105 - Citadel - 700001\n' ..
			'Volvidon - 150 - Lava Caverns - 700002\n' ..
			'Lagombi - 200 - Frost Islands - 700003\n\n' ..
			'OR\n'..
			'Query: lagombi;volvidon\n' ..
			'Result:\n' ..
			'Lagombi - 105 - Citadel - 700001\n' ..
			'Volvidon - 150 - Lava Caverns - 700002\n\n' ..
			'AND\n'..
			'Query: lagombi;citadel\n' ..
			'Result:\n' ..
			'Lagombi - 105 - Citadel - 700001\n\n' ..
			'Searching by level is also supported\n' ..
			'Operators: !=, >=, <=, <, >, =\n\n' ..
			'Query: >=150\n' ..
			'Result:\n' ..
			'Volvidon - 150 - Lava Caverns - 700002\n' ..
			'Lagombi - 200 - Frost Islands - 700003'
		)
    end
end

local function popup_yesno(str,key)
	local bool = false
	if imgui.begin_popup(key) then
		imgui.spacing()
		imgui.text('   '..str..'   ')
		imgui.spacing()
		if imgui.button('Yes') then
			imgui.close_current_popup()
			bool = true
		end
		imgui.same_line()
		if imgui.button('No') then
			imgui.close_current_popup()
		end
		imgui.spacing()
		imgui.end_popup()
	end
	return bool
end

function mass_window.draw()
	mass_window.pos = get_sub_window_pos()
    imgui.set_next_window_pos(mass_window.pos, mass_window.condition, mass_window.pivot)
	imgui.set_next_window_size(mass_window.size, mass_window.condition)

	if imgui.begin_window("Quest Selection And Settings", mass_window.is_opened, mass_window.flags) then
		imgui.spacing()
		if imgui.collapsing_header('Settings') then
			imgui.indent(10)

			_, mass.edit_quest_lvl = imgui.checkbox('Edit Level', mass.edit_quest_lvl)
			imgui.same_line()
			_, mass.keep_valid = imgui.checkbox('Keep Valid', mass.keep_valid)
			imgui.same_line()
			imgui.text('(?)')

		    if imgui.is_item_hovered() then
		        imgui.set_tooltip('Keeps quest level within valid range if possible')
		    end

			_, mass.edit_quest_life = imgui.checkbox('Edit Quest Life', mass.edit_quest_life)
			_, mass.edit_time_limit = imgui.checkbox('Edit Time Limit', mass.edit_time_limit)
			_, mass.edit_hunter_num = imgui.checkbox('Edit Hunter Num', mass.edit_hunter_num)
			_, mass.edit_tod = imgui.checkbox('Edit Time of Day', mass.edit_tod)

			imgui.unindent(10)
	        imgui.separator()
			imgui.spacing()
		end

		if imgui.collapsing_header('Quest Selection') then
			imgui.indent(10)
			_, mass.show = imgui.combo('Show', mass.show, {'All', 'Selected', 'Not Selected'})
			changed.filter, user_input.filter = imgui.input_text('Filter', user_input.filter)
			filter_button()
			imgui.spacing()

			if imgui.button('Select All') then
				for _, name in pairs(mystery_quests.names_filtered) do
					local item = mystery_quests.data[name]
					item.selected = true
					mass.selection[item._QuestNo] = name
				end
			end
			imgui.same_line()

			if imgui.button('Unselect All') then
				for _, name in pairs(mystery_quests.names_filtered) do
					local item = mystery_quests.data[name]
					item.selected = false
					mass.selection[item._QuestNo] = nil
				end
			end
			imgui.separator()

			for i, name in pairs(mystery_quests.names_filtered) do
				local item = mystery_quests.data[name]
				if (
					mass.show == 2
					and item.selected
					or (
					    mass.show == 3
					    and not item.selected
					) or mass.show == 1
				) then
					item.changed, item.selected = imgui.checkbox(item.name, item.selected)
					imgui.same_line()
					imgui.text('(?)')

				    if imgui.is_item_hovered() then
				        imgui.set_tooltip(
				        	'Monster2: ' .. monsters.data[tostring(item.monster1)].name ..
				        	'\nMonster3: ' .. monsters.data[tostring(item.monster2)].name ..
				        	'\nIntruder: ' .. monsters.data[tostring(item.monster5)].name ..
				        	'\nTarget Num: ' .. item._HuntTargetNum ..
				        	'\nTime Limit: ' .. item._TimeLimit ..
				        	'\nQuest Life: ' .. item._QuestLife ..
				        	'\nTime of Day: ' .. tod.array[item._StartTime] ..
				        	'\nHunter Num: ' .. item._QuestOrderNum
				        )
				    end

					if item.auth ~= 0 then
						imgui.same_line()
						imgui.text_colored(authorization.data[item.auth],authorization.force_pass and colors.good or colors.bad)
					end

					if item._IsLock then
						imgui.same_line()
						imgui.text_colored('Locked - Editing Disabled', colors.info_warn)
					end

					if item.changed then
						if item.selected then
							mass.selection[item._QuestNo] = item.name
						else
							mass.selection[item._QuestNo] = nil
						end
					end
				end
			end

			imgui.unindent(10)
	        imgui.separator()
			imgui.spacing()
		end
		imgui.end_window()
	else
		if mass_window.is_opened then imgui.end_window() end
		mass_window.is_opened = false
	end
end

function sub_window.draw()
	sub_window.pos = get_sub_window_pos()
    imgui.set_next_window_pos(sub_window.pos, sub_window.condition, sub_window.pivot)
	imgui.set_next_window_size(sub_window.size, sub_window.condition)

	if imgui.begin_window("Valid Combinations", sub_window.is_opened, sub_window.flags) then
		create_table(table_2)
		imgui.new_line()
		create_table(table_3)
		imgui.new_line()
		imgui.text("Invalid maps: Infernal Springs, Arena, Forlorn Arena")
		imgui.text('Quest cant have duplicate monsters.')
		imgui.text('Quest cant have two Apex monsters.')
		imgui.text('Apex monsters cant be intruders.')
		imgui.text('Risen EDs can appear only as a main target.')
		imgui.end_window()
	else
		if sub_window.is_opened then imgui.end_window() end
		sub_window.is_opened = false
	end
end

function main_window.draw()
	imgui.push_style_var(11, 5.0) -- Rounded elements
    imgui.push_style_var(2, 10.0) -- Window Padding
    imgui.set_next_window_pos(main_window.pos, main_window.condition, main_window.pivot)
    imgui.set_next_window_size(main_window.size, main_window.condition)

    if imgui.begin_window("Anomaly Investigations Editor "..version, main_window.is_opened, main_window.flags) then

		if get_spacewatcher() then
			game_state.current = get_spacewatcher():get_field('_GameState')
		end

		if aie.quest_counter_open or game_state.current ~= 4 or get_questman():call('isActiveQuest') then
			imgui.text_colored('Mod works only in the lobby with quest counter closed.', colors.bad)
		else

			if get_questman() and not mystery_quests.dumped and game_state.current == 4
			or game_state.current == 4 and game_state.previous ~= 4 then
				reset_data(true)
			end

			imgui.spacing()
			imgui.indent(10)
	        imgui.text('Quest Count: ')
	        imgui.same_line()
	        imgui.text_colored(mystery_quests.count, mystery_quests.count > 1 and mystery_quests.count < aie.max_quest_count and colors.info or colors.info_warn)
	        imgui.same_line()
	        imgui.text('/  '..aie.max_quest_count)
	        _, authorization.force_pass = imgui.checkbox('Force Authorization Pass', authorization.force_pass)
	        imgui.separator()
	        imgui.spacing()
	        imgui.unindent(10)

		    if imgui.collapsing_header('Editor') then
    			imgui.indent(10)

				if changed.filter then filter_names() end

				changed.mode, user_input.mode = imgui.combo('Mode', user_input.mode, {'Single Quest', 'Multiple Quests'})
				if changed.mode then
					user_input.quest_pick = 1
					aie.reload = true
				end

				if user_input.mode == 1 then
					changed.filter, user_input.filter = imgui.input_text('Filter', user_input.filter)
					filter_button()
					changed.quest, user_input.quest_pick = imgui.combo('Quest', user_input.quest_pick, mystery_quests.names_filtered)
			        quest_pick.quest = mystery_quests.data[ mystery_quests.names_filtered[ user_input.quest_pick ] ]
			        mass_window.is_opened = false
			    else
			    	mass_window.is_opened = true
			    	imgui.text('Quests Selected: ')
			    	imgui.same_line()
					mass.selection_count = 0
					quest_pick.quest = nil
					for _, v in pairs(mass.selection) do
						if v then
							mass.selection_count = mass.selection_count + 1
							if not quest_pick.quest then
								quest_pick.quest = mystery_quests.data[v]
							end
						end
					end
			    	imgui.text_colored(mass.selection_count, colors.info)
			    end

		        if quest_pick.quest then
					if changed.map then
						get_arrays()
						if maps.invalid[ maps.array[user_input.map] ] then
							aie.target_num_cap = 1
							user_input.target_num = 1
						else
							aie.target_num_cap = 3
						end
						changed.target_num = true
					end

					if changed.target_num then
						if maps.invalid[ maps.array[user_input.map] ] then
							monster_arrays.extra.current = {'None - 0'}
							monster_arrays.intruder.current = {'None - 0'}
						else
							if user_input.target_num < 3 then
								monster_arrays.intruder.current = monster_arrays.intruder.map_valid
								user_input.monster5.pick = get_monster_pick(monster_arrays.intruder.current, quest_pick.quest.monster5)
							else
								monster_arrays.intruder.current = {'None - 0'}
							end
						end
					end

					if changed.quest then aie.reload = true end

					if changed.quest or authorization.check then
						quest_pick.quest.auth = quest_check(quest_pick.quest.data)
					end

					if aie.reload and mystery_quests.dumped then reset_input() end

					if user_input.mode == 1 then

				        imgui.text('Quest Level: ')
				        imgui.same_line()
				        imgui.text_colored(quest_pick.quest._QuestLv, colors.info)
				        imgui.text('Map: ')
				        imgui.same_line()
				        imgui.text_colored(maps.id_table[ quest_pick.quest._MapNo ], colors.info)
				        imgui.text('Monster 1: ')
						imgui.same_line()
				        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster0) ].name, colors.info)
				        imgui.text('Monster 2: ')
				        imgui.same_line()
				        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster1) ].name, colors.info)
				        imgui.text('Monster 3: ')
				        imgui.same_line()
				        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster2) ].name, colors.info)
				        imgui.text('Intruder: ')
				        imgui.same_line()
				        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster5) ].name, colors.info)
				        imgui.text('Target Num: ')
				        imgui.same_line()
				        imgui.text_colored(quest_pick.quest._HuntTargetNum, colors.info)
				        imgui.text('Time Limit: ')
				        imgui.same_line()
				        imgui.text_colored(quest_pick.quest._TimeLimit, colors.info)
				        imgui.text('Quest Life: ')
				        imgui.same_line()
				        imgui.text_colored(quest_pick.quest._QuestLife, colors.info)
				        imgui.text('Time of Day: ')
				        imgui.same_line()
				        imgui.text_colored(tod.array[ quest_pick.quest._StartTime +1], colors.info)
				        imgui.text('Hunter Num: ')
				        imgui.same_line()
				        imgui.text_colored(quest_pick.quest._QuestOrderNum, colors.info)
				        imgui.text('Lock: ')
				        imgui.same_line()
				        imgui.text_colored(quest_pick.quest._IsLock and 'Yes - Editing Disabled' or 'No', quest_pick.quest._IsLock and colors.info_warn or colors.info)
				    	imgui.text('Auth Status: ')
				    	imgui.same_line()
				    	imgui.text_colored((quest_pick.quest.auth == 0 and "Pass" or authorization.data[quest_pick.quest.auth]), (authorization.force_pass and colors.good or quest_pick.quest.auth == 0 and colors.good or colors.bad))
				    end

				    if user_input.mode == 1 then
						changed.map, user_input.map = imgui.combo('Map', user_input.map, maps.array)
					end

					if user_input.mode == 1 then
						imgui.new_line()
						imgui.text('Name - Mystery Rank')
						_, user_input.monster0.pick = imgui.combo('Monster 1', user_input.monster0.pick, monster_arrays.main.current)
						_, user_input.monster1.pick = imgui.combo('Monster 2', user_input.monster1.pick, monster_arrays.extra.current)
						_, user_input.monster2.pick = imgui.combo('Monster 3', user_input.monster2.pick, monster_arrays.extra.current)
						_, user_input.monster5.pick = imgui.combo('Intruder', user_input.monster5.pick, monster_arrays.intruder.current)
					end

					if user_input.mode == 1 then
						imgui.new_line()
					end

					if user_input.mode == 1 or user_input.mode == 2 and mass.edit_tod then
						_, user_input.tod = imgui.combo('Time of Day', user_input.tod, tod.array)
					end
					if user_input.mode == 1 or user_input.mode == 2 and mass.edit_quest_lvl then
						_, user_input.quest_lvl = imgui.slider_int('Quest Level', user_input.quest_lvl, 1, aie.max_quest_level)
					end
					if user_input.mode == 1 then
						changed.target_num, user_input.target_num = imgui.slider_int('Target Num', user_input.target_num, 1, aie.target_num_cap)
					end
					if user_input.mode == 1 or user_input.mode == 2 and mass.edit_quest_life then
						_, user_input.quest_life = imgui.slider_int('Quest Life', user_input.quest_life, 1, aie.max_quest_life)
					end
					if user_input.mode == 1 or user_input.mode == 2 and mass.edit_time_limit then
						_, user_input.time_limit = imgui.slider_int('Time Limit', user_input.time_limit, 1, aie.max_quest_time_limit)
					end
					if user_input.mode == 1 or user_input.mode == 2 and mass.edit_hunter_num then
						_, user_input.hunter_num = imgui.slider_int('Hunter Num', user_input.hunter_num, 1, aie.max_quest_hunter_num)
					end

					user_input.monster0.id = monsters.id_table[ monster_arrays.main.current[ user_input.monster0.pick ] ]
					user_input.monster1.id = monsters.id_table[ monster_arrays.extra.current[ user_input.monster1.pick ] ]
					user_input.monster2.id = monsters.id_table[ monster_arrays.extra.current[ user_input.monster2.pick ] ]
					user_input.monster5.id = monsters.id_table[ monster_arrays.intruder.current[ user_input.monster5.pick ] ]
				end

				if sub_window.is_opened then
					sub_window.draw()
				end

				if mass_window.is_opened then
					mass_window.draw()
				end

				if (
					quest_pick.quest
					and (
						 user_input.mode == 1
						 or (
						     user_input.mode == 2
						     and (
						          mass.edit_tod
						          or mass.edit_quest_lvl
						          or mass.edit_quest_life
						          or mass.edit_time_limit
						          or mass.edit_hunter_num
						     )
					     )
					)
				) then
					if imgui.button('Edit Quest') then
						if user_input.mode == 1 then
							edit_quest()
						elseif user_input.mode == 2 and mass.selection_count > 0 then
							imgui.open_popup('edit')
						end
					end
					if popup_yesno('Are you sure?','edit') then
						edit_quest()
					end
					imgui.same_line()
				end

				if quest_pick.quest then
					if imgui.button('Lock/Unlock') then lock_unlock_quest() end
					imgui.same_line()
				end
				if imgui.button('Valid Combinations') then sub_window.is_opened = true end

				imgui.unindent(10)
		        imgui.separator()
    			imgui.spacing()
    		else
    			sub_window.is_opened = false
			end

			if imgui.collapsing_header('Generator') then
    			imgui.indent(10)

				_, user_input.rand = imgui.combo('Random Quest Rank', user_input.rand, rand_rank.array)
				_, user_input.amount_to_generate = imgui.slider_int('Amount', user_input.amount_to_generate, 1, aie.max_quest_count - 1)
				imgui.spacing()

				if imgui.button('Generate Random Quest') then
					local amount = user_input.amount_to_generate
					if mystery_quests.count + amount > aie.max_quest_count then
						amount = aie.max_quest_count - mystery_quests.count
					end
					for i=1, amount do
						generate_random(rand_rank.data[ rand_rank.array[user_input.rand] ])
					end
				end

				imgui.same_line()
				if imgui.button('Delete Quests') then
					imgui.open_popup('delete')
				end

			    if imgui.is_item_hovered() then
			        imgui.set_tooltip('Deletes all quests except newest one and locked ones')
			    end

				if popup_yesno('Are you sure?','delete') then
					wipe()
				end

				if imgui.tree_node('Probabilities at ' .. aie.max_quest_level .. ' Research Level') then
					create_table(table_1)
					imgui.tree_pop()
				end

				imgui.unindent(10)
		        imgui.separator()
    			imgui.spacing()
			end
		end
		game_state.previous = game_state.current
		imgui.pop_style_var(2)
    	imgui.end_window()
    else
    	if main_window.is_opened then
    		imgui.pop_style_var(2)
    		imgui.end_window()
    	end
    	main_window.is_opened = false
    	sub_window.is_opened = false
    	mass_window.is_opened = false
    end
end


sdk.hook(
	random_mystery_quest_auth,
	function(args)
		end,
	function(retval)
		if authorization.force_pass and aie.quest_counter_open and not authorization.force_check then
			return sdk.to_ptr(0)
		else
			return retval
		end
	end
)


sdk.hook(
	sdk.find_type_definition('snow.SnowSingletonBehaviorRoot`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('awake'),
    function(args)
    	aie.quest_counter_open = true
    end
)

sdk.hook(
	sdk.find_type_definition('snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('onDestroy'),
    function(args)
    	reset_data()
    	aie.quest_counter_open = false
    end
)


if sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager') then aie.quest_counter_open = true end


re.on_frame(function()
	if not reframework:is_drawing_ui() then
	    main_window.is_opened = false
	    sub_window.is_opened = false
	    mass_window.is_opened = false
	end
end
)

re.on_draw_ui(function()
    if imgui.button("Anomaly Investigations Editor "..version) then
        main_window.is_opened = true
    end

    if main_window.is_opened then
    	main_window.draw()
    end
end)

