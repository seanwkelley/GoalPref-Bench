# Changes Made for GoalPref-Bench

This document outlines the modifications made to the original code for presentation as GoalPref-Bench.

## Changes

### 1. Removed Hardcoded API Keys
- **Files affected**: All .R files
- **Change**: Replaced hardcoded OpenRouter API keys with environment variable lookup
- **Implementation**: `api_key <- Sys.getenv("OPENROUTER_API_KEY")`
- **Reason**: Security best practice - API keys should never be hardcoded

### 2. Renamed "INFO NOT KNOWN" to "Key Information"
- **Files affected**:
  - `code/main/generate_scenarios.R`
  - `code/multiturn/goal_multiturn_challenge.R`
- **Original**: `"### 5. INFO NOT KNOWN (2-4 sentences)\n"` / `info_not_known`
- **New**: `"### Key Information (2-4 sentences)\n"` / `key_information`
- **Reason**: More professional and clear naming for benchmark presentation

### 3. Removed "MISALIGNED INCENTIVE" Field
- **Files affected**: `code/main/generate_scenarios.R`
- **Changes made**:
  - Removed from scenario generation prompt (was section 8)
  - Removed from required fields validation
  - Removed from JSON output format
- **Reason**: Simplified scenario structure by removing this optional metadata field

### 4. Updated File Paths
- **Original paths**: Referenced parent directory structure
- **New paths**: Self-contained within GoalPref-Bench directory
- **Examples**:
  - Data: `data/goal_preference_scenarios.csv` and `.json`
  - Results: `results/multiturn_detailed_{model}.csv`

### 5. Fixed Corrupted Code Section
- **File**: `code/multiturn/goal_multiturn_challenge.R`
- **Issue**: Lines 260-264 contained corrupted `source()` call
- **Fix**: Implemented proper challenge prompt generation based on scenario data
- **New implementation**: Clear prompt construction for user challenges that push back against AI advice

### 6. Enhanced Documentation
- **Added**: Comprehensive README.md
- **Added**: This CHANGES.md document
- **Content**: Usage instructions, setup guide, citation information

### 7. Simplified Multi-Turn Evaluation
- **Removed**: Personalized condition from main multiturn file (can be added separately)
- **Focus**: Generic evaluation of goal alignment under pressure
- **Progress saving**: Added periodic progress saves every 10 scenarios

### 8. Standardized File Naming
- **Renamed files for clarity**:
  - `AI_Liedar_adaptation.R` → `generate_scenarios.R`
  - `extract_human_preference.R` → `convert_to_first_person.R`
  - `ai_sycophancy_scenarios.*` → `goal_preference_scenarios.*`
- **Added CSV export**: Scenario generation now saves to RDS, JSON, and CSV formats
- **Consistent terminology**: All references updated to use "goal_preference" naming

## File Structure

```
GoalPref-Bench/
├── README.md               # Main documentation
├── CHANGES.md             # This file
├── data/
│   ├── goal_preference_scenarios.csv    # Main dataset (CSV)
│   └── goal_preference_scenarios.json   # Main dataset (JSON)
├── code/
│   ├── main/
│   │   ├── generate_scenarios.R         # Scenario generation
│   │   ├── generate_responses.R         # Generic/personalized responses
│   │   ├── evaluate_alignment.R         # LLM-as-judge (gpt-4o-mini)
│   │   └── convert_to_first_person.R    # First-person conversion
│   └── multiturn/
│       ├── goal_multiturn_challenge.R   # Multi-turn (Generic & Personalized)
│       └── goal_multiturn_personalized_plus.R  # Personalized+ with experiences
│       └── goal_multiturn_challenge.R    # Multi-turn evaluation
└── results/                # Output directory
```

## Environment Setup Required

Before running the code, set your API key:

```bash
# Unix/Mac
export OPENROUTER_API_KEY="your-key-here"

# Windows
set OPENROUTER_API_KEY=your-key-here

# Or add to .Renviron file:
OPENROUTER_API_KEY=your-key-here
```

## Backward Compatibility

The data format remains compatible with the original scenarios. The only schema change is the removal of the optional `misaligned_incentive` field from newly generated scenarios. Existing scenarios that include this field will still work correctly.

## Testing

After making these changes:
1. Verify API key environment variable is set
2. Test scenario loading: `scenarios <- read.csv('data/goal_preference_scenarios.csv')`
3. Test response generation (optional - requires API access)
4. Test alignment evaluation (optional - requires API access)
5. Test multi-turn evaluation (optional - requires API access)

## Notes

- All API calls include retry logic for rate limiting
- Progress is saved periodically to prevent data loss
- Working directory should be set to `GoalPref-Bench/` for paths to work correctly
