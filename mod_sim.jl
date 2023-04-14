using Random, Profile, PProf
include("project_functions.jl")
# import Pkg; Pkg.add("ProgressBars")

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
sim = SimAnnealing([step1, step2, step3, step4, step5, step6, step8, step9, step10, step11, step12], objective, cool_fun, metro_fun, 10, 3, 11, 50000)
sim = SimAnnealing([step1, step2, step3, step4, step5, step6, step10, step11, step12], objective, cool_fun, metro_fun, 10, 3, 11, 50000)
sim = SimAnnealing([step1, step2, step3, step4, step5, step6, step10, step11, step12], objective, cool_fun, metro_fun, 10, 3, 10, 100000)

# opt = gen_in(35146671702464, 10)

# Initialising values and step count list
cur, cur_eval, steps_taken = initialise(sim.population, sim.restrict, sim.steptype)

# Initialising arguments
sa_status = false
args = [100, 0.35, 6, 12]

# Simulated Annealing
new, new_eval, step_count, best_sol, best_eval = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, cur, cur_eval, sim.metropolis, steps_taken, sa_status, args)
show(stdout, "text/plain", best_eval)
new, new_eval, step_count, best_sol, best_eval = sim_ann(sim.it_tot, sim.population, sim.steptype, objective_mix, sim.restrict, sim.cooling, sim.init_temp, best_eval, best_sol, sim.metropolis, steps_taken, sa_status, args)
show(stdout, "text/plain", best_eval)
sum(best_eval)
mem_calcs(best_eval, 6)
mem_calcs_full(best_eval, 6)
sum(new)
objective(best_eval, sim.population, sim.restrict)
mem_calcs_full(best_eval, sim.population)
show(stdout, "text/plain", new)
objective(new, sim.population, sim.restrict)
mem_calcs_full(new, sim.population)
println(new_eval)

sol_list = []

for i in 1:100
    println(i)
    new, new_eval, step_count, best_sol, best_eval = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, cur, cur_eval, sim.metropolis, steps_taken, sa_status, args)
    # new, new_eval, step_count, best_sol, best_eval = sim_ann(sim.it_tot, sim.population, sim.steptype, sim.obj_function, sim.restrict, sim.cooling, sim.init_temp, best_eval, best_sol, sim.metropolis, steps_taken, sa_status, args)
    push!(sol_list, best_eval)
end

# step_count

# println(length(sol_list))
# println(unique(sol_list))

maxi = 0

for i in unique(sol_list)
    println(count(j->(j==i), sol_list), ", ", sum(i))
    if sum(i) > maxi
        maxi = sum(i)
    end
    if sum(i) == 24
        println("---------------")
        show(stdout, "text/plain", i)
        println("---------------")
        # mem_calcs_full(i, 11)
        println(mem_calcs(i, 10))
        # mem_calcs_full(i, sim.population)
    end
end

println(maxi)

okay1 = Array[]
try5 = [0 1 0 1 1; 0 0 1 1 1; 0 0 0 1 0; 0 0 0 0 1; 0 0 0 0 0]
okay7 = [0 1 1 0 1 1 1; 0 0 1 0 1 1 1; 0 0 0 1 1 1 1; 0 0 0 0 1 0 0; 0 0 0 0 0 1 1; 0 0 0 0 0 0 1; 0 0 0 0 0 0 0]

okay9 = [0 1 1 1 0 1 1 1 1; 0 0 1 1 0 1 1 1 1; 0 0 0 1 0 1 1 1 1; 0 0 0 0 1 1 1 1 1; 0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0]
okay11 = [0 1 1 1 1 0 1 1 1 1 1; 0 0 1 1 1 0 1 1 1 1 1; 0 0 0 1 1 0 1 1 1 1 1; 0 0 0 0 1 0 1 1 1 1 1; 0 0 0 0 0 1 1 1 1 1 1; 0 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 0 1 1 1 1; 0 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0]
okay10 = [0 1 1 1 0 0 1 1 1 1; 0 0 1 1 0 0 1 1 1 1; 0 0 0 1 1 0 1 1 1 1; 0 0 0 0 1 1 1 1 1 1; 0 0 0 0 0 0 1 0 0 0 ; 0 0 0 0 0 0 1 1 0 0 ; 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0]
okay102 = [0 1 1 1 0 0 1 1 1 1; 0 0 1 1 0 0 1 1 1 1; 0 0 0 1 0 1 1 1 1 1; 0 0 0 0 1 1 1 1 1 1; 0 0 0 0 0 0 1 1 0 0 ; 0 0 0 0 0 0 1 0 0 0 ; 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0]
okay13 = [0 1 1 1 1 1 0 1 1 1 1 1 1; 0 0 1 1 1 1 0 1 1 1 1 1 1; 0 0 0 1 1 1 0 1 1 1 1 1 1; 0 0 0 0 1 1 0 1 1 1 1 1 1; 0 0 0 0 0 1 0 1 1 1 1 1 1; 0 0 0 0 0 0 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 0 0 1 1 1 1 1; 0 0 0 0 0 0 0 0 0 1 1 1 1; 0 0 0 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0 0 0]
okay156
disp_mat(okay156)
mem_calcs_full(okay156, 15)
println(sum(okay10))
okay176 = [0 1 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1; 0 0 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1; 0 0 0 1 1 1 1 0 0 0 1 1 1 1 1 1 1; 0 0 0 0 1 1 1 0 0 0 1 1 1 1 1 1 1; 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

hw11 = [0 1 1 1 1 1 1 1 1 1 1; 0 0 1 1 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 1 1; 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0]

hw9 = [0 1 1 1 1 1 1 1 1; 0 0 1 1 1 1 1 1 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0]
# for i in 1:length(okay)
#     okay1[i,:] = okay[i]
# end
sum(hw11)
sum(okay11)
mem_calcs_full(okay11, 11)
mem_calcs_full(hw9, 9)
mem_calcs_full(okay9, 9)
mem_calcs_full(hw11, 11)
mem_calcs_full(try5, 5)
mem_calcs_full(okay13, 13)
mem_calcs_full(okay7, 7)
mem_calcs_full(okay10, 10)
sum(okay11)
sum(okay13)
sum(okay176)
sum(okay10)
currr = unique(sol_list)[1]
currr[2,3:7] .= 1
currr[1:5, 6] .= 1
mem_calcs_full(currr, sim.population)
show(stdout, 'text/plain', currr)
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

exper = gen_in(600, 5)
exper1 = step3(exper, 5)
mem_calcs_full(exper, 5)
mem_calcs_full(exper1, 5)

experr = gen_in(1000, 6)
experr1 = step3(experr, 6)
mem_calcs_full(experr, 5)
mem_calcs_full(experr1, 5)

experrr = gen_in(1000000000000, 10)
experrr1 = step3(experrr, 10)
mem_calcs_full(experrr, 10)
mem_calcs_full(experrr1, 10)

experrrr = gen_in(9600, 10)
mem_calcs_full(experrrr, 10)
experrrr1 = step3(experrrr, 10)
mem_calcs_full(experrrr1, 10)

experrr
test12 = step12(experrr, 10)
mem_calcs_full(test12, 10)
