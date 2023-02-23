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

sim = SimAnnealing([step, step2, step3, step4, step5, step6], objective, cool_fun, metro_fun, 10, 3, 13, 50000)
opt = gen_in(35146671702464, 45)

mem_calcs(opt, 10)
sum(opt)
best = gen_in(35184372088831, 45)
mem_calcs(best, sim.population)
best = gen_in(0, 45)
hmm = gen_in(295164793806804975616, 190)
best = gen_in(0, 78)

# for i in 2:20
#     nom = i
#     for j in 1:nom-1
#         if j < 5
#             best[j, i] = 1
#         end
#     end
# end

best = gen_in(0, 13)
mem_calcs(best, sim.population)
sum(best)
println(best)
best_eval = objective(best, sim.population, sim.restrict)
cur, cur_eval = best, best_eval
steps_taken = zeros(6)

@profile for i in 0:sim.it_tot
# for i in 0:sim.it_tot

    # generating and evaluating candidate
    num = rand((1, 2, 3, 4, 5))
    cand = sim.steptype[num](cur, sim.population) # changing cur
    cand_sum = sim.obj_function(cand, sim.population, sim.restrict)
    # if num == 5
    #     if cand_sum > cur_eval
    #         println(cur_eval, " ", cand_sum)
    #     end
    # end
    diff = cur_eval - cand_sum

    t = sim.cooling(i, sim.init_temp, sim.it_tot)

    metro = sim.metropolis(t, diff)
    # println(metro, " m")
    # println(diff, " diff")
    if diff < 0 || rand(Float64) < metro
        cur, cur_eval = cand, cand_sum
        steps_taken[num] = steps_taken[num] + 1
        
    # else
    #     println("NOT TAKEN", i)
    end
    # println("--------")
end

# pprof()
objective(cur, sim.population, sim.restrict)
sum(cur)
mem_calcs_full(best, sim.population)
mem_calcs(cur, sim.population)
show(stdout, "text/plain", cur)
steps_taken
println(cur_eval)

godd = copy(cur)
# okkkk = step5(okkk, 10)
# mem_calcs(okkkk, 10)
# sum(okkkk)
# good = copy(cur)