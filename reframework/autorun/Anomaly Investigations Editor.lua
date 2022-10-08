local monsters = json.load_file('Anomaly Investigations Editor/monsters.json')

if not monsters then return end

local questman = nil
local spacewatcher = nil

local create_rand_myst = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('CreateRandomMysteryQuest')
local check_auth = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('checkRandomMysteryQuestOrderBan')

local window_flags = 0x10120
local window_pos = Vector2f.new(400, 200)
local window_pivot = Vector2f.new(0, 0)
local window_size = Vector2f.new(560, 820)
local is_opened = false
local version = '1.2.1'

local table_flags = 0x12780
local table_row_flags = 0x1
local table_ = {
	{'','1    ','1-4','1-5','2-6','3-6','4-6','5-6'},
	{'1',100,25,10,0,0,0,0},
	{'2',0,40,25,10,0,0,0},
	{'3',0,30,35,25,15,0,0},
	{'4',0,5,25,40,30,20,0},
	{'5',0,0,5,20,40,35,35},
	{'6',0,0,0,5,15,45,65},
}

local monster_main_array = {}
local monster_extra_array = {}
local monster_intruder_array = {}
local monster_intruder_array_ = {}
local monsters_id_table = {}
local maps_table = {}
local maps_array = {}
local mystery_quests = {}
local mystery_quests_names = {}
local mystery_quests_names_filtered = {}
local maps = {
		    Citadel=13,
		    ["Flooded Forest"]=3,
		    ["Frost Islands"]=4,
		    Jungle=12,
		    ["Lava Caverns"]=5,
		    ["Sandy Plains"]=2,
		    ["Shrine Ruins"]=1
			}
local time_of_day = {
				Default=0,
				Day=1,
				Night=2
				}
local time_of_day_array = {'Default','Day','Night'}
local auth_status_dict = {
					[0]='Pass',
					[1]='Fail',
					[2]='Quest Level Too High',
					[3]='Monster Rank Too High For Quest Level',
					[4]='Duplicate Monsters'
					}
local rand_rank = {
			['1']=0,
			['1-4']=107,
			['1-5']=19,
			['2-6']=1,
			['3-6']=349,
			['4-6']=351,
			['5-6']=350
}
local rand_rank_array = {}
local change_vals = true
local filter = ''
local filter_c = true
local pick_name = nil
local qc_open = false
local map_c = false
local id_c = false
local tn_c = true
local auth_status = true
local auth_check = true
local dumped = false
local quest_id = nil
local quest = nil
local force_auth_pass = false
local force_check = false
local monster0_id = nil
local monster1_id = nil
local monster2_id = nil
local monster5_id = nil
local game_state = 0
local prev_game_state = 0
local quest_count = 1
local id_pick = 1
local map = 1
local monster0 = 1
local monster1 = 2
local monster2 = 3
local monster5 = 1
local quest_lvl = 1
local quest_life = 3
local time_limit = 50
local hunter_num = 4
local tod = 1
local target_num = 1
local rand_id = 0


for id,data in pairs(monsters) do
	monsters_id_table[ data['name'] ] = id
end

for name,id in pairs(maps) do
	maps_table[id] = name
	table.insert(maps_array,name)
end
table.sort(maps_array)

for k,_ in pairs(rand_rank) do
	table.insert(rand_rank_array,k)
end
table.sort(rand_rank_array)

local function get_questman()
    if not questman then
        questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return questman
end

local function get_spacewatcher()
    if not spacewatcher then
        spacewatcher = sdk.get_managed_singleton('snow.wwise.WwiseChangeSpaceWatcher')
    end
    return spacewatcher
end

local function get_free_quest_no()
	local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData')
	local mystery_quest_no = get_questman():call('getFreeMysteryQuestNo')
	local quest_idx_list = get_questman():call('getFreeSpaceMysteryQuestIDXList',mystery_quest_data,mystery_quest_no,1,true)
	local free_mystery_idx_list = get_questman():call('getFreeMysteryQuestDataIdx2IndexList',quest_idx_list)
	local mystery_idx = free_mystery_idx_list:call('get_Item',0)
	return mystery_quest_no + 700000,mystery_idx
end

local function get_quest_count()
	return 120 - get_questman():call('getFreeMysteryQuestDataIndexList',120):call('get_Count')
end

