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