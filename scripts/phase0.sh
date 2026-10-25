#!/usr/bin/env bash
# Phase 0: reproduce the SmolVLA LIBERO number (4 suites x 10 tasks x 10 episodes).
# batch_size = episodes per task, as the LeRobot LIBERO docs recommend for comparable runs.
# Needs conda env `env_lerobot` (Python 3.12) and uv.
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_BIN="$(conda run -n env_lerobot python -c 'import sys, os; print(os.path.dirname(sys.executable))')"
uv pip install --python "$ENV_BIN/python" "lerobot[smolvla,dataset,evaluation,libero]==0.6.1"

# stdin answers LIBERO's one-time dataset-path prompt.
MUJOCO_GL=egl "$ENV_BIN/lerobot-eval" <<< N \
  --policy.path=HuggingFaceVLA/smolvla_libero \
  --env.type=libero \
  --env.task=libero_spatial,libero_object,libero_goal,libero_10 \
  --eval.batch_size=10 \
  --eval.n_episodes=10 \
  --env.max_parallel_tasks=1 \
  --output_dir=outputs/phase0_libero
