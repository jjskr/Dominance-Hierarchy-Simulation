using Compose, MetaGraphs, TikzGraphs, TikzPictures, LinearAlgebra, GraphRecipes, Plots, Graphs, GraphPlot


# function graph_matrix(x, pop)
#     p = pop
#     A = Float64[ rand() < 0.5 ? 0 : rand() for i=1:p, j=1:p]
#     println(A)
#     for i=1:p
#         A[i, 1:i-1] = A[1:i-1, i]
#         A[i, i] = 0
#     end
#     graphplot(A, markersize = 0.2,
#         #   node_weights = 1:p,
#         #   markercolor = range(colorant"yellow", stop=colorant"red", length=p),
#           names = 1:p,
#           fontsize = 10,
#           linecolor = :darkgrey
#           )
# end

# # graph_matrix(cur, 15)
# g = wheel_graph(sim.population)
# graphplot(g, curves=false)
# nodelabels = 1:sim.population
# # gr = SimpleGraph(sim.population)
# # add_edge!(gr,1,5)
# # add_edge!(gr,2,4)
# # add_edge!(gr,3,4)
# # add_edge!(gr,4,5)
# # graphplot(gr)
# test_graph = LightGraphs.DiGraph(cur)
# graphplot(test_graph)
# g = Graphs.path_graph(10)
# g = wheel_graph(10)
# g = Graphs.Graph(10)
# Graphs.add_edge!(g, 1, 2)
# Graphs.add_edge!(g, 1, 3)
# Graphs.add_edge!(g, 1, 4)
# Graphs.add_edge!(g, 1, 5)
# Graphs.add_edge!(g, 1, 6)
# Graphs.add_edge!(g, 1, 7)
# Graphs.add_edge!(g, 1, 8)
# Graphs.add_edge!(g, 1, 9)
# Graphs.add_edge!(g, 1, 10)
# Graphs.add_edge!(g, 2, 4)
# Graphs.add_edge!(g, 2, 5)
# Graphs.add_edge!(g, 2, 6)
# Graphs.add_edge!(g, 2, 7)
# Graphs.add_edge!(g, 2, 8)
# Graphs.add_edge!(g, 2, 9)
# Graphs.add_edge!(g, 2, 10)
# Graphs.add_edge!(g, 3, 4)
# Graphs.add_edge!(g, 3, 5)
# Graphs.add_edge!(g, 3, 6)
# Graphs.add_edge!(g, 3, 7)
# Graphs.add_edge!(g, 3, 8)
# Graphs.add_edge!(g, 3, 9)
# Graphs.add_edge!(g, 3, 10)
# Graphs.add_edge!(g, 4, 5)
# Graphs.add_edge!(g, 4, 6)
# Graphs.add_edge!(g, 4, 7)
# Graphs.add_edge!(g, 4, 8)
# Graphs.add_edge!(g, 4, 9)
# Graphs.add_edge!(g, 4, 10)
# Graphs.add_edge!(g, 5, 6)
# Graphs.add_edge!(g, 5, 7)
# Graphs.add_edge!(g, 5, 8)
# Graphs.add_edge!(g, 5, 9)
# Graphs.add_edge!(g, 5, 10)
# Graphs.add_edge!(g, 6, 7)
# Graphs.add_edge!(g, 6, 8)
# Graphs.add_edge!(g, 6, 9)
# Graphs.add_edge!(g, 6, 10)
# Graphs.add_edge!(g, 7, 8)
# Graphs.add_edge!(g, 7, 9)
# Graphs.add_edge!(g, 7, 10)
# Graphs.add_edge!(g, 8, 9)
# Graphs.add_edge!(g, 8, 10)
# Graphs.add_edge!(g, 9, 10)

# plot(g, nodelabel=1:10)
# curr = Symmetric(current)
# attempt = Graphs.Graph(current)
# gplot(new, nodelabel=1:15)
# # am = Matrix(adjacency_matrix(g))
# # loc_x, loc_y = layout_spring_adj(am)
# # LightGraphs.draw_layout_adj(am)
# nm = Graphs.wheel_graph(10)
# nm = path_graph(10)
list = unique(sol_list)
for i in list
    println(i)
    println(sum(i))
    if sum(i) == 18
        mem_calcs_full(i, 7)
    end
end
best_cur = unique(sol_list)[3]
sec = unique(sol_list)[5]
mem_calcs_full(best_cur, 7)
nm = Graphs.DiGraph(best_cur)
# ne(nm)
# Graphs.add_edge!(nm, 9, 10)
# gplot(nm, nodelabel=1:sim.population)

# t = Plots.plot(nm, nodelabel=1:15)

# plot n = 5, m = 1
opt51 = unique(sol_list)[1]
opt512 = unique(sol_list)[2]
graph51 = Graphs.DiGraph(opt512)
# graphplot(opt51, nodesize=0.3, names=1:5, fontsize=10, layout=circular_layout)
gplot(graph51, NODESIZE=0.15, NODELABELSIZE=7, nodesize=1, nodelabel=1:5, layout=circular_layout)
# draw(SVG("opt51.svg", 15cm, 15cm), gplot(graph51, nodelabel=1:5, layout=circular_layout))


# plot n = 11, m = 4
opt114 = okay11
graph114 = Graphs.DiGraph(opt114)
gplot(graph114, nodelabel=1:11)

# plot n = 9, m = 3
opt93 = okay9
graph93 = Graphs.DiGraph(opt93)
gplot(graph93, nodelabel=1:9)
graphplot(opt93, nodesize=0.3, names=1:9, fontsize=10)

# plot n = 7, m = 2
opt72 = okay7
graph72 = Graphs.DiGraph(opt72)
gplot(graph93, nodelabel=1:9)
graphplot(opt72, nodesize=0.3, names=1:7, fontsize=10)
draw(PNG("opt72.png", 15cm, 15cm), graphplot(graph72, nodesize=0.3, names=1:7, fontsize=10))
draw(PNG("opt72.png", 15cm, 15cm), gplot(graph72, nodelabel=1:7))
draw(SVGJS("opt72.svg"), gplot(graph72, nodelabel=1:7))
png(graphplot(opt72, nodesize=0.3, names=1:7, fontsize=10), "opt72")
savefig(graphplot(opt72, nodesize=0.3, names=1:7, fontsize=10), "opt72")