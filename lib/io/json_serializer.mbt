///|
/// 检查字符是否为数字或小数点
fn json_is_digit_or_dot(c : Int) -> Bool {
  (c >= 0x30 && c <= 0x39) || c == 0x2E || c == 0x2D
}

///|
/// 跳过 JSON 空白字符
fn json_skip_space(s : String, pos : Int) -> Int {
  let mut p = pos
  let len = s.length()
  while p < len {
    let c = s[p].to_int()
    if c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D {
      p = p + 1
    } else {
      break
    }
  }
  p
}

///|
/// 检查指定位置是否匹配关键字
fn json_match_keyword(s : String, pos : Int, keyword : String) -> Bool {
  let klen = keyword.length()
  let slen = s.length()
  if pos + klen > slen {
    return false
  }
  let mut i = 0
  while i < klen {
    if s[pos + i].to_int() != keyword[i].to_int() {
      return false
    }
    i = i + 1
  }
  true
}

///|
/// 将图序列化为 JSON 格式字符串
pub fn[G : @core.GraphReadable] graph_to_json(
  graph : G,
  pretty : Bool,
) -> String {
  let directed = @core.GraphReadable::is_directed(graph)
  let n = @core.GraphReadable::node_count(graph)
  let m = @core.GraphReadable::edge_count(graph)

  let indent : String = if pretty { "  " } else { "" }
  let newl : String = if pretty { "\n" } else { "" }
  let sp : String = if pretty { " " } else { "" }

  // Build nodes array
  let node_ids : Array[String] = Array::make(n, "")
  let mut ni = 0
  while ni < n {
    node_ids[ni] = ni.to_string()
    ni = ni + 1
  }

  let nodes_json = indent + "\"nodes\": [" + sp
  let mut nodes_str = ""
  let mut i = 0
  while i < n {
    if i > 0 {
      nodes_str = nodes_str + "," + sp
    }
    nodes_str = nodes_str + node_ids[i]
    i = i + 1
  }
  let nodes_section = nodes_json + nodes_str + "]" + newl

  // Build edges array
  let edges_json = indent + "\"edges\": [" + sp
  let mut edges_str = ""
  let mut edge_idx = 0
  let edges_iter = @core.GraphReadable::edges(graph)
  for e in edges_iter {
    if edge_idx > 0 {
      edges_str = edges_str + "," + sp
    }
    let (from, to, weight) = e
    if pretty {
      edges_str = edges_str +
        indent +
        indent +
        "{ \"source\": " +
        from.0.to_string() +
        ", \"target\": " +
        to.0.to_string() +
        ", \"weight\": " +
        weight.to_string() +
        " }"
    } else {
      edges_str = edges_str +
        "{ \"source\": " +
        from.0.to_string() +
        ", \"target\": " +
        to.0.to_string() +
        ", \"weight\": " +
        weight.to_string() +
        " }"
    }
    edge_idx = edge_idx + 1
  }

  let edges_section = edges_json + edges_str + newl + indent + "]"

  let direct_str = if directed { "true" } else { "false" }

  let result = "{" +
    newl +
    indent +
    "\"mbtgraph\": \"1.0\"," +
    newl +
    indent +
    "\"directed\": " +
    direct_str +
    "," +
    newl +
    nodes_section +
    "," +
    newl +
    edges_section +
    newl +
    "}"

  result
}

