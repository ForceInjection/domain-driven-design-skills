---
name: rl-evaluation
description: Rigorous RL evaluation - statistical protocols, train/test discipline, metrics, generalization
---

# RL Evaluation: Rigorous Methodology for Agent Assessment

<CRITICAL_CONTEXT>
RL evaluation is uniquely challenging due to high variance, temporal instability, environment overfitting, and sample efficiency considerations. Without rigorous methodology, you will:

- Draw conclusions from statistical noise
- Report results that don't generalize
- Deploy agents that fail in production
- Waste resources on false improvements

This skill provides systematic evaluation protocols that ensure statistical validity, generalization measurement, and deployment-ready assessment.
</CRITICAL_CONTEXT>

## When to Use This Skill

Use this skill when:

- ✅ Evaluating RL agent performance
- ✅ Comparing multiple RL algorithms
- ✅ Reporting results for publication or deployment
- ✅ Making algorithm selection decisions
- ✅ Assessing readiness for production deployment
- ✅ Debugging training (need accurate performance estimates)

DO NOT use for:

- ❌ Quick sanity checks during development (use informal evaluation)
- ❌ Monitoring training progress (use running averages)
- ❌ Initial hyperparameter sweeps (use coarse evaluation)

**When in doubt:** If the evaluation result will inform a decision (publish, deploy, choose algorithm), use this skill.

---

## Core Principles

### Principle 1: Statistical Rigor is Non-Negotiable

**Reality:** RL has inherently high variance. Single runs are meaningless.

**Enforcement:**

- Minimum 5-10 random seeds for any performance claim
- Report mean ± std or 95% confidence intervals
- Statistical significance testing when comparing algorithms
- Never report single-seed results as representative

### Principle 2: Train/Test Discipline Prevents Overfitting

**Reality:** Agents exploit environment quirks. Training performance ≠ generalization.

**Enforcement:**

- Separate train/test environment instances
- Different random seeds for train/eval
- Test on distribution shifts (new instances, physics, appearances)
- Report both training and generalization performance

### Principle 3: Sample Efficiency Matters

**Reality:** Final performance ignores cost. Samples are often expensive.

**Enforcement:**

- Report sample efficiency curves (reward vs steps)
- Include "reward at X steps" for multiple budgets
- Consider deployment constraints
- Compare at SAME sample budget, not just asymptotic

### Principle 4: Evaluation Mode Must Match Deployment

**Reality:** Stochastic vs deterministic evaluation changes results by 10-30%.

**Enforcement:**

- Specify evaluation mode (stochastic/deterministic)
- Match evaluation to deployment scenario
- Report both if ambiguous
- Explain choice in methodology

### Principle 5: Offline RL Requires Special Care

**Reality:** Cannot accurately evaluate offline RL without online rollouts.

**Enforcement:**

- Acknowledge evaluation limitations
- Use conservative metrics (in-distribution performance)
- Quantify uncertainty
- Staged deployment (offline → small online trial → full)

---

## Statistical Evaluation Protocol

### Multi-Seed Evaluation (MANDATORY)

**Minimum Requirements:**

- **Exploration/research**: 5-10 seeds minimum
- **Publication**: 10-20 seeds
- **Production deployment**: 20-50 seeds (depending on variance)

**Protocol:**

```python
import numpy as np
from scipy import stats

def evaluate_multi_seed(algorithm, env_name, seeds, total_steps):
    """
    Evaluate algorithm across multiple random seeds.

    Args:
        algorithm: RL algorithm class
        env_name: Environment name
        seeds: List of random seeds
        total_steps: Training steps per seed

    Returns:
        Dictionary with statistics
    """
    final_rewards = []
    sample_efficiency_curves = []

    for seed in seeds:
        # Train agent
        env = gym.make(env_name, seed=seed)
        agent = algorithm(env, seed=seed)

        # Track performance during training
        eval_points = np.linspace(0, total_steps, num=20, dtype=int)
        curve = []

        for step in eval_points:
            agent.train(steps=step)
            reward = evaluate_deterministic(agent, env, episodes=10)
            curve.append((step, reward))

        sample_efficiency_curves.append(curve)
        final_rewards.append(curve[-1][1])  # Final performance

    final_rewards = np.array(final_rewards)

    return {
        'mean': np.mean(final_rewards),
        'std': np.std(final_rewards),
        'median': np.median(final_rewards),
        'min': np.min(final_rewards),
        'max': np.max(final_rewards),
        'iqr': (np.percentile(final_rewards, 75) -
                np.percentile(final_rewards, 25)),
        'confidence_interval_95': stats.t.interval(
            0.95,
            len(final_rewards) - 1,
            loc=np.mean(final_rewards),
            scale=stats.sem(final_rewards)
        ),
        'all_seeds': final_rewards,
        'curves': sample_efficiency_curves
    }

# Usage
results = evaluate_multi_seed(
    algorithm=PPO,
    env_name="HalfCheetah-v3",
    seeds=range(10),  # 10 seeds
    total_steps=1_000_000
)

print(f"Performance: {results['mean']:.1f} ± {results['std']:.1f}")
print(f"95% CI: [{results['confidence_interval_95'][0]:.1f}, "
      f"{results['confidence_interval_95'][1]:.1f}]")
print(f"Median: {results['median']:.1f}")
print(f"Range: [{results['min']:.1f}, {results['max']:.1f}]")
```

**Reporting Template:**

```
Algorithm: PPO
Environment: HalfCheetah-v3
Seeds: 10
Total Steps: 1M

Final Performance:
- Mean: 4,523 ± 387
- Median: 4,612
- 95% CI: [4,246, 4,800]
- Range: [3,812, 5,201]

Sample Efficiency:
- Reward at 100k steps: 1,234 ± 156
- Reward at 500k steps: 3,456 ± 289
- Reward at 1M steps: 4,523 ± 387
```

### Statistical Significance Testing

**When comparing algorithms:**

