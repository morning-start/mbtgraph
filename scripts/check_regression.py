#!/usr/bin/env python3
"""
mbtgraph 性能回归检测脚本

用法:
  python check_regression.py                    # 运行基准测试并对比基线
  python check_regression.py --threshold 15     # 设置回归阈值 (默认 10%)
  python check_regression.py --skip-run         # 仅对比已有输出文件

流程:
  1. 运行 moon test benchmarks 和 benchmarks_large
  2. 解析 JSON 输出，计算每操作耗时 (μs)
  3. 与 baselines 目录下的 CSV 基线对比
  4. 报告回归 (超过阈值) 和提升 (改进超过阈值)
"""

import json
import os
import re
import subprocess
import sys
import csv
from pathlib import Path
from typing import Any

# ── 配置 ──
PROJECT_ROOT = Path(__file__).resolve().parent.parent
BENCHMARKS_DIR = PROJECT_ROOT / "benchmarks"
BENCHMARKS_LARGE_DIR = PROJECT_ROOT / "benchmarks_large"
BASELINE_CSV = BENCHMARKS_DIR / "baseline_v0.1.3.csv"
BASELINE_LARGE_CSV = BENCHMARKS_LARGE_DIR / "baseline_v0.1.3.csv"
REGRESSION_THRESHOLD_PCT = 10.0  # 超过此百分比视为回归

# 小规模基准: 100 节点, k=5 → 500 边; 1000 节点, k=10 → 10000 边
# 大规模基准: 5000/10000 节点, k=1 → 节点数 = 边数
NAMES_TO_EDGES = {
    "(n=100)": 500,
    "(n=1000)": 10000,
    "(n=5000)": 5000,
    "(n=10000)": 10000,
}


def parse_benchmark_name(name: str) -> tuple[str, int, int] | None:
    """
    从基准测试名称解析算法名、节点数、边数。
    例如: "dijkstra(n=100)" → ("dijkstra", 100, 500)
    """
    m = re.match(r'^(.+)\(n=(\d+)\)$', name)
    if not m:
        return None
    algo = m.group(1).strip()
    nodes = int(m.group(2))
    suffix = f"(n={nodes})"
    edges = NAMES_TO_EDGES.get(suffix)
    if edges is None:
        return None
    return (algo, nodes, edges)


def load_baseline(path: Path) -> dict[tuple[str, int, int], dict[str, Any]]:
    """加载基线 CSV，返回 {(algo, nodes, edges): row} 映射"""
    baseline: dict[tuple[str, int, int], dict[str, Any]] = {}
    if not path.exists():
        print(f"⚠️  基线文件不存在: {path}")
        return baseline
    with open(path, encoding="utf-8") as f:
        lines = [line for line in f if not line.startswith("#")]
        reader = csv.DictReader(lines, skipinitialspace=True)
        for row in reader:
            algo = row["algorithm"].strip()
            nodes = int(row["nodes"])
            edges = int(row["edges"])
            key = (algo, nodes, edges)
            baseline[key] = {
                "mean_us": float(row["mean_us"]),
                "median_us": float(row["median_us"]),
                "std_dev_pct": float(row["std_dev_pct"]),
                "runs": int(row["runs"]),
            }
    return baseline


def run_benchmarks(pkg_dir: Path) -> list[dict[str, Any]]:
    """运行 moon test 并解析 JSON 输出"""
    print(f"  🏃 运行基准测试: {pkg_dir.name} ...", end=" ", flush=True)
    result = subprocess.run(
        ["moon", "test", str(pkg_dir)],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
        timeout=600,
    )
    if result.returncode != 0:
        print(f"❌ 失败 (exit={result.returncode})")
        print(result.stderr[:500])
        return []

    # 输出可能包含多行 JSON 数组，或者测试失败信息
    # 每行是一个 JSON 数组
    all_results: list[dict[str, Any]] = []
    for line in result.stdout.strip().splitlines():
        line = line.strip()
        if line.startswith("["):
            try:
                data = json.loads(line)
                all_results.extend(data)
            except json.JSONDecodeError:
                continue

    print(f"✅ {len(all_results)} 项测量")
    return all_results


def compute_us_per_op(result: dict[str, Any]) -> float | None:
    """
    从基准测试结果获取每操作耗时 (微秒)。
    mean 字段已经是每操作微秒数，batch_size 仅为测量次数参考。
    """
    mean = result.get("mean")
    if mean is None:
        return None
    return mean


