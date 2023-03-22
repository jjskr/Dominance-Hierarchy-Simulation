using Random, Profile, PProf
include("project_functions.jl")


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

# Initialising struct
sim = SimAnnealing([step1, step2, step3, step4, step5, step6, step8, step9], objective, cool_fun, metro_fun, 10, 3, 10, 100000)
# opt = gen_in(35146671702464, 10)

# Initialising values and step count list
cur, cur_eval, steps_taken = initialise(sim.population, sim.restrict)

# Simulated Annealing
new, new_eval, step_count = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, cur, cur_eval, sim.metropolis, steps_taken)
sum(step_count)
sum(new)
show(stdout, "text/plain", new)
objective(new, sim.population, sim.restrict)
mem_calcs_full(new, sim.population)
println(new_eval)

godd = copy(cur)

ok1 = gen_in(3000002, 10)
mem_calcs_full(ok1, 10)
ok2 = gen_in(3000001, 10)
mem_calcs_full(ok2, 10)