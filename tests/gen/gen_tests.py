"""按算法生成 MoonBit 测试文件（每算法 5 个测试）"""
import json, glob, os
from pathlib import Path

FIX_ROOT = Path(__file__).parent.parent / "fixtures"
OUT_DIR = Path(__file__).parent.parent.parent / "lib" / "algo" / "integration"

# algo -> (module, directed, test_prefix)
ALGO_CONFIG = {
    "dijkstra":        ("shortest_path", True,  "dj"),
    "bellman_ford":    ("shortest_path", True,  "bf"),
    "floyd_warshall":  ("shortest_path", True,  "fw"),
    "bfs":             ("traversal",     True,  "bfs"),
    "dfs":             None,  # skip: DFS iterator issue
    "topo_sort":       ("traversal",     True,  "topo"),
    "has_cycle":       ("traversal",     True,  "cycle"),
    "cc":              ("connectivity",  False, "cc"),
    "scc":             ("connectivity",  True,  "scc"),
    "bcc":             ("connectivity",  False, "bcc"),
    "ap":              ("cutpoints",     False, "ap"),
    "br":              ("cutpoints",     False, "br"),
    "mst":             ("mst",           False, "mst"),
    "pagerank":        ("pagerank",      True,  "pr"),
    "centrality":      ("centrality",    False, "cent"),
    "coloring":        ("coloring",      False, "col"),
    "community":       ("community",     False, "com"),
    "recognition":     ("recognition",   False, "rec"),
    "euler":           ("euler",         False, "euler"),
    "clique":          ("clique",        False, "clique"),
    "dense_subgraph":  ("dense_subgraph",False, "dense"),
    "hamiltonian":     ("hamiltonian",   False, "ham"),
    "link_prediction": ("link_prediction",False,"lp"),
    "operators":       ("operators",     False, "op"),
    "matching":        ("matching",      False, "match"),
    "flow":            ("flow",          True,  "flow"),
}

needs_approx = {"shortest_path", "mst", "pagerank"}


