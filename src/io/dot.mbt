///|
/// DOT 格式 Token 类型
pub(all) enum DotToken {
  Ident(String)
  Number(Int)
  Arrow
  EdgeOp
  LBrace
  RBrace
  LBracket
  RBracket
  Equals
  Semicolon
  Eof
}

///|
fn is_space_code(code : Int) -> Bool {
  code == 0x20 || code == 0x09 || code == 0x0A || code == 0x0D
}

///|
fn is_digit_code(code : Int) -> Bool {
  code >= 0x30 && code <= 0x39
}

///|
fn is_ident_start(code : Int) -> Bool {
  (code >= 0x41 && code <= 0x5A) ||
  (code >= 0x61 && code <= 0x7A) ||
  code == 0x5F
}

///|
fn is_ident_cont(code : Int) -> Bool {
  is_ident_start(code) || is_digit_code(code)
}

///|
/// 将图序列化为 DOT 格式字符串
pub fn[G : @core.GraphReadable] write_dot(
  graph : G,
  graph_name : String,
) -> String {
  let directed = @core.GraphReadable::is_directed(graph)
  let m = @core.GraphReadable::edge_count(graph)

  let edge_op : String = if directed { " -> " } else { " -- " }
  let graph_type : String = if directed { "digraph" } else { "graph" }

  let header = graph_type + " " + graph_name + " {"
  let lines : Array[String] = Array::make(m + 2, "")
  lines[0] = header

  let mut edge_idx = 0
  let edges_iter = @core.GraphReadable::edges(graph)
  for e in edges_iter {
    let (from, to, weight) = e
    let line = "    " +
      from.0.to_string() +
      edge_op +
      to.0.to_string() +
      " [weight=" +
      weight.to_string() +
      "];"
    lines[edge_idx + 1] = line
    edge_idx = edge_idx + 1
  }
  lines[m + 1] = "}"

  let mut result = ""
  let mut i = 0
  while i < lines.length() {
    if i > 0 {
      result = result + "\n"
    }
    result = result + lines[i]
    i = i + 1
  }
  result
}

///|
priv struct DotParserState {
  input : String
  pos : Int
  len : Int
}

///|
fn advance(s : DotParserState, n : Int) -> DotParserState {
  let new_pos = s.pos + n
  if new_pos > s.len {
    DotParserState::{ input: s.input, pos: s.len, len: s.len }
  } else {
    DotParserState::{ input: s.input, pos: new_pos, len: s.len }
  }
}

///|
fn code_at(s : DotParserState, offset : Int) -> Int {
  let idx = s.pos + offset
  if idx < 0 || idx >= s.len {
    0
  } else {
    s.input[idx].to_int()
  }
}

///|
fn skip_whitespace(s : DotParserState) -> DotParserState {
  let mut st = s
  while st.pos < st.len && is_space_code(st.input[st.pos].to_int()) {
    st = advance(st, 1)
  }
  st
}

///|
fn skip_comment(s : DotParserState) -> DotParserState {
  let mut st = s
  let c0 = code_at(st, 0)
  let c1 = code_at(st, 1)
  if (c0 == 0x2F && c1 == 0x2F) || c0 == 0x23 {
    while st.pos < st.len && st.input[st.pos].to_int() != 0x0A {
      st = advance(st, 1)
    }
  } else if c0 == 0x2F && c1 == 0x2A {
    st = advance(st, 2)
    while st.pos + 1 < st.len {
      let a = st.input[st.pos].to_int()
      let b = st.input[st.pos + 1].to_int()
      if a == 0x2A && b == 0x2F {
        break
      }
      st = advance(st, 1)
    }
    if st.pos + 1 < st.len {
      st = advance(st, 2)
    }
  }
  st
}

///|
fn skip_comments_and_space(s : DotParserState) -> DotParserState {
  let mut st = s
  while true {
    st = skip_whitespace(st)
    if st.pos < st.len {
      let c = st.input[st.pos].to_int()
      if c == 0x2F || c == 0x23 {
        st = skip_comment(st)
      } else {
        break
      }
    } else {
      break
    }
  }
  st
}