```python
def compare_algorithms(results_A, results_B, alpha=0.05):
    """
    Compare two algorithms with statistical rigor.

    Args:
        results_A: Array of final rewards for algorithm A (multiple seeds)
        results_B: Array of final rewards for algorithm B (multiple seeds)
        alpha: Significance level (default 0.05)

    Returns:
        Dictionary with comparison statistics
    """
    # T-test for difference in means
    t_statistic, p_value = stats.ttest_ind(results_A, results_B)

    # Effect size (Cohen's d)
    pooled_std = np.sqrt((np.std(results_A)**2 + np.std(results_B)**2) / 2)
    cohens_d = (np.mean(results_A) - np.mean(results_B)) / pooled_std

    # Bootstrap confidence interval for difference
    def bootstrap_diff(n_bootstrap=10000):
        diffs = []
        for _ in range(n_bootstrap):
            sample_A = np.random.choice(results_A, size=len(results_A))
            sample_B = np.random.choice(results_B, size=len(results_B))
            diffs.append(np.mean(sample_A) - np.mean(sample_B))
        return np.percentile(diffs, [2.5, 97.5])

    ci_diff = bootstrap_diff()

    return {
        'mean_A': np.mean(results_A),
        'mean_B': np.mean(results_B),
        'difference': np.mean(results_A) - np.mean(results_B),
        'p_value': p_value,
        'significant': p_value < alpha,
        'cohens_d': cohens_d,
        'ci_difference': ci_diff,
        'conclusion': (
            f"Algorithm A is {'significantly' if p_value < alpha else 'NOT significantly'} "
            f"better than B (p={p_value:.4f})"
        )
    }

# Usage
ppo_results = np.array([4523, 4612, 4201, 4789, 4456, 4390, 4678, 4234, 4567, 4498])
sac_results = np.array([4678, 4890, 4567, 4923, 4712, 4645, 4801, 4556, 4734, 4689])

comparison = compare_algorithms(ppo_results, sac_results)
print(comparison['conclusion'])
print(f"Effect size (Cohen's d): {comparison['cohens_d']:.3f}")
print(f"95% CI for difference: [{comparison['ci_difference'][0]:.1f}, "
      f"{comparison['ci_difference'][1]:.1f}]")
```

