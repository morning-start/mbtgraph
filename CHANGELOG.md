# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Flow network module with Edmonds-Karp max flow algorithm
- Complete test suite for all algorithm modules (179+ tests total)
- Comprehensive documentation for all modules

---

## [0.3.0] - 2026-05-19

### Major Changes - Complete Algorithm Library (P0-P3 ✅)

#### Core Module - [0.1.0]
**Status**: 🟢 Stable Foundation
**Commits**: 7 commits (1 feat, 4 refactor, 2 docs)

**Changes**:
- `feat`: Add graph data structure core module (types, traits, error handling)
- `refactor`: Optimize code structure, adjust visibility, remove redundant implementations
- `refactor`: Fix trait visibility and type definitions
- `docs`: Add comprehensive README documentation

**Key Components**:
- `NodeId`, `Node`, `Edge` types
- `GraphReadable`, `GraphWritable`, `GraphDirected` traits
- `GraphError` error type

**Stability**: Production-ready, foundational API stable

---

#### Storage Module - [0.2.0]
**Status**: 🟢 Feature-Rich & Stable
**Commits**: 13+ commits (5 feat, 3 refactor, 1 fix, 3 docs, 1 chore)

**Breaking Changes from 0.1.x**:
- Major restructure: Split monolithic storage into specialized implementations
- New storage formats: CSR/CSC for sparse graphs
- Enhanced converter system with bidirectional transformations

**Changes**:
- `feat`: Complete graph storage implementation (AdjList, Matrix, EdgeList, CSR, CSC)
- `feat`: Add undirected variants for all storage types
- `feat`: Implement GraphDirected trait and refactor conversion logic
- `feat`: Add CSC structure and conversion functions
- `refactor`: Restructure storage module, extract shared helpers
- `refactor`: Split adjacency list converters, add directed/undirected implementations
- `fix`: Fix struct visibility, Array::make 2D initialization bug, add GraphDirected impls
- `chore`: Update mbti binding files for all modules

**Key Components**:
- Directed/Undirected Adjacency List (`directed_adj_list`, `undirected_adj_list`)
- Directed/Undirected Matrix (`directed_matrix`, `undirected_matrix`)
- Edge List Graphs (`edge_list`, `undirected_edge_list`)
- Compressed Formats (`csr`, `csc`)
- Converter System (`converter`) with format transformations
- Shared Helpers (`shared_helpers`)

**Test Coverage**: Cross-storage compatibility verified

**Stability**: Mature implementation, extensive testing

---

#### Traversal Module - [0.1.1]
**Status**: 🟢 Complete & Documented
**Commits**: 8 commits (2 feat, 2 refactor, 1 test, 2 docs, 1 chore)

**Changes from 0.1.0**:
- `feat`: Add BFS and DFS graph traversal algorithms
- `feat`: Add cycle detection and topological sort utilities
- `refactor`: Fix internal helper visibility and struct fields for public API
- `refactor`: Remove unnecessary pub modifiers from utility functions
- `test`: Add complete cross-storage traversal test suite
- `docs`: Add README documentation and design document

**Key Algorithms**:
- Breadth-First Search (BFS)
- Depth-First Search (DFS)
- Cycle Detection
- Topological Sort

**Stability**: Well-tested, clean public API

---

#### Generators Module - [0.1.1]
**Status**: 🟢 Complete & Tested
**Commits**: 6 commits (1 feat, 1 fix, 1 test, 2 docs, 1 chore)

**Changes from 0.1.0**:
- `feat`: Add graph generators with generic GraphWritable support (16 functions)
- `fix`: Fix MoonBit syntax compatibility for compilation
- `test`: Add 56 tests with cross-storage compatibility verification
- `docs`: Add package README and design document

**Key Generators**:
- Classic graphs: Complete, Cycle, Path, Star, Wheel, Bipartite
- Grid graphs: 2D/3D grid, Torus, Hexagonal
- Random graphs: Erdős–Rényi, Watts-Strogatz, Barabási–Albert
- Special: Tree, DAG

**Test Coverage**: 56 tests, cross-storage compatibility verified

**Stability**: Robust, well-documented

---

#### Shortest Path Module - [0.1.0]
**Status**: 🟢 Initial Release
**Commits**: 4 commits (1 feat, 1 test, 1 docs, 1 chore)

**Changes**:
- `feat`: Add Dijkstra, Bellman-Ford, Floyd-Warshall algorithms
- `test`: Add 32 tests with cross-storage compatibility
- `docs`: Add complete README documentation

