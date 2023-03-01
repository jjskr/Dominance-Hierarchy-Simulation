using Random, Profile, PProf
include("functions.jl")

struct SimAnnealing
    steptype
    obj_function
    cooling
    metropolis
    init_temp::Int64
    restrict::Int64
    population::Int64
    it_tot::Int64
end

sim = SimAnnealing([step, step2, step3, step4, step5, step6, step8], objective, cool_fun, metro_fun, 10, 4, 15, 50000)
opt = gen_in(35146671702464, 10)

cur, cur_eval, steps_taken = initialise(sim.population, sim.restrict)

cur, step_count = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, cur, cur_eval, sim.metropolis, steps_taken)

sum(cur)
show(stdout, "text/plain", cur)
objective(cur, sim.population, sim.restrict)
mem_calcs_full(cur, sim.population)
steps_taken
println(cur_eval)

godd = copy(cur)
