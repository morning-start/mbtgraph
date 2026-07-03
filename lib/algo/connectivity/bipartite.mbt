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
pub fn[G : @core.GraphReadable] is_bipartite(graph : G) -> Array[Int]? {
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
        if n_id < 0 || n_id >= size {
          continue
        }
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
