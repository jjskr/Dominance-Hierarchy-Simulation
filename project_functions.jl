using Random, Profile, PProf

function disp_mat(i)
    """
    Function displays matrix i
    """
    show(stdout, "text/plain", i)
end

function initialise(pop, res, step_list)
    """
    Function initialises parameters for simulated annealing

    pop: Population size
    res: Memory restrictions

    returns: Initial matrix, initial objective value, initial step count
    """
    # Initialise matrix, solution and step count matrix
    best = gen_in(0, pop)
    best_eval = objective(best, pop, res)
    cur, cur_eval = best, best_eval
    steps_taken = zeros(length(step_list))

    return cur, cur_eval, steps_taken
end

function sim_ann(it, pop, step_list, obj_fun, res, cool_fun, init_temp, current, current_eval, metro, step_count, sa=0, args=[100, 0.28, 0, 0])
    """
    Function carries out simulated annealing algorithm

    it: Number of iterations
    pop: Population size
    step_list: List of possible steps
    res: Memory restriction
    cool_fun: Cooling function
    init_temp: Initial simulated annealing temperature
    cur: Current state
    cur_eval: Current objective value
    metro: Hasting-Metropolis function
    step_count: Initial step count
    
    returns: Best obj value, best state found by simulated annealing and final step count
    """

    # Initial best set to 0
    best = current_eval
    best_cur = current

    if obj_fun == objective_mix
        best = objective_mix(current, pop, res)
    end

    for i in 0:it
        # generating and evaluating candidate
        num = rand((1:length(step_list))) # step chosen randomly

        cand = step_list[num](current, pop) # candidate chosen

        cand_sum = obj_fun(cand, pop, res, sa, args) # candidate objective solution

        diff = current_eval - cand_sum # difference between current and candidate solutions
        # diff = cand_sum - current_eval
        t = cool_fun(i, init_temp, it) # temperature calculation

        metrop = metro(t, diff) # metropolis calculation

        # check if candidate replaces current state
        if diff < 0 || rand(Float64) < metrop
            current, current_eval = cand, cand_sum
            step_count[num] = step_count[num] + 1
            # if sum(current) == 17
            #     println(i)
            #     disp_mat(current)
            # end
            # if cur_eval > best
            #     println(it)
            #     best = cur_eval
            #     best_cur = cur
            # end          
        end

        # if i == 50000
        #     show(stdout, "text/plain", current)
        #     sum(current)
        #     mem_calcs_full(current, pop)
        #     println(obj_fun(current, pop, res))
        # end
        # keep track of best solution
        if current_eval > best
            # println(i)
            best = current_eval
            best_cur = current
        end
            
    end
    return current, current_eval, step_count, best, best_cur
end

function mem_calcs(x, pop, sa=0, args=[100, 0.28, 0, 0])
    """
    Function returns memory statistics

    x: Strategy matrix
    pop: Total population

    returns: Maximum individual memory, total memory
    """
    # sa_agent, sa_mem = args[3], args[4]
    # calculating hawk and dove strategies
    dove = sum(x, dims=1)
    hawk = sum(eachcol(x))

    # calculating mixed strategies
    mix_ar = zeros(Int64, pop, 1)

    for i in 1:pop
        mixes = pop - 1 - hawk[i] - dove[i]
        mix_ar[i] = mixes
    end

    # memory calculations
    max_mem = 0
    tot_mem = 0
    mix_mem = 0
    super_v = 0

    if sa > 0
        sa_agents = []
        sa_mem = []
        for j in 1:sa
            push!(sa_agents, args[2+2j-1])
            push!(sa_mem, args[2+2j])
        end
        # println(sa_agents)
        # println(sa_mem)
    end

    for i in 1:pop
        if sa > 0
            if i in sa_agents
                a = findall(x->x==i, sa_agents)[1]
                # println(a)
                a_mem = sa_mem[a]
                # println(a_mem)
                def = max(dove[i], hawk[i], mix_ar[i]) # assign default action
                mem_need = pop - 1 - def # calculate memory requirement
    
                # monitor memory used for mixed strategy
                if mix_ar[i] != def
                    mix_mem += mix_ar[i]
                end
    
                #tot_mem = tot_mem + mem_need # update total memory usage
    
                # check if memory restriction is violated
                if mem_need > a_mem
                    mem_vio = a_mem - mem_need
                    if mem_vio > super_v
                        super_v = mem_vio
                    end
                end
            else
                def = max(dove[i], hawk[i], mix_ar[i]) # assign default action
                mem_need = pop - 1 - def # calculate memory requirement
    
                # monitor memory used for mixed strategy
                if mix_ar[i] != def
                    mix_mem += mix_ar[i]
                end
    
                tot_mem = tot_mem + mem_need # update total memory usage
    
                # check if memory restriction is violated
                if mem_need > max_mem
                    max_mem = mem_need
                end
            end
        else
            def = max(dove[i], hawk[i], mix_ar[i]) # assign default action
            mem_need = pop - 1 - def # calculate memory requirement

            # monitor memory used for mixed strategy
            if mix_ar[i] != def
                mix_mem += mix_ar[i]
            end

            tot_mem = tot_mem + mem_need # update total memory usage

            # check if memory restriction is violated
            if mem_need > max_mem
                max_mem = mem_need
            end
        end
        # println(i, ", ", mem_need)
    end

    return max_mem, tot_mem, mix_mem, super_v