///|
fn next_token_and_state(s : DotParserState) -> (DotParserState, DotToken) {
  let st = skip_comments_and_space(s)
  if st.pos >= st.len {
    return (st, Eof)
  }

  let c = st.input[st.pos].to_int()

  if c == 0x7B {
    return (advance(st, 1), LBrace)
  }
  if c == 0x7D {
    return (advance(st, 1), RBrace)
  }
  if c == 0x5B {
    return (advance(st, 1), LBracket)
  }
  if c == 0x5D {
    return (advance(st, 1), RBracket)
  }
  if c == 0x3D {
    return (advance(st, 1), Equals)
  }
  if c == 0x3B {
    return (advance(st, 1), Semicolon)
  }

  if c == 0x2D && code_at(st, 1) == 0x3E {
    return (advance(st, 2), Arrow)
  }
  if c == 0x2D && code_at(st, 1) == 0x2D {
    return (advance(st, 2), EdgeOp)
  }

  if is_digit_code(c) {
    let mut val = 0
    let mut st2 = st
    while st2.pos < st2.len && is_digit_code(st2.input[st2.pos].to_int()) {
      val = val * 10 + (st2.input[st2.pos].to_int() - 48)
      st2 = advance(st2, 1)
    }
    return (st2, Number(val))
  }

  if is_ident_start(c) {
    let mut buf = ""
    let mut st2 = st
    while st2.pos < st2.len && is_ident_cont(st2.input[st2.pos].to_int()) {
      buf = buf + st2.input[st2.pos].to_int().unsafe_to_char().to_string()
      st2 = advance(st2, 1)
    }
    return (st2, Ident(buf))
  }

  if c == 0x22 {
    let mut buf = ""
    let mut st2 = advance(st, 1)
    while st2.pos < st2.len {
      let qc = st2.input[st2.pos].to_int()
      if qc == 0x22 {
        break
      }
      buf = buf + qc.to_string()
      st2 = advance(st2, 1)
    }
    if st2.pos < st2.len {
      st2 = advance(st2, 1)
    }
    return (st2, Ident(buf))
  }

  (advance(st, 1), Ident(""))
}

///|
/// 解析 DOT 格式字符串并构建到图中
pub fn[G : @core.GraphWritable] parse_dot_into(
  graph : G,
  dot_string : String,
) -> Result[Unit, IOError] {
  let len = dot_string.length()
  let state = DotParserState::{ input: dot_string, pos: 0, len }

  let (st1, tok1) = next_token_and_state(state)
  let (st2, _graph_type) = match tok1 {
    Ident(s) =>
      if s == "digraph" || s == "graph" {
        (st1, s)
      } else {
        return Err(ParseError("Expected 'digraph' or 'graph', got '" + s + "'"))
      }
    _ => return Err(ParseError("Expected graph type keyword"))
  }

  let (st_next, tok2) = next_token_and_state(st2)
  let (st3, _graph_name) = match tok2 {
    Ident(s) => (st_next, s)
    _ => (st2, "")
  }

  let (st4, tok_brace) = match tok2 {
    Ident(_) => next_token_and_state(st3)
    _ => (st2, tok2)
  }
  let st_head = match tok_brace {
    LBrace => st4
    _ => return Err(ParseError("Expected '{' after graph name"))
  }

  let mut current_state = st_head
  while true {
    let (st_next, tok) = next_token_and_state(current_state)
    let matched = match tok {
      RBrace => true
      Eof => true
      _ => false
    }
    if matched {
      break
    }

    let (st_after_id, source_id) = match tok {
      Number(n) => (st_next, n)
      Ident(_) => (st_next, 0)
      _ => {
        current_state = st_next
        continue
      }
    }

    let (st_after_lookahead, lookahead_tok) = next_token_and_state(st_after_id)

    let is_edge = match lookahead_tok {
      Arrow => true
      EdgeOp => true
      _ => false
    }

    if is_edge {
      let sn = @core.NodeId(source_id)
      if !@core.GraphReadable::contains_node(graph, sn) {
        @core.GraphWritable::add_node(graph, 0.0) |> ignore
      }

      let (st_after_tgt, target_tok) = next_token_and_state(st_after_lookahead)
      let target_id = match target_tok {
        Number(n) => n
        _ => return Err(ParseError("Expected node ID after edge operator"))
      }
      let tn = @core.NodeId(target_id)
      if !@core.GraphReadable::contains_node(graph, tn) {
        @core.GraphWritable::add_node(graph, 0.0) |> ignore
      }

      let (st_after_attr, weight_val) = parse_edge_attributes(st_after_tgt)
      @core.GraphWritable::add_edge(
        graph,
        @core.NodeId(source_id),
        @core.NodeId(target_id),
        weight_val,
      )
      |> ignore
      current_state = st_after_attr
    } else {
      let nid = @core.NodeId(source_id)
      if !@core.GraphReadable::contains_node(graph, nid) {
        @core.GraphWritable::add_node(graph, 0.0) |> ignore
      }
      current_state = st_after_lookahead
    }
  }

  Ok(())
}

///|
fn parse_edge_attributes(st : DotParserState) -> (DotParserState, Double) {
  let (st1, tok) = next_token_and_state(st)
  match tok {
    LBracket => {
      let (st2, key_tok) = next_token_and_state(st1)
      match key_tok {
        Ident(key) => {
          let (st3, _) = next_token_and_state(st2)
          let (st4, val_tok) = next_token_and_state(st3)
          let (st5, weight) = match (key, val_tok) {
            ("weight", Number(n)) => {
              let (st5, _) = next_token_and_state(st4)
              (st5, n.to_double())
            }
            _ => {
              let (st5, _) = next_token_and_state(st4)
              (st5, 1.0)
            }
          }
          let (st6, _) = next_token_and_state(st5)
          (st6, weight)
        }
        _ => (st2, 1.0)
      }
    }
    Semicolon => (st1, 1.0)
    _ => (st, 1.0)
  }
}
