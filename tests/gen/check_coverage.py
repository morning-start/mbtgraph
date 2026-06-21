"""精确检查：每个算法是否有 NetworkX 对应 + 是否有测试"""
import re, os, glob

# 每个模块的算法 -> NetworkX 对应（None = 无法用 Python 测试）
ALGO_NETWORKX = {
    "shortest_path": {
        "dijkstra": "nx.shortest_path_length(weight='weight')",
        "bellman_ford": "nx.shortest_path_length(weight='weight')",
        "floyd_warshall": "nx.all_pairs_shortest_path_length(weight='weight')",
        "a_star": "nx.astar_path_length(weight='weight')",
        "dijkstra_targeted": "nx.shortest_path_length(weight='weight')",
        "bidirectional_dijkstra": "nx.bidirectional_dijkstra(weight='weight')",
        "johnson": "nx.johnson(weight='weight')",
        "yen_k_shortest": "nx.shortest_simple_paths()",
    },
    "traversal": {
        "bfs": "nx.bfs_tree / nx.shortest_path_length",
        "bfs_all": "nx.bfs_tree",
        "bfs_shortest_path": "nx.shortest_path",
        "bidirectional_bfs": "nx.bidirectional_shortest_path",
        "dfs": "nx.dfs_tree",
        "dfs_all": "nx.dfs_tree",
        "topo_sort": "nx.topological_sort",
        "topo_sort_dfs": "nx.topological_sort",
        "has_cycle": "nx.is_directed_acyclic_graph",
        "has_undirected_cycle": "nx.cycle_basis",
    },
    "connectivity": {
        "connected_components": "nx.connected_components",
        "tarjan_scc": "nx.strongly_connected_components",
        "kosaraju_scc": "nx.strongly_connected_components",
        "biconnected_components": "nx.biconnected_components",
    },
    "cutpoints": {
        "find_articulation_points_undirected": "nx.articulation_points",
        "find_articulation_points_directed": "nx.articulation_points",
        "find_bridges_undirected": "nx.bridges",
        "find_bridges_directed": "nx.bridges",
    },
    "mst": {
        "kruskal": "nx.minimum_spanning_tree(algorithm='kruskal')",
        "prim": "nx.minimum_spanning_tree(algorithm='prim')",
    },
    "pagerank": {
        "pagerank": "nx.pagerank",
    },
    "centrality": {
        "degree_centrality": "nx.degree_centrality",
        "betweenness_centrality": "nx.betweenness_centrality",
        "closeness_centrality": "nx.closeness_centrality",
        "eigenvector_centrality": "nx.eigenvector_centrality",
        "katz_centrality": "nx.katz_centrality",
        "harmonic_centrality": "nx.harmonic_centrality",
        "communication_centrality": None,  # 无直接对应
        "group_betweenness_centrality": None,
    },
    "coloring": {
        "greedy_coloring": "nx.coloring.greedy_color",
        "greedy_coloring_with_order": "nx.coloring.greedy_color",
        "welsh_powell": "nx.coloring.greedy_color(strategy='largest_first')",
        "dsatur_coloring": None,  # NetworkX 无 dsatur
        "exact_chromatic_number": None,  # NP-hard
        "edge_coloring": "nx.algorithms.coloring.edge_coloring",
    },
    "community": {
        "louvain": "nx_comm.louvain_communities",
        "label_propagation": "nx_comm.label_propagation_communities",
        "leiden": "nx_comm.leiden_communities",
        "spectral_clustering": None,  # 需要 sklearn
    },
    "recognition": {
        "is_bipartite": "nx.is_bipartite",
        "is_complete": "nx.is_complete (manual check)",
        "is_regular": "nx.is_regular",
        "is_tree": "nx.is_tree",
        "is_forest": "nx.is_forest",
        "is_chordal": "nx.is_chordal",
        "is_graphic_sequence": "nx.is_graphical",
    },
    "euler": {
        "has_euler_path_undirected": "nx.has_eulerian_path",
        "has_euler_circuit_undirected": "nx.is_eulerian",
        "has_euler_path_directed": "nx.has_eulerian_path",
        "has_euler_circuit_directed": "nx.is_eulerian",
        "find_euler_path_undirected": "nx.eulerian_path",
        "find_euler_circuit_undirected": "nx.eulerian_circuit",
        "find_euler_path_directed": "nx.eulerian_path",
        "find_euler_circuit_directed": "nx.eulerian_circuit",
    },
    "clique": {
        "find_maximum_clique": "nx.find_cliques",
        "find_maximum_independent_set": "nx.maximal_independent_set",
        "find_minimum_vertex_cover_exact": "nx.min_weight_vertex_cover",
        "find_minimum_vertex_cover_approx": "nx.min_weight_vertex_cover",
    },
    "dense_subgraph": {
        "count_triangles": "nx.triangles",
        "k_core_decomposition": "nx.k_shell",
        "k_truss_decomposition": None,  # NetworkX 无 k-truss
        "clustering_coefficients": "nx.clustering",
        "local_clustering_coefficient": "nx.clustering",
        "average_clustering_coefficient": "nx.average_clustering",
    },
    "hamiltonian": {
        "has_hamiltonian_circuit_quick_check": None,  # NP-hard
        "find_hamiltonian_path_backtrack": None,  # NP-hard
        "find_hamiltonian_circuit_backtrack": None,  # NP-hard
        "tsp_nearest_neighbor": None,  # NetworkX tsp 需要特殊输入
        "tsp_exact_held_karp": None,
    },
    "link_prediction": {
        "common_neighbors": "nx.common_neighbors",
        "jaccard_coefficient": "nx.jaccard_coefficient",
        "adamic_adar_index": "nx.adamic_adar_index",
        "preferential_attachment": "nx.preferential_attachment",
        "resource_allocation": "nx.resource_allocation_index",
        "link_prediction_score": None,  # 自定义组合
    },
    "operators": {
        "complement": "nx.complement",
        "reverse": "nx.reverse",
        "graph_union": "nx.disjoint_union",
        "graph_intersection": None,  # NetworkX 无直接对应
        "graph_difference": None,
        "cartesian_product": "nx.cartesian_product",
        "tensor_product": "nx.tensor_product",
        "lexicographic_product": "nx.lexicographic_product",
        "line_graph": "nx.line_graph",
        "contract": None,
        "power_graph": "nx.power",
    },
    "matching": {
        "hopcroft_karp": "nx.algorithms.bipartite.matching.hopcroft_karp_matching",
        "bipartite_matching": "nx.algorithms.bipartite.matching.hopcroft_karp_matching",
        "bipartite_matching_graph": "nx.algorithms.bipartite.matching",
        "edmonds_maximum_matching": "nx.maximal_matching",
        "kuhn_munkres": None,  # 需要 scipy
    },
    "flow": {
        "edmonds_karp": "nx.maximum_flow_value",
        "dinic": "nx.maximum_flow_value",
        "push_relabel": "nx.maximum_flow_value",
        "min_cost_max_flow": "nx.min_cost_flow",
        "capacity_scaling": "nx.min_cost_flow",
    },
}

# 读取每个模块的测试文件，看测试了哪些算法
tested = {}
for f in sorted(glob.glob('lib/algo/integration/*_test.mbt')):
    mod = os.path.basename(f).replace('_test.mbt', '')
    with open(f, encoding='utf-8') as fh:
        content = fh.read()
    # 提取测试的算法前缀
    tests = re.findall(r'test "(\w+)_', content)
    prefixes = set(t.split('_')[0] for t in tests if '_' in t)
    tested[mod] = prefixes

print("Module              | Total | Can Test | Tested | Missing (can test but no test)")
print("-" * 90)
for mod in sorted(ALGO_NETWORKX.keys()):
    algos = ALGO_NETWORKX[mod]
    can_test = {a: v for a, v in algos.items() if v is not None}
    total = len(algos)
    n_can = len(can_test)
    tested_count = len(tested.get(mod, set()))
    missing = set(can_test.keys()) - tested.get(mod, set())
    # Simplify missing list
    missing_short = [m.split('_')[0] for m in missing]
    print(f"{mod:20s} | {total:5d} | {n_can:8d} | {tested_count:6d} | {missing_short}")