**Key Algorithms**:
- Dijkstra (non-negative weights)
- Bellman-Ford (negative edges, negative cycle detection)
- Floyd-Warshall (all-pairs shortest paths)

**Test Coverage**: 32 tests, multiple storage backends

**Stability**: Complete implementation, ready for use

---

#### MST Module - [0.1.0]
**Status**: 🟢 Initial Release
**Commits**: 3 commits (1 feat, 1 test, 1 chore)

**Changes**:
- `feat`: Add Kruskal and Prim minimum spanning tree algorithms
- `test`: Add 16 tests (shared with connectivity)

**Key Algorithms**:
- Kruskal's algorithm (with Union-Find data structure)
- Prim's algorithm (with binary heap optimization)

**Supporting Data Structures**:
- Union-Find (Disjoint Set Union) with path compression and union by rank
- Binary Min-Heap for priority queue operations

**Test Coverage**: 16 tests

**Stability**: Complete implementation

---

#### Connectivity Module - [0.1.0]
**Status**: 🟢 Initial Release
**Commits**: 5 commits (1 feat, 1 test, 2 docs, 1 chore)

**Changes**:
- `feat`: Add connected components, Tarjan SCC, Kosaraju SCC algorithms
- `test`: Add 21 tests (shared with MST)
- `docs`: Add design documentation

**Key Algorithms**:
- Connected Components (undirected graphs)
- Tarjan's Strongly Connected Components
- Kosaraju's Strongly Connected Components

**Test Coverage**: 21 tests

**Stability**: Complete implementation

---

#### Flow Module - [0.1.0]
**Status**: 🟢 Initial Release (Latest)
**Commits**: 5 commits (2 feat, 1 test, 2 docs)

**Changes**:
- `feat`: Add FlowNetwork base types and struct
- `feat`: Implement Edmonds-Karp max flow algorithm
- `test`: Add complete test suite (17 tests)
- `docs`: Add README and design document

**Key Components**:
- `FlowNetwork` type (independent from Graph trait)
- Edmonds-Karp algorithm (BFS-based Ford-Fulkerson)
- Capacity/Flow matrix management

**Design Decision**:
- Independent type system (not extending GraphReadable) for semantic clarity
- Pure functional semantics with deep copy for immutability

**Test Coverage**: 17 tests

**Stability**: Freshly implemented, well-tested

---

## Project Summary

| Module | Version | Status | Tests | Key Features |
|--------|---------|--------|-------|--------------|
| **core** | 0.1.0 | 🟢 Stable | - | Types, Traits, Errors |
| **storage** | 0.2.0 | 🟢 Mature | - | 10+ formats, Converters |
| **traversal** | 0.1.1 | 🟢 Complete | - | BFS, DFS, Cycle, TopoSort |
| **generators** | 0.1.1 | 🟢 Robust | 56 | 16 graph generators |
| **shortest_path** | 0.1.0 | 🟢 Ready | 32 | Dijkstra, BF, FW |
| **mst** | 0.1.0 | 🟢 Ready | 16 | Kruskal, Prim |
| **connectivity** | 0.1.0 | 🟢 Ready | 21 | CC, Tarjan, Kosaraju |
| **flow** | 0.1.0 | 🟢 New | 17 | Edmonds-Karp |

**Total Test Count**: 179+ tests across all algorithm modules

**Roadmap Progress**: ✅ P0 (Core+Storage) → ✅ P1 (Traversal+Generators) → ✅ P2 (Shortest Path+MST+Connectivity) → ✅ P3 (Flow)

---

## Version Guidelines

### Version Number Meaning
- **MAJOR** (x.0.0): Incompatible API changes / Complete rewrites
- **MINOR** (0.x.0): Backward-compatible new features / Significant additions
- **PATCH** (0.0.x): Backward-compatible bug fixes / Documentation updates

### Update Triggers
- **MAJOR**: Breaking changes to public API, removal of features
- **MINOR**: New algorithm modules, major feature additions, significant refactors
- **PATCH**: Bug fixes, documentation improvements, test coverage increases

### Current Version Strategy
- Core/Storage: Higher minor versions reflect maturity and extensive refactoring
- Algorithm Modules: Start at 0.1.0, patch increments for refinements
- Next major release will synchronize all modules when API stabilizes

---

[Unreleased]: https://github.com/morning-start/mbtgraph/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.3.0
