using Random, Profile, PProf
include("model_bin_adj.jl")

function initialise(pop, res)

    best = gen_in(0, pop)
    best_eval = objective(best, pop, res)
    cur, cur_eval = best, best_eval
    steps_taken = zeros(7)

    return cur, cur_eval, steps_taken
end

function sim_ann(it, pop, step_list, obj_fun, res, cool_fun, init_temp, cur, cur_eval, metro, step_count)
    @profile for i in 0:it
        # for i in 0:sim.it_tot
        
            # generating and evaluating candidate
            num = rand((1, 2, 3, 4, 5, 6, 7))
            cand = step_list[num](cur, pop) # changing cur
            cand_sum = obj_fun(cand, pop, res)

            diff = cur_eval - cand_sum
        
            t = cool_fun(i, init_temp, it)
        
            metrop = metro(t, diff)

            if diff < 0 || rand(Float64) < metrop
                cur, cur_eval = cand, cand_sum
                step_count[num] = step_count[num] + 1
                
            end
        end
    return cur, step_count
end

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

function mem_calcs_full(x, pop)
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
        # output individuals memory usage
        println(i, ", ", mem_need)
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

    # Random row and column to invert is chosen
    row = rand((1: pop-1))
    col = rand((row+1: pop))

    # Value inverted
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
    
    # Two random rows and columns chosen
    row = rand((1: pop-1))
    col = rand((row+1: pop))

    row2 = rand((1: pop-1))
    col2 = rand((row2+1: pop))

    # Values inverted
    if newx[row, col] == 0
        newx[row, col] = 1
    else
        newx[row, col] = 0
    end

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

    # Random row to invert chosen
    row = rand((1: pop-1))

    # Each value in chosen row inverted
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

    # Random column to invert chosen
    col = rand((2: pop))

    # Each value in chosen column inverted
    for i in 1:col-1
        e = newx[i, col]
        newx[i, col] = ~e
    end
    return newx
end

function step5(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Random row chosen, column deduced
    row = rand((1:pop-1))

    if sum(x[row, :]) == pop - row
        while sum(x[row, :]) == pop - row
            row = rand((1:pop-1))
        end
    end

    col = pop + 1 - row

    # Change all values in row to True
    for i in row+1:pop
        newx[row, i] = true
    end

    for i in row+1:pop-1
        newx[i, col] = false
    end

    return newx
end

function step6(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Random row chosen, column deduced
    row = rand((1:pop-1))
    col = pop + 1 - row

    if sum(x[row, :]) < pop - row
        for i in row+1:pop
            newx[row, i] = false
        end
        for i in 1:row-1
            newx[i, row] = true
        end
    end
    return newx
end

function step7(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Random row chosen
    row = rand((1:pop-1))

    if sum(x[row, :]) < 0.5*(pop - row)
        for i in row+1:pop
            newx[row, i] = true
        end
    end
    return newx
end

function step8(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Two rows chosen at random
    row1 = rand((1:pop-2))
    row2 = rand((row1+1:pop-1))

    # Calculate difference between row numbers
    diff = row1 - row2

    if diff > 1
        if row2 < pop - 1
            for i in 1:diff-1
                a = newx[row1, row2 - i]
                b = newx[row1 + i, row2]
                newx[row1, row2 - i] = b
                newx[row1 + i, row2] = a
            end
            for i in row2+1:pop
                a = newx[row1, i]
                b = newx[row2, i]
                newx[row1, i] = b
                newx[row2, i] = a
            end
        end
        if row2 == pop - 1
            for i in 1:diff
                a = newx[row1, row2 - i]
                b = newx[row1 + i, row2]
                newx[row1, row2 - i] = b
                newx[row1 + i, row2] = a
            end
        end
    end
    
    for i in row2+1:pop
        a = newx[row1, i]
        b =  newx[row2, i]
        newx[row1, i] = b
        newx[row2, i] = a
    end
    return newx
end

function step9(x, pop)
    """
    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)
    col1 = rand((2:pop-1))
    col2 = rand((col1+1:pop))
    diff = col1 - col2
    if diff > 1
        if col2 < pop
            for i in 1:diff-1
                a = newx[row1, row2 - i]
                b = newx[row1 + i, row2]
                newx[row1, row2 - i] = b
                newx[row1 + i, row2] = a
            end
            for i in row2+1:pop
                a = newx[row1, i]
                b = newx[row2, i]
                newx[row1, i] = b
                newx[row2, i] = a
            end
        end
        if row2 == pop - 1
            for i in 1:diff
                a = newx[row1, row2 - i]
                b = newx[row1 + i, row2]
                newx[row1, row2 - i] = b
                newx[row1 + i, row2] = a
            end
        end
    end
    
    for i in row2+1:pop
        a = newx[row1, i]
        b =  newx[row2, i]
        newx[row1, i] = b
        newx[row2, i] = a
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

function gen_in(no, pop)
    """
    no: Number to turn into BitArray/Bool matrix

    returns: Upper-triangular Bool Matrix for number
    """
    # 5 is pad 10, 10 pad 45, 20 pad 190
    # turn decimal to binary
    bin_vec = (digits(Int(no), base=2, pad=Int(((pop*pop)-pop)/2))|> reverse)

    # turn binary to matrix
    s_mat = vec4utri(bin_vec)

    return s_mat
end