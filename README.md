# Garry's Mod Profiler

Rewritten to be a lua_run console function

Arg 1, Benches it for set time
Arg 2, Calls it how many times per engine tick
Arg 3, The function, this can be a single function like CurTime or a function like function() math.random(32, 64) + math.random(182, 283) end

Run it and it returns
The amount of times called during the duration
The total time the functions called took
The average time per function call
Printed into console

WARNING DO NOT RUN MULTIPLE INSTANCES OF THIS FUNCTION, IT MAY BREAK AND NOT GIVE ACCURATE RESULTS
