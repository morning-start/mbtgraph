///|
/// Union-Find（并查集）数据结构
///
/// 带路径压缩和按秩合并，用于 Kruskal 算法。
priv struct UnionFind {
  parent : Array[Int]
  rank : Array[Int]
}

///|
fn uf_new(size : Int) -> UnionFind {
  let p : Array[Int] = []
  let r : Array[Int] = []
  for i in 0..<size {
    p.push(i)
    r.push(0)
  }
  UnionFind::{ parent: p, rank: r }
}

///|
fn uf_find(uf : UnionFind, x : Int) -> Int {
  if uf.parent[x] != x {
    let root = uf_find(uf, uf.parent[x])
    uf.parent[x] = root
    root
  } else {
    x
  }
}

///|
fn uf_union(uf : UnionFind, x : Int, y : Int) -> Bool {
  let rx = uf_find(uf, x)
  let ry = uf_find(uf, y)
  if rx == ry {
    return false
  }
  if uf.rank[rx] < uf.rank[ry] {
    uf.parent[rx] = ry
  } else if uf.rank[rx] > uf.rank[ry] {
    uf.parent[ry] = rx
  } else {
    uf.parent[ry] = rx
    uf.rank[rx] = uf.rank[rx] + 1
  }
  true
}
