# Project Memory

## 项目基础

- **模块**: `morning-start/mbtgraph`
- **语言**: MoonBit
- **协议**: Apache-2.0
- **架构**: MoonBit 包按目录组织，每个目录含 `moon.pkg` 声明依赖

## 图存储架构

### Trait 分层体系

采用 4 层 trait 架构，遵循 SOLID 原则（特别是 LSP 和 ISP）：

```
GraphReadable[N, E]  ← 基础只读（所有存储都实现）
    ├── GraphWritable[N, E]  ← 可写（仅动态存储实现）
    └── GraphDirected[N, E]  ← 有向图入边查询
            └── GraphFull[N, E]  ← 完整图别名（= Writable + Directed）
```

- **核心决策**: CSR 等只读存储**不实现** `GraphWritable`，避免违反里氏替换原则
- **语法**: MoonBit 支持 `pub trait B: A` 继承语法
- **算法依赖**: 算法使用 trait 约束 `bfs[G: GraphReadable](g: G)` 而非具体类型

### 包结构

```
src/
├── core/          # 基础类型 + trait 定义
├── storage/       # 存储实现（adjacency_list/ adjacency_matrix/ csr/ 等子目录）
├── algorithms/    # 图算法（遍历/最短路径/MST/连通性等）
├── generators/    # 图生成器（经典图/随机图）
└── utils/         # 工具层（序列化等）
```

### 存储实现优先级

| 阶段 | 内容 |
|------|------|
| P0 | 核心 trait 定义（GraphReadable/Writable/Directed/Full） |
| P1 | 邻接表实现（AdjacencyListGraph） |
| P2 | 基础算法（BFS/DFS/连通分量） |
| P3 | CSR 实现 + 格式转换器 |
| P4+ | 邻接矩阵/边集数组/最短路径/生成器等 |

### 向后兼容

- 保留现有 `AdjGraph` 作为类型别名：`pub type Graph = AdjacencyListGraph[Double, Double]`

## 编码规范

- **块风格**: 代码块以 `///|` 分隔，块顺序无关
- **废弃代码**: 移至 `deprecated.mbt`
- **测试**: 白盒测试 `*_wbtest.mbt`，黑盒测试 `*_test.mbt`
- **接口文件**: 修改后运行 `moon info` 更新 `.mbti`，检查 diff 确认变更可见性

## 工具链

```bash
moon info && moon fmt    # 更新接口并格式化
moon test                 # 运行测试
moon test --update        # 更新快照
moon bench                # 基准测试
moon coverage analyze     # 覆盖率分析
```
