"""shortest_path 模块测试数据生成"""
import json, random as rng, sys, networkx as nx
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from utils import export_mbtgraph_json, export_ground_truth, random_weights, fixtures_dir

FIX = fixtures_dir("shortest_path")

def gen_dijkstra():
    print("  [Dijkstra] x5")
    for i, (n, p, seed) in enumerate([(10,0.3,1),(15,0.2,2),(20,0.25,3),(12,0.4,4),(18,0.15,5)], 1):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        random_weights(G, seed=seed)
        name = f"dijkstra_n{n}_{i}"
        export_mbtgraph_json(G, True, FIX / f"{name}.json")
        truth = {"algo": "dijkstra", "node_count": n, "edge_count": G.number_of_edges(),
                 "pairs": []}
        for t in range(n):
            try:
                l = nx.shortest_path_length(G, 0, t, weight="weight")
                truth["pairs"].append({"target": t, "length": l})
            except nx.NetworkXNoPath:
                truth["pairs"].append({"target": t, "length": -1})
        export_ground_truth(truth, FIX / f"{name}_truth.json")

def gen_bellman_ford():
    print("  [Bellman-Ford] x5")
    for i, (n, p, seed) in enumerate([(10,0.3,1),(12,0.25,2),(15,0.2,3),(8,0.4,4),(20,0.15,5)], 1):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        r = rng.Random(seed)
        for u, v in G.edges():
            G[u][v]['weight'] = round(r.uniform(1.0, 10.0), 2)
        name = f"bf_n{n}_{i}"
        export_mbtgraph_json(G, True, FIX / f"{name}.json")
        truth = {"algo": "bellman_ford", "node_count": n, "edge_count": G.number_of_edges(),
                 "pairs": []}
        for t in range(n):
            try:
                l = nx.shortest_path_length(G, 0, t, weight="weight")
                truth["pairs"].append({"target": t, "length": l})
            except nx.NetworkXNoPath:
                truth["pairs"].append({"target": t, "length": -1})
        export_ground_truth(truth, FIX / f"{name}_truth.json")

def gen_floyd_warshall():
    print("  [Floyd-Warshall] x5")
    for i, (n, p, seed) in enumerate([(8,0.3,1),(10,0.25,2),(6,0.4,3),(12,0.2,4),(9,0.35,5)], 1):
        G = nx.gnp_random_graph(n, p, directed=True, seed=seed)
        random_weights(G, seed=seed, low=1.0, high=10.0)
        name = f"fw_n{n}_{i}"
        export_mbtgraph_json(G, True, FIX / f"{name}.json")
        r2 = rng.Random(seed + 100)
        pairs = []
        for _ in range(3):
            s, t = r2.randint(0, n-1), r2.randint(0, n-1)
            try:
                l = nx.shortest_path_length(G, s, t, weight="weight")
                pairs.append({"source": s, "target": t, "length": l})
            except nx.NetworkXNoPath:
                pairs.append({"source": s, "target": t, "length": -1})
        truth = {"algo": "floyd_warshall", "node_count": n, "edge_count": G.number_of_edges(),
                 "pairs": pairs}
        export_ground_truth(truth, FIX / f"{name}_truth.json")

if __name__ == "__main__":
    gen_dijkstra()
    gen_bellman_ford()
    gen_floyd_warshall()
