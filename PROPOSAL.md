# Breakpoint: where does a robot policy break, and can its digital twin fix it?

*Cyberwave Builders, cohort 3 proposal · Ishaan Singh (Discord: raamlaal) · AgileX PiPER*

## Pitch

I'll teach a PiPER arm a tabletop stacking task with SmolVLA, then break it on purpose. A fixed sweep of camera pose, start pose, lighting, distractors and swapped instructions shows exactly where the policy fails. Each failure is classified as perception, grounding or control. The worst one is fixed with synthetic data from the arm's digital twin, and the fix is measured on held-out real episodes. It follows the starter kit's loop (demonstrate → record → train → deploy → test → improve), and every step ends in a number.

## Why it matters

- **Learned robot demos rarely say how often they work.** None of the cohort 1 and 2 projects I read reports a success rate. Cyberwave Sim already produces automatic evaluation replays; this project adds held-out evaluation on the real robot.
- **The likely failures are known, and they are cheap to fix in simulation.** On LIBERO-Plus, π0 falls from 94% to 16% when the camera moves and to 7% when the robot's start pose changes ([arXiv 2510.13626](https://arxiv.org/abs/2510.13626)). Both are things a digital twin can randomise for free.
- **Twin data has a measured payoff.** Co-training 20–50 real demos with task-matched sim data raised real pick-and-place success from 45% to 81% ([arXiv 2503.24361](https://arxiv.org/abs/2503.24361)). Breakpoint tests whether that holds for a 450M VLA, one fixed camera, and a twin built on a builder's arm.

## What already exists

- **Pipeline and evaluation discipline** ([README](README.md)):
  - SmolVLA reproduced on LIBERO: 258/400 (64.5%, Wilson 95% CI 59.7–69.0), with every run reported as raw k/n.
  - Isaac Lab Mimic synthetic-data pipeline: 100 successful stacking demos in 16 minutes at 32 parallel envs on a 16 GB RTX A4000.

  ![SmolVLA on LIBERO-Goal](docs/phase0_libero.gif)
- **[hexasim](https://github.com/sim-daas/hexasim):** hexapod locomotion trained with PPO in Isaac Lab, including a servo model of the real actuators.
- **Research intern at RRC, IIIT Hyderabad:** a 2-DOF aerial manipulator, residual dynamics models from flight logs, and visual servoing with an EKF and a safety abort.

## Setup

- **Robot:** AgileX PiPER (6-DOF, parallel gripper), driven through Cyberwave's PiPER edge driver.
- **Camera:** one fixed USB camera.
- **Compute:** a laptop as the edge device, plus an RTX A4000 for training.
- **Policy:** SmolVLA, trained on Cyberwave's VLA cloud node if beta access is available, otherwise locally with LeRobot. ACT trained on the same data as a cheap check.
- **Twin:** the PiPER in Isaac Lab 3, built from AgileX's URDF, with Isaac Lab Mimic for synthetic demos. Work on it starts now, before the cohort.

## Four weeks

| Week | Cyberwave's theme | Breakpoint |
|---|---|---|
| 0 (before start) | | PiPER twin in Isaac Lab; stacking task and Mimic config; camera pose matched to the real one |
| 1 | Set up | SDK, twin sync, teleop; write the evaluation protocol (fixed start poses and object layouts); record 50 real demos |
| 2 | Prototype | Fine-tune SmolVLA; baseline on 50 real episodes |
| 3 | Break & improve | 20 episodes on each of 5 perturbation axes; label each failure by stage; generate twin data randomised along the worst axis; co-train and retrain |
| 4 | Ship | Held-out real evaluation before and after the fix (50 episodes each), demo video, docs |

**Stretch: a failure detector.** A small probe reads SmolVLA's internal features at every step and predicts whether the episode will fail, using the labelled rollouts from week 3. A conformal threshold makes the arm pause and escalate to a human before a grasp misses, with a live failure-probability trace in the video. It predicts *task* failure from the policy itself, not hardware faults or collisions. The honest headline is whether it still works under the perturbations. A similar probe dropped from ROC-AUC 0.87 on seen tasks to 0.64 on unseen ones ([arXiv 2506.09937](https://arxiv.org/abs/2506.09937)).

## Success checks

- Every result is reported as k/n with a Wilson 95% interval, on a protocol written down before the runs. At 20 episodes that interval is about ±20 points, and the write-up says so.
- Deliverables:
  - a failure-boundary table: success per perturbation axis, failures by stage
  - one before/after result for the twin fix
  - a demo video
- The fix counts as done when it is measured, whether or not it helps. A fix that doesn't work is still a result.

## What Cyberwave gets back

- An open-source PiPER twin in Isaac Lab with a Mimic config, and a converter from Isaac Lab HDF5 to LeRobot v3 datasets.
- A reusable held-out evaluation script for real-robot policies.
- Written feedback on the VLA cloud node, teleop and twin sync from a robot-learning workflow.
- If time allows, a UFACTORY xArm 7 integration (URDF plus a wrapper around `xarm_ros2`).

## About me

Third-year B.Tech student in Data Science & AI at IIIT Naya Raipur, and research intern at RRC, IIIT Hyderabad. I work on robot learning for real hardware: VLAs, reinforcement learning in Isaac Lab, and edge perception on Jetson.
