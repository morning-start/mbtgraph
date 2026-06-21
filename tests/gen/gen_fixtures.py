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

def _make_configs(n_list=None):
    return list(zip(n_list or N_LIST, SEEDS))

# ═══════ shortest_path ═══════
def gen_shortest_path():
    m = "shortest_path"; print(f"[{m}]")
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed); random_weights(G, seed=seed)
        pairs = [{"t":t,"l":round(nx.shortest_path_length(G,0,t,weight="weight"),2)} if nx.has_path(G,0,t) else {"t":t,"l":-1} for t in range(n)]
        save(m, f"dj_{i+1}", G, True, {"algo":"dijkstra","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+100); random_weights(G, seed=seed+100)
        pairs = [{"t":t,"l":round(nx.shortest_path_length(G,0,t,weight="weight"),2)} if nx.has_path(G,0,t) else {"t":t,"l":-1} for t in range(n)]
        save(m, f"bf_{i+1}", G, True, {"algo":"bellman_ford","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    fwn = [(8,0.3),(10,0.25),(6,0.4),(12,0.2),(9,0.35)]
    for i, ((n,p),seed) in enumerate(zip(fwn, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed); random_weights(G, seed=seed)
        r2=rng.Random(seed+200); pairs=[]
        for _ in range(3):
            s,t=r2.randint(0,n-1),r2.randint(0,n-1)
            try: pairs.append({"s":s,"t":t,"l":round(nx.shortest_path_length(G,s,t,weight="weight"),2)})
            except: pairs.append({"s":s,"t":t,"l":-1})
        save(m, f"fw_{i+1}", G, True, {"algo":"floyd_warshall","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    # a_star x5
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+300); random_weights(G, seed=seed+300)
        pairs = [{"t":t,"l":round(nx.astar_path_length(G,0,t,weight="weight"),2)} if nx.has_path(G,0,t) else {"t":t,"l":-1} for t in range(n)]
        save(m, f"astar_{i+1}", G, True, {"algo":"a_star","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    # bidirectional_dijkstra x5
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+400); random_weights(G, seed=seed+400)
        pairs = [{"t":t,"l":round(nx.shortest_path_length(G,0,t,weight="weight"),2)} if nx.has_path(G,0,t) else {"t":t,"l":-1} for t in range(n)]
        save(m, f"bdj_{i+1}", G, True, {"algo":"bidirectional_dijkstra","nc":n,"ec":G.number_of_edges(),"pairs":pairs})

# ═══════ traversal ═══════
def gen_traversal():
    m = "traversal"; print(f"[{m}]")
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        pairs = [{"t":t,"d":nx.shortest_path_length(G,0,t)} if nx.has_path(G,0,t) else {"t":t,"d":-1} for t in range(n)]
        save(m, f"bfs_{i+1}", G, True, {"algo":"bfs","nc":n,"ec":G.number_of_edges(),"pairs":pairs})
    for i, ((n,_p),seed) in enumerate(_make_configs()):
        G = nx.DiGraph(); G.add_nodes_from(range(n)); r=rng.Random(seed)
        for u in range(n):
            for v in range(u+1,n):
                if r.random()<0.3: G.add_edge(u,v)
        save(m, f"topo_{i+1}", G, True, {"algo":"topo_sort","nc":n,"ec":G.number_of_edges()})
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+20)
        save(m, f"cycle_{i+1}", G, True, {"algo":"has_cycle","nc":n,"ec":G.number_of_edges(),"has_cycle":not nx.is_directed_acyclic_graph(G)})

# ═══════ connectivity ═══════
def gen_connectivity():
    m = "connectivity"; print(f"[{m}]")
    uc = [(10,0.4),(12,0.35),(15,0.3),(8,0.5),(18,0.25)]
    for i, ((n,p),seed) in enumerate(zip(uc, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed)); random_weights(G, seed=seed)
        cc = list(nx.connected_components(G))
        save(m, f"cc_{i+1}", G, False, {"algo":"cc","nc":n,"ec":G.number_of_edges(),"count":len(cc)})
    dc = [(10,0.3),(12,0.25),(15,0.2),(8,0.35),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(dc, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        sccs = list(nx.strongly_connected_components(G))
        save(m, f"scc_{i+1}", G, True, {"algo":"scc","nc":n,"ec":G.number_of_edges(),"count":len(sccs)})
    for i, ((n,p),seed) in enumerate(zip(dc, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed+60)
        sccs = list(nx.strongly_connected_components(G))
        save(m, f"kosaraju_{i+1}", G, True, {"algo":"kosaraju_scc","nc":n,"ec":G.number_of_edges(),"count":len(sccs)})
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
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed+70)); random_weights(G, seed=seed+70)
        mst = nx.minimum_spanning_tree(G, algorithm="prim")
        w = sum(d["weight"] for _,_,d in mst.edges(data=True))
        save(m, f"prim_{i+1}", G, False, {"algo":"prim","nc":n,"ec":G.number_of_edges(),"weight":round(w,2),"edges":mst.number_of_edges()})

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
        save(m, f"cent_{i+1}", G, False, {"algo":"centrality","nc":n,"ec":G.number_of_edges(),
            "dc_top":int(max(dc,key=dc.get)),"bc_top":int(max(bc,key=bc.get))})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+10)
        cc = nx.closeness_centrality(G); ec = nx.eigenvector_centrality(G, max_iter=1000)
        save(m, f"cent_cc_{i+1}", G, False, {"algo":"closeness_centrality","nc":n,"ec":G.number_of_edges(),
            "cc_top":int(max(cc,key=cc.get))})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+20)
        ec = nx.eigenvector_centrality(G, max_iter=1000)
        save(m, f"cent_ec_{i+1}", G, False, {"algo":"eigenvector_centrality","nc":n,"ec":G.number_of_edges(),
            "ec_top":int(max(ec,key=ec.get))})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+30)
        kz = nx.katz_centrality(G, max_iter=1000)
        save(m, f"cent_katz_{i+1}", G, False, {"algo":"katz_centrality","nc":n,"ec":G.number_of_edges(),
            "katz_top":int(max(kz,key=kz.get))})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+40)
        hm = nx.harmonic_centrality(G)
        save(m, f"cent_harm_{i+1}", G, False, {"algo":"harmonic_centrality","nc":n,"ec":G.number_of_edges(),
            "harm_top":int(max(hm,key=hm.get))})

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
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+10)
        coloring = nx.coloring.greedy_color(G, strategy="largest_first")
        nc = max(coloring.values())+1 if coloring else 0
        valid = all(coloring.get(u)!=coloring.get(v) for u,v in G.edges())
        save(m, f"col_wp_{i+1}", G, False, {"algo":"welsh_powell","nc":n,"ec":G.number_of_edges(),"colors":nc,"valid":valid})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+20)
        # edge coloring: approximate via max degree + 1
        max_deg = max(d for _, d in G.degree()) if G.number_of_edges() > 0 else 0
        save(m, f"col_edge_{i+1}", G, False, {"algo":"edge_coloring","nc":n,"ec":G.number_of_edges(),"colors":max_deg + 1})

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
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+10)
        from networkx.algorithms.community import label_propagation_communities
        communities = list(label_propagation_communities(G))
        save(m, f"com_lp_{i+1}", G, False, {"algo":"label_propagation","nc":n,"ec":G.number_of_edges(),
            "communities":len(communities)})
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+20)
        from networkx.algorithms.community import greedy_modularity_communities
        communities = greedy_modularity_communities(G)
        save(m, f"com_leiden_{i+1}", G, False, {"algo":"leiden","nc":n,"ec":G.number_of_edges(),
            "communities":len(communities)})

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
            "regular":len(set(d for _,d in G.degree()))==1,"tree":nx.is_tree(G),"forest":nx.is_forest(G),
            "chordal":nx.is_chordal(G)})
    # complete x5
    for i, G in enumerate([nx.complete_graph(k) for k in [4,5,6,7,8]], 1):
        n=G.number_of_nodes()
        save(m, f"rec_complete_{i}", G, False, {"algo":"is_complete","nc":n,"ec":G.number_of_edges(),"complete":True})
    # regular x5
    for i, G in enumerate([nx.random_regular_graph(3, k, seed=i) for k in [6,8,10,12,14]], 1):
        n=G.number_of_nodes()
        save(m, f"rec_regular_{i}", G, False, {"algo":"is_regular","nc":n,"ec":G.number_of_edges(),"regular":True})
    # chordal x5
    for i, G in enumerate([nx.cycle_graph(k) for k in [4,5,6,7,8]], 1):
        n=G.number_of_nodes()
        save(m, f"rec_chordal_{i}", G, False, {"algo":"is_chordal","nc":n,"ec":G.number_of_edges(),"chordal":nx.is_chordal(G)})

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
    # find_euler_path x5
    for i, (rtype, G) in enumerate(configs, 1):
        has = nx.is_eulerian(G) or nx.has_eulerian_path(G)
        path_len = 0
        if has:
            try:
                path = list(nx.eulerian_path(G))
                path_len = len(path)
            except: pass
        save(m, f"euler_fp_{i}", G, False, {"algo":"find_euler_path","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "has":has,"path_len":path_len})
    # find_euler_circuit x5
    for i, (rtype, G) in enumerate(configs, 1):
        is_eul = nx.is_eulerian(G)
        circ_len = 0
        if is_eul:
            try:
                circ = list(nx.eulerian_circuit(G))
                circ_len = len(circ)
            except: pass
        save(m, f"euler_fc_{i}", G, False, {"algo":"find_euler_circuit","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "has":is_eul,"circ_len":circ_len})

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
    # independent_set x5
    for i, (rtype, G) in enumerate(configs, 1):
        mis = nx.maximal_independent_set(G)
        save(m, f"clique_is_{i}", G, False, {"algo":"independent_set","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "size":len(mis)})
    # vertex_cover x5 (greedy approximation)
    for i, (rtype, G) in enumerate(configs, 1):
        # greedy vertex cover: pick edges, add both endpoints
        vc = set()
        for u, v in G.edges():
            if u not in vc and v not in vc:
                vc.add(u); vc.add(v)
        save(m, f"clique_vc_{i}", G, False, {"algo":"vertex_cover","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "size":len(vc)})

# ═══════ dense_subgraph ═══════
def gen_dense_subgraph():
    m = "dense_subgraph"; print(f"[{m}]")
    configs = [(10,0.3),(12,0.25),(15,0.2),(8,0.4),(20,0.15)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        triangles = sum(nx.triangles(G).values())//3
        save(m, f"dense_{i+1}", G, False, {"algo":"dense_subgraph","nc":n,"ec":G.number_of_edges(),
            "triangles":triangles,"avg_cc":round(nx.average_clustering(G),6)})
    # k_core x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+10)
        core_numbers = nx.core_number(G)
        max_core = max(core_numbers.values()) if core_numbers else 0
        save(m, f"dense_kcore_{i+1}", G, False, {"algo":"k_core","nc":n,"ec":G.number_of_edges(),
            "max_core":max_core})
    # clustering x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+20)
        cc = nx.clustering(G)
        save(m, f"dense_cc_{i+1}", G, False, {"algo":"clustering","nc":n,"ec":G.number_of_edges(),
            "avg_cc":round(sum(cc.values())/len(cc),6) if cc else 0})

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
        save(m, f"lp_{i+1}", G, False, {"algo":"common_neighbors","nc":n,"ec":G.number_of_edges(),"u":u,"v":v,"cn":cn})
    # jaccard x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+10)
        non_edges = list(nx.non_edges(G))
        if non_edges:
            u,v = non_edges[0]
            jc = list(nx.jaccard_coefficient(G, [(u,v)]))[0][2]
        else: u,v,jc = 0,1,0.0
        save(m, f"lp_jac_{i+1}", G, False, {"algo":"jaccard","nc":n,"ec":G.number_of_edges(),"u":u,"v":v,"score":round(jc,6)})
    # adamic_adar x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+20)
        non_edges = list(nx.non_edges(G))
        if non_edges:
            u,v = non_edges[0]
            aa = list(nx.adamic_adar_index(G, [(u,v)]))[0][2]
        else: u,v,aa = 0,1,0.0
        save(m, f"lp_aa_{i+1}", G, False, {"algo":"adamic_adar","nc":n,"ec":G.number_of_edges(),"u":u,"v":v,"score":round(aa,6)})
    # preferential x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+30)
        non_edges = list(nx.non_edges(G))
        if non_edges:
            u,v = non_edges[0]
            pa = list(nx.preferential_attachment(G, [(u,v)]))[0][2]
        else: u,v,pa = 0,1,0
        save(m, f"lp_pa_{i+1}", G, False, {"algo":"preferential_attachment","nc":n,"ec":G.number_of_edges(),"u":u,"v":v,"score":pa})
    # resource x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed+40)
        non_edges = list(nx.non_edges(G))
        if non_edges:
            u,v = non_edges[0]
            ra = list(nx.resource_allocation_index(G, [(u,v)]))[0][2]
        else: u,v,ra = 0,1,0.0
        save(m, f"lp_ra_{i+1}", G, False, {"algo":"resource_allocation","nc":n,"ec":G.number_of_edges(),"u":u,"v":v,"score":round(ra,6)})

# ═══════ operators ═══════
def gen_operators():
    m = "operators"; print(f"[{m}]")
    configs = [(6,0.4),(8,0.3),(5,0.5),(10,0.2),(7,0.35)]
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        comp = nx.complement(G)
        save(m, f"op_{i+1}", G, False, {"algo":"operators","nc":n,"ec":G.number_of_edges(),
            "comp_ec":comp.number_of_edges(),"comp_nc":comp.number_of_nodes()})
    # reverse x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        rev = nx.reverse(G)
        save(m, f"op_rev_{i+1}", G, True, {"algo":"reverse","nc":n,"ec":G.number_of_edges(),
            "rev_nc":rev.number_of_nodes(),"rev_ec":rev.number_of_edges()})
    # union x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G1 = nx.gnp_random_graph(n, p, seed=seed)
        G2 = nx.gnp_random_graph(n, p, seed=seed+10)
        u = nx.disjoint_union(G1, G2)
        save(m, f"op_union_{i+1}", G1, False, {"algo":"graph_union","nc":G1.number_of_nodes(),"ec":G1.number_of_edges(),
            "union_nc":u.number_of_nodes(),"union_ec":u.number_of_edges()})
    # cartesian x5
    for i, ((n,p),seed) in enumerate(zip([(4,0.5),(5,0.4),(3,0.6),(4,0.3),(5,0.5)], SEEDS)):
        G1 = nx.gnp_random_graph(n, p, seed=seed)
        G2 = nx.gnp_random_graph(3, 0.5, seed=seed+20)
        cp = nx.cartesian_product(G1, G2)
        save(m, f"op_cart_{i+1}", G1, False, {"algo":"cartesian_product","nc":G1.number_of_nodes(),"ec":G1.number_of_edges(),
            "prod_nc":cp.number_of_nodes(),"prod_ec":cp.number_of_edges()})
    # tensor x5
    for i, ((n,p),seed) in enumerate(zip([(4,0.5),(5,0.4),(3,0.6),(4,0.3),(5,0.5)], SEEDS)):
        G1 = nx.gnp_random_graph(n, p, seed=seed)
        G2 = nx.gnp_random_graph(3, 0.5, seed=seed+30)
        tp = nx.tensor_product(G1, G2)
        save(m, f"op_tensor_{i+1}", G1, False, {"algo":"tensor_product","nc":G1.number_of_nodes(),"ec":G1.number_of_edges(),
            "prod_nc":tp.number_of_nodes(),"prod_ec":tp.number_of_edges()})
    # lex x5
    for i, ((n,p),seed) in enumerate(zip([(4,0.5),(5,0.4),(3,0.6),(4,0.3),(5,0.5)], SEEDS)):
        G1 = nx.gnp_random_graph(n, p, seed=seed)
        G2 = nx.gnp_random_graph(3, 0.5, seed=seed+40)
        lp = nx.lexicographic_product(G1, G2)
        save(m, f"op_lex_{i+1}", G1, False, {"algo":"lexicographic_product","nc":G1.number_of_nodes(),"ec":G1.number_of_edges(),
            "prod_nc":lp.number_of_nodes(),"prod_ec":lp.number_of_edges()})
    # line_graph x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = nx.gnp_random_graph(n, p, seed=seed)
        lg = nx.line_graph(G)
        save(m, f"op_line_{i+1}", G, False, {"algo":"line_graph","nc":n,"ec":G.number_of_edges(),
            "line_nc":lg.number_of_nodes(),"line_ec":lg.number_of_edges()})
    # power x5
    for i, ((n,p),seed) in enumerate(zip(configs, SEEDS)):
        G = ensure_connected(nx.gnp_random_graph(n, p, seed=seed))
        pg = nx.power(G, 2)
        save(m, f"op_power_{i+1}", G, False, {"algo":"power_graph","nc":n,"ec":G.number_of_edges(),
            "power_nc":pg.number_of_nodes(),"power_ec":pg.number_of_edges()})

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
    # bipartite_matching x5
    for i, ((left,right,p), seed) in enumerate(zip(configs, SEEDS)):
        G = nx.complete_bipartite_graph(left,right); r=rng.Random(seed+10)
        to_remove = [(u,v) for u,v in G.edges() if u<left and r.random()>p]
        G.remove_edges_from(to_remove)
        left_set = set(range(left))
        matching = nx.algorithms.bipartite.matching.hopcroft_karp_matching(G, top_nodes=left_set)
        save(m, f"match_bp_{i+1}", G, False, {"algo":"bipartite_matching","nc":G.number_of_nodes(),"ec":G.number_of_edges(),
            "left":left,"right":right,"size":len(matching)//2})
    # edmonds x5
    for i, ((n,p),seed) in enumerate(_make_configs()):
        G = nx.gnp_random_graph(n, p, seed=seed)
        mm = nx.maximal_matching(G)
        save(m, f"match_ed_{i+1}", G, False, {"algo":"edmonds_matching","nc":n,"ec":G.number_of_edges(),
            "size":len(mm)})

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
