import os, glob, re

# For each module, find all pub fn names (algorithms)
modules = {}
for f in sorted(glob.glob('lib/algo/*/*.mbt')):
    parts = f.split(os.sep)
    mod = parts[1]
    if mod in ('integration',): continue
    basename = os.path.basename(f)
    if 'test' in basename or 'types' in basename or 'aliases' in basename:
        continue
    content = open(f, encoding='utf-8').read()
    fns = re.findall(r'pub fn.*?\s(\w+)\s*\(', content)
    # filter out methods (with self param) and type methods
    real_fns = [fn for fn in fns if fn[0].islower() and fn not in ('new', 'get_score', 'get_label', 'max_node', 'edge_count', 'size', 'count', 'total_triangles', 'node_triangles', 'local_coefficient', 'global_coefficient', 'node_pair', 'is_visited', 'reachable_count', 'path_to', 'distance', 'is_reachable', 'distance_to', 'nodes_in_community', 'largest_community_size', 'nonzero_count', 'edge_color', 'core_number', 'truss_number')]
    if real_fns:
        modules.setdefault(mod, set()).update(real_fns)

# For each integration test, count tests per prefix
test_prefixes = {}
for f in sorted(glob.glob('lib/algo/integration/*_test.mbt')):
    mod = os.path.basename(f).replace('_test.mbt', '')
    with open(f, encoding='utf-8') as fh:
        tests = [l.strip() for l in fh if l.strip().startswith('test ')]
    prefixes = {}
    for t in tests:
        idx = t.find('"')
        if idx < 0: continue
        idx2 = t.find('"', idx + 1)
        name = t[idx+1:idx2]
        parts = name.split('_')
        prefix = parts[0] if len(parts) > 1 else name
        prefixes[prefix] = prefixes.get(prefix, 0) + 1
    test_prefixes[mod] = prefixes

print("Module              | # Algorithms | # Tests | Per Algo")
print("-" * 70)
for mod in sorted(set(list(modules.keys()) + list(test_prefixes.keys()))):
    algos = sorted(modules.get(mod, []))
    tp = test_prefixes.get(mod, {})
    total_tests = sum(tp.values())
    n_algos = len(algos)
    per_algo = f"~{total_tests // n_algos}" if n_algos > 0 else "N/A"
    algo_list = ", ".join(algos[:5])
    if len(algos) > 5:
        algo_list += f" (+{len(algos)-5} more)"
    print(f"{mod:20s} | {n_algos:12d} | {total_tests:7d} | {per_algo:6s}  [{algo_list}]")
