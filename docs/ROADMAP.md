# mbtgraph 项目路线图

> **最后更新**: 2026-05-23 | **当前版本**: v0.5.0 | **状态**: 🎉 P0-P5 核心算法全部完成

---

## 📌 项目愿景

**成为 MoonBit 生态系统中最完整、最高质量的图算法库，覆盖从基础遍历到高级图分析的全面需求。**

### 核心定位

- **目标用户**: 算法竞赛选手、科研工作者、图数据库开发者、需要图算法的生产系统
- **差异化优势**:
  - ✅ 唯一覆盖 **6 大算法领域**的 MoonBit 图库（遍历/路径/流/匹配/图论/NP-Hard）
  - ✅ 业界领先的 **6 层 Trait 设计**（对标 petgraph 的 3 层）
  - ✅ **8 种存储结构**（比 petgraph 多 2 种）
  - ✅ **原生多后端**支持（wasm/js/native）
  - ✅ **超小体积**（wasm < 1MB）

---

## 🎯 年度目标与关键结果 (OKR)

### O1: 完成 v1.0.0 生产就绪版本（2026 Q2-Q3）

**目标**: 将 mbtgraph 从"算法原型库"升级为"生产级图计算引擎"

#### KR1.1: 扩展高级图分析算法套件 [Must]

- [ ] 实现 **PageRank** 算法（迭代/幂法，O(kE)）
- [ ] 实现 **中心性分析** 套件（度/介数/接近/特征向量中心性）
- [ ] 实现 **社区检测** 算法（Louvain/Girvan-Newman/Label Propagation）
- [ ] 新增 **~100+ 测试用例**，覆盖率 ≥ 90%
- **衡量标准**: 3 个新模块 + 100 tests + 完整文档

#### KR1.2: 完善 I/O 与序列化能力 [Should]

- [ ] 实现 **DOT 格式** 解析器/生成器（Graphviz 兼容）
- [ ] 实现 **GraphML** 格式读写（XML-based）
- [ ] 实现 **JSON** 序列化（自定义 schema）
- [ ] 支持从文件/字符串构建图对象
- **衡量标准**: 3 种格式 + 双向读写 + 40+ 测试

#### KR1.3: 达到工程化生产标准 [Must]

- [ ] 建立 **CI/CD Pipeline**（GitHub Actions: lint/test/build/release）
- [ ] 创建 **Benchmark 套件**（性能基线测试 + 回归检测）
- [ ] 实现 **API 冻结前审查**（semver 兼容性检查）
- [ ] 编写 **迁移指南**（v0.x → v1.0 breaking changes 文档）
- **衡量标准**: CI 绿色 + Benchmark 通过 + API 审计报告

---

### O2: 构建活跃的开源社区（2026 Q3-Q4）

**目标**: 从个人项目成长为有贡献者的 MoonBit 标准库候选

#### KR2.1: 提升项目可见度与易用性 [Should]

- [ ] 发布到 **mooncakes.io** 包仓库（官方推荐渠道）
- [ ] 编写 **10+ 使用示例**（教程/最佳实践/常见问题）
- [ ] 创建 **交互式 Demo**（wasm 在线运行，类似 playground）
- [ ] 翻译文档为 **英文版**（国际化准备）
- **衡量标准**: 月下载量 > 100 + Star > 50 + 文档完整度 100%

#### KR2.2: 建立质量保障体系 [Must]

- [ ] 达成 **代码覆盖率 ≥ 85%**（核心模块 ≥ 95%）
- [ ] 引入 **Fuzz Testing**（随机图生成器 + 属性验证）
- [ ] 添加 **性能回归检测**（每次 PR 自动 benchmark 对比）
- [ ] 建立 **Issue/PR 模板**（标准化贡献流程）
- **衡量标准**: 覆盖率报告 + Fuzz suite + 性能基线数据

#### KR2.3: 培养早期贡献者 [Could]

- [ ] 标记 **"Good First Issue"** 任务（降低参与门槛）
- [ ] 编写 **贡献者指南**（CONTRIBUTING.md 详细流程）
- [ ] 举办 **1 次 MoonBit 图算法分享会**（社区推广）
- **衡量标准**: ≥ 3 个外部 PR + 1 个长期贡献者

