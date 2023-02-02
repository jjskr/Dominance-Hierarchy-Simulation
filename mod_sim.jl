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

    end

    return max_mem, tot_mem
end

function objective(x, n_agents, res, args=(100, 1))
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

    return sum(x) - res_inf*mem_v - tot_inf*tot_v
end

function gen_in(no)
    """
    no: Number to turn into BitArray/Bool matrix

    returns: Upper-triangular Bool Matrix for number
    """
    # 5 is pad 10, 10 pad 45
    # turn decimal to binary
    bin_vec = (digits(Int(no), base=2, pad=45)|> reverse)

    # turn binary to matrix
    s_mat = vec4utri(bin_vec)

    return s_mat
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
    newx = copy(x)
    row = rand((1: pop-1))
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
    metro = (exp(-10*difference/temp))
    return metro
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

sim = SimAnnealing(step2, objective, cool_fun, metro_fun, 10, 3, 10, 100)
 
best = gen_in(35184372088831)
best = gen_in(0)
best_eval = objective(best, sim.population, sim.restrict)
# println(count(new[:], 1))
n = gen_in(35184371302399)
mem_calcs(n, sim.population)
n_e = objective(n, sim.population, sim.restrict)

cur, cur_eval = best, best_eval

@profile for i in 0:sim.it_tot

    # generating and evaluating candidate
    cand = sim.steptype(cur, sim.population) # changing cur
    cand_sum = sim.obj_function(cand, sim.population, sim.restrict)

    diff = cur_eval - cand_sum

    t = sim.cooling(i, sim.init_temp, sim.it_tot)
    println(t, ", t")
    metro = sim.metropolis(t, diff)
    println(metro, ", m")
    println(diff, " difference")
    if diff < 0 || rand(Float64) < metro
        cur, cur_eval = cand, cand_sum
        println("STEP TAKEN", i)
    else
        println("NOT TAKEN", i)
    end
    # println("--------")
end

pprof()

show(stdout, "text/plain", cur)
println(mem_calcs(cur, sim.population))
println(cur_eval)
sum(cur)
