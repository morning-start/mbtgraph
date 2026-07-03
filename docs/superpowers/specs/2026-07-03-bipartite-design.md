# Bipartite Check Algorithm Design Document

**Date**: 2026-07-03  
**Status**: Approved (Brainstormed with user)  

## 1. Requirement & Goals
To check if a graph is a bipartite graph (i.e., its vertices can be divided into two independent sets $U$ and $V$ such that every edge connects a vertex in $U$ to one in $V$).
If it is bipartite, return the node coloring array where each node is colored either `0` or `1`. Unused or non-existent node IDs are colored `-1`.
If it is not bipartite (contains odd cycles), return `None`.

## 2. API Design
Located in [lib/algo/connectivity/bipartite.mbt](file:///E:/Workplace/APP/MoonBit/mbtgraph/lib/algo/connectivity/bipartite.mbt).

```moonbit
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
) -> Option[Array[Int]]
```

## 3. Detailed Logic (BFS Coloring)
1. Determine `max_node_id` of the graph to allocate the `colors` array of size `max_node_id + 1`.
2. Initialize all elements in `colors` to `-1`.
3. Loop through all nodes in the graph. If a node is not yet colored (`colors[id] == -1`):
   - Color it `0`.
   - Initialize a BFS queue `queue : Array[@core.NodeId] = []` and push the node.
   - Run BFS: while `head < queue.length()`, pop `cur`.
   - For each neighbor `neighbor` of `cur`:
     - If `colors[neighbor.0] == -1`: color it `1 - colors[cur.0]` and push it to `queue`.
     - If `colors[neighbor.0] == colors[cur.0]`: odd cycle detected, immediately return `None`.
4. If the traversal finishes successfully, return `Some(colors)`.

## 4. Test Strategy
Test cases will be implemented in `lib/algo/connectivity/bipartite_test.mbt` covering:
- **Empty graph**: Should return `Some([])`.
- **Single Node / Isolated Nodes**: Should return valid colorings.
- **Tree**: Any tree is bipartite. Check if it colors correctly.
- **Even Cycle (e.g., C4)**: Should return `Some` with alternating colors.
- **Odd Cycle (e.g., C3, C5)**: Should return `None`.
- **Multiple Components**: If one component contains an odd cycle, the whole check should return `None`. If all components are bipartite, return `Some` coloring.
