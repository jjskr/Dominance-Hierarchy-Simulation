using Plots, BenchmarkTools, PProf, Profile, Dates


function vec4utri(v)
    """
    v: Vector of binary numbers

    returns: Upper-triangular adjacency matrix of v
    """
    zz = false
    n = length(v)
    s = round((sqrt(8n+1)-1)/2)
    # s*(s+1)/2 == n || error("vec2utri: length of vector is not triangular")
    p = [ i<j && i<=s && j<=s ? Bool(v[Int((j)*(j-1)/2+(i+1))]) : zz for i=0:s, j=0:s ]
    return p
end

function memory_calculation(n, d, h, m)
    max_mem = 0
    tot_mem = 0
    for i in 1:n
        def = max(d[i], h[i], m[i])
        mem_need = n-1 - def
        tot_mem = tot_mem + mem_need
        if mem_need > max_mem
            max_mem = mem_need
        end
    end
    return max_mem, tot_mem
end

function mixed(n, h, d)
    mix_ar = zeros(Int64, n, 1)
    for i in 1:n
        mixes = n-1 - h[i] - d[i]
        mix_ar[i] = mixes
    end
    # println("Mixed:")
    # println(mix_ar)
    return mix_ar
end

function main()
    n_agents = 5
    vecc = digits(Int(101), base=2, pad=10)
    smat = vec4utri(vecc)
    dove = sum(smat, dims=1)
    hawk = sum(eachcol(smat))
    mix = mixed(n_agents, hawk, dove)
    println(memory_calculation(n_agents, dove, hawk, mix))

    a = digits(Int((2^10)-1), base=2, pad=10)
    smat = vec4utri(a)
    dove = sum(smat, dims=1)
    hawk = sum(eachcol(smat))
    mix = mixed(n_agents, hawk, dove)
    println(memory_calculation(n_agents, dove, hawk, mix))

    n_agents = 5
    # 2^(n_agents*(n_agents-1)/2)-1
    # bin_vec = digits(Int(1023), base=2, pad=10)|> reverse
    # strat = vec3utri(bin_vec)
    # g = vec2utri(bin_vec)
    # kk = vec4utri(bin_vec)
    # println(strat[4, :])
    mem_arr = []
    Dates.format(now(),  "HH:MM:SS")
    @time for i in 1:2^(n_agents*(n_agents-1)/2)-1
    # @profile for i in 1:2^(n_agents*(n_agents-1)/2)-1
        # println(i)
        bin_vec = digits(Int(i), base=2, pad=10)|> reverse
        s_mat = vec4utri(bin_vec)
        println(s_mat)
        dove = sum(s_mat, dims=1)
        hawk = sum(eachcol(s_mat))
        mix = mixed(n_agents, hawk, dove)
        mem, tot = memory_calculation(n_agents, dove, hawk, mix)
        # println(mem)
        # println(mem_arr)
        push!(mem_arr, mem)
        # println(mem)
    end
    Dates.format(now(),  "HH:MM:SS")
    pprof()
    # digits(24, base=2)
    p1 = histogram(mem_arr)
end

pprof()

println(PROGRAM_FILE)
println(@__FILE__)

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end