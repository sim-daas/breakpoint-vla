# Research progress

Running log of what has been done, measured and learned. The plan itself lives in `README.md`.

## 2026-10-11 to 2026-10-12: roadmap finalised, Phase 0 complete

### Done

- Surveyed the field and the local install, then rewrote the roadmap in `README.md`.
- Reproduced a SmolVLA LIBERO number with `bash scripts/phase0.sh`.
- Proved the Isaac Sim side with Arena's zero-action smoke test.
- Ran the stock Franka Mimic pipeline end to end (annotate, generate) at 8, 16 and 32 envs.

### Measured (RTX A4000 16GB)

**SmolVLA on LIBERO**, checkpoint `HuggingFaceVLA/smolvla_libero`, 10 episodes × 10 tasks per suite, 2 h 52 min:

| Suite | This run | Paper (0.45B) |
|---|---|---|
| Spatial | 70/100 | 90 |
| Object | 77/100 | 96 |
| Goal | 73/100 | 92 |
| Long | 38/100 | 71 |
| All | 258/400 (64.5%, Wilson 95% CI 59.7–69.0) | 87.3 |

**Spatial check with 10-step action chunks** (`--policy.n_action_steps=10`, same seed and initial states): 60/100 in 9 min, against 70/100 in about 35 min when replanning every step. The intervals overlap, so chunk length does not explain the gap to the paper, and it is not better. The remaining suspect is the checkpoint itself, which is unproven.

**Stock Franka Mimic**, 100 successful demos per run, two 200×200 cameras:

| Envs | Yield | Wall time | Peak VRAM |
|---|---|---|---|
| 8 | 38.6% | 45 min (GPU shared) | 4.7 GB |
| 16 | 45.9% | 29 min (GPU shared) | 5.5 GB |
| 32 | 35.0% | 16 min | 7.6 GB |

Annotating the 10 source demos took 8 min. At 32 envs, 1,000 demos should take under 3 hours.

### Decisions

- Phase 0 uses LIBERO for the reference number, because no Franka SmolVLA checkpoint exists for Arena.
- Phases 1–3 train on the fixed camera only. The real xArm 7 has a parallel gripper and a fixed camera; a wrist camera is a later ablation.
- Phase 4 is a menu, chosen after Phase 3.
- Eval sizes are at least 100 episodes per condition, reported as raw k/n with a Wilson interval.
- Checkpoints are chosen by rollouts, not by loss.

### Findings from the field survey

- **What fits 16GB:** ACT, Diffusion Policy and SmolVLA fine-tune locally. π0, π0.5, GR00T N1.7 and X-VLA need 24GB or more to fine-tune; π0.5 inference fits at 14.5GB.
- **LIBERO is saturated and rewards memorisation.** Top models sit at 96–98%; LIBERO-Plus spreads them to 71–85%, with camera pose and robot start state as the worst perturbations.
- **Grounding is the weak point of current VLAs.** Grasping stays reliable while instruction-following falls when object positions are randomised. This is why Phase 3 adds a multi-object language variant.
- **Industry:** production picking uses purpose-built systems, not VLAs. The one documented factory VLA deployment (Siemens, π0.5, 2,535 episodes) missed its target. Indian postings I could read ask for PyTorch, ROS 2, C++, Isaac Sim, sim-to-real and real-robot evidence; VLA is usually "preferred".
- **Mimic:** needs object poses at generation time, a fixed subtask order and rigid objects. Reported yield runs from about 40% on stacking to below 10% on tight assembly.

### Tooling gaps to plan around

- Arena 0.3.1 has no LeRobot policy client. Its remote policies speak the `openpi_client` websocket protocol, so the SmolVLA server is Phase 1 glue.
- Isaac Lab has no xArm 7 robot config. The USD exists in Isaac Sim 6.1 (`Robots/Ufactory/xarm7/xarm7.usd`); the `ArticulationCfg`, stack env and Mimic config must be copied from the Franka ones.
- The stock stack task's grasp signals assume Franka fingers. The xArm gripper is a linkage, so this is the likeliest place to lose time.
- The installed HDF5 → LeRobot converter targets GR00T-style v2 datasets for humanoids. A v3 converter for two-camera xArm data is Phase 1 glue.
- `annotate_demos.py` crashes headless on the camera task in Isaac Lab 3; pass `--experience <IsaacLab>/apps/isaaclab.python.headless.rendering.kit`.
- `lerobot/smolvla_libero` fails `lerobot-eval` with a camera-name mismatch.