end

function mem_calcs_full(x, pop)
    """
    Function returns memory statistics and prints individual memory and default action usage

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
    mix_mem = 0
    for i in 1:pop

        def = max(dove[i], hawk[i], mix_ar[i])
        println("Dove ", dove[i], " Hawk ", hawk[i], " Mix ", mix_ar[i])
        mem_need = pop - 1 - def

        if mix_ar[i] != def
            mix_mem += mix_ar[i]
        end

        tot_mem = tot_mem + mem_need
        if mem_need > max_mem
            max_mem = mem_need
        end
        # output individuals memory usage
        println(i, ", ", mem_need)
    end

    return max_mem, tot_mem, mix_mem
end

function objective(x, n_agents, res, sa=false, args=[100, 0.35, 0, 0])
    """
    Function returns objective function cost

    x: Strategy matrix
    n_agents: Total population
    res: Memory restriction
    args: args for objective function

    returns: Cost of strategy matrix
    """
    res_inf, tot_inf, sa_agent, sa_mem = args[1], args[2], args[3], args[4]
    mem, tot, mix, s_vio = mem_calcs(x, n_agents, sa, args)
    
    # calculating memory violation
    mem_diff = mem - res

    if mem_diff < 1
        mem_v = 0
    else
        mem_v = mem_diff
    end

    # problem is with co-efficients
    # disp_mat(x)
    # println(' ')
    # println(sum(x)*(2/((n_agents-1)*n_agents)))
    # println(mem_v*(2/(n_agents-1)))
    # println(tot*(1/((0.5*n_agents)*((0.5*n_agents)-1))))

    return sum(x)*(2/((n_agents-1)*n_agents)) - res_inf*mem_v*(2/(n_agents-2)) - tot_inf*tot*(1/((0.5*n_agents)*((0.5*n_agents)-1)))# - 0.1*mix/n_agents*n_agents
end

function objective_mix(x, n_agents, res, sa=false, args=[100, 0.28, 0, 0])
    """
    Function returns objective function cost penalising mixed strategy

    x: Strategy matrix
    n_agents: Total population
    res: Memory restriction
    args: args for objective function

    returns: Cost of strategy matrix
    """
    res_inf, tot_inf, sa_agent, sa_mem = args[1], args[2], args[3], args[4]
    mem, tot, mix = mem_calcs(x, n_agents)
    
    # calculating memory violation
    mem_diff = mem - res

    if mem_diff < 1
        mem_v = 0
    else
        mem_v = mem_diff
    end
    # problem is with co-efficients
    return sum(x)*(2/((n_agents-1)*n_agents)) - res_inf*mem_v*(2/(n_agents-1)) - tot_inf*tot*(1/((0.5*n_agents)*((0.5*n_agents)-1))) - 0.1*mix/n_agents*n_agents
end

function step1(x, pop)
    """
    Function changes one entry

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
    Function changes two entries

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
    Function inverts row

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
        if e == 0
            newx[row, i] = 1
        else
            newx[row, i] = 0
        end
    end
    return newx
end

function step4(x, pop)
    """
    Function inverts column

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
        if e == 0
            newx[i, col] = 1
        else
            newx[i, col] = 0
        end
    end
    return newx
end

function step5(x, pop)
    """
    Function turns row to 1 and column to 0

    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """

    if sum(x) == ((pop*pop)-pop)/2

        return x
    else
        newx = copy(x)

        # Random row chosen
        row = rand((1:pop-1))
        # println(row)

        # This is a fraudulent while loop
        if sum(x[row, :]) == pop - row
            while sum(x[row, :]) == pop - row
                row = rand((1:pop-1))
            end
        end

        col = pop + 1 - row

        # Change all values in row to True
        for i in 1:col-1
            newx[i, col] = 0
        end
        for i in row+1:pop
            newx[row, i] = 1
        end
    end

    return newx
end

function step6(x, pop)
    """
    Function turns row to 1

    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Random row chosen
    row = rand((1:pop-1))

    # if row is not already complete, completed
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

function step7(x, pop)
    """
    Function turns row to 1

    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Random row chosen
    row = rand((1:pop-1))

    if sum(x[row, :]) < 0.5*(pop - row)
        for i in row+1:pop
            newx[row, i] = 1
        end
    end
    return newx
end

function step10(x, pop)
    """
    Function turns column to 1

    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Random row chosen
    col = rand((1:pop-1))

    if sum(x[:, col]) < col-1
        for i in 1:col-1
            newx[i, col] = 1
        end
    end
    return newx
