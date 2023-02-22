using Random, Profile, PProf
include("model_bin_adj.jl")

function mem_calcs(x, pop)

    """
    x: Strategy matrix
    pop: Total population

    returns: Maximum individual memory, total memory
    """
    # calculating hawk and dove strategies
    dove = sum(x, dims=1)
    hawk = sum(eachcol(x))

    # calculating mixed strategies
    mix_ar = zeros(Int64, pop, 1)

    for i in 1:pop
        mixes = pop-1 - hawk[i] - dove[i]
        mix_ar[i] = mixes
    end

    # memory calculations
    max_mem = 0
    tot_mem = 0
    for i in 1:pop

        def = max(dove[i], hawk[i], mix_ar[i])
        mem_need = pop - 1 - def

        tot_mem = tot_mem + mem_need
        if mem_need > max_mem
            max_mem = mem_need
        end
        # println(i, ", ", mem_need)
    end

    return max_mem, tot_mem
end

function objective(x, n_agents, res, args=(200, 10))
    """
    x: Strategy matrix
    n_agents: Total population
    res: Memory restriction
    args: args for objective function

    returns: Cost of strategy matrix
    """
    res_inf, tot_inf = args[1], args[2]
    mem, tot = mem_calcs(x, n_agents)
    
    # calculating memory usage
    mem_diff = mem - res

    if mem_diff < 1
        mem_v = 0
    else
        mem_v = mem_diff
    end

    tot_v = tot/n_agents

    return 2*sum(x) - res_inf*mem_v - tot_inf*tot_v
end

function step(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)
    row = rand((1: pop-1))
    col = rand((row+1: pop))
    if newx[row, col] == 0
        newx[row, col] = 1
    else
        newx[row, col] = 0
    end
    return newx
end

function step2(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)
    row = rand((1: pop-1))
    col = rand((row+1: pop))
    if newx[row, col] == 0
        newx[row, col] = 1
    else
        newx[row, col] = 0
    end

    row2 = rand((1: pop-1))
    col2 = rand((row2+1: pop))
    if newx[row2, col2] == 0
        newx[row2, col2] = 1
    else
        newx[row2, col2] = 0
    end

    return newx
end

function step3(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)
    row = rand((1: pop-1))
    for i in row+1:pop
        e = newx[row, i]
        newx[row, i] = ~e
    end
    return newx
end

function step4(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)
    col = rand((2: pop))
    for i in 1:col-1
        e = newx[i, col]
        newx[i, col] = ~e
    end
    return newx
end

function step5(x, pop)
    newx = copy(x)
    row = rand((1:pop-1))
    # if row in 1:5
    #     println(row)
    # end
    col = pop + 1 - row
    # println(row, ", row")
    # println("sum: ", sum(x[row, :]))
    # println(row)
    # println(col)
    if sum(x[row, :]) < pop - row
        for i in row+1:pop
            newx[row, i] = 1
        end
        for i in row+1:pop-1
            newx[i, col] = 0
        end
    end
    return newx
end

function step6(x, pop)
    newx = copy(x)
    row = rand((1:pop-1))
    col = pop + 1 - row
    # println(row, ", row")
    # println("sum: ", sum(x[row, :]))
    # println(row)
    # println(col)
    if sum(x[row, :]) < pop - row
        for i in row+1:pop
            newx[row, i] = 0
        end
        for i in 1:row-1
            newx[i, row] = 1
        end
    end
    return newx
end

function cool_fun(it, in_temp, iters)
    """
    t: iteration number
    temp: initial temperature
    iters: total number of iterations

    returns: temperature
    """
    t = in_temp*(1-(it)/iters)
    return t
end

function metro_fun(temp, difference)
    """
    temp: current temperature
    difference: cost difference between current and candidate

    returns: metropolis-hastings value
    """
    metro = (exp(-1*difference/temp))
    return metro
end

function gen_in(no, pad_size)
    """
    no: Number to turn into BitArray/Bool matrix

    returns: Upper-triangular Bool Matrix for number
    """
    # 5 is pad 10, 10 pad 45, 20 pad 190
    # turn decimal to binary
    bin_vec = (digits(Int(no), base=2, pad=pad_size)|> reverse)

    # turn binary to matrix
    s_mat = vec4utri(bin_vec)

    return s_mat
end

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
mem_calcs(best, 10)
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
best = gen_in(0, 78)
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
mem_calcs(cur, sim.population)
show(stdout, "text/plain", cur)
steps_taken
println(cur_eval)
# okkkk = step5(okkk, 10)
# mem_calcs(okkkk, 10)
# sum(okkkk)
# good = copy(cur)