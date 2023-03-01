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

# mem_calcs(opt, 10)
# sum(opt)
# best = gen_in(35184372088831, 45)
# mem_calcs(best, sim.population)
# best = gen_in(0, 45)
# hmm = gen_in(295164793806804975616, 190)
# best = gen_in(0, 78)

# for i in 2:20
#     nom = i
#     for j in 1:nom-1
#         if j < 5
#             best[j, i] = 1
#         end
#     end
# end

cur, cur_eval, steps_taken = initialise(sim.population, sim.restrict)

cur, step_count = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, cur, cur_eval, sim.metropolis, steps_taken)

sum(cur)
show(stdout, "text/plain", cur)
objective(cur, sim.population, sim.restrict)
mem_calcs_full(cur, sim.population)
steps_taken
println(cur_eval)

godd = copy(cur)
# okkkk = step5(okkk, 10)
# mem_calcs(okkkk, 10)
# sum(okkkk)
# good = copy(cur)