def main():
    global REGRESSION_THRESHOLD_PCT

    # 解析命令行参数
    skip_run = False
    args = sys.argv[1:]
    for i, arg in enumerate(args):
        if arg == "--skip-run":
            skip_run = True
        elif arg == "--threshold" and i + 1 < len(args):
            REGRESSION_THRESHOLD_PCT = float(args[i + 1])
    threshold = REGRESSION_THRESHOLD_PCT

    print("=" * 60)
    print(f"  mbtgraph 性能回归检测 (阈值: {threshold}%)")
    print("=" * 60)

    # 1. 加载基线
    baselines = {}
    baselines["small"] = load_baseline(BASELINE_CSV)
    baselines["large"] = load_baseline(BASELINE_LARGE_CSV)
    total_baseline = len(baselines["small"]) + len(baselines["large"])
    print(f"\n📊 基线数据: {total_baseline} 项 (small={len(baselines['small'])}, large={len(baselines['large'])})")

    # 2. 运行基准测试
    if not skip_run:
        print("\n🔬 运行基准测试...")
        small_results = run_benchmarks(BENCHMARKS_DIR)
        large_results = run_benchmarks(BENCHMARKS_LARGE_DIR)
    else:
        print("\n⏭️  跳过运行 (--skip-run)")
        small_results = []
        large_results = []

    if not small_results and not large_results:
        print("❌ 没有基准测试结果")
        sys.exit(1)

    # 3. 对比分析
    print("\n📈 性能对比...")
    regressions: list[str] = []
    improvements: list[str] = []
    unmatched: list[str] = []
    compared_count = 0

    for results, scale in [(small_results, "small"), (large_results, "large")]:
        baseline = baselines[scale]
        for res in results:
            name = res.get("name", "")
            parsed = parse_benchmark_name(name)
            if not parsed:
                unmatched.append(f"  ⚠️  无法解析名称: {name}")
                continue

            algo, nodes, edges = parsed
            key = (algo, nodes, edges)
            base = baseline.get(key)
            if base is None:
                # 尝试用 (algo, nodes) 匹配，忽略边数
                for bkey, bval in baseline.items():
                    if bkey[0] == algo and bkey[1] == nodes:
                        base = bval
                        key = bkey
                        break

            new_us = compute_us_per_op(res)
            if new_us is None:
                unmatched.append(f"  ⚠️  无法计算耗时: {name}")
                continue

            label = f"{algo}(n={nodes})"

            if base is None:
                unmatched.append(f"  ➕ 新基准 (无基线): {label} = {new_us:.2f} μs")
                continue

            base_us = base["mean_us"]
            change_pct = (new_us - base_us) / base_us * 100

            compared_count += 1

            if change_pct > threshold:
                severity = "🔴" if change_pct > 20 else "🟠"
                regressions.append(
                    f"  {severity} {label}: {base_us:.2f} → {new_us:.2f} μs "
                    f"(+{change_pct:.1f}%, std_dev={base['std_dev_pct']:.1f}%)"
                )
            elif change_pct < -threshold:
                improvements.append(
                    f"  🟢 {label}: {base_us:.2f} → {new_us:.2f} μs "
                    f"({change_pct:.1f}%)"
                )
            else:
                # 正常范围
                pass

    # 4. 输出报告
    print(f"\n{'=' * 60}")
    print(f"  📋 报告 (对比 {compared_count} 项)")
    print(f"  ⚠️  注意: 基线 CSV 可能来自不同机器/编译器配置")
    print(f"  {'=' * 54}")
    print(f"{'=' * 60}")

    # 按严重程度排序
    def extract_pct(s: str) -> float:
        import re
        m = re.search(r'[+-]?(\d+\.?\d*)%', s)
        return float(m.group(1)) if m else 0.0
    regressions.sort(key=extract_pct, reverse=True)
    improvements.sort(key=extract_pct, reverse=True)

    if regressions:
        print(f"\n❌ 回归 ({len(regressions)} 项):")
        # 显示前 10 项最严重的 + 统计
        for r in regressions[:10]:
            print(r)
        if len(regressions) > 10:
            print(f"  ... 及 {len(regressions) - 10} 项更多")

    if improvements:
        print(f"\n✅ 改进 ({len(improvements)} 项):")
        for r in improvements:
            print(r)

    if not regressions and not improvements:
        print(f"\n✅ 全部 {compared_count} 项在阈值 ±{threshold}% 内")

    if unmatched:
        print(f"\n📌 其他 ({len(unmatched)} 项):")
        for u in unmatched:
            print(u)

    # 5. 返回码
    if regressions:
        print(f"\n💥 发现 {len(regressions)} 项回归!")
        sys.exit(1)
    else:
        print(f"\n✅ 通过! 无回归。")
        sys.exit(0)


if __name__ == "__main__":
    main()