# GoalPref-Bench Release Checklist

## ✅ Completed

### Data
- [x] Converted ai_sycophancy_scenarios.rds to CSV and JSON
- [x] Removed `misaligned_incentive` field
- [x] Renamed `info_not_known` → `key_information`
- [x] 250 scenarios ready in both formats

### Code
- [x] Removed all hardcoded API keys
- [x] Updated all code to use `key_information`
- [x] Scenario generation code (generate_scenarios.R)
- [x] Response generation code (generate_responses.R)
- [x] Multi-turn evaluation code (goal_multiturn_challenge.R)
- [x] First-person conversion code (convert_to_first_person.R)

### Documentation
- [x] Comprehensive README.md matching paper
- [x] CHANGES.md documenting modifications
- [x] SETUP_SUMMARY.md with technical details
- [x] QUICKSTART.md for new users
- [x] .gitignore for version control

## ⚠️ Before Publishing

### Required
- [x] Add LICENSE file (MIT)
- [ ] Update README.md with actual GitHub URL
- [ ] Update README.md with contact email
- [ ] Test fresh clone on clean machine
- [ ] Create `results/.gitkeep` to preserve directory

### Recommended
- [ ] Add CONTRIBUTING.md with contribution guidelines
- [ ] Create example notebook (Jupyter or R Markdown)
- [ ] Add sample outputs in examples/ directory
- [ ] Create GitHub Actions for testing
- [ ] Add issue templates
- [ ] Create release notes for v1.0

### Optional
- [ ] Add visualization scripts
- [ ] Create interactive demo (Streamlit/Shiny)
- [ ] Add pre-computed results for comparison
- [ ] Create Docker container for reproducibility

## Publishing Platform

### GitHub Only

```
Repository: github.com/seanwkelley/GoalPref-Bench
Purpose: Code, documentation, data, issues, collaboration
```

**What to include**:
- Full repository with code
- Dataset in `data/` (CSV and JSON formats)
- Documentation
- Issues for bug reports
- Discussions for Q&A

**GitHub Advantages**:
- ✅ Better for code repositories
- ✅ Issues and pull requests
- ✅ GitHub Actions for CI/CD
- ✅ Better README rendering
- ✅ More familiar to researchers
- ✅ Can host both code and data

## File Structure

```
GoalPref-Bench/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── workflows/
│       └── test.yml
├── code/
│   ├── main/
│   │   ├── generate_scenarios.R
│   │   ├── generate_responses.R
│   │   ├── evaluate_alignment.R
│   │   └── convert_to_first_person.R
│   └── multiturn/
│       ├── goal_multiturn_challenge.R
│       └── goal_multiturn_personalized_plus.R
├── data/
│   ├── goal_preference_scenarios.csv
│   ├── goal_preference_scenarios.json
│   └── README.md  # Dataset description
├── examples/
│   ├── quick_start.R
│   └── analysis_example.R
├── results/
│   └── .gitkeep
├── .gitignore
├── CHANGES.md
├── CONTRIBUTING.md
├── LICENSE
├── QUICKSTART.md
├── README.md
├── RELEASE_CHECKLIST.md  # This file
└── SETUP_SUMMARY.md
```

## Publishing Steps

### GitHub

1. **Initialize repository**:
   ```bash
   cd GoalPref-Bench
   git init
   git add .
   git commit -m "Initial release: GoalPref-Bench v1.0"
   ```

2. **Create GitHub repository**:
   - Go to github.com/new
   - Name: `GoalPref-Bench`
   - Description: "Benchmark for evaluating goal-preference alignment in LLMs"
   - Public
   - No README (we have one)

3. **Push to GitHub**:
   ```bash
   git remote add origin https://github.com/seanwkelley/GoalPref-Bench.git
   git branch -M main
   git push -u origin main
   ```

4. **Configure repository**:
   - Add topics: `llm`, `benchmark`, `alignment`, `sycophancy`, `personalization`
   - Set repository image
   - Enable Issues and Discussions
   - Add repository description
   - Pin README.md

5. **Create release**:
   - Tag: v1.0.0
   - Title: "GoalPref-Bench v1.0: Initial Release"
   - Description: Include key features and link to paper

## Post-Publication

### Announce
- [ ] Post on Twitter/X with paper link
- [ ] Post on Reddit (r/MachineLearning)
- [ ] Share in relevant Slack/Discord communities
- [ ] Email to relevant researchers
- [ ] Add to Papers With Code

### Monitor
- [ ] Watch GitHub issues
- [ ] Respond to questions
- [ ] Track citations
- [ ] Update documentation based on feedback

### Maintain
- [ ] Fix bugs promptly
- [ ] Review pull requests
- [ ] Add examples based on user requests
- [ ] Update with new findings

## Version 1.0 Goals

**Minimum Viable Release**:
- ✅ Dataset available and documented
- ✅ Code for generating responses
- ✅ Code for multi-turn evaluation
- ✅ Clear usage instructions
- ⚠️  Testing on fresh install

**Success Metrics**:
- GitHub stars: 50+ in first month
- Issues opened: 5-10 (indicates usage)
- Forks: 10+ (indicates adoption)
- Citations: Track via Google Scholar

## Future Versions

**v1.1** (1 month):
- Add more detailed examples
- Include pre-computed baselines
- Add analysis scripts from paper

**v1.2** (3 months):
- Support for other LLM providers
- Python implementation
- Automated evaluation pipeline

**v2.0** (6 months):
- Extended scenarios (500+)
- Additional conflict domains
- Multi-language support

## Decisions Made

1. **License**: ✅ MIT License
2. **Authors**: ✅ Sean Kelley, Christoph Riedl
3. **Contact**: ✅ se.kelley@northeastern.edu
4. **Repository**: ✅ github.com/seanwkelley/GoalPref-Bench
5. **Platform**: ✅ GitHub only (no HuggingFace)

## Ready to Publish?

Run through this checklist:

1. ✅ All code has no hardcoded secrets
2. ✅ Dataset is in standard format (CSV/JSON)
3. ✅ Documentation is complete
4. ✅ LICENSE file added (MIT)
5. ⚠️  Tested on fresh clone
6. ⚠️  GitHub repository created
7. ⬜ Announcement prepared

**Once items 1-6 are complete: Ready to publish!**

## Support

For questions about this checklist:
- See SETUP_SUMMARY.md for technical details
- See QUICKSTART.md for testing
- See README.md for user-facing documentation