local function get_mystery_quest_data_table()
    local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData'):get_elements()
    mystery_quests_names = {}
    mystery_quests = {}
    for i,quest in ipairs(mystery_quest_data) do
        local quest_no = quest:get_field('_QuestNo')
        if quest_no ~= -1 then
            local quest_monsters = quest:get_field('_BossEmType')
            local monster0 = quest_monsters:call('get_Item',0)
            local monster0_name = monsters[ tostring(monster0) ]['name']
            local quest_lvl = quest:get_field('_QuestLv')
            local map_no = quest:get_field('_MapNo')
            local key = monster0_name .. '  -  '.. quest_lvl .. '  -  ' .. maps_table[map_no] .. '  -  ' .. quest_no

            table.insert(mystery_quests_names,key)

            mystery_quests[ key ] = {
            						quest_no=quest_no,
            						sort=quest:get_field('_Idx'),
            						name=key,
            						index=i-1,
                                    _QuestLv=quest_lvl,
                                    _QuestType=quest:get_field('_QuestType'),
                                    _MapNo=map_no,
                                    _BaseTime=quest:get_field('_BaseTime'),
                                    _HuntTargetNum=quest:get_field('_HuntTargetNum'),
                                    monster0=monster0,
                                    monster1=quest_monsters:call('get_Item',1),
                                    monster2=quest_monsters:call('get_Item',2),
                                    monster5=quest_monsters:call('get_Item',5),
                                    _TimeLimit=quest:get_field('_TimeLimit'),
                                    _QuestLife=quest:get_field('_QuestLife'),
                                    _StartTime=quest:get_field('_StartTime'),
                                    _QuestOrderNum=quest:get_field('_QuestOrderNum'),
                                    data=quest
                                    }
        end
    end

    table.sort(mystery_quests_names,function(x,y) return mystery_quests[x]['sort'] > mystery_quests[y]['sort'] end)
    dumped = true
end

local function reset_data(skip)
	if not skip then
		pick_name = mystery_quests_names[ id_pick ]
	else
		pick_name = nil
	end

	if pick_name then pick_sort = mystery_quests[ pick_name ]['sort'] end

	get_mystery_quest_data_table()
	quest_count = get_quest_count()
	filter_c = true
	auth_check = true
end

local function generate_random(id)
	if quest_count == 120 then return end

	local mystery_data = sdk.create_instance('snow.quest.RandomMysteryQuestData')
	local mystery_quest_no,mystery_index = get_free_quest_no()

	if not mystery_quest_no then
		reset_data()
	 	return
	end

	mystery_data:set_field('_QuestLv',200)
	em_types = mystery_data:get_field('_BossEmType')
	em_types:call('set_Item',0,id)

	create_rand_myst:call(get_questman(),mystery_data,1,mystery_index,mystery_quest_no,true)

	id_pick = 1
	reset_data(true)
end

