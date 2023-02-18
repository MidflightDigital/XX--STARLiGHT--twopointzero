local Rates = {
    Val = {},
    Str = {},
}
for i = 0.3, 2.01, 0.01 do
    table.insert( Rates.Val, string.format( "%.2f",i ) )
    table.insert( Rates.Str, string.format( "%.2fx",i ) )
end
--table.insert( Rates.Str, "Haste" )
--table.insert( Rates.Val, "haste" )


return {
    SmartTimings =
    {
        GenForUserPref = true,
        Default = TimingModes[2],
        Choices = TimingModes,
        Values = TimingModes
    }
}