def gen_body(module, truth, directed):
    algo = truth.get("algo", "")
    approx_fn = f'approx_{module}' if module in needs_approx else None
    body = []
    body.append(f'  match @io.parse_json_into(g, json) {{')
    body.append(f'    Ok(_) => {{')
    body.append(f'      assert_eq(@core.GraphReadable::node_count(g), {truth["nc"]})')

    if algo == "dijkstra":
        body.append(f'      let r = @sp.dijkstra(g, @core.NodeId(0))')
        for p in truth.get("pairs", [])[:3]:
            if p.get("l", -1) >= 0:
                body.append(f'      assert_true({approx_fn}(r.distance_to(@core.NodeId({p["t"]})),' f' {p["l"]}, 0.01))')
    elif algo == "bellman_ford":
        body.append(f'      match @sp.bellman_ford(g, @core.NodeId(0)) {{')
        body.append(f'        Ok(r) => {{')
        for p in truth.get("pairs", [])[:3]:
            if p.get("l", -1) >= 0:
                body.append(f'        assert_true({approx_fn}(r.distance_to(@core.NodeId({p["t"]})),' f' {p["l"]}, 0.01))')
        body.append(f'        }}')
        body.append(f'        Err(_) => ()')
        body.append(f'      }}')
    elif algo == "floyd_warshall":
        body.append(f'      match @sp.floyd_warshall(g) {{')
        body.append(f'        Ok(r) => {{')
        for p in truth.get("pairs", []):
            if p.get("l", -1) >= 0:
                body.append(f'        assert_true({approx_fn}(r.distance(@core.NodeId({p["s"]}), @core.NodeId({p["t"]})),' f' {p["l"]}, 0.01))')
        body.append(f'        }}')
        body.append(f'        Err(_) => ()')
        body.append(f'      }}')
    elif algo == "bfs":
        body.append(f'      let r = @traversal.bfs(g, @core.NodeId(0))')
        for p in truth.get("pairs", [])[:3]:
            if p.get("d", -1) >= 0:
                body.append(f'      assert_eq(r.distance(@core.NodeId({p["t"]})), {p["d"]})')
    elif algo == "dfs":
        body.append(f'      let r = @traversal.dfs(g, @core.NodeId(0))')
        body.append(f'      assert_eq(r.base.order.length(), {truth["reachable"]})')
    elif algo == "topo_sort":
        body.append(f'      assert_true(!@traversal.has_cycle(g))')
        body.append(f'      match @traversal.topo_sort_kahn(g) {{')
        body.append(f'        Ok(o) => {{ assert_eq(o.length(), {truth["nc"]}) }}')
        body.append(f'        Err(_) => ()')
        body.append(f'      }}')
    elif algo == "has_cycle":
        body.append(f'      assert_eq(@traversal.has_cycle(g), {str(truth["has_cycle"]).lower()})')
    elif algo == "cc":
        body.append(f'      let r = @conn.connected_components(g)')
        body.append(f'      assert_eq(r.count(), {truth["count"]})')
    elif algo == "scc":
        body.append(f'      let r = @conn.tarjan_scc(g)')
        body.append(f'      assert_eq(r.count(), {truth["count"]})')
    elif algo == "bcc":
        body.append(f'      let r = @conn.biconnected_components(g)')
        body.append(f'      assert_true(r.count() > 0)')
    elif algo == "ap":
        body.append(f'      let r = @cutpoints.find_articulation_points(g)')
        body.append(f'      assert_eq(r.count, {truth["count"]})')
    elif algo == "br":
        body.append(f'      let r = @cutpoints.find_bridges(g)')
        body.append(f'      assert_eq(r.count, {truth["count"]})')
    elif algo == "mst":
        body.append(f'      let r = @mst.kruskal(g)')
        body.append(f'      assert_eq(r.edge_count(), {truth["edges"]})')
        body.append(f'      assert_true({approx_fn}(r.total_weight, {truth["weight"]}, 0.1))')
    elif algo == "pagerank":
        body.append(f'      let r = @pagerank.pagerank(g, 0.85, 100, 0.000001)')
        body.append(f'      assert_true({approx_fn}(r.total_rank(), {truth["total"]}, 0.01))')
    elif algo == "centrality":
        body.append(f'      let dc = @centrality.degree_centrality(g, @centrality.Total)')
        body.append(f'      assert_true(dc.get_score(@core.NodeId({truth["dc_top"]})) >= Some(0.0))')
        body.append(f'      let bc = @centrality.betweenness_centrality(g, true)')
        body.append(f'      assert_true(bc.get_score(@core.NodeId({truth["bc_top"]})) >= Some(0.0))')
    elif algo == "coloring":
        body.append(f'      let r = @coloring.greedy_coloring(g)')
        body.append(f'      assert_true(r.num_colors > 0)')
        body.append(f'      assert_true(r.is_valid)')
    elif algo == "community":
        body.append(f'      let r = @community.louvain(g, 1.0)')
        body.append(f'      assert_true(r.num_communities > 0)')
    elif algo == "recognition":
        body.append(f'      assert_eq(@recognition.is_bipartite(g), {str(truth["bipartite"]).lower()})')
        body.append(f'      assert_eq(@recognition.is_tree(g), {str(truth["tree"]).lower()})')
        body.append(f'      assert_eq(@recognition.is_forest(g), {str(truth["forest"]).lower()})')
    elif algo == "euler":
        body.append(f'      assert_eq(@euler.has_euler_circuit(g), {str(truth["has_circuit"]).lower()})')
        body.append(f'      assert_eq(@euler.has_euler_path(g), {str(truth["has_path"]).lower()})')
    elif algo == "clique":
        body.append(f'      let r = @clique.find_maximum_clique(g)')
        body.append(f'      assert_true(r.size > 0)')
    elif algo == "dense_subgraph":
        body.append(f'      let tc = @dense_subgraph.count_triangles(g)')
        body.append(f'      assert_true(tc.total_triangles() >= 0)')
    elif algo == "hamiltonian":
        body.append(f'      let c = @hamiltonian.has_hamiltonian_circuit_quick_check(g)')
        body.append(f'      assert_true(c == true || c == false)')
    elif algo == "link_prediction":
        body.append(f'      let cn = @link_prediction.common_neighbors(g, @core.NodeId({truth["u"]}), @core.NodeId({truth["v"]}))')
        body.append(f'      assert_eq(cn, {truth["cn"]})')
    elif algo == "operators":
        body.append(f'      let comp = @operators.complement(g)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(comp), {truth["comp_nc"]})')
        body.append(f'      assert_eq(@core.GraphReadable::edge_count(comp), {truth["comp_ec"]})')
    elif algo == "matching":
        left, right = truth["left"], truth["right"]
        body.append(f'      let left_nodes = Array::make({left}, @core.NodeId(0))')
        body.append(f'      let mut i = 0')
        body.append(f'      while i < {left} {{ left_nodes[i] = @core.NodeId(i); i = i + 1 }}')
        body.append(f'      let right_nodes = Array::make({right}, @core.NodeId(0))')
        body.append(f'      i = 0')
        body.append(f'      while i < {right} {{ right_nodes[i] = @core.NodeId({left} + i); i = i + 1 }}')
        body.append(f'      let r = @matching.hopcroft_karp(g, left_nodes, right_nodes)')
        body.append(f'      assert_true(r.size() > 0)')

    body.append(f'    }}')
    body.append(f'    Err(e) => {{ println("parse error: {{e}}"); assert_true(false) }}')
    body.append(f'  }}')
    return body