end

function step8(x, pop)
    """
    Function swaps two agents fighting actions, column values

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
    
    if diff == 1
        for i in row2+1:pop
            a = newx[row1, i]
            b =  newx[row2, i]
            newx[row1, i] = b
            newx[row2, i] = a
        end
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
    diff = col2 - col1
    if diff > 1
        if col1 > 2
            for i in 1:col1-1
                a = newx[i, col1]
                b = newx[i, col2]
                newx[i, col1] = b
                newx[i, col2] = a
            end
            for i in 0:diff-2
                a = newx[col1+i, col1+1+i]
                b = newx[col1+1+i, col2]
                newx[col1+i, col1+1+i] = b
                newx[col1+i+1, col2] = a
            end
        end
        # if row2 == pop - 1
        #     for i in 1:diff
        #         a = newx[row1, row2 - i]
        #         b = newx[row1 + i, row2]
        #         newx[row1, row2 - i] = b
        #         newx[row1 + i, row2] = a
        #     end
        # end
    end
    
    if diff == 1
        for i in 1:col1-1
            a = newx[i, col1]
            b = newx[i, col2]
            newx[i, col1] = b
            newx[i, col2] = a
        end
    end
    return newx
end

function step11(x, pop)
    """
    Function swaps two agents fighting actions

    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)

    # Two rows chosen at random
    row1 = rand((1:pop-2))
    row2 = rand((row1+1:pop-1))

    # Calculate difference between row numbers
    diff = row2 - row1

    if diff > 1
        for i in 1:diff-1
            a = newx[row1, row1 + i]
            b = newx[row2 - i, row2]
            newx[row1, row1 + i] = b
            newx[row2 - i, row2] = a
        end
        for i in row2+1:pop
            a = newx[row1, i]
            b = newx[row2, i]
            newx[row1, i] = b
            newx[row2, i] = a
        end
        # if row2 == pop - 1
        #     for i in 1:diff
        #         a = newx[row1, row2 - i]
        #         b = newx[row1 + i, row2]
        #         newx[row1, row2 - i] = b
        #         newx[row1 + i, row2] = a
        #     end
        # end
    end
    
    if diff == 1
        for i in row2+1:pop
            a = newx[row1, i]
            b =  newx[row2, i]
            newx[row1, i] = b
            newx[row2, i] = a
        end
    end

    return newx
end

function step12(x, pop)
    """
    Function swaps two agents fighting actions

    x: Boolean upper-triangular adjacency matrix
    pop: Total population

    returns: Suggested next candidate
    """
    newx = copy(x)
    col1 = rand((2:pop-1))
    col2 = rand((col1+1:pop))
    diff = col2 - col1
    # println(diff, " ", col1, col2)
    if diff > 1
        if col1 > 2
            for i in 1:col1-1
                a = newx[i, col1]
                b = newx[i, col2]
                newx[i, col1] = b
                newx[i, col2] = a
            end
            for i in 0:diff-2
                a = newx[col1, col1+1+i]
                b = newx[col2-1-i, col2]
                newx[col1, col1+1+i] = b
                newx[col2-1-i, col2] = a
            end
        end
        # if row2 == pop - 1
        #     for i in 1:diff
        #         a = newx[row1, row2 - i]
        #         b = newx[row1 + i, row2]
        #         newx[row1, row2 - i] = b
        #         newx[row1 + i, row2] = a
        #     end
        # end
    end
    
    if diff == 1
        for i in 1:col1-1
            a = newx[i, col1]
            b = newx[i, col2]
            newx[i, col1] = b
            newx[i, col2] = a
        end
    end
    return newx
end

function cool_fun(it, in_temp, iters)
    """
    Function returns temperature at current iteration

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
    Function returns metropolis hastings value at given temperature and cost difference

    temp: current temperature
    difference: cost difference between current and candidate

    returns: metropolis-hastings value
    """
    metro = (exp(-1*difference/temp))
    return metro
end

function gen_in(no, pop)
    """
    Function generates boolean upper-triangular Matrix

    no: number to turn into BitArray/Bool matrix
    pop: population size

    returns: Upper-triangular Bool Matrix for number
    """
    # 5 is pad 10, 10 pad 45, 20 pad 190
    # turn decimal to binary
    bin_vec = (digits(Int(no), base=2, pad=Int(((pop*pop)-pop)/2))|> reverse)

    # turn binary to matrix
    s_mat = vec4utri(bin_vec)

    return s_mat
end

function vec4utri(v)
    """
    Function returns upper-triangular matrix

    v: Vector of binary numbers

    returns: Upper-triangular adjacency matrix of v
    """
    # zz = false
    n = length(v)
    s = round((sqrt(8n+1)-1)/2)
    # s*(s+1)/2 == n || error("vec2utri: length of vector is not triangular")
    p = [ i<j && i<=s && j<=s ? Bool(v[Int((j)*(j-1)/2+(i+1))]) : false for i=0:s, j=0:s ]
    return p
end