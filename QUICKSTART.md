# Quick Start Guide

Get started with GoalPref-Bench in 5 minutes!

## Step 1: Setup (2 minutes)

```bash
# Clone repository
git clone https://github.com/seanwkelley/GoalPref-Bench.git
cd GoalPref-Bench

# Set API key
export OPENROUTER_API_KEY="your-key-here"
```

In R:
```r
# Install dependencies
install.packages(c("jsonlite", "httr", "dplyr"))
```

## Step 2: Load Data (30 seconds)

```r
library(jsonlite)

# Load scenarios
scenarios <- read.csv('data/goal_preference_scenarios.csv')

# View first scenario
print(scenarios[1, c('scenario_id', 'conflict_domain', 'human_goal', 'human_preference')])

# Output:
#   scenario_id                            conflict_domain
# 1           1  Debt Elimination vs. Lifestyle Maintenance
#         human_goal                                    human_preference
# 1  I genuinely... I strongly prefer to maintain my current lifestyle...
```

## Step 3: Generate Responses (2 minutes for 3 scenarios)

```r
setwd("path/to/GoalPref-Bench")  # Update this
source('code/main/generate_responses.R')

# Test on 3 scenarios
results <- generate_all_responses(
  scenarios = scenarios,
  model = "openai/gpt-4o-mini",  # Cheaper for testing
  n_scenarios = 3
)

# View results
head(results)
```

## Step 4: Inspect Results

```r
# Compare generic vs personalized for first scenario
cat("\nGeneric Response:\n")
cat(results$generic_response[1])

cat("\n\nPersonalized Response:\n")
cat(results$personalized_response[1])
```

## Step 4.5: Evaluate Alignment (Optional)

```r
source('code/main/evaluate_alignment.R')

# Evaluate which responses are more goal-aligned
# Uses gpt-4o-mini as judge (~$0.02 for 3 scenarios)
evaluation <- evaluate_all_responses(
  responses_df = results,
  scenarios = scenarios,
  judge_model = "openai/gpt-4o-mini"
)

# View results
head(evaluation)
```

## Step 5: Multi-Turn Evaluation (Optional)

**Standard Multi-Turn:**
```r
source('code/multiturn/goal_multiturn_challenge.R')

# Run 3 scenarios, 5 rounds each
multiturn_results <- run_multiturn_evaluation(
  scenarios = scenarios,
  model = "openai/gpt-4o-mini",
  n_scenarios = 3,
  n_rounds = 5
)
```

**Personalized+ Multi-Turn (with personal experiences):**
```r
source('code/multiturn/goal_multiturn_personalized_plus.R')

# Load profiles (you'll need a personas file)
profiles <- fromJSON('path/to/personas.json')

# Run Personalized+ evaluation
personalized_plus_results <- run_personalized_plus_evaluation(
  scenarios = scenarios,
  profiles = profiles,
  model = "openai/gpt-4o-mini",
  n_scenarios = 3,
  n_rounds = 5
)
```

## What's Next?

### For Research
- Run full evaluation (250 scenarios)
- Compare multiple models
- Analyze affective vs epistemic alignment

### For Development
- Generate new scenarios for your domain
- Modify evaluation prompts
- Add new treatment conditions

### For Understanding
- Read the paper (see README)
- Explore different conflict domains
- Examine multi-turn position changes

## Common Issues

**"API key not found"**
```bash
# Make sure to export it
export OPENROUTER_API_KEY="sk-or-v1-..."

# Or in R
Sys.setenv(OPENROUTER_API_KEY = "sk-or-v1-...")
```

**"Rate limited"**
- Code has automatic retry logic
- It will wait and retry automatically
- Reduce n_scenarios if hitting limits frequently

**"Out of memory"**
- Process scenarios in batches
- Save intermediate results
- Use smaller max_tokens

## Cost Management

**Testing** (3 scenarios):
- Cost: ~$0.05-0.10
- Time: ~2 minutes

**Small evaluation** (25 scenarios):
- Cost: ~$1-2
- Time: ~15-20 minutes

**Full evaluation** (250 scenarios):
- Cost: ~$15-25 per model
- Time: ~2-3 hours

**Tip**: Start small, verify output quality, then scale up!

## Example: Analyze One Scenario in Depth

```r
# Load data
scenarios <- read.csv('data/goal_preference_scenarios.csv')

# Pick an interesting scenario
scenario <- scenarios[scenarios$conflict_domain ==
  "Debt Elimination vs. Lifestyle Maintenance", ]

# Display all fields
cat("Scenario:", scenario$scenario, "\n\n")
cat("Human Goal:", scenario$human_goal, "\n\n")
cat("Human Preference:", scenario$human_preference, "\n\n")
cat("AI Goal:", scenario$ai_agent_goal, "\n\n")
cat("Key Information:", scenario$key_information, "\n\n")

# Generate responses
source('code/main/generate_responses.R')

# Create mini-dataset with just this scenario
mini_df <- scenario[1, ]

results <- generate_all_responses(
  scenarios = mini_df,
  model = "openai/gpt-4o-mini",
  n_scenarios = 1
)

# Compare responses
cat("\n=== GENERIC ===\n")
cat(results$generic_response[1])

cat("\n\n=== PERSONALIZED ===\n")
cat(results$personalized_response[1])
```

## Next Steps

1. ✅ Tested basic loading
2. ✅ Generated first responses
3. ⬜ Run full evaluation
4. ⬜ Compare models
5. ⬜ Analyze results
6. ⬜ Publish findings

## Need Help?

- 📖 Read the full [README.md](README.md)
- 🔧 Check [SETUP_SUMMARY.md](SETUP_SUMMARY.md) for details
- 💬 Open an issue on GitHub
- 📧 Contact the authors

---

**Ready to go?** Start with 3 scenarios and build from there!
