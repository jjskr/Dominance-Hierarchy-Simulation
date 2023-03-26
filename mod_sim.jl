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
# sim = SimAnnealing([step1, step2, step3, step4, step5, step6, step8, step9], objective, cool_fun, metro_fun, 10, 3, 13, 100000)
sim = SimAnnealing([step1, step2, step3, step4, step5, step6, step8, step9], objective, cool_fun, metro_fun, 10, 4, 12, 100000)

# opt = gen_in(35146671702464, 10)

# Initialising values and step count list
cur, cur_eval, steps_taken = initialise(sim.population, sim.restrict)

# Simulated Annealing
new, new_eval, step_count, best_sol, best_eval = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, cur, cur_eval, sim.metropolis, steps_taken)
show(stdout, "text/plain", best_eval)
new, new_eval, step_count, best_sol, best_eval = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, best_eval, best_sol, sim.metropolis, steps_taken)
show(stdout, "text/plain", best_eval)
sum(best_eval)
mem_calcs_full(best_eval, 12)
sum(new)
objective(best_eval, sim.population, sim.restrict)
mem_calcs_full(best_eval, sim.population)
show(stdout, "text/plain", new)
objective(new, sim.population, sim.restrict)
mem_calcs_full(new, sim.population)
println(new_eval)

godd = copy(cur)

ok1 = gen_in(800, 5)
mem_calcs_full(ok1, 5)
ok2 = gen_in(768, 5)
mem_calcs_full(ok2, 5)
ok3 = gen_in(32, 5)
mem_calcs_full(ok3, 5)
ok4 = gen_in(15, 5)
mem_calcs_full(ok4, 5)
ok5 = gen_in(0, 5)
ste = step3(ok5, 5)
mem_calcs_full(ste, 5)
mem_calcs_full(ok5, 5)
ok6 = gen_in(840, 5)
mem_calcs_full(ok6, 5)
ok10 = gen_in(1023, 5)
mem_calcs_full(ok10, 5)

ok66 = gen_in(32767, 6)
mem_calcs_full(ok66, 6)

ok77 = gen_in(2097151, 7)
mem_calcs_full(ok77, 7)

ok88 = gen_in(268435455, 8)
mem_calcs_full(ok88, 8)

ok99 = gen_in(68719476735, 9)
mem_calcs_full(ok99, 9)

ok1010 = gen_in(35184372088831, 10)
mem_calcs_full(ok1010, 10)

ok1111 = gen_in(36028797018963967, 11)
mem_calcs_full(ok1111, 11)

ok1212 = gen_in(73786976294838206463, 12)

ok7 = step3(ok5, 5)
stee = step5(ok6, 5)
mem_calcs_full(stee, 5)