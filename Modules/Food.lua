if not StarlightCache.Food then
    local Food = {}
    StarlightCache.Food = Food

--These need to be sorted by ascending kcal count. If they aren't,
--GetFoodAndPercentage doesn't work.
Food.Data = {
{"peanut", 5},
{"orange", 30},
{"grape", 50},
{"kiwi", 60},
{"banana", 70},
{"egg", 85},
{"apple", 100},
{"milk", 120},
{"onigiri", 150},
{"pudding", 200},
{"rice", 220},
{"daifuku", 235},
{"creampuff", 250},
{"stew", 280},
{"cake", 300},
{"karaage", 330},
{"tonkatsu", 355},
{"pizza", 400},
{"pilaf", 430},
{"ramen", 450},
{"chaahan", 505},
{"cheeseburger", 550},
{"carbonara", 570},
{"oyakodon", 600},
{"gyuudon", 620},
{"curryrice", 700},
{"omurice", 740},
{"hayashi", 870},
{"katsudon", 900}
}


    --Returns a table with 4 things
    --1. the food descriptor {internal_name, kcals}
    --2. the localized name of the food
    --3. how far along you are in burning the calories for this food (0..1)
    --4. the number of times the food counter has wrapped around.
    function Food.GetFoodAndPercentage(kcals)
        local data = Food.Data
        local data_len = #data

        --DDR uses this to draw the "katsudon count" next to the larger calorie
        --data sheet
        local last_food_kcals = data[data_len][2]
        local reduced_kcals = math.fmod(kcals, last_food_kcals)

        for i=1,data_len do
            local this_food = data[i]
            if reduced_kcals < this_food[2] or i==data_len then
                local lookup_name = this_food[1]:gsub("^.", string.upper)
                return {this_food, THEME:GetString("Food", lookup_name),
                    math.min(reduced_kcals/this_food[2], 1.0), math.floor(kcals/last_food_kcals)}
            end
        end
    end

end


return StarlightCache.Food
