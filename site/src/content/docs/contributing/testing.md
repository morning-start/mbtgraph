---
title: 测试规范
description: mbtgraph 的双轨测试策略、命名规范、运行命令和 CI/CD 集成
---

# 测试规范

> ⏱️ **预计阅读时间**: 8 分钟

## 双轨测试体系

mbtgraph 采用**双轨制测试**，覆盖从公开 API 到内部逻辑的所有层面：

### Blackbox 测试（功能测试）

- **文件命名**: `*_test.mbt`
- **目的**: 验证公开 API 的正确性和输入输出行为
- **关注点**: 算法返回结果符合预期、类型正确、错误处理合理
- **示例**: `dijkstra_test.mbt`, `flow_test.mbt`

```moonbit
// blackbox 测试示例：仅通过公开 API 测试
test "dijkstra works on basic graph" {
  let g = build_sample_weighted_graph()
  let result = @shortest_path.dijkstra(g, @core.NodeId(0))
  inspect(result.distance_to(@core.NodeId(5)), content="11.0")
}
```

### Whitebox 测试（内部逻辑验证）

- **文件命名**: `*_wbtest.mbt`
- **目的**: 验证内部实现细节和边界情况
- **关注点**: 辅助函数正确性、极端输入、不变性约束
- **示例**: `traversal_wbtest.mbt`, `helpers_wbtest.mbt`

```moonbit
// whitebox 测试示例：验证内部辅助函数
test "find_max_node_id works with non-contiguous ids" {
  let g = build_sparse_graph()
  let max_id = find_max_node_id(g)  // 内部函数
  inspect(max_id, content="100")
}
```

## 文件结构

每个算法模块的测试文件位于模块同目录下：

```
lib/algo/shortest_path/
├── dijkstra.mbt              # 核心实现
├── dijkstra_test.mbt         # 公开 API 功能测试 (blackbox)
├── dijkstra_wbtest.mbt       # 内部逻辑测试 (whitebox)
├── types.mbt                 # 结果类型
└── moon.pkg                  # 包配置
```

跨模块集成测试位于 `lib/algo/integration/`：

```
lib/algo/integration/
├── traversal_test.mbt        # BFS + DFS 集成
├── shortest_path_test.mbt    # Dijkstra + Bellman-Ford 集成
├── flow_test.mbt             # 流网络集成
└── ...
```

## 测试分类比例

| 类别 | 占比 | 说明 |
|------|:----:|------|
| 🟢 **基础功能测试** | ~30% | 类型创建、方法正确性、基本 I/O |
| 🔵 **算法正确性测试** | ~40% | 经典案例、已知答案验证 |
| 🟡 **边界情况测试** | ~20% | 空图、越界、无效输入、负权边 |
| 🟣 **属性验证测试** | ~10% | 不可变性、一致性约束、纯函数语义 |

## 断言方式

| 方式 | 函数 | 适用场景 |
|------|------|---------|
| **布尔断言** | `assert_eq(a, b)` | 简单值比较 |
| **快照测试** | `inspect(value, content="...")` | 复杂结构输出 |
| **错误测试** | `test "..." {}` + `inspect` 错误结果 | 异常处理验证 |

## 运行测试

```bash
# 全量测试（所有包）
moon test

# 单模块测试
moon test lib/algo/pagerank

# 跨模块测试
moon test lib/algo/integration

# 更新快照
moon test --update

# 覆盖率分析
moon coverage analyze
moon coverage report              # 生成 HTML 报告
```

## 测试数据生成

复杂算法在测试文件中使用辅助构建函数生成测试数据：

```moonbit
// 构建一个标准的示例图用于多个测试
fn build_sample_weighted_graph() -> DirectedAdjList {
  let mut g = DirectedAdjList::new_with_capacity(6, 10)
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 6]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[2], 2.0)
  // ...
  g
}
```

## CI/CD 集成

GitHub Actions（`.github/workflows/`）自动执行：

```yaml
# 每次 push 自动运行：
# 1. moon fmt 格式检查
# 2. moon check 类型检查
# 3. moon test 全量测试
# 4. 覆盖率报告生成
```

当前测试规模：**940+ 测试用例**，覆盖全部 49+ 算法和 8 种存储结构。

---

**相关文档：**
- [开发环境搭建](/contributing/setup)
- [编码规范](/contributing/coding-standards)
- [测试策略设计文档](/reference/example/)

> 💡 **提示**: 添加新算法时，遵循"类型→算法→测试→文档"的提交顺序，测试在实现之后、文档之前。