**Interpreting Effect Size (Cohen's d):**

- d < 0.2: Negligible difference
- 0.2 ≤ d < 0.5: Small effect
- 0.5 ≤ d < 0.8: Medium effect
- d ≥ 0.8: Large effect

**Red Flag:** If p-value < 0.05 but Cohen's d < 0.2, the difference is statistically significant but practically negligible. Don't claim "better" without practical significance.

### Power Analysis: How Many Seeds Needed?

```python
def required_seeds_for_precision(std_estimate, mean_estimate,
                                  desired_precision=0.1, confidence=0.95):
    """
    Calculate number of seeds needed for desired precision.

    Args:
        std_estimate: Estimated standard deviation (from pilot runs)
        mean_estimate: Estimated mean performance
        desired_precision: Desired precision as fraction of mean (0.1 = ±10%)
        confidence: Confidence level (0.95 = 95% CI)

    Returns:
        Required number of seeds
    """
    # Z-score for confidence level
    z = stats.norm.ppf(1 - (1 - confidence) / 2)

    # Desired margin of error
    margin = desired_precision * mean_estimate

    # Required sample size
    n = (z * std_estimate / margin) ** 2

    return int(np.ceil(n))

# Example: You ran 3 pilot seeds
pilot_results = [4500, 4200, 4700]
std_est = np.std(pilot_results)  # 250
mean_est = np.mean(pilot_results)  # 4467

# How many seeds for ±10% precision at 95% confidence?
n_required = required_seeds_for_precision(std_est, mean_est,
                                           desired_precision=0.1)
print(f"Need {n_required} seeds for ±10% precision")  # ~12 seeds

# How many for ±5% precision?
n_tight = required_seeds_for_precision(std_est, mean_est,
                                        desired_precision=0.05)
print(f"Need {n_tight} seeds for ±5% precision")  # ~47 seeds
```

**Practical Guidelines:**

- Quick comparison: 5 seeds (±20% precision)
- Standard evaluation: 10 seeds (±10% precision)
- Publication: 20 seeds (±7% precision)
- Production deployment: 50+ seeds (±5% precision)

---

## Train/Test Discipline

### Environment Instance Separation

**CRITICAL:** Never evaluate on the same environment instances used for training.

```python
# WRONG: Single environment for both training and evaluation
env = gym.make("CartPole-v1", seed=42)
agent.train(env)
performance = evaluate(agent, env)  # BIASED!

# CORRECT: Separate environments
train_env = gym.make("CartPole-v1", seed=42)
eval_env = gym.make("CartPole-v1", seed=999)  # Different seed

agent.train(train_env)
performance = evaluate(agent, eval_env)  # Unbiased
```

### Train/Test Split for Custom Environments

**For environments with multiple instances (levels, objects, configurations):**

```python
def create_train_test_split(all_instances, test_ratio=0.2, seed=42):
    """
    Split environment instances into train and test sets.

    Args:
        all_instances: List of environment configurations
        test_ratio: Fraction for test set (default 0.2)
        seed: Random seed for reproducibility

    Returns:
        (train_instances, test_instances)
    """
    np.random.seed(seed)
    n_test = int(len(all_instances) * test_ratio)

    indices = np.random.permutation(len(all_instances))
    test_indices = indices[:n_test]
    train_indices = indices[n_test:]

    train_instances = [all_instances[i] for i in train_indices]
    test_instances = [all_instances[i] for i in test_indices]

    return train_instances, test_instances

# Example: Maze environments
all_mazes = [MazeLayout(seed=i) for i in range(100)]
train_mazes, test_mazes = create_train_test_split(all_mazes, test_ratio=0.2)

print(f"Training on {len(train_mazes)} mazes")  # 80
print(f"Testing on {len(test_mazes)} mazes")    # 20

# Train only on training set
agent.train(train_mazes)

# Evaluate on BOTH train and test (measure generalization gap)
train_performance = evaluate(agent, train_mazes)
test_performance = evaluate(agent, test_mazes)

generalization_gap = train_performance - test_performance
print(f"Train: {train_performance:.1f}")
print(f"Test: {test_performance:.1f}")
print(f"Generalization gap: {generalization_gap:.1f}")

# Red flag: If gap > 20% of train performance, agent is overfitting
if generalization_gap > 0.2 * train_performance:
    print("WARNING: Significant overfitting detected!")
```

### Randomization Protocol

**Ensure independent randomization for train/eval:**

```python
class EvaluationProtocol:
    def __init__(self, env_name, train_seed=42, eval_seed=999):
        """
        Proper train/eval environment management.

        Args:
            env_name: Gym environment name
            train_seed: Seed for training environment
            eval_seed: Seed for evaluation environment (DIFFERENT)
        """
        self.env_name = env_name
        self.train_seed = train_seed
        self.eval_seed = eval_seed

        # Separate environments
        self.train_env = gym.make(env_name)
        self.train_env.seed(train_seed)
        self.train_env.action_space.seed(train_seed)
        self.train_env.observation_space.seed(train_seed)

        self.eval_env = gym.make(env_name)
        self.eval_env.seed(eval_seed)
        self.eval_env.action_space.seed(eval_seed)
        self.eval_env.observation_space.seed(eval_seed)

    def train_step(self, agent):
        """Training step on training environment."""
        return agent.step(self.train_env)

    def evaluate(self, agent, episodes=100):
        """Evaluation on SEPARATE evaluation environment."""
        rewards = []
        for _ in range(episodes):
            state = self.eval_env.reset()
            episode_reward = 0
            done = False

            while not done:
                action = agent.act_deterministic(state)
                state, reward, done, _ = self.eval_env.step(action)
                episode_reward += reward

            rewards.append(episode_reward)

        return np.mean(rewards), np.std(rewards)

# Usage
protocol = EvaluationProtocol("HalfCheetah-v3", train_seed=42, eval_seed=999)

# Training
agent = SAC()
for step in range(1_000_000):
    protocol.train_step(agent)

    if step % 10_000 == 0:
        mean_reward, std_reward = protocol.evaluate(agent, episodes=10)
        print(f"Step {step}: {mean_reward:.1f} ± {std_reward:.1f}")
```

---

## Sample Efficiency Metrics

### Sample Efficiency Curves

**Report performance at multiple sample budgets, not just final:**

```python
def compute_sample_efficiency_curve(agent_class, env_name, seed,
                                     max_steps, eval_points=20):
    """
    Compute sample efficiency curve (reward vs steps).

    Args:
        agent_class: RL algorithm class
        env_name: Environment name
        seed: Random seed
        max_steps: Maximum training steps
        eval_points: Number of evaluation points

    Returns:
        List of (steps, reward) tuples
    """
    env = gym.make(env_name, seed=seed)
    agent = agent_class(env, seed=seed)

    eval_steps = np.logspace(3, np.log10(max_steps), num=eval_points, dtype=int)
    # [1000, 1500, 2200, ..., max_steps] (logarithmic spacing)

    curve = []
    current_step = 0

    for target_step in eval_steps:
        # Train until target_step
        steps_to_train = target_step - current_step
        agent.train(steps=steps_to_train)
        current_step = target_step

        # Evaluate
        reward = evaluate_deterministic(agent, env, episodes=10)
        curve.append((target_step, reward))

    return curve

# Compare sample efficiency of multiple algorithms
algorithms = [PPO, SAC, TD3]
env_name = "HalfCheetah-v3"
max_steps = 1_000_000

for algo in algorithms:
    # Average across 5 seeds
    all_curves = []
    for seed in range(5):
        curve = compute_sample_efficiency_curve(algo, env_name, seed, max_steps)
        all_curves.append(curve)

    # Aggregate
    steps = [point[0] for point in all_curves[0]]
    rewards_at_step = [[curve[i][1] for curve in all_curves]
                       for i in range(len(steps))]
    mean_rewards = [np.mean(rewards) for rewards in rewards_at_step]
    std_rewards = [np.std(rewards) for rewards in rewards_at_step]

    # Report at specific budgets
    for i, step in enumerate([100_000, 500_000, 1_000_000]):
        idx = steps.index(step)
        print(f"{algo.__name__} at {step} steps: "
              f"{mean_rewards[idx]:.1f} ± {std_rewards[idx]:.1f}")
```

**Sample Output:**

```
PPO at 100k steps: 1,234 ± 156
PPO at 500k steps: 3,456 ± 289
PPO at 1M steps: 4,523 ± 387

SAC at 100k steps: 891 ± 178
SAC at 500k steps: 3,789 ± 245
SAC at 1M steps: 4,912 ± 312

TD3 at 100k steps: 756 ± 134
TD3 at 500k steps: 3,234 ± 298
TD3 at 1M steps: 4,678 ± 276
```

**Analysis:**

- PPO is most sample-efficient early (1,234 at 100k)
- SAC has best final performance (4,912 at 1M)
- If sample budget is 100k → PPO is best choice
- If sample budget is 1M → SAC is best choice

### Area Under Curve (AUC) Metric

**Single metric for sample efficiency:**

```python
def compute_auc(curve):
    """
    Compute area under sample efficiency curve.

    Args:
        curve: List of (steps, reward) tuples

    Returns:
        AUC value (higher = more sample efficient)
    """
    steps = np.array([point[0] for point in curve])
    rewards = np.array([point[1] for point in curve])

    # Trapezoidal integration
    auc = np.trapz(rewards, steps)
    return auc

# Compare algorithms by AUC
for algo in algorithms:
    all_aucs = []
    for seed in range(5):
        curve = compute_sample_efficiency_curve(algo, env_name, seed, max_steps)
        auc = compute_auc(curve)
        all_aucs.append(auc)

    print(f"{algo.__name__} AUC: {np.mean(all_aucs):.2e} ± {np.std(all_aucs):.2e}")
```

**Note:** AUC is sensitive to evaluation point spacing. Use consistent evaluation points across algorithms.

---

## Generalization Testing

### Distribution Shift Evaluation

**Test on environment variations to measure robustness:**

```python
def evaluate_generalization(agent, env_name, shifts):
    """
    Evaluate agent on distribution shifts.

    Args:
        agent: Trained RL agent
        env_name: Base environment name
        shifts: Dictionary of shift types and parameters

    Returns:
        Dictionary of performance on each shift
    """
    results = {}

    # Baseline (no shift)
    baseline_env = gym.make(env_name)
    baseline_perf = evaluate(agent, baseline_env, episodes=50)
    results['baseline'] = baseline_perf

    # Test shifts
    for shift_name, shift_params in shifts.items():
        shifted_env = apply_shift(env_name, shift_params)
        shift_perf = evaluate(agent, shifted_env, episodes=50)
        results[shift_name] = shift_perf

        # Compute degradation
        degradation = (baseline_perf - shift_perf) / baseline_perf
        results[f'{shift_name}_degradation'] = degradation

    return results

# Example: Robotic grasping
shifts = {
    'lighting_dim': {'lighting_scale': 0.5},
    'lighting_bright': {'lighting_scale': 1.5},
    'camera_angle_15deg': {'camera_rotation': 15},
    'table_height_+5cm': {'table_height_offset': 0.05},
    'object_mass_+50%': {'mass_scale': 1.5},
    'object_friction_-30%': {'friction_scale': 0.7}
}

gen_results = evaluate_generalization(agent, "RobotGrasp-v1", shifts)

print(f"Baseline: {gen_results['baseline']:.2%} success")
for shift_name in shifts.keys():
    perf = gen_results[shift_name]
    deg = gen_results[f'{shift_name}_degradation']
    print(f"{shift_name}: {perf:.2%} success ({deg:.1%} degradation)")

# Red flag: If any degradation > 50%, agent is brittle
```

### Zero-Shot Transfer Evaluation

**Test on completely new environments:**

```python
def zero_shot_transfer(agent, train_env_name, test_env_names):
    """
    Evaluate zero-shot transfer to related environments.

    Args:
        agent: Agent trained on train_env_name
        train_env_name: Training environment
        test_env_names: List of related test environments

    Returns:
        Transfer performance dictionary
    """
    results = {}

    # Source performance
    source_env = gym.make(train_env_name)
    source_perf = evaluate(agent, source_env, episodes=50)
    results['source'] = source_perf

    # Target performances
    for target_env_name in test_env_names:
        target_env = gym.make(target_env_name)
        target_perf = evaluate(agent, target_env, episodes=50)
        results[target_env_name] = target_perf

        # Transfer efficiency
        transfer_ratio = target_perf / source_perf
        results[f'{target_env_name}_transfer_ratio'] = transfer_ratio

    return results

# Example: Locomotion transfer
agent_trained_on_cheetah = train(PPO, "HalfCheetah-v3")

transfer_results = zero_shot_transfer(
    agent_trained_on_cheetah,
    train_env_name="HalfCheetah-v3",
    test_env_names=["Hopper-v3", "Walker2d-v3", "Ant-v3"]
)

print(f"Source (HalfCheetah): {transfer_results['source']:.1f}")
for env in ["Hopper-v3", "Walker2d-v3", "Ant-v3"]:
    perf = transfer_results[env]
    ratio = transfer_results[f'{env}_transfer_ratio']
    print(f"{env}: {perf:.1f} ({ratio:.1%} of source)")
```

### Robustness to Adversarial Perturbations

**Test against worst-case scenarios:**

```python
def adversarial_evaluation(agent, env, perturbation_types,
                            perturbation_magnitudes):
    """
    Evaluate robustness to adversarial perturbations.

    Args:
        agent: RL agent to evaluate
        env: Environment
        perturbation_types: List of perturbation types
        perturbation_magnitudes: List of magnitudes to test

    Returns:
        Robustness curve for each perturbation type
    """
    results = {}

    for perturb_type in perturbation_types:
        results[perturb_type] = []

        for magnitude in perturbation_magnitudes:
            # Apply perturbation
            perturbed_env = add_perturbation(env, perturb_type, magnitude)

            # Evaluate
            perf = evaluate(agent, perturbed_env, episodes=20)
            results[perturb_type].append((magnitude, perf))

    return results

# Example: Vision-based control
perturbation_types = ['gaussian_noise', 'occlusion', 'brightness']
magnitudes = [0.0, 0.1, 0.2, 0.3, 0.5]

robustness = adversarial_evaluation(
    agent, env, perturbation_types, magnitudes
)

for perturb_type, curve in robustness.items():
    print(f"\n{perturb_type}:")
    for magnitude, perf in curve:
        print(f"  Magnitude {magnitude}: {perf:.1f} reward")
```

---

## Evaluation Protocols

### Stochastic vs Deterministic Evaluation

**Decision Tree:**

```
Is the policy inherently deterministic?
├─ YES (DQN, DDPG without noise)
│  └─ Use deterministic evaluation
└─ NO (PPO, SAC, stochastic policies)
   ├─ Will deployment use stochastic policy?
   │  ├─ YES (dialogue, exploration needed)
   │  │  └─ Use stochastic evaluation
   │  └─ NO (control, deterministic deployment)
   │     └─ Use deterministic evaluation
   └─ Unsure?
      └─ Report BOTH stochastic and deterministic
```

**Implementation:**

```python
class EvaluationMode:
    @staticmethod
    def deterministic(agent, env, episodes=100):
        """
        Deterministic evaluation (use mean/argmax action).
        """
        rewards = []
        for _ in range(episodes):
            state = env.reset()
            episode_reward = 0
            done = False

            while not done:
                # Use mean action (no sampling)
                if hasattr(agent, 'act_deterministic'):
                    action = agent.act_deterministic(state)
                else:
                    action = agent.policy.mean(state)  # Or argmax for discrete

                state, reward, done, _ = env.step(action)
                episode_reward += reward

            rewards.append(episode_reward)

        return np.mean(rewards), np.std(rewards)

    @staticmethod
    def stochastic(agent, env, episodes=100):
        """
        Stochastic evaluation (sample from policy).
        """
        rewards = []
        for _ in range(episodes):
            state = env.reset()
            episode_reward = 0
            done = False

            while not done:
                # Sample from policy distribution
                action = agent.policy.sample(state)

                state, reward, done, _ = env.step(action)
                episode_reward += reward

            rewards.append(episode_reward)

        return np.mean(rewards), np.std(rewards)

    @staticmethod
    def report_both(agent, env, episodes=100):
        """
        Report both evaluation modes for transparency.
        """
        det_mean, det_std = EvaluationMode.deterministic(agent, env, episodes)
        sto_mean, sto_std = EvaluationMode.stochastic(agent, env, episodes)

        return {
            'deterministic': {'mean': det_mean, 'std': det_std},
            'stochastic': {'mean': sto_mean, 'std': sto_std},
            'difference': det_mean - sto_mean
        }

# Usage
sac_agent = SAC(env)
sac_agent.train(steps=1_000_000)

eval_results = EvaluationMode.report_both(sac_agent, env, episodes=100)

print(f"Deterministic: {eval_results['deterministic']['mean']:.1f} "
      f"± {eval_results['deterministic']['std']:.1f}")
print(f"Stochastic: {eval_results['stochastic']['mean']:.1f} "
      f"± {eval_results['stochastic']['std']:.1f}")
print(f"Difference: {eval_results['difference']:.1f}")
```

**Interpretation:**

- If difference < 5% of mean: Evaluation mode doesn't matter much
- If difference > 15% of mean: Evaluation mode significantly affects results
  - Must clearly specify which mode used
  - Ensure fair comparison across algorithms (same mode)

### Episode Count Selection

**How many evaluation episodes needed?**

```python
def required_eval_episodes(env, agent, desired_sem, max_episodes=1000):
    """
    Determine number of evaluation episodes for desired standard error.

    Args:
        env: Environment
        agent: Agent to evaluate
        desired_sem: Desired standard error of mean
        max_episodes: Maximum episodes to test

    Returns:
        Required number of episodes
    """
    # Run initial episodes to estimate variance
    initial_episodes = min(20, max_episodes)
    rewards = []

    for _ in range(initial_episodes):
        state = env.reset()
        episode_reward = 0
        done = False

        while not done:
            action = agent.act_deterministic(state)
            state, reward, done, _ = env.step(action)
            episode_reward += reward

        rewards.append(episode_reward)

    # Estimate standard deviation
    std_estimate = np.std(rewards)

    # Required episodes: n = (std / desired_sem)^2
    required = int(np.ceil((std_estimate / desired_sem) ** 2))

    return min(required, max_episodes)

# Usage
agent = PPO(env)
agent.train(steps=1_000_000)

# Want standard error < 10 reward units
n_episodes = required_eval_episodes(env, agent, desired_sem=10)
print(f"Need {n_episodes} episodes for SEM < 10")

# Evaluate with required episodes
final_eval = evaluate(agent, env, episodes=n_episodes)
```

**Rule of Thumb:**

- Quick check: 10 episodes
- Standard evaluation: 50-100 episodes
- Publication/deployment: 100-200 episodes
- High-variance environments: 500+ episodes

### Evaluation Frequency During Training

**How often to evaluate during training?**

```python
def adaptive_evaluation_schedule(total_steps, early_freq=1000,
                                  late_freq=10000, transition_step=100000):
    """
    Create adaptive evaluation schedule.

    Early training: Frequent evaluations (detect divergence early)
    Late training: Infrequent evaluations (policy more stable)

    Args:
        total_steps: Total training steps
        early_freq: Evaluation frequency in early training
        late_freq: Evaluation frequency in late training
        transition_step: Step to transition from early to late

    Returns:
        List of evaluation timesteps
    """
    eval_steps = []

    # Early phase
    current_step = 0
    while current_step < transition_step:
        eval_steps.append(current_step)
        current_step += early_freq

    # Late phase
    while current_step < total_steps:
        eval_steps.append(current_step)
        current_step += late_freq

    # Always evaluate at end
    if eval_steps[-1] != total_steps:
        eval_steps.append(total_steps)

    return eval_steps

# Usage
schedule = adaptive_evaluation_schedule(
    total_steps=1_000_000,
    early_freq=1_000,    # Every 1k steps for first 100k
    late_freq=10_000,    # Every 10k steps after 100k
    transition_step=100_000
)

print(f"Total evaluations: {len(schedule)}")
print(f"First 10 eval steps: {schedule[:10]}")
print(f"Last 10 eval steps: {schedule[-10:]}")

# Training loop
agent = PPO(env)
for step in range(1_000_000):
    agent.train_step()

    if step in schedule:
        eval_perf = evaluate(agent, eval_env, episodes=10)
        log(step, eval_perf)
```

**Guidelines:**

- Evaluation is expensive (10-100 episodes × episode length)
- Early training: Evaluate frequently to detect divergence
- Late training: Evaluate less frequently (policy stabilizes)
- Don't evaluate every step (wastes compute)
- Save checkpoints at evaluation steps (for later analysis)

---

## Offline RL Evaluation

### The Offline RL Evaluation Problem

**CRITICAL:** You cannot accurately evaluate offline RL policies without online rollouts.

**Why:**

- Learned Q-values are only accurate for data distribution
- Policy wants to visit out-of-distribution states
- Q-values for OOD states are extrapolated (unreliable)
- Dataset doesn't contain policy's trajectories

**What to do:**

```python
class OfflineRLEvaluation:
    """
    Conservative offline RL evaluation protocol.
    """

    @staticmethod
    def in_distribution_performance(offline_dataset, policy):
        """
        Evaluate policy on dataset trajectories (lower bound).

        This measures: "How well does policy match best trajectories
        in dataset?" NOT "How good is the policy?"
        """
        returns = []

        for trajectory in offline_dataset:
            # Check if policy would generate this trajectory
            policy_match = True
            for (state, action) in trajectory:
                policy_action = policy(state)
                if not actions_match(policy_action, action):
                    policy_match = False
                    break

            if policy_match:
                returns.append(trajectory.return)

        if len(returns) == 0:
            return None  # Policy doesn't match any dataset trajectory

        return np.mean(returns)

    @staticmethod
    def behavioral_cloning_baseline(offline_dataset):
        """
        Train behavior cloning on dataset (baseline).

        Offline RL should outperform BC, otherwise it's not learning.
        """
        bc_policy = BehaviorCloning(offline_dataset)
        bc_policy.train()
        return bc_policy

    @staticmethod
    def model_based_evaluation(offline_dataset, policy, model):
        """
        Use learned dynamics model for evaluation (if available).

        CAUTION: Model errors compound. Short rollouts only.
        """
        # Train dynamics model on dataset
        model.train(offline_dataset)

        # Generate short rollouts (5-10 steps)
        rollout_returns = []
        for _ in range(100):
            state = sample_initial_state(offline_dataset)
            rollout_return = 0

            for step in range(10):  # Short rollouts only
                action = policy(state)
                next_state, reward = model.predict(state, action)
                rollout_return += reward
                state = next_state

            rollout_returns.append(rollout_return)

        # Heavy discount for model uncertainty
        uncertainty = model.get_uncertainty(offline_dataset)
        adjusted_return = np.mean(rollout_returns) * (1 - uncertainty)

        return adjusted_return

    @staticmethod
    def state_coverage_metric(offline_dataset, policy, num_rollouts=100):
        """
        Measure how much policy stays in-distribution.

        Low coverage → policy goes OOD → evaluation unreliable
        """
        # Get dataset state distribution
        dataset_states = get_all_states(offline_dataset)

        # Simulate policy rollouts
        policy_states = []
        for _ in range(num_rollouts):
            trajectory = simulate_with_model(policy)  # Needs model
            policy_states.extend(trajectory.states)

        # Compute coverage (fraction of policy states near dataset states)
        coverage = compute_coverage(policy_states, dataset_states)
        return coverage

    @staticmethod
    def full_offline_evaluation(offline_dataset, policy):
        """
        Comprehensive offline evaluation (still conservative).
        """
        results = {}

        # 1. In-distribution performance
        results['in_dist_perf'] = OfflineRLEvaluation.in_distribution_performance(
            offline_dataset, policy
        )

        # 2. Compare to behavior cloning
        bc_policy = OfflineRLEvaluation.behavioral_cloning_baseline(offline_dataset)
        results['bc_baseline'] = evaluate(bc_policy, offline_dataset)

        # 3. Model-based evaluation (if model available)
        # model = train_dynamics_model(offline_dataset)
        # results['model_eval'] = OfflineRLEvaluation.model_based_evaluation(
        #     offline_dataset, policy, model
        # )

        # 4. State coverage
        # results['coverage'] = OfflineRLEvaluation.state_coverage_metric(
        #     offline_dataset, policy
        # )

        return results

# Usage
offline_dataset = load_offline_dataset("d4rl-halfcheetah-medium-v0")
offline_policy = CQL(offline_dataset)
offline_policy.train()

eval_results = OfflineRLEvaluation.full_offline_evaluation(
    offline_dataset, offline_policy
)

print("Offline Evaluation (CONSERVATIVE):")
print(f"In-distribution performance: {eval_results['in_dist_perf']}")
print(f"BC baseline: {eval_results['bc_baseline']}")
print("\nWARNING: These are lower bounds. True performance unknown without online evaluation.")
```

### Staged Deployment for Offline RL

**Best practice: Gradually introduce online evaluation**

```python
def staged_offline_to_online_deployment(offline_policy, env):
    """
    Staged deployment: Offline → Small online trial → Full deployment

    Stage 1: Offline evaluation (conservative)
    Stage 2: Small online trial (safety-constrained)
    Stage 3: Full online evaluation
    Stage 4: Deployment
    """
    results = {}

    # Stage 1: Offline evaluation
    print("Stage 1: Offline evaluation")
    offline_perf = offline_evaluation(offline_policy)
    results['offline'] = offline_perf

    if offline_perf < minimum_threshold:
        print("Failed offline evaluation. Stop.")
        return results

    # Stage 2: Small online trial (100 episodes)
    print("Stage 2: Small online trial (100 episodes)")
    online_trial_perf = evaluate(offline_policy, env, episodes=100)
    results['small_trial'] = online_trial_perf

    # Check degradation
    degradation = (offline_perf - online_trial_perf) / offline_perf
    if degradation > 0.3:  # >30% degradation
        print(f"WARNING: {degradation:.1%} performance drop in online trial")
        print("Policy may be overfitting to offline data. Investigate.")
        return results

    # Stage 3: Full online evaluation (1000 episodes)
    print("Stage 3: Full online evaluation (1000 episodes)")
    online_full_perf = evaluate(offline_policy, env, episodes=1000)
    results['full_online'] = online_full_perf

    # Stage 4: Deployment decision
    if online_full_perf > deployment_threshold:
        print("Passed all stages. Ready for deployment.")
        results['deploy'] = True
    else:
        print("Failed online evaluation. Do not deploy.")
        results['deploy'] = False

    return results
```

---

## Common Pitfalls

### Pitfall 1: Single Seed Reporting

**Symptom:** Reporting one training run as "the result"

**Why it's wrong:** RL has high variance. Single seed is noise.

**Detection:**

- Paper shows single training curve
- No variance/error bars
- No mention of multiple seeds

**Fix:** Minimum 5-10 seeds, report mean ± std

---

### Pitfall 2: Cherry-Picking Results

**Symptom:** Running many experiments, reporting best

**Why it's wrong:** Creates false positives (p-hacking)

**Detection:**

- Results seem too good
- No mention of failed runs
- "We tried many seeds and picked a representative one"

**Fix:** Report ALL runs. Pre-register experiments.

---

### Pitfall 3: Evaluating on Training Set

**Symptom:** Agent evaluated on same environment instances used for training

**Why it's wrong:** Measures memorization, not generalization

**Detection:**

- No mention of train/test split
- Same random seed for training and evaluation
- Perfect performance on specific instances

**Fix:** Separate train/test environments with different seeds

---

### Pitfall 4: Ignoring Sample Efficiency

**Symptom:** Comparing algorithms only on final performance

**Why it's wrong:** Final performance ignores cost to achieve it

**Detection:**

- No sample efficiency curves
- No "reward at X steps" metrics
- Only asymptotic performance reported

**Fix:** Report sample efficiency curves, compare at multiple budgets

---

### Pitfall 5: Conflating Train and Eval Performance

**Symptom:** Using training episode returns as evaluation

**Why it's wrong:** Training uses exploration, evaluation should not

**Detection:**

- "Training reward" used for algorithm comparison
- No separate evaluation protocol
- Same environment instance for both

**Fix:** Separate training (with exploration) and evaluation (without)

---

### Pitfall 6: Insufficient Evaluation Episodes

**Symptom:** Evaluating with 5-10 episodes

**Why it's wrong:** High variance → unreliable estimates

**Detection:**

- Large error bars
- Inconsistent results across runs
- SEM > 10% of mean

**Fix:** 50-100 episodes minimum, power analysis for exact number

---

### Pitfall 7: Reporting Peak Instead of Final

**Symptom:** Selecting best checkpoint during training

**Why it's wrong:** Peak is overfitting to evaluation variance

**Detection:**

- "Best performance during training" reported
- Early stopping based on eval performance
- No mention of final performance

**Fix:** Report final performance, or use validation set for model selection

---

### Pitfall 8: No Generalization Testing

**Symptom:** Only evaluating on single environment configuration

**Why it's wrong:** Doesn't measure robustness to distribution shift

**Detection:**

- No mention of distribution shifts
- Only one environment configuration tested
- No transfer/zero-shot evaluation

**Fix:** Test on held-out environments, distribution shifts, adversarial cases

---

### Pitfall 9: Inconsistent Evaluation Mode

**Symptom:** Comparing stochastic and deterministic evaluations

**Why it's wrong:** Evaluation mode affects results by 10-30%

**Detection:**

- No mention of evaluation mode
- Comparing algorithms with different modes
- Unclear if sampling or mean action used

**Fix:** Specify evaluation mode, ensure consistency across comparisons

---

### Pitfall 10: Offline RL Without Online Validation

**Symptom:** Deploying offline RL policy based on Q-values alone

**Why it's wrong:** Q-values extrapolate OOD, unreliable

**Detection:**

- No online rollouts before deployment
- Claiming performance based on learned values
- Ignoring distribution shift

**Fix:** Staged deployment (offline → small online trial → full deployment)

---

## Red Flags

| Red Flag | Implication | Action |
|----------|-------------|--------|
| Only one training curve shown | Single seed, cherry-picked | Demand multi-seed results |
| No error bars or confidence intervals | No variance accounting | Require statistical rigor |
| "We picked a representative seed" | Cherry-picking | Reject, require all seeds |
| No train/test split mentioned | Likely overfitting | Check evaluation protocol |
| No sample efficiency curves | Ignoring cost | Request curves or AUC |
| Evaluation mode not specified | Unclear methodology | Ask: stochastic or deterministic? |
| < 20 evaluation episodes | High variance | Require more episodes |
| Only final performance reported | Missing sample efficiency | Request performance at multiple steps |
| No generalization testing | Narrow evaluation | Request distribution shift tests |
| Offline RL with no online validation | Unreliable estimates | Require online trial |
| Results too good to be true | Probably cherry-picked or overfitting | Deep investigation |
| p-value reported without effect size | Statistically significant but practically irrelevant | Check Cohen's d |

---

## Rationalization Table

| Rationalization | Why It's Wrong | Counter |
|-----------------|----------------|---------|
| "RL papers commonly use single seed, so it's acceptable" | Common ≠ correct. Field is improving standards. | "Newer venues require multi-seed. Improve rigor." |
| "Our algorithm is deterministic, variance is low" | Algorithm determinism ≠ environment/initialization determinism | "Environment randomness still causes variance." |
| "We don't have compute for 10 seeds" | Then don't make strong performance claims | "Report 3-5 seeds with caveats, or wait for compute." |
| "Evaluation on training set is faster" | Speed < correctness | "Fast wrong answer is worse than slow right answer." |
| "We care about final performance, not sample efficiency" | Depends on application, often sample efficiency matters | "Clarify deployment constraints. Samples usually matter." |
| "Stochastic/deterministic doesn't matter" | 10-30% difference is common | "Specify mode, ensure fair comparison." |
| "10 eval episodes is enough" | Standard error likely > 10% of mean | "Compute SEM, use power analysis." |
| "Our environment is simple, doesn't need generalization testing" | Deployment is rarely identical to training | "Test at least 2-3 distribution shifts." |
| "Offline RL Q-values are accurate" | Only for in-distribution, not OOD | "Q-values extrapolate. Need online validation." |
| "We reported the best run, but all were similar" | Then report all and show they're similar | "Show mean ± std to prove similarity." |

---

## Decision Trees

### Decision Tree 1: How Many Seeds?

```
What is the use case?
├─ Quick internal comparison
│  └─ 3-5 seeds (caveat: preliminary results)
├─ Algorithm selection for production
│  └─ 10-20 seeds
├─ Publication
│  └─ 10-20 seeds (depends on venue)
└─ Safety-critical deployment
   └─ 20-50 seeds (need tight confidence intervals)
```

### Decision Tree 2: Evaluation Mode?

```
Is policy inherently deterministic?
├─ YES (DQN, deterministic policies)
│  └─ Deterministic evaluation
└─ NO (PPO, SAC, stochastic policies)
   ├─ Will deployment use stochastic policy?
   │  ├─ YES
   │  │  └─ Stochastic evaluation
   │  └─ NO
   │     └─ Deterministic evaluation
   └─ Unsure?
      └─ Report BOTH, explain trade-offs
```

### Decision Tree 3: How Many Evaluation Episodes?

```
What is variance estimate?
├─ Unknown
│  └─ Start with 20 episodes, estimate variance, use power analysis
├─ Known (σ)
│  ├─ Low variance (σ < 0.1 * μ)
│  │  └─ 20-50 episodes sufficient
│  ├─ Medium variance (0.1 * μ ≤ σ < 0.3 * μ)
│  │  └─ 50-100 episodes
│  └─ High variance (σ ≥ 0.3 * μ)
│     └─ 100-500 episodes (or use variance reduction techniques)
```

### Decision Tree 4: Generalization Testing?

```
Is environment parameterized or procedurally generated?
├─ YES (multiple instances possible)
│  ├─ Use train/test split (80/20)
│  └─ Report both train and test performance
└─ NO (single environment)
   ├─ Can you create distribution shifts?
   │  ├─ YES (modify dynamics, observations, etc.)
   │  │  └─ Test on 3-5 distribution shifts
   │  └─ NO
   │     └─ At minimum, use different random seed for eval
```

### Decision Tree 5: Offline RL Evaluation?

```
Can you do online rollouts?
├─ YES
│  └─ Use staged deployment (offline → small trial → full online)
├─ NO (completely offline)
│  ├─ Use conservative offline metrics
│  ├─ Compare to behavior cloning baseline
│  ├─ Clearly state limitations
│  └─ Do NOT claim actual performance, only lower bounds
└─ PARTIAL (limited online budget)
   └─ Use model-based evaluation + small online trial
```

---

## Workflow

### Standard Evaluation Workflow

```
1. Pre-Experiment Planning
   ☐ Define evaluation protocol BEFORE running experiments
   ☐ Select number of seeds (minimum 5-10)
   ☐ Define train/test split if applicable
   ☐ Specify evaluation mode (stochastic/deterministic)
   ☐ Define sample budgets for efficiency curves
   ☐ Pre-register experiments (commit to protocol)

2. Training Phase
   ☐ Train on training environments ONLY
   ☐ Use separate eval environments with different seeds
   ☐ Evaluate at regular intervals (adaptive schedule)
   ☐ Save checkpoints at evaluation points
   ☐ Log both training and evaluation performance

3. Evaluation Phase
   ☐ Final evaluation on test set (never seen during training)
   ☐ Use sufficient episodes (50-100 minimum)
   ☐ Evaluate across all seeds
   ☐ Compute statistics (mean, std, CI, median, IQR)
   ☐ Test generalization (distribution shifts, zero-shot transfer)

4. Analysis Phase
   ☐ Compute sample efficiency metrics (AUC, reward at budgets)
   ☐ Statistical significance testing if comparing algorithms
   ☐ Check effect size (Cohen's d), not just p-value
   ☐ Identify failure cases and edge cases
   ☐ Measure robustness to perturbations

5. Reporting Phase
   ☐ Report all seeds, not selected subset
   ☐ Include mean ± std or 95% CI
   ☐ Show sample efficiency curves
   ☐ Report both training and generalization performance
   ☐ Specify evaluation mode
   ☐ Include negative results and failure analysis
   ☐ Provide reproducibility details (seeds, hyperparameters)
```

### Checklist for Publication/Deployment

```
Statistical Rigor:
☐ Minimum 10 seeds
☐ Mean ± std or 95% CI reported
☐ Statistical significance testing (if comparing algorithms)
☐ Effect size reported (Cohen's d)

Train/Test Discipline:
☐ Separate train/test environments
☐ Different random seeds for train/eval
☐ No evaluation on training data
☐ Generalization gap reported (train vs test performance)

Comprehensive Metrics:
☐ Final performance
☐ Sample efficiency curves
☐ Performance at multiple sample budgets
☐ Evaluation mode specified (stochastic/deterministic)

Generalization:
☐ Tested on distribution shifts
☐ Zero-shot transfer evaluation (if applicable)
☐ Robustness to perturbations

Methodology:
☐ Sufficient evaluation episodes (50-100+)
☐ Evaluation protocol clearly described
☐ Reproducibility details provided
☐ Negative results included

Offline RL (if applicable):
☐ Conservative offline metrics used
☐ Online validation included (or limitations clearly stated)
☐ Comparison to behavior cloning baseline
☐ Distribution shift acknowledged
```

---

## Integration with rl-debugging

RL evaluation and debugging are closely related:

**Use rl-debugging when:**

- Evaluation reveals poor performance
- Need to diagnose WHY agent fails
- Debugging training issues

**Use rl-evaluation when:**

- Agent seems to work, need to measure HOW WELL
- Comparing multiple algorithms
- Preparing for deployment

**Combined workflow:**

1. Train agent
2. Evaluate (rl-evaluation skill)
3. If performance poor → Debug (rl-debugging skill)
4. Fix issues
5. Re-evaluate
6. Repeat until satisfactory
7. Final rigorous evaluation for deployment

---

## Summary

RL evaluation is NOT just "run the agent and see what happens." It requires:

1. **Statistical rigor**: Multi-seed, confidence intervals, significance testing
2. **Train/test discipline**: Separate environments, no overfitting
3. **Comprehensive metrics**: Sample efficiency, generalization, robustness
4. **Appropriate protocols**: Evaluation mode, episode count, frequency
5. **Offline RL awareness**: Conservative estimates, staged deployment

Without rigorous evaluation:

- You will draw wrong conclusions from noise
- You will deploy agents that fail in production
- You will waste resources on false improvements
- You will make scientifically invalid claims

With rigorous evaluation:

- Reliable performance estimates
- Valid algorithm comparisons
- Deployment-ready agents
- Reproducible research

**When in doubt:** More seeds, more episodes, more generalization tests.

---

**END OF SKILL**