local function random(array)
	local id = nil
	repeat
		id = monsters_id_table[ array[ math.random(#array) ] ]
	until id ~= '0' and id ~= '-1'
	return id
end

local function edit_quest(mystery_data)
	if quest_count == 1 then return end

	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local seed = nil
	local seed_index = nil
	local em_types = nil
	local em_cond = nil
	local swap_cond = nil
	local swap_param = nil
	local quest_type = 2
	local mon0_cond = 1
	local mon1_cond = 14
	local mon2_cond = 14
	local mon5_cond = 15

	if not mystery_data then
		reset_data()
		return
	end

	if monster0_id == '-1' then monster0_id = random(monster_main_array) end
	if monster1_id == '-1' then monster1_id = random(monster_extra_array) end
	if monster2_id == '-1' then monster2_id = random(monster_extra_array) end
	if monster5_id == '-1' then monster5_id = random(monster_intruder_array) end

	if target_num == 2 and monsters[monster1_id]['capture']
	or target_num == 3 and (monsters[monster1_id]['capture'] or monsters[monster2_id]['capture']) then
		quest_type = 1
	end

	mystery_data:set_field('_MapNo',maps[ maps_array[ map ] ])
	mystery_data:set_field('_HuntTargetNum',target_num)
	mystery_data:set_field('_TimeLimit',time_limit)
	mystery_data:set_field('_QuestLife',quest_life)
	mystery_data:set_field('_QuestType',quest_type)
	mystery_data:set_field('_QuestOrderNum',hunter_num)
	mystery_data:set_field('_StartTime',time_of_day[ time_of_day_array[ tod ] ])
	mystery_data:set_field('_QuestLv',quest_lvl)
	mystery_data:set_field('_IsNewFlag',true)

	if target_num == 2 then
		mon1_cond = 1
	elseif target_num == 3 then
		mon0_cond = 3
		mon1_cond = 1
		mon2_cond = 1
		monster5_id = '0'
	end

	em_types = mystery_data:get_field('_BossEmType')
	em_types:call('set_Item',0,tonumber(monster0_id))
	em_types:call('set_Item',1,tonumber(monster1_id))
	em_types:call('set_Item',2,tonumber(monster2_id))
	em_types:call('set_Item',5,tonumber(monster5_id))

	if monster5_id == '0' then mon5_cond = 0 end

	em_cond = mystery_data:get_field('_BossSetCondition')
	em_cond:call('set_Item',0,mon0_cond)
	em_cond:call('set_Item',1,mon1_cond)
	em_cond:call('set_Item',2,mon2_cond)
	em_cond:call('set_Item',5,mon5_cond)

	swap_cond = mystery_data:get_field('_SwapSetCondition')
	swap_param = mystery_data:get_field('_SwapSetParam')

	if monster5_id == '0' then
		swap_cond:call('set_Item',0,0)
		swap_param:call('set_Item',0,0)
		mystery_data:set_field('_SwapStopType',0)
		mystery_data:set_field('_SwapExecType',0)
	else
		swap_cond:call('set_Item',0,1)
		swap_param:call('set_Item',0,12)
		mystery_data:set_field('_SwapStopType',1)
		mystery_data:set_field('_SwapExecType',1)
	end

	mystery_data:set_field('_MainTargetMysteryRank',monsters[monster0_id]['mystery_rank'])

	seed = get_questman():call('getRandomQuestSeedFromQuestNo',mystery_data:get_field('_QuestNo'))
	seed_index = mystery_seeds:call('IndexOf',seed)

	if not seed or not seed_index then return end

	seed:set_field('_QuestLv',quest_lvl)
	seed:set_field('_QuestType',quest_type)
	seed:set_field('_HuntTargetNum',target_num)
	seed:set_field('_MapNo',maps[ maps_array[ map ] ])
	seed:set_field('_TimeLimit',time_limit)
	seed:set_field('_QuestLife',quest_life)
	seed:set_field('_QuestOrderNum',hunter_num)
	seed:set_field('_StartTime',time_of_day[ time_of_day_array[ tod ] ])
	seed:set_field('_MysteryLv',200)
	seed:call('setEnemyTypes',em_types)
	mystery_seeds:call('set_Item',seed_index,seed)

	reset_data()
end

local function get_arrays()
	local map_id = tostring( maps[ maps_array[ map ] ] )

	monster_main_array = {}
	monster_extra_array = {}
	monster_intruder_array_ = {}

	monster0 = 1
	monster1 = 2
	monster2 = 3
	monster5 = 1

	for name,id in pairs(monsters_id_table) do
		if monsters[id]['maps'][map_id] then
			if monsters[id]['main'] then
				table.insert(monster_main_array,name)
			end
			table.insert(monster_extra_array,name)
			table.insert(monster_intruder_array_,name)
		end
	end

	table.insert(monster_intruder_array_,'None')

	table.sort(monster_main_array)
	table.sort(monster_extra_array)
	table.sort(monster_intruder_array_)

	monster_intruder_array = monster_intruder_array_
end

local function index_of(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function filter_names()
	mystery_quests_names_filtered = {}
	id_pick = nil

	for _,k in ipairs(mystery_quests_names) do
		if string.find(k:lower(),filter:lower()) then
			table.insert(mystery_quests_names_filtered,k)
		end
	end

	if #mystery_quests_names_filtered > 0 and pick_name then
		id_pick = index_of(mystery_quests_names_filtered,pick_name)
		if not id_pick then
			for _,k in pairs(mystery_quests) do
				if k['sort'] == pick_sort then
					id_pick = index_of(mystery_quests_names_filtered,k['name'])
					break
				end
			end
		end
	end

	if not id_pick then
		id_pick = 1
		change_vals = true
		auth_check = true
	end
end

local function reset_input()
	map = index_of(maps_array,maps_table[ quest['_MapNo'] ])
	get_arrays()

	tod = quest['_StartTime'] + 1
	quest_lvl = quest['_QuestLv']
	target_num = quest['_HuntTargetNum']
	quest_life = quest['_QuestLife']
	time_limit = quest['_TimeLimit']
	hunter_num = quest['_QuestOrderNum']

	if target_num == 3 then
		monster_intruder_array = {'None'}
	else
		monster_intruder_array = monster_intruder_array_
	end

	monster0 = index_of(monster_main_array,monsters[ tostring(quest['monster0']) ]['name'])
	monster1 = index_of(monster_extra_array,monsters[ tostring(quest['monster1']) ]['name'])
	monster2 = index_of(monster_extra_array,monsters[ tostring(quest['monster2']) ]['name'])
	monster5 = index_of(monster_intruder_array,monsters[ tostring(quest['monster5']) ]['name'])

	change_vals = false
end

local function quest_check(mystery_data)
	force_check = true
	auth_status = check_auth:call(get_questman(),mystery_data)
	force_check = false
	auth_check = false
end

local function wipe()
	local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData'):get_elements()
	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local quest_no = nil
	local newest_no = mystery_quests[ mystery_quests_names[1] ]['quest_no']

	for _,quest in ipairs(mystery_quest_data) do
		quest_no = quest:get_field('_QuestNo')
		if not quest:get_field('_IsLock') and quest_no ~= -1 and quest_no ~= newest_no then
			seed = get_questman():call('getRandomQuestSeedFromQuestNo',quest:get_field('_QuestNo'))
			seed_index = mystery_seeds:call('IndexOf',seed)
			quest:call('clear')
			seed:call('clear')
			mystery_seeds:call('set_Item',seed_index,seed)
		end
	end
	reset_data(true)
end


sdk.hook(check_auth,
	function(args)
		end,
	function(retval)
		if force_auth_pass and not force_check then
			return sdk.to_ptr(0)
		else
			return retval
		end
	end
)

sdk.hook(
    sdk.find_type_definition('snow.SnowSingletonBehaviorRoot`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('awake'),
    function(args)
    	qc_open = true
    end
)

sdk.hook(sdk.find_type_definition('snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('onDestroy'),
    function(args)
    	reset_data()
    	qc_open = false
    end
)


if sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager') then qc_open = true end


re.on_frame(function()
	if not reframework:is_drawing_ui() then
	    is_opened = false
	end
end
)

re.on_draw_ui(function()
    if imgui.button("Anomaly Investigations Editor "..version) then
        is_opened = true
    end

    if is_opened then

	    imgui.set_next_window_pos(window_pos, 1 << 3, window_pivot)
	    imgui.set_next_window_size(window_size, 1 << 3)

        if imgui.begin_window("Anomaly Investigations Editor "..version, is_opened, window_flags) then


			if get_spacewatcher() then
				game_state = get_spacewatcher():get_field('_GameState')
			end

			if qc_open or game_state ~= 4 or get_questman():call('isActiveQuest') then
				imgui.text_colored('Mod works only in the lobby with quest counter closed.', 0xff1947ff)
			else

				if get_questman() and not dumped and game_state == 4
				or game_state == 4 and prev_game_state ~= 4 then
					reset_data()
				end

				if map_c then get_arrays() end

				if filter_c then filter_names() end

				_,force_auth_pass = imgui.checkbox('Force Authorization Pass', force_auth_pass)
				filter_c,filter = imgui.input_text('Filter',filter)
				id_c,id_pick = imgui.combo('Quest',id_pick,mystery_quests_names_filtered)
		        quest_id = mystery_quests_names_filtered[ id_pick ]
		        quest = mystery_quests[quest_id]

		        if quest then
			        imgui.text('Quest Level: ')
			        imgui.same_line()
			        imgui.text_colored(quest['_QuestLv'], 0xff27f3f5)
			        imgui.text('Map: ')
			        imgui.same_line()
			        imgui.text_colored(maps_table[ quest['_MapNo'] ], 0xff27f3f5)
			        imgui.text('Monster 1: ')
					imgui.same_line()
			        imgui.text_colored(monsters[ tostring(quest['monster0']) ]['name'], 0xff27f3f5)
			        imgui.text('Monster 2: ')
			        imgui.same_line()
			        imgui.text_colored(monsters[ tostring(quest['monster1']) ]['name'], 0xff27f3f5)
			        imgui.text('Monster 3: ')
			        imgui.same_line()
			        imgui.text_colored(monsters[ tostring(quest['monster2']) ]['name'], 0xff27f3f5)
			        imgui.text('Intruder: ')
			        imgui.same_line()
			        imgui.text_colored(monsters[ tostring(quest['monster5']) ]['name'], 0xff27f3f5)
			        imgui.text('Target Num: ')
			        imgui.same_line()
			        imgui.text_colored(quest['_HuntTargetNum'], 0xff27f3f5)
			        imgui.text('Time Limit: ')
			        imgui.same_line()
			        imgui.text_colored(quest['_TimeLimit'], 0xff27f3f5)
			        imgui.text('Quest Life: ')
			        imgui.same_line()
			        imgui.text_colored(quest['_QuestLife'], 0xff27f3f5)
			        imgui.text('Time of Day: ')
			        imgui.same_line()
			        imgui.text_colored(time_of_day_array[ quest['_StartTime'] +1], 0xff27f3f5)
			        imgui.text('Hunter Num: ')
			        imgui.same_line()
			        imgui.text_colored(quest['_QuestOrderNum'], 0xff27f3f5)
			    	imgui.text('Auth Status: ')
			    	imgui.same_line()
			    	imgui.text_colored((auth_status == 0 and "Pass" or auth_status_dict[auth_status]), (force_auth_pass and 0xff47ff59 or auth_status == 0 and 0xff47ff59 or 0xff1947ff))
			        imgui.text('Quest Count: ')
			        imgui.same_line()
			        imgui.text_colored(quest_count, 0xff27f3f5)
			        imgui.same_line()
			        imgui.text('/  120')

					map_c,map = imgui.combo('Map',map,maps_array)
					imgui.new_line()

					if tn_c and target_num == 3 then
						monster_intruder_array = {'None'}
					elseif tn_c and target_num < 3 then
						monster_intruder_array = monster_intruder_array_
						monster5 = index_of(monster_intruder_array,monsters[ tostring(quest['monster5']) ]['name'])
					end

					_,monster0 = imgui.combo('Monster 1',monster0,monster_main_array)
					_,monster1 = imgui.combo('Monster 2',monster1,monster_extra_array)
					_,monster2 = imgui.combo('Monster 3',monster2,monster_extra_array)
					_,monster5 = imgui.combo('Intruder',monster5,monster_intruder_array)

					imgui.new_line()
					_,tod = imgui.combo('Time of Day',tod,time_of_day_array)
					_,quest_lvl = imgui.slider_int('Quest Level', quest_lvl, 1, 200)
					tn_c,target_num = imgui.slider_int('Target Num', target_num, 1, 3)
					_,quest_life = imgui.slider_int('Quest Life', quest_life, 1, 9)
					_,time_limit = imgui.slider_int('Time Limit', time_limit, 1, 50)
					_,hunter_num = imgui.slider_int('Hunter Num', hunter_num, 1, 4)

					monster0_id = monsters_id_table[ monster_main_array[ monster0 ] ]
					monster1_id = monsters_id_table[ monster_extra_array[ monster1 ] ]
					monster2_id = monsters_id_table[ monster_extra_array[ monster2 ] ]
					monster5_id = monsters_id_table[ monster_intruder_array[ monster5 ] ]

					if imgui.button('Edit Quest') then edit_quest(quest['data']) end
					imgui.new_line()

					_,rand_id = imgui.combo('Random Quest Rank',rand_id,rand_rank_array)

					if imgui.tree_node('Probabilities at 120 Research Level') then

						if imgui.begin_table('',8, table_flags) then
							for row=0,6 do

								if (row % 2 == 0) then
									imgui.table_next_row()
								else
									imgui.table_next_row(table_row_flags)
								end

								for col=0,7 do
									imgui.table_set_column_index(col)
									imgui.text(table_[row+1][col+1])
								end

							end
							imgui.end_table()
						end
						imgui.tree_pop()
					end

					if imgui.button('Generate Random Quest') then generate_random(rand_rank[ rand_rank_array[rand_id] ]) end
					imgui.same_line()
					if imgui.button('Delete Quests') then wipe() end

					if id_c then change_vals = true end

					if id_c or auth_check then quest_check(quest['data']) end

					if change_vals and dumped then reset_input() end
				end
			end
			prev_game_state = game_state
        	imgui.end_window()
        else
        	if is_opened then imgui.end_window() end
        	is_opened = false
        end
    end
end)