///|
/// 从 JSON 字符串解析并构建到图中
pub fn[G : @core.GraphWritable] parse_json_into(
  graph : G,
  json_string : String,
) -> Result[Unit, IOError] {
  let len = json_string.length()
  let mut pos = 0

  // Expect opening brace
  pos = json_skip_space(json_string, pos)
  if pos >= len || json_string[pos].to_int() != 0x7B {
    return Err(ParseError("Expected JSON object"))
  }
  pos = pos + 1

  let mut directed = true

  // Parse fields
  while true {
    pos = json_skip_space(json_string, pos)
    if pos >= len {
      break
    }

    // Check for closing brace
    if json_string[pos].to_int() == 0x7D {
      pos = pos + 1
      break
    }

    // Parse key
    if json_string[pos].to_int() != 0x22 {
      return Err(ParseError("Expected quoted key"))
    }
    pos = pos + 1

    let mut key = ""
    while pos < len && json_string[pos].to_int() != 0x22 {
      key = key + json_string[pos].to_int().unsafe_to_char().to_string()
      pos = pos + 1
    }
    if pos >= len {
      return Err(ParseError("Unterminated key string"))
    }
    pos = pos + 1

    // Expect colon
    pos = json_skip_space(json_string, pos)
    if pos >= len || json_string[pos].to_int() != 0x3A {
      return Err(ParseError("Expected ':' after key"))
    }
    pos = pos + 1

    pos = json_skip_space(json_string, pos)

    // Parse value based on key
    if key == "directed" {
      if json_match_keyword(json_string, pos, "true") {
        directed = true
        pos = pos + 4
      } else if json_match_keyword(json_string, pos, "false") {
        directed = false
        pos = pos + 5
      }
    } else if key == "nodes" {
      // Expect array
      if pos >= len || json_string[pos].to_int() != 0x5B {
        return Err(ParseError("Expected array for 'nodes'"))
      }
      pos = pos + 1

      while true {
        pos = json_skip_space(json_string, pos)
        if pos >= len {
          break
        }

        if json_string[pos].to_int() == 0x5D {
          pos = pos + 1
          break
        }

        // Parse node ID
        let mut nval = 0
        let mut has_digits = false
        while pos < len &&
              json_string[pos].to_int() >= 0x30 &&
              json_string[pos].to_int() <= 0x39 {
          has_digits = true
          nval = nval * 10 + (json_string[pos].to_int() - 48)
          pos = pos + 1
        }
        if !has_digits {
          return Err(ParseError("Invalid node id"))
        }

        let nid = @core.NodeId(nval)
        if !@core.GraphReadable::contains_node(graph, nid) {
          @core.GraphWritable::add_node(graph, 0.0) |> ignore
        }

        // Skip comma
        pos = json_skip_space(json_string, pos)
        if pos < len && json_string[pos].to_int() == 0x2C {
          pos = pos + 1
        }
      }
    } else if key == "edges" {
      if pos >= len || json_string[pos].to_int() != 0x5B {
        return Err(ParseError("Expected array for 'edges'"))
      }
      pos = pos + 1

      while true {
        pos = json_skip_space(json_string, pos)
        if pos >= len {
          break
        }

        if json_string[pos].to_int() == 0x5D {
          pos = pos + 1
          break
        }

        // Expect object
        if json_string[pos].to_int() != 0x7B {
          return Err(ParseError("Expected object for edge"))
        }
        pos = pos + 1

        let mut source_id = -1
        let mut target_id = -1
        let mut weight_val = 1.0

        while true {
          pos = json_skip_space(json_string, pos)
          if pos >= len {
            break
          }
          if json_string[pos].to_int() == 0x7D {
            pos = pos + 1
            break
          }

          if json_string[pos].to_int() != 0x22 {
            return Err(ParseError("Expected quoted key in edge object"))
          }
          pos = pos + 1

          let mut ekey = ""
          while pos < len && json_string[pos].to_int() != 0x22 {
            ekey = ekey + json_string[pos].to_int().unsafe_to_char().to_string()
            pos = pos + 1
          }
          pos = pos + 1

          pos = json_skip_space(json_string, pos)
          if pos >= len || json_string[pos].to_int() != 0x3A {
            pos = pos + 1
          }
          pos = pos + 1
          pos = json_skip_space(json_string, pos)

          if ekey == "source" || ekey == "target" {
            let mut v = 0
            let mut has_digits = false
            while pos < len &&
                  json_string[pos].to_int() >= 0x30 &&
                  json_string[pos].to_int() <= 0x39 {
              has_digits = true
              v = v * 10 + (json_string[pos].to_int() - 48)
              pos = pos + 1
            }
            if !has_digits {
              return Err(ParseError("Invalid edge id"))
            }
            if ekey == "source" {
              source_id = v
            } else {
              target_id = v
            }
          } else if ekey == "weight" {
            let mut w = 0.0
            let mut frac = false
            let mut div = 1.0
            let mut neg = false
            if pos < len && json_string[pos].to_int() == 0x2D {
              neg = true
              pos = pos + 1
            }
            while pos < len {
              let dc = json_string[pos].to_int()
              if dc >= 0x30 && dc <= 0x39 {
                let d = (dc - 48).to_double()
                if frac {
                  div = div * 10.0
                  w = w + d / div
                } else {
                  w = w * 10.0 + d
                }
                pos = pos + 1
              } else if dc == 0x2E {
                frac = true
                pos = pos + 1
              } else {
                break
              }
            }
            if neg {
              w = -w
            }
            weight_val = w
          } else {
            // Skip unknown field value
            while pos < len {
              let xc = json_string[pos].to_int()
              if xc == 0x2C || xc == 0x7D {
                break
              }
              pos = pos + 1
            }
          }

          // Skip comma
          pos = json_skip_space(json_string, pos)
          if pos < len && json_string[pos].to_int() == 0x2C {
            pos = pos + 1
          }
        }
        if source_id < 0 || target_id < 0 {
          return Err(ParseError("Edge missing source or target"))
        }

        if source_id >= 0 && target_id >= 0 {
          let sn = @core.NodeId(source_id)
          let tn = @core.NodeId(target_id)
          if !@core.GraphReadable::contains_node(graph, sn) {
            @core.GraphWritable::add_node(graph, 0.0) |> ignore
          }
          if !@core.GraphReadable::contains_node(graph, tn) {
            @core.GraphWritable::add_node(graph, 0.0) |> ignore
          }
          @core.GraphWritable::add_edge(graph, sn, tn, weight_val) |> ignore
        }

        pos = json_skip_space(json_string, pos)
        if pos < len && json_string[pos].to_int() == 0x2C {
          pos = pos + 1
        }
      }
    } else {
      // Skip unknown field value
      while pos < len {
        let xc = json_string[pos].to_int()
        if xc == 0x2C || xc == 0x7D {
          break
        }
        pos = pos + 1
      }
    }

    pos = json_skip_space(json_string, pos)
    if pos < len && json_string[pos].to_int() == 0x2C {
      pos = pos + 1
    }
  }

  let _ = directed

  Ok(())
}