---

### O3: 探索前沿图计算方向（2026 Q4+）

**目标**: 保持技术领先性，探索 MoonBit 特有的图计算优势

#### KR3.1: 图机器学习基础 [Could]

- [ ] 调研 **GNN (图神经网络)** 在 MoonBit 的可行性
- [ ] 实现 **Node2Vec/DeepWalk** 嵌入算法
- [ ] 探索 **WebAssembly 加速**机会（SIMD/WASM GC）
- **衡量标准**: 可行性报告 + 1 个 PoC 原型

#### KR3.2: 大规模图处理能力 [Could]

- [ ] 实现 **外部存储**支持（内存映射文件/磁盘溢出）
- [ ] 开发 **分布式图计算**接口设计（预留扩展点）
- [ ] 优化 **CSR/CSC** 的批量操作性能（向量化/SIMD）
- **衡量标准**: 支持 1M+ 节点的性能基准测试

---

## 📅 里程碑时间轴

```
2026 Q2 (当前) ────────────────────────────────────── ✅ v0.5.0 已发布
│
├─ 5月23日: P5 图论核心算法完成 (483 tests)
│
│
2026 Q2-Q3 ─────────────────────────────────────────── 🔨 v0.6.0 - v0.8.0 开发中
│
├─ 📍 里程碑 M1: 高级图分析算法 (目标: 6月底)
│  ├─ PageRank + 中心性分析 (~35 tests)
│  ├─ 社区检测算法 (~40 tests)
│  └─ 版本号: v0.6.0
│
├─ 📍 里程碑 M2: I/O 序列化 (目标: 7月中旬)
│  ├─ DOT/GraphML/JSON 格式支持 (~45 tests)
│  └─ 版本号: v0.7.0
│
├─ 📍 里程碑 M3: 工程化完善 (目标: 7月底)
│  ├─ CI/CD Pipeline 上线
│  ├─ Benchmark 套件建立
│  └─ 版本号: v0.8.0
│
│
2026 Q3 ───────────────────────────────────────────── 🚀 v0.9.0 Beta → v1.0.0 RC
│
├─ 📍 里程碑 M4: API 冻结与文档完善 (目标: 8月中)
│  ├─ API 审计 + Breaking Changes 文档
│  ├─ 迁移指南 + 英文文档
│  └─ 版本号: v0.9.0 (Beta)
│
├─ 📍 里程碑 M5: v1.0.0 正式发布 (目标: 8月底)
│  ├─ semver 稳定版
│  ├─ mooncakes.io 发布
│  └─ 交互式 Demo 上线
│
│
2026 Q4 ───────────────────────────────────────────── 🌟 v1.1.0 - v1.2.0 生态扩展
│
├─ 📍 里程碑 M6: 社区建设初见成效 (目标: 10月)
│  ├─ 首个外部贡献者 PR 合并
│  ├─ Fuzz Testing + 性能回归上线
│  └─ 版本号: v1.1.0
│
├─ 📍 里程碑 M7: 前沿探索 (目标: 12月)
│  ├─ GNN 可行性报告 / Node2Vec PoC
│  ├─ 大规模图处理优化
│  └─ 版本号: v1.2.0
│
│
2027+ ─────────────────────────────────────────────── 🔮 长期愿景
│
└─ 成为 MoonBit 官方推荐图算法库
   └─ 支持工业级场景（社交网络分析/知识图谱/推荐系统）
```

---

## ⚠️ 风险评估与缓解策略

### 🔴 高风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|---------|
| **MoonBit 语言稳定性** | API breaking changes 导致大量重构 | 中 | 密切跟踪 changelog；抽象层隔离语言变更 |
| **性能瓶颈** | 复杂算法在 wasm/native 后端性能不达标 | 中 | 早期 benchmark；关键路径手写优化 |
| **维护负担** | 个人项目难以持续维护 30+ 算法 | 高 | 优先级排序（P0>P1>P2）；吸引贡献者 |

