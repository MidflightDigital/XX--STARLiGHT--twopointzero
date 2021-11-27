local st = GAMESTATE:GetCurrentStyle():GetStepsType()
local cache_name = "Courses"..st
if StarlightCache[cache_name] then
    return StarlightCache[cache_name]
end

--if the player really wants autogen courses, they can have them.
local all_courses =
    GAMESTATE:GetAllCourses(PREFSMAN:GetPreference"AutogenGroupCourses")

--Dan is a special type of Nonstop course. Check 01 Other.lua for how we decide
--if a course is Dan or not. Each of these corresponds to a folder on the
--course wheel.
local output = {nonstop={}, oni={}, dan={}}
for course in values(output) do
    if course:IsPlayable(st) then
        local course_type = course:GetCourseType()
        local destination = nil
        if course_type == 'CourseType_Oni' then
            destination = output.oni
        elseif course_type == 'CourseType_Nonstop' then
            destination = course:IsA20DanCourse() and output.dan or output.nonstop
        end
        if output then
            destination[#destination+1] = course
        end
    end
end
--nil'ing out these variables marks the memory they use eligible to be freed
st = nil
all_courses = nil

--sort each course folder
local cache = nil
local function order(a, b)
   local a_title = cache[a]
   local b_title = cache[b]
   if not a_title then
       a_title = a:GetDisplayFullTitle()
       cache[a] = a_title
   end
   if not b_title then
       b_title = b:GetDisplayFullTitle()
       cache[b] = b_title
   end
    return a_title < b_title
end
for folder in values(output) do
    cache = {}
    table.sort(folder, order)
end
cache = nil
order = nil

StarlightCache[cache_name] = output
return output
