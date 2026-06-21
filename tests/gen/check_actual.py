import glob, os, re

for f in sorted(glob.glob('lib/algo/integration/*_test.mbt')):
    mod = os.path.basename(f).replace('_test.mbt','')
    with open(f, encoding='utf-8') as fh:
        content = fh.read()
    tests = re.findall(r'test "([^"]+)"', content)
    algos_called = set()
    for fn in ['dijkstra','bellman_ford','floyd_warshall','bfs','dfs','topo_sort','has_cycle',
               'connected_components','tarjan_scc','kosaraju_scc','biconnected_components',
               'find_articulation_points','find_bridges','kruskal','prim','pagerank',
               'degree_centrality','betweenness_centrality','closeness_centrality','eigenvector_centrality',
               'katz_centrality','harmonic_centrality','greedy_coloring','welsh_powell','dsatur_coloring',
               'edge_coloring','louvain','label_propagation','leiden',
               'is_bipartite','is_complete','is_regular','is_tree','is_forest','is_chordal',
               'has_euler_path','has_euler_circuit','find_euler_path','find_euler_circuit',
               'find_maximum_clique','find_maximum_independent_set','find_minimum_vertex_cover',
               'count_triangles','k_core_decomposition','clustering_coefficients',
               'has_hamiltonian_circuit_quick_check','common_neighbors','jaccard_coefficient',
               'complement','reverse','hopcroft_karp','bipartite_matching','edmonds_maximum_matching']:
        if fn in content:
            algos_called.add(fn)
    print(f'{mod:20s} tests={len(tests):2d}  algos={sorted(algos_called)}')