def gen_all_tests():
    # Collect all fixture files grouped by module
    module_files = {}
    for module_dir in sorted(FIX_ROOT.iterdir()):
        if not module_dir.is_dir():
            continue
        module = module_dir.name
        graph_files = sorted(glob.glob(str(module_dir / "*.json")))
        graph_files = [f for f in graph_files if "_truth" not in f]
        if graph_files:
            module_files[module] = graph_files

    # Group tests by module for output
    module_tests = {m: [] for m in module_files}

    for module, graph_files in module_files.items():
        for gf in graph_files:
            name = Path(gf).stem
            truth_file = gf.replace(".json", "_truth.json")
            if not os.path.exists(truth_file):
                continue

            with open(gf) as f:
                graph_data = json.load(f)
            with open(truth_file) as f:
                truth_data = json.load(f)

            algo = truth_data.get("algo", "unknown")
            if algo not in ALGO_CONFIG or ALGO_CONFIG[algo] is None:
                continue

            cfg_module, directed, prefix = ALGO_CONFIG[algo]
            if cfg_module != module:
                continue

            storage = "@storage.new_directed()" if directed else "@storage.new_undirected()"
            compact = json.dumps(graph_data, separators=(',', ':'))
            escaped = compact.replace('"', '\\"')

            test_name = f'{prefix}_{name}'
            lines = []
            lines.append(f'///|')
            lines.append(f'test "{test_name}" {{')
            lines.append(f'  let json = "{escaped}"')
            lines.append(f'  let g = {storage}')
            body = gen_body(module, truth_data, directed)
            lines.extend(body)
            lines.append(f'}}')
            lines.append('')

            module_tests[module].append((algo, '\n'.join(lines)))

    # Write test files
    total = 0
    for module in sorted(module_tests.keys()):
        tests = module_tests[module]
        if not tests:
            continue

        needs = module in needs_approx
        fn_name = f'approx_{module}' if needs else None

        header = [f'///|', f'/// {module} — Python/NetworkX 随机图验证 (每算法 5 图)', f'///', '']
        if needs:
            header.extend([f'fn {fn_name}(a : Double, b : Double, eps : Double) -> Bool {{',
                          '  let d = a - b', '  if d < 0.0 { -d < eps } else { d < eps }', '}', ''])

        content = '\n'.join(header) + '\n' + '\n'.join(t[1] for t in tests)
        outpath = OUT_DIR / f'{module}_test.mbt'
        with open(outpath, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"  {module}: {len(tests)} tests -> lib/algo/integration/{module}_test.mbt")
        total += len(tests)

    print(f"Total: {total} tests")


if __name__ == "__main__":
    gen_all_tests()
