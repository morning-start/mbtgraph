# Bipartite Check Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Bipartite Check (is_bipartite) algorithm using BFS coloring for the MoonBit graph library, enabling verification of bipartite graphs.

**Architecture:** Use BFS to color vertices with `0` and `1` starting from any unvisited node (supporting multi-component graphs). If a neighbor has the same color as the current node, an odd cycle is detected and the graph is not bipartite.

**Tech Stack:** MoonBit, MoonBit build system (`moon check`, `moon test`).

## Global Constraints

- Use fully-qualified name `@core.NodeId`
- Explicit parameter pattern `(self)` rather than `mut self`
- Declare mutability only as needed
- Avoid keywords `fn` and `var` (use `let mut` instead of `var`)
- Match multiple statements must be wrapped in `{}` instead of commas
- No nested generics with `>>` (use `]]` instead)

---

### Task 1: Implement Bipartite Check

**Files:**
- Create: `lib/algo/connectivity/bipartite.mbt`
- Modify: `lib/algo/integration/connectivity_test.mbt`

**Interfaces:**
- Consumes: `@core.GraphReadable`, `@core.NodeId`
- Produces: `is_bipartite[G : @core.GraphReadable](graph : G) -> Option[Array[Int]]`

- [ ] **Step 1: Write the failing tests**

Append the following test code to `lib/algo/integration/connectivity_test.mbt`:

```moonbit
///|
test "is_bipartite_bipartite_c4" {
  // Even Cycle (Bipartite)
  let g = @storage.new_undirected()
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n3, n0, 1.0) |> ignore

  match @conn.is_bipartite(g) {
    Some(colors) => {
      assert_eq(colors[0], 0)
      assert_eq(colors[1], 1)
      assert_eq(colors[2], 0)
      assert_eq(colors[3], 1)
    }
    None => assert_true(false)
  }
}

///|
test "is_bipartite_not_bipartite_c3" {
  // Odd Cycle (Not Bipartite)
  let g = @storage.new_undirected()
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n0, 1.0) |> ignore

  match @conn.is_bipartite(g) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "is_bipartite_empty" {
  let g = @storage.new_undirected()
  match @conn.is_bipartite(g) {
    Some(colors) => assert_eq(colors.length(), 0)
    None => assert_true(false)
  }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run the test command in workspace:
Run: `moon test -p lib/algo/integration`
Expected output: Compilation error or test failure because `is_bipartite` is not defined in `@conn`.

- [ ] **Step 3: Write minimal implementation**

Create `lib/algo/connectivity/bipartite.mbt` with the following implementation:

```moonbit
///|
fn[G : @core.GraphReadable] find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// Checks if an undirected graph is a bipartite graph.
///
/// If it is bipartite, returns `Some(colors)`, where `colors` is an `Array[Int]`
/// of size `max_node_id + 1`. Each existing node's color is either `0` or `1`.
/// Non-existent node IDs in the array will have a color value of `-1`.
///
/// If the graph is not bipartite, returns `None`.
pub fn[G : @core.GraphReadable] is_bipartite(
  graph : G,
) -> Option[Array[Int]] {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return Some([])
  }

  let max_id = find_max_id(graph)
  let size = max_id + 1
  let colors = Array::make(size, -1)

  for start in @core.GraphReadable::node_ids(graph) {
    let start_id = start.0
    if colors[start_id] != -1 {
      continue
    }

    colors[start_id] = 0
    let queue : Array[@core.NodeId] = []
    queue.push(start)
    let mut head = 0

    while head < queue.length() {
      let cur = queue[head]
      head = head + 1
      let cur_color = colors[cur.0]

      for neighbor in @core.GraphReadable::neighbors(graph, cur) {
        let n_id = neighbor.0
        if colors[n_id] == -1 {
          colors[n_id] = 1 - cur_color
          queue.push(neighbor)
        } else if colors[n_id] == cur_color {
          return None
        }
      }
    }
  }

  Some(colors)
}
```

Format and update package interfaces:
Run: `moon fmt && moon info` (This will update `lib/algo/connectivity/pkg.generated.mbti`).

- [ ] **Step 4: Run test to verify it passes**

Run: `moon test -p lib/algo/integration`
Expected output: Tests pass with no failures.

- [ ] **Step 5: Run all package tests**

Run: `moon test`
Expected output: All 940+ tests pass.

- [ ] **Step 6: Commit**

Run:
```bash
git add lib/algo/connectivity/bipartite.mbt lib/algo/connectivity/pkg.generated.mbti lib/algo/integration/connectivity_test.mbt docs/superpowers/specs/2026-07-03-bipartite-design.md docs/superpowers/plans/2026-07-03-bipartite-check.md
git commit -m "feat(connectivity): add bipartite check algorithm using BFS coloring"
```
