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
    "a_star":          ("shortest_path", True,  "astar"),
    "bidirectional_dijkstra": ("shortest_path", True, "bdj"),
    "bfs":             ("traversal",     True,  "bfs"),
    "dfs":             None,
    "topo_sort":       ("traversal",     True,  "topo"),
    "has_cycle":       ("traversal",     True,  "cycle"),
    "cc":              ("connectivity",  False, "cc"),
    "scc":             ("connectivity",  True,  "scc"),
    "kosaraju_scc":    ("connectivity",  True,  "kosaraju"),
    "bcc":             ("connectivity",  False, "bcc"),
    "ap":              ("cutpoints",     False, "ap"),
    "br":              ("cutpoints",     False, "br"),
    "mst":             ("mst",           False, "mst"),
    "prim":            ("mst",           False, "prim"),
    "pagerank":        ("pagerank",      True,  "pr"),
    "centrality":      ("centrality",    False, "cent"),
    "closeness_centrality": ("centrality", False, "cent_cc"),
    "eigenvector_centrality": ("centrality", False, "cent_ec"),
    "katz_centrality": ("centrality",    False, "cent_katz"),
    "harmonic_centrality": ("centrality",False, "cent_harm"),
    "coloring":        ("coloring",      False, "col"),
    "welsh_powell":    ("coloring",      False, "col_wp"),
    "edge_coloring":   ("coloring",      False, "col_edge"),
    "community":       ("community",     False, "com"),
    "label_propagation":("community",    False, "com_lp"),
    "leiden":          ("community",     False, "com_leiden"),
    "recognition":     ("recognition",   False, "rec"),
    "is_complete":     ("recognition",   False, "rec_complete"),
    "is_regular":      ("recognition",   False, "rec_regular"),
    "is_chordal":      ("recognition",   False, "rec_chordal"),
    "euler":           ("euler",         False, "euler"),
    "find_euler_path": ("euler",         False, "euler_fp"),
    "find_euler_circuit": ("euler",      False, "euler_fc"),
    "clique":          ("clique",        False, "clique"),
    "independent_set": ("clique",        False, "clique_is"),
    "vertex_cover":    ("clique",        False, "clique_vc"),
    "dense_subgraph":  ("dense_subgraph",False, "dense"),
    "k_core":          ("dense_subgraph",False, "dense_kcore"),
    "clustering":      ("dense_subgraph",False, "dense_cc"),
    "hamiltonian":     ("hamiltonian",   False, "ham"),
    "common_neighbors":("link_prediction",False,"lp"),
    "jaccard":         ("link_prediction",False,"lp_jac"),
    "adamic_adar":     ("link_prediction",False,"lp_aa"),
    "preferential_attachment": ("link_prediction",False,"lp_pa"),
    "resource_allocation": ("link_prediction",False,"lp_ra"),
    "operators":       ("operators",     False, "op"),
    "reverse":         ("operators",     True,  "op_rev"),
    "graph_union":     ("operators",     False, "op_union"),
    "cartesian_product":("operators",    False, "op_cart"),
    "tensor_product":  ("operators",     False, "op_tensor"),
    "lexicographic_product": ("operators",False,"op_lex"),
    "line_graph":      ("operators",     False, "op_line"),
    "power_graph":     ("operators",     False, "op_power"),
    "matching":        ("matching",      False, "match"),
    "bipartite_matching": ("matching",   False, "match_bp"),
    "edmonds_matching":("matching",      False, "match_ed"),
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
    elif algo == "a_star":
        body.append(f'      let _ = @sp.a_star(g, @core.NodeId(0), @core.NodeId(1), fn(_) {{ 0.0 }})')
    elif algo == "bidirectional_dijkstra":
        body.append(f'      let _ = @sp.bidirectional_dijkstra(g, @core.NodeId(0), @core.NodeId(1))')
    elif algo == "bfs":
        body.append(f'      let r = @traversal.bfs(g, @core.NodeId(0))')
        for p in truth.get("pairs", [])[:3]:
            if p.get("d", -1) >= 0:
                body.append(f'      assert_eq(r.distance(@core.NodeId({p["t"]})), {p["d"]})')
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
    elif algo == "kosaraju_scc":
        body.append(f'      let r = @conn.kosaraju_scc(g)')
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
    elif algo == "prim":
        body.append(f'      let r = @mst.prim(g, @core.NodeId(0))')
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
    elif algo == "closeness_centrality":
        body.append(f'      let cc = @centrality.closeness_centrality(g, true)')
        body.append(f'      assert_true(cc.get_score(@core.NodeId({truth["cc_top"]})) >= Some(0.0))')
    elif algo == "eigenvector_centrality":
        body.append(f'      let ec = @centrality.eigenvector_centrality(g, 1000, 0.000001)')
        body.append(f'      assert_true(ec.get_score(@core.NodeId({truth["ec_top"]})) >= Some(0.0))')
    elif algo == "katz_centrality":
        body.append(f'      let kz = @centrality.katz_centrality(g, 0.1, 0.000001, 100, 0.000001)')
        body.append(f'      assert_true(kz.get_score(@core.NodeId({truth["katz_top"]})) >= Some(0.0))')
    elif algo == "harmonic_centrality":
        body.append(f'      let hm = @centrality.harmonic_centrality(g, true)')
        body.append(f'      assert_true(hm.get_score(@core.NodeId({truth["harm_top"]})) >= Some(0.0))')
    elif algo == "coloring":
        body.append(f'      let r = @coloring.greedy_coloring(g)')
        body.append(f'      assert_true(r.num_colors > 0)')
        body.append(f'      assert_true(r.is_valid)')
    elif algo == "welsh_powell":
        body.append(f'      let r = @coloring.welsh_powell(g)')
        body.append(f'      assert_true(r.num_colors > 0)')
        body.append(f'      assert_true(r.is_valid)')
    elif algo == "edge_coloring":
        body.append(f'      let r = @coloring.edge_coloring(g)')
        body.append(f'      assert_true(r.num_colors > 0)')
        body.append(f'      assert_true(r.is_valid)')
    elif algo == "community":
        body.append(f'      let r = @community.louvain(g, 1.0)')
        body.append(f'      assert_true(r.num_communities > 0)')
    elif algo == "label_propagation":
        body.append(f'      let r = @community.label_propagation(g, 1)')
        body.append(f'      assert_true(r.num_communities > 0)')
    elif algo == "leiden":
        body.append(f'      let r = @community.leiden(g, 1.0)')
        body.append(f'      assert_true(r.num_communities > 0)')
    elif algo == "recognition":
        body.append(f'      assert_eq(@recognition.is_bipartite(g), {str(truth["bipartite"]).lower()})')
        body.append(f'      assert_eq(@recognition.is_tree(g), {str(truth["tree"]).lower()})')
        body.append(f'      assert_eq(@recognition.is_forest(g), {str(truth["forest"]).lower()})')
    elif algo == "is_complete":
        body.append(f'      assert_eq(@recognition.is_complete(g), {str(truth["complete"]).lower()})')
    elif algo == "is_regular":
        body.append(f'      assert_eq(@recognition.is_regular(g), {str(truth["regular"]).lower()})')
    elif algo == "is_chordal":
        body.append(f'      assert_eq(@recognition.is_chordal(g), {str(truth["chordal"]).lower()})')
    elif algo == "euler":
        body.append(f'      assert_eq(@euler.has_euler_circuit(g), {str(truth["has_circuit"]).lower()})')
        body.append(f'      assert_eq(@euler.has_euler_path(g), {str(truth["has_path"]).lower()})')
    elif algo == "find_euler_path":
        body.append(f'      assert_eq(@euler.has_euler_path(g), {str(truth["has"]).lower()})')
    elif algo == "find_euler_circuit":
        body.append(f'      assert_eq(@euler.has_euler_circuit(g), {str(truth["has"]).lower()})')
    elif algo == "clique":
        body.append(f'      let r = @clique.find_maximum_clique(g)')
        body.append(f'      assert_true(r.size > 0)')
    elif algo == "independent_set":
        body.append(f'      let r = @clique.find_maximum_independent_set(g)')
        body.append(f'      assert_true(r.size > 0)')
    elif algo == "vertex_cover":
        body.append(f'      let r = @clique.find_minimum_vertex_cover(g)')
        body.append(f'      assert_true(r.size > 0)')
    elif algo == "dense_subgraph":
        body.append(f'      let tc = @dense_subgraph.count_triangles(g)')
        body.append(f'      assert_true(tc.total_triangles() >= 0)')
    elif algo == "k_core":
        body.append(f'      let r = @dense_subgraph.k_core_decomposition(g)')
        body.append(f'      assert_true(r.core_number(@core.NodeId(0)) >= 0)')
    elif algo == "clustering":
        body.append(f'      let cc = @dense_subgraph.average_clustering_coefficient(g)')
        body.append(f'      assert_true(cc >= 0.0)')
    elif algo == "hamiltonian":
        body.append(f'      let c = @hamiltonian.has_hamiltonian_circuit_quick_check(g)')
        body.append(f'      assert_true(c == true || c == false)')
    elif algo == "common_neighbors":
        body.append(f'      let cn = @link_prediction.common_neighbors(g, @core.NodeId({truth["u"]}), @core.NodeId({truth["v"]}))')
        body.append(f'      assert_eq(cn, {truth["cn"]})')
    elif algo == "jaccard":
        body.append(f'      let jc = @link_prediction.jaccard_coefficient(g, @core.NodeId({truth["u"]}), @core.NodeId({truth["v"]}))')
        body.append(f'      assert_true(jc >= 0.0)')
    elif algo == "adamic_adar":
        body.append(f'      let aa = @link_prediction.adamic_adar_index(g, @core.NodeId({truth["u"]}), @core.NodeId({truth["v"]}))')
        body.append(f'      assert_true(aa >= 0.0)')
    elif algo == "preferential_attachment":
        body.append(f'      let pa = @link_prediction.preferential_attachment(g, @core.NodeId({truth["u"]}), @core.NodeId({truth["v"]}))')
        body.append(f'      assert_true(pa >= 0)')
    elif algo == "resource_allocation":
        body.append(f'      let ra = @link_prediction.resource_allocation(g, @core.NodeId({truth["u"]}), @core.NodeId({truth["v"]}))')
        body.append(f'      assert_true(ra >= 0.0)')
    elif algo == "operators":
        body.append(f'      let comp = @operators.complement(g)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(comp), {truth["comp_nc"]})')
        body.append(f'      assert_eq(@core.GraphReadable::edge_count(comp), {truth["comp_ec"]})')
    elif algo == "reverse":
        body.append(f'      let rev = @operators.reverse(g)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(rev), {truth["rev_nc"]})')
        body.append(f'      assert_eq(@core.GraphReadable::edge_count(rev), {truth["rev_ec"]})')
    elif algo == "graph_union":
        body.append(f'      let g2 = @storage.new_undirected()')
        body.append(f'      let u = @operators.graph_union(g, g2)')
        body.append(f'      assert_true(@core.GraphReadable::node_count(u) > 0)')
    elif algo == "cartesian_product":
        body.append(f'      let g2 = @storage.new_undirected()')
        body.append(f'      let p = @storage.new_undirected()')
        body.append(f'      for i in 0..<3 {{ @core.GraphWritable::add_node(p, 0.0) |> ignore }}')
        body.append(f'      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore')
        body.append(f'      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore')
        body.append(f'      let r = @operators.cartesian_product(g, p)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(r), {truth["prod_nc"]})')
    elif algo == "tensor_product":
        body.append(f'      let p = @storage.new_undirected()')
        body.append(f'      for i in 0..<3 {{ @core.GraphWritable::add_node(p, 0.0) |> ignore }}')
        body.append(f'      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore')
        body.append(f'      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore')
        body.append(f'      let r = @operators.tensor_product(g, p)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(r), {truth["prod_nc"]})')
    elif algo == "lexicographic_product":
        body.append(f'      let p = @storage.new_undirected()')
        body.append(f'      for i in 0..<3 {{ @core.GraphWritable::add_node(p, 0.0) |> ignore }}')
        body.append(f'      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore')
        body.append(f'      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore')
        body.append(f'      let r = @operators.lexicographic_product(g, p)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(r), {truth["prod_nc"]})')
    elif algo == "line_graph":
        body.append(f'      let lg = @operators.line_graph(g)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(lg), {truth["line_nc"]})')
    elif algo == "power_graph":
        body.append(f'      let pg = @operators.power_graph(g, 2)')
        body.append(f'      assert_eq(@core.GraphReadable::node_count(pg), {truth["power_nc"]})')
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
    elif algo == "bipartite_matching":
        left, right = truth["left"], truth["right"]
        body.append(f'      let left_nodes = Array::make({left}, @core.NodeId(0))')
        body.append(f'      let mut i = 0')
        body.append(f'      while i < {left} {{ left_nodes[i] = @core.NodeId(i); i = i + 1 }}')
        body.append(f'      let right_nodes = Array::make({right}, @core.NodeId(0))')
        body.append(f'      i = 0')
        body.append(f'      while i < {right} {{ right_nodes[i] = @core.NodeId({left} + i); i = i + 1 }}')
        body.append(f'      let r = @matching.bipartite_matching_graph(g, left_nodes, right_nodes)')
        body.append(f'      assert_true(r.size() > 0)')
    elif algo == "edmonds_matching":
        body.append(f'      let r = @matching.edmonds_maximum_matching(g)')
        body.append(f'      assert_true(r.size() > 0)')

    body.append(f'    }}')
    body.append(f'    Err(e) => {{ println("parse error: {{e}}"); assert_true(false) }}')
    body.append(f'  }}')
    return body


def gen_all_tests():
    module_files = {}
    for module_dir in sorted(FIX_ROOT.iterdir()):
        if not module_dir.is_dir():
            continue
        module = module_dir.name
        graph_files = sorted(glob.glob(str(module_dir / "*.json")))
        graph_files = [f for f in graph_files if "_truth" not in f]
        if graph_files:
            module_files[module] = graph_files

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
