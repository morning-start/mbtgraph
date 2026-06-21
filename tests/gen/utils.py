"""公共工具：mbtgraph JSON 格式导出"""

import json
from pathlib import Path


def fixtures_dir(module_name):
    """返回指定模块的 fixture 目录"""
    d = Path(__file__).parent.parent / "fixtures" / module_name
    d.mkdir(parents=True, exist_ok=True)
    return d


def export_mbtgraph_json(G, directed, filepath):
    """将 NetworkX 图导出为 mbtgraph JSON 格式"""
    nodes = sorted(G.nodes())
    edges = []
    for u, v, data in G.edges(data=True):
        weight = data.get("weight", 1.0)
        edges.append({"source": u, "target": v, "weight": float(weight)})
    doc = {"mbtgraph": "1.0", "directed": directed, "nodes": nodes, "edges": edges}
    filepath = Path(filepath)
    filepath.parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, "w") as f:
        json.dump(doc, f, indent=2)


def export_ground_truth(data, filepath):
    """导出 ground truth 结果"""
    filepath = Path(filepath)
    filepath.parent.mkdir(parents=True, exist_ok=True)
    with open(filepath, "w") as f:
        json.dump(data, f, indent=2)


def random_weights(G, low=1.0, high=10.0, seed=None):
    """为图的边随机赋权"""
    import random as rng
    r = rng.Random(seed)
    for u, v in G.edges():
        G[u][v]["weight"] = round(r.uniform(low, high), 2)
    return G


def ensure_connected(G):
    """确保无向图连通"""
    import networkx as nx
    comps = list(nx.connected_components(G))
    if len(comps) > 1:
        largest = max(comps, key=len)
        for c in comps:
            if c != largest:
                for nd in c:
                    G.add_edge(nd, next(iter(largest)))
    return G
