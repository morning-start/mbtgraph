"""按算法生成 fixture 数据（每算法 5 个图）"""
import json, random as rng, sys, networkx as nx
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from utils import export_mbtgraph_json, export_ground_truth, random_weights, ensure_connected, fixtures_dir

ALL_FIX = {}

def fix(module):
    if module not in ALL_FIX:
        ALL_FIX[module] = fixtures_dir(module)
    return ALL_FIX[module]

def save(module, name, G, directed, truth):
    export_mbtgraph_json(G, directed, fix(module) / f"{name}.json")
    export_ground_truth(truth, fix(module) / f"{name}_truth.json")

SEEDS = [1, 2, 3, 4, 5]
N_LIST = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]

# ═══════ shortest_path ═══════
def gen_shortest_path():
    m = "shortest_path"; print(f"[{m}]")
    # dijkstra x5
    for i, ((n,p),seed) in enumerate(zip(N_LIST, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed); random_weights(G, seed=seed)
        pairs = [{"t":t,"l":round(nx.shortest_path_length(G,0,t,weight="weight"),2)} if nx.has_path(G,0,t) else {"t":t,"l":-1} for t in range(n)]
        save(m, f"dj_{i+1}", G, True, {"algo":"dijkstra","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    # bellman_ford x5
    for i, ((n,p),seed) in enumerate(zip(N_LIST, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+100); random_weights(G, seed=seed+100)
        pairs = [{"t":t,"l":round(nx.shortest_path_length(G,0,t,weight="weight"),2)} if nx.has_path(G,0,t) else {"t":t,"l":-1} for t in range(n)]
        save(m, f"bf_{i+1}", G, True, {"algo":"bellman_ford","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    # floyd_warshall x5
    fwn = [(8,0.3),(10,0.25),(6,0.4),(12,0.2),(9,0.35)]
    for i, ((n,p),seed) in enumerate(zip(fwn, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed); random_weights(G, seed=seed)
        r2=rng.Random(seed+200); pairs=[]
        for _ in range(3):
            s,t=r2.randint(0,n-1),r2.randint(0,n-1)
            try: pairs.append({"s":s,"t":t,"l":round(nx.shortest_path_length(G,s,t,weight="weight"),2)})
            except: pairs.append({"s":s,"t":t,"l":-1})
        save(m, f"fw_{i+1}", G, True, {"algo":"floyd_warshall","nc":n,"ec":G.number_of_edges(),"pairs":pairs})

# ═══════ traversal ═══════
def gen_traversal():
    m = "traversal"; print(f"[{m}]")
    # bfs x5
    for i, ((n,p),seed) in enumerate(zip(N_LIST, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        pairs = [{"t":t,"d":nx.shortest_path_length(G,0,t)} if nx.has_path(G,0,t) else {"t":t,"d":-1} for t in range(n)]
        save(m, f"bfs_{i+1}", G, True, {"algo":"bfs","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    # dfs x5
    for i, ((n,p),seed) in enumerate(zip(N_LIST, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+10)
        reachable = set(); queue = [0]
        while queue:
            node = queue.pop(0)
            if node not in reachable:
                reachable.add(node)
                for nb in G.successors(node):
                    if nb not in reachable: queue.append(nb)
        save(m, f"dfs_{i+1}", G, True, {"algo":"dfs","nc":n,"ec":G.number_of_edges(),"reachable":len(reachable)})
    # topo_sort x5 (DAG)
    for i, ((n,_p),seed) in enumerate(zip(N_LIST, SEEDS)):
        G = nx.DiGraph(); G.add_nodes_from(range(n)); r=rng.Random(seed)
        for u in range(n):
            for v in range(u+1,n):
                if r.random()<0.3: G.add_edge(u,v)
        save(m, f"topo_{i+1}", G, True, {"algo":"topo_sort","nc":n,"ec":G.number_of_edges()})
    # has_cycle x5
    for i, ((n,p),seed) in enumerate(zip(N_LIST, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+20)
        save(m, f"cycle_{i+1}", G, True, {"algo":"has_cycle","nc":n,"ec":G.number_of_edges(),"has_cycle":not nx.is_directed_acyclic_graph(G)})

# ═══════ connectivity ═══════
def gen_connectivity():
    m = "connectivity"; print(f"[{m}]")
    uc = [(10,0.4),(12,0.35),(15,0.3),(8,0.5),(18,0.25)]
    for i, ((n,p),seed) in enumerate(zip(uc, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed)); random_weights(G, seed=seed)
        cc = list(nx.connected_components(G))
        save(m, f"cc_{i+1}", G, False, {"algo":"cc","nc":n,"ec":G.number_of_edges(),"count":len(cc),"sizes":sorted([len(c) for c in cc],reverse=True)})
    dc = [(10,0.3),(12,0.25),(15,0.2),(8,0.35),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(dc, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        sccs = list(nx.strongly_connected_components(G))
        save(m, f"scc_{i+1}", G, True, {"algo":"scc","nc":n,"ec":G.number_of_edges(),"count":len(sccs)})
    for i, ((n,p),seed) in enumerate(zip(uc, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed+50))
        bcc = list(nx.biconnected_components(G))
        save(m, f"bcc_{i+1}", G, False, {"algo":"bcc","nc":n,"ec":G.number_of_edges(),"count":len(bcc)})

# ═══════ cutpoints ═══════
def gen_cutpoints():
    m = "cutpoints"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed))
        save(m, f"ap_{i+1}", G, False, {"algo":"ap","nc":n,"ec":G.number_of_edges(),"count":len(list(nx.articulation_points(G)))})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed+50))
        save(m, f"br_{i+1}", G, False, {"algo":"br","nc":n,"ec":G.number_of_edges(),"count":len(list(nx.bridges(G)))})

# ═══════ mst ═══════
def gen_mst():
    m = "mst"; print(f"[{m}]")
    configs = [(10,0.4),(12,0.35),(15,0.3),(8,0.5),(20,0.25)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed)); random_weights(G, seed=seed)
        mst = nx.minimum_spanning_tree(G, algorithm="kruskal")
        w = sum(d["weight"] for _,_,d in mst.edges(data=True))
        save(m, f"mst_{i+1}", G, False, {"algo":"mst","nc":n,"ec":G.number_of_edges(),"weight":round(w,2),"edges":mst.number_of_edges()})

# ═══════ pagerank ═══════
def gen_pagerank():
    m = "pagerank"; print(f"[{m}]")
    configs = [(10,0.3),(15,0.2),(20,0.15),(12,0.25),(8,0.4)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        for nd in range(n):
            if G.out_degree(nd)==0:
                for t in range(n):
                    if t!=nd: G.add_edge(nd,t)
        pr = nx.pagerank(G, alpha=0.85)
        save(m, f"pr_{i+1}", G, True, {"algo":"pagerank","nc":n,"ec":G.number_of_edges(),"total":round(sum(pr.values()),6)})

# ═══════ centrality ═══════
def gen_centrality():
    m = "centrality"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        dc = nx.degree_centrality(G); bc = nx.betweenness_centrality(G)
        cc = nx.closeness_centrality(G); ec = nx.eigenvector_centrality(G, max_iter=1000)
        save(m, f"cent_{i+1}", G, False, {"algo":"centrality","nc":n,"ec":G.number_of_edges(),
            "dc_top":int(max(dc,key=dc.get)),"bc_top":int(max(bc,key=bc.get)),
            "cc_top":int(max(cc,key=cc.get)),"ec_top":int(max(ec,key=ec.get))})

# ═══════ coloring ═══════
def gen_coloring():
    m = "coloring"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        coloring = nx.coloring.greedy_color(G, strategy="largest_first")
        nc = max(coloring.values())+1 if coloring else 0
        valid = all(coloring.get(u)!=coloring.get(v) for u,v in G.edges())
        save(m, f"col_{i+1}", G, False, {"algo":"coloring","nc":n,"ec":G.number_of_edges(),"colors":nc,"valid":valid})

# ═══════ community ═══════
def gen_community():
    m = "community"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        from networkx.algorithms.community import louvain_communities, modularity
        communities = louvain_communities(G, seed=seed)
        save(m, f"com_{i+1}", G, False, {"algo":"community","nc":n,"ec":G.number_of_edges(),
            "communities":len(communities),"modularity":round(modularity(G,communities),6)})

# ═══════ recognition ═══════
def gen_recognition():
    m = "recognition"; print(f"[{m}]")
    configs = [
        ("bipartite", nx.complete_bipartite_graph(4,5)),
        ("complete_k5", nx.complete_graph(5)),
        ("regular", nx.random_regular_graph(3,8,seed=1)),
        ("tree", nx.random_labeled_tree(10,seed=2)),
        ("forest", nx.disjoint_union(nx.random_labeled_tree(5,seed=3), nx.random_labeled_tree(4,seed=4))),
    ]
    for i, (rtype, G) in enumerate(configs, 1):
        n=G.number_of_nodes()
        save(m, f"rec_{i}", G, False, {"algo":"recognition","nc":n,"ec":G.number_of_edges(),
            "bipartite":nx.is_bipartite(G),"complete":n*(n-1)//2==G.number_of_edges(),
            "regular":len(set(d for _,d in G.degree()))==1,"tree":nx.is_tree(G),"forest":nx.is_forest(G)})

# ═══════ euler ═══════
def gen_euler():
    m = "euler"; print(f"[{m}]")
    configs = [
        ("circuit", nx.cycle_graph(6)),
        ("path", nx.path_graph(5)),
        ("no_euler", nx.complete_graph(5)),
        ("circuit2", nx.complete_graph(4)),
        ("no_euler2", nx.star_graph(5)),
    ]
    for i, (rtype, G) in enumerate(configs, 1):
        save(m, f"euler_{i}", G, False, {"algo":"euler","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "has_path":nx.is_eulerian(G) or nx.has_eulerian_path(G),"has_circuit":nx.is_eulerian(G)})

# ═══════ clique ═══════
def gen_clique():
    m = "clique"; print(f"[{m}]")
    configs = [
        ("k5", nx.complete_graph(5)),
        ("petersen", nx.petersen_graph()),
        ("cycle6", nx.cycle_graph(6)),
        ("k4", nx.complete_graph(4)),
        ("random", nx.gnp_random_graph(8, 0.5, seed=42)),
    ]
    for i, (rtype, G) in enumerate(configs, 1):
        cliques = list(nx.find_cliques(G))
        save(m, f"clique_{i}", G, False, {"algo":"clique","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "max_clique":max(len(c) for c in cliques) if cliques else 0})

# ═══════ dense_subgraph ═══════
def gen_dense_subgraph():
    m = "dense_subgraph"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        triangles = sum(nx.triangles(G).values())//3
        save(m, f"dense_{i+1}", G, False, {"algo":"dense_subgraph","nc":n,"ec":G.number_of_edges(),
            "triangles":triangles,"avg_cc":round(nx.average_clustering(G),6)})

# ═══════ hamiltonian ═══════
def gen_hamiltonian():
    m = "hamiltonian"; print(f"[{m}]")
    configs = [
        ("cycle", nx.cycle_graph(8)),
        ("complete", nx.complete_graph(6)),
        ("path", nx.path_graph(5)),
        ("star", nx.star_graph(5)),
        ("petersen", nx.petersen_graph()),
    ]
    for i, (rtype, G) in enumerate(configs, 1):
        save(m, f"ham_{i}", G, False, {"algo":"hamiltonian","nc":G.number_of_nodes(),"ec":G.number_of_edges()})

# ═══════ link_prediction ═══════
def gen_link_prediction():
    m = "link_prediction"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(8,0.4),(15,0.2),(6,0.5)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        non_edges = list(nx.non_edges(G))
        if non_edges:
            u,v = non_edges[0]; cn = len(list(nx.common_neighbors(G,u,v)))
        else: u,v,cn = 0,1,0
        save(m, f"lp_{i+1}", G, False, {"algo":"link_prediction","nc":n,"ec":G.number_of_edges(),"u":u,"v":v,"cn":cn})

# ═══════ operators ═══════
def gen_operators():
    m = "operators"; print(f"[{m}]")
    configs = [(6,0.4),(8,0.3),(5,0.5),(10,0.2),(7,0.35)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        comp = nx.complement(G)
        save(m, f"op_{i+1}", G, False, {"algo":"operators","nc":n,"ec":G.number_of_edges(),
            "comp_ec":comp.number_of_edges(),"comp_nc":comp.number_of_nodes()})

# ═══════ matching ═══════
def gen_matching():
    m = "matching"; print(f"[{m}]")
    configs = [(5,5,0.5),(6,4,0.4),(8,6,0.3),(4,4,0.6),(7,5,0.35)]
    for i, ((left,right,p), seed) in enumerate(zip(configs, SEEDS)):
        G = nx.complete_bipartite_graph(left,right); r=rng.Random(seed)
        to_remove = [(u,v) for u,v in G.edges() if u<left and r.random()>p]
        G.remove_edges_from(to_remove)
        left_set = set(range(left))
        matching = nx.algorithms.bipartite.matching.hopcroft_karp_matching(G, top_nodes=left_set)
        save(m, f"match_{i+1}", G, False, {"algo":"matching","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "left":left,"right":right,"size":len(matching)//2})

# ═══════ flow ═══════
def gen_flow():
    m = "flow"; print(f"[{m}]")
    configs = [(6,0.5),(8,0.4),(10,0.3),(5,0.6),(7,0.45)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        random_weights(G, seed=seed, low=1.0, high=20.0)
        if not nx.has_path(G, 0, n-1): G.add_edge(0, n-1, weight=10.0)
        mf = nx.maximum_flow_value(G, 0, n-1, capacity="weight")
        save(m, f"flow_{i+1}", G, True, {"algo":"flow","nc":n,"ec":G.number_of_edges(),"mf":round(mf,2),"src":0,"snk":n-1})


ALL_GENS = [
    gen_shortest_path, gen_traversal, gen_connectivity, gen_cutpoints,
    gen_mst, gen_pagerank, gen_centrality, gen_coloring, gen_community,
    gen_recognition, gen_euler, gen_clique, gen_dense_subgraph,
    gen_hamiltonian, gen_link_prediction, gen_operators, gen_matching, gen_flow,
]

if __name__ == "__main__":
    print("=== Generating fixtures (per algorithm, 5 each) ===")
    for g in ALL_GENS:
        g()
    print("=== Done ===")
