# I/O 与序列化模块设计文档

> **模块**: `lib/io/`
> **创建日期**: 2026-06-12
> **状态**: ✅ 4 个序列化 + 6 个统计函数

---

## 1. 架构设计

### 1.1 模块划分

```
lib/io/
├── dot.mbt              — DOT 格式序列化/反序列化
├── json_serializer.mbt  — JSON 格式序列化/反序列化
├── graph_stats.mbt      — 图统计与度量工具
├── types.mbt            — IOError + 统计结果类型
├── io_test.mbt          — 集成测试 (42 tests)
└── moon.pkg
```

### 1.2 双轨序列化

```
Graph → String (write_dot / graph_to_json)
String → Result[UndirectedAdjList, IOError] (parse_dot_into / parse_json_into)
```

反序列化结果统一为 UndirectedAdjList，确保最大兼容性。

---

## 2. 设计决策记录

### DDR-01: DOT 解析器手写递归下降

| 方案 | 优势 | 劣势 |
|------|------|------|
| **手写递归下降** ⭐ | 零依赖，完全控制 | 维护成本 |
| 使用 PEG/Packrat | 语法清晰 | 外部依赖 |
| 使用正则表达式 | 简单 | 无法处理嵌套结构 |

**理由**: MoonBit 生态尚无成熟的解析器生成器，手写解析器约 200 行，可维护。

### DDR-02: JSON 格式自定义 Schema

```json
{
  "mbtgraph": "v1.0",
  "directed": true,
  "nodes": [{"id": 0, "data": 3.14}, ...],
  "edges": [{"from": 0, "to": 1, "weight": 1.0}, ...]
}
```

选择自描述格式的原因：
- 明确标记图方向性（`directed` 字段）
- 节点数据与边数据分离清晰
- 版本字段便于未来兼容

### DDR-03: GraphStats 泛型兼容

```moonbit
pub fn[G : GraphReadable] basic_stats(graph : G) -> GraphStats
pub fn[G : GraphReadable] degree_distribution(graph : G) -> DegreeDistribution
```

所有统计函数兼容 8 种存储类型（有向/无向）。

---

## 3. I/O 格式对比

| 格式 | 支持读写 | 有向图 | 权重 | 注释 | 复杂度 |
|------|:-------:|:------:|:----:|:----:|:------:|
| DOT  | ✅ R/W | ✅ | ✅ | ✅ | O(V+E) |
| JSON | ✅ R/W | ✅ | ✅ | ❌ | O(V+E) |
| GEXF | ⬜ | — | — | — | — |
| GraphML | ⬜ | — | — | — | — |

---

## 4. 统计函数

| 函数 | 返回类型 | 复杂度 |
|------|---------|:------:|
| `basic_stats` | GraphStats | O(V+E) |
| `degree_distribution` | DegreeDistribution | O(V+E) |
| `connectivity_stats` | ConnectivityStats | O(V+E) |
| `distance_metrics` | DistanceMetrics | O(V(V+E)) |
| `network_efficiency` | NetworkEfficiency | O(V(V+E)) |
| `triad_count` | TriadCount | O(V·d²) |

---

## 5. 错误处理

```moonbit
pub(all) enum IOError {
  ParseError(String)      // 解析语法错误
  UnsupportedFeature(String) // 不支持的特性
  IoError(String)         // I/O 系统错误
}
```

所有 I/O 函数返回 `Result[T, IOError]`，调用方必须显式处理错误。

---

## 6. 测试策略

- DOT 序列化→解析→再序列化的双向一致性验证
- JSON 序列化→解析→再序列化的双向一致性验证
- 错误输入解析的异常路径测试
- 跨 8 种存储类型的兼容性测试
- 空图/单节点图/完全图的统计计算验证