### Open questions

- Why the LIBERO run is 23 points below the paper. Chunk length is ruled out; the checkpoint is the remaining suspect. Settling it means fine-tuning SmolVLA on `lerobot/libero` ourselves (the docs recipe is 100k steps at batch 64, which is cloud-sized), so it is parked.
- Whether the real xArm 7 will have a wrist camera.
- xArm 7 USD joint names, drive gains and gripper variant; not yet opened in a stage.
- Mimic yield on an untuned xArm port.

## 2026-10-18: Cyberwave Builders track added

- Applying to Cyberwave Builders cohort 3, mainly for free hardware. The plan is Track B in `README.md`: failure analysis on a PiPER (SO-101 fallback).
- **Found:** builders get SO-101, PiPER or UGV Beast, and no xArm. The platform takes LeRobot v2.1/v3 datasets and trains and deploys SmolVLA in the cloud. Past cohorts were mostly plain SO-101 + SmolVLA demos; two did safety gating, and measured failure analysis was rare. Their week 3 is "find out what breaks".
- **Confirmed:** hardware ships to India. Form and Discord intro submitted on 2026-10-18.
- **Unknown:** whether hardware is kept, deadline, prize amounts, ACT support.
- hexasim made public on 2026-10-18. VLAs stays private until the resume PDF is removed from its git history.

## 2026-10-25: retarget to the PiPER, Cyberwave proposal written

### Found
- Cohort 3 picks 40 builders. Cohorts 1 and 2 had 15 and 30 core builders. Hardware ships before the cohort and is kept. Cyberwave (Rishabh) invited a proposal before selection (about 2–3 weeks) and said the idea can change afterwards.
- **Arms:** the PiPER is the most capable arm builders can request (6-DOF, 1.5 kg payload, about €3.4k). Cyberwave has a PiPER edge driver over CAN, and MuJoCo Menagerie has `agilex_piper`. LeRobot has no native PiPER support. UR7e, OpenArm and Kinova are supported by the platform but not shown as requestable.
- **Past projects:** none of the featured cohort 1/2 projects reports a success rate. Clodbot and BenchPilot are scripted, not learned.
- **Platform:** Cyberwave's RL tasks (mjlab + skrl, new 2026-09-09) have arm examples only for Kinova and OpenArm. Their docs say evaluations "are not held-out" and have no sim-to-real section. Policy upload is skrl checkpoints only. The VLA cloud node (SmolVLA) is a private beta.
- **Discord intros (about 53):** about 17 rovers, about 15 template or LLM assistants, none evaluating a learned manipulation policy. Nearest: a safety layer on a PiPER, SO-101 hardware-fault detection from telemetry, Lite6 rehab.

### Decisions
- The PiPER is the primary embodiment for the whole project; the xArm 7 is a later second embodiment.
- The twin stays in Isaac Lab 3 + Mimic.
- Track B core: twin-to-real Breakpoint. Stretch: a failure detector on SmolVLA features, framed as task-failure prediction, which separates it from hardware faults and collision gating. Residual RL moves to after the cohort.
- Proposal: `PROPOSAL.md`, to be shared once the repo is public.

### Open
- PiPER teleop method in Cyberwave.
- VLA cloud node beta access.
- Cohort 3 dates.
- PiPER finger joint count against the stack task's two-joint asserts.

### Next (Phase 1)

1. PiPER `ArticulationCfg` (from AgileX `piper_gripper.urdf`) and stack env, one-week time-box, Franka fallback.
2. Teleoperate 15–20 demos with the keyboard.
3. Mimic generation at 32 envs.
4. HDF5 → LeRobot v3 converter.
5. SmolVLA fine-tune, policy server, closed-loop eval over at least 100 episodes.
