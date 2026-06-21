"""主控脚本：生成所有 fixture 和测试"""
import subprocess, sys
from pathlib import Path

gen_dir = Path(__file__).parent

print("=== Step 1: Generating fixtures ===")
subprocess.run([sys.executable, str(gen_dir / "gen_fixtures.py")], check=True)

print("\n=== Step 2: Generating MoonBit tests ===")
subprocess.run([sys.executable, str(gen_dir / "gen_tests.py")], check=True)

print("\n=== All done ===")