### 🟡 中风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|---------|
| **竞品出现** | 其他 MoonBit 图库分流用户 | 低 | 差异化（Trait 设计/算法广度/文档质量） |
| **测试覆盖不足** | 边界 case 导致生产 bug | 中 | Fuzz testing + 属性验证 + 集成测试 |
| **文档滞后** | 代码更新但文档过时 | 高 | 强制文档更新（CI check）；自动化生成 |

### 🟢 低风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|---------|
| **包管理变更** | mooncakes.io 迁移或规则变化 | 低 | 关注官方公告；保持兼容性 |
| **依赖冲突** | 第三方依赖版本不兼容 | 低 | 最小化依赖；锁定版本 |

---

## 📊 资源需求与优先级矩阵

### MoSCoW 优先级（v1.0.0 前）

| 类别 | 功能 | 优先级 | 理由 |
|------|------|:------:|------|
| **Must** | PageRank + 中心性 + 社区检测 | P0 | 补齐图分析核心能力，提升实用性 |
| **Must** | I/O 序列化 (DOT/JSON) | P0 | 生产环境必需，否则无法导入真实数据 |
| **Must** | CI/CD + Benchmark | P0 | 工程化基础，保证质量 |
| **Should** | GraphML 支持 | P1 | XML 格式较复杂，可后续补充 |
| **Should** | 英文文档 + 教程 | P1 | 国际化重要但非阻塞 |
| **Should** | 交互式 Demo | P1 | 提升体验但开发成本高 |
| **Could** | GNN/Node2Vec | P2 | 前沿探索，非核心功能 |
| **Could** | 分布式图计算 | P2 | 过早优化，待实际需求驱动 |
| **Won't** | GUI 可视化编辑器 | — | 超出范围，应使用现有工具（如 yEd） |

---

## 🔄 迭代计划（Sprint 视图）

### Sprint 1: 高级图分析算法（2 周）

**目标**: 完成 PageRank、中心性分析、社区检测三大模块

**交付物**:
- `src/algo/pagerank/` — PageRank 算法实现（~200 行, 15 tests）
- `src/algo/centrality/` — 4 种中心性指标（~350 行, 25 tests）
- `src/algo/community/` — Louvain + Label Propagation（~400 行, 30 tests）
- README.md + design doc 各模块
- **总测试数**: ~70 new tests

**验收标准**:
- [ ] `moon test` 全部通过（0 failure）
- [ ] `moon check` 零错误零警告
- [ ] 覆盖率 ≥ 85%（新模块）
- [ ] 文档包含使用示例 + 复杂度分析

---

### Sprint 2: I/O 序列化（1.5 周）

**目标**: 实现 DOT/GraphML/JSON 三种格式的双向转换

**交付物**:
- `src/io/dot.mbt` — DOT 解析器/生成器（~300 行, 20 tests）
- `src/io/graphml.mbt` — GraphML 读写（~250 行, 12 tests）
- `src/io/json_serializer.mbt` — JSON 序列化（~150 行, 10 tests）
- 集成测试：真实 .dot/.graphml/.json 文件
- **总测试数**: ~42 new tests

**验收标准**:
- [ ] 支持 NetworkX/petgraph 生成的标准 DOT 文件
- [ ] GraphML 与 JGraphT 互操作
- [ ] JSON schema 向后兼容
- [ ] 错误处理完善（ malformed input 友好提示）

---

### Sprint 3: 工程化基础设施（1 周）

**目标**: 建立 CI/CD 和 Benchmark 体系

**交付物**:
- `.github/workflows/ci.yml` — 自动化流水线（lint/test/build）
- `.github/workflows/benchmark.yml` — 性能回归检测
- `benchmarks/` — 基准测试脚本（各算法性能数据）
- `scripts/api_compat_check.sh` — semver 兼容性检查
- **文档**: CONTRIBUTING.md + CI 说明

**验收标准**:
- [ ] PR 自动触发 CI（通过才能 merge）
- [ ] Benchmark 数据可视化（趋势图）
- [ ] API breaking change 自动检测
- [ ] 文档覆盖率 100%

---

### Sprint 4: 文档与发布准备（1 周）

**目标**: 完善文档体系，准备 v1.0.0 发布

**交付物**:
- 英文版 README.md
- Migration Guide (v0.x → v1.0)
- API Reference（自动生成或手动整理）
- 10+ Tutorial 示例（Jupyter notebook 风格）
- Changelog 更新至 v1.0.0
- Git Tag: v1.0.0

**验收标准**:
- [ ] 所有公开 API 有文档注释
- [ ] 示例代码可直接运行
- [ ] Breaking changes 完整列出
- [ ] 发布说明（Release Notes）撰写完毕

---

## 📈 成功度量指标

### 技术指标

| 指标 | 当前值 (v0.5.0) | 目标值 (v1.0.0) | 衡量方式 |
|------|:---------------:|:---------------:|---------|
| **测试总数** | ~551 | **≥ 700** | `moon test --count` |
| **代码覆盖率** | ~80% | **≥ 85%** | `moon coverage analyze` |
| **算法数量** | 30+ | **40+** | 统计 pub fn 数量 |
| **文档完整度** | 90% | **100%** | 人工审计 + CI check |
| **构建时间** | < 30s | **< 60s**（含 benchmark）| CI 日志 |
| **wasm 体积** | ~900KB | **< 1MB** | `moon build --target wasm` |

### 社区指标

| 指标 | 当前值 | 目标值 (v1.0.0 后 3 个月) | 衡量方式 |
|------|:-----:|:------------------------:|---------|
| **GitHub Stars** | - | **≥ 50** | GitHub API |
| **月下载量** | - | **≥ 100** | mooncakes.io 统计 |
| **Contributors** | 1 | **≥ 3** | GitHub 贡献者列表 |
| **Open Issues** | 0 | **≤ 10**（及时关闭）| Issue tracker |
| **PR 合并率** | - | **≥ 80%** | GitHub 统计 |

---

## 🎯 下一步行动（立即执行）

### 本周任务（Week of 5.23 - 5.30）

1. **[P0]** 创建 `src/algo/pagerank/` 目录结构 + types.mbt
2. **[P0]** 开始 PageRank 幂法实现（迭代公式 + 收敛判断）
3. **[P1]** 调研 DOT format 规范（参考 NetworkX 实现）
4. **[P1]** 设计 JSON serialization schema（字段映射表）

### 关键决策点

- [ ] **I/O 模块位置**: 放在 `src/io/` 还是 `src/utils/io/`？
- [ ] **PageRank 实现**: 是否支持 personalized/damping factor 配置？
- [ ] **Benchmark 工具**: 使用 Criterion.rs 风格还是简单计时？

---

## 📚 相关文档

- **详细设计文档**: [docs/design/](docs/design/) （每个算法的设计决策）
- **竞品调研**: [docs/reference/](docs/reference/) （NetworkX/petgraph/JGraphT 分析）
- **架构总览**: [docs/architecture.md](docs/architecture.md)
- **编码规范**: [AGENTS.md](../AGENTS.md) （Top 10 陷阱 + 错误速查）
- **更新日志**: [CHANGELOG.md](../CHANGELOG.md) （版本历史）
- **记忆系统**: [MEMORY.md](../MEMORY.md) （关键决策记录）

---

## 🙏 致谢与参考

本路线图参考了以下项目的成熟实践：

- **[NetworkX](https://networkx.org/)** (Python) — 算法分类与优先级
- **[petgraph](https://github.com/petgraph/petgraph)** (Rust) — Trait 设计理念
- **[JGraphT](https://jgrapht.org/)** (Java) — 模块化架构
- **[LEMON](https://lemon.cs.elte.hu/)** (C++) — 性能优化思路

---

## 📝 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| **v1.0.0-draft** | 2026-05-23 | 🎉 初始版本：基于 v0.5.0 现状重新规划，聚焦 v1.0.0 生产就绪目标 |

---

<div align="center">

**🎯 让我们一起打造 MoonBit 最强的图算法库！**

*最后更新: 2026-05-23 | 维护者: @morning-start | 下次评审: 2026-06-23*

</div>
