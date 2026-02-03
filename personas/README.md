# Personas

This folder contains simulated user personas used for the Personalized and Personalized+ evaluation conditions in GoalPref-Bench.

## Files

- **`generate_personas.R`**: Code to generate 500 diverse simulated personas
- **`all_personas_first_person.json`**: 500 pre-generated personas with demographics, personality traits, and natural language descriptions

## Persona Structure

Each persona contains:

### 1. Demographics
- Age range (18-24, 25-34, 35-44, 45-54, 55-64, 65+)
- Gender (Male, Female)
- Education level (High School, Some College, Bachelors, Postgraduate)
- Employment status (Employed, Unemployed, Student, Retired)
- Socioeconomic status (Low income, Middle income, Upper-middle income, High income)

### 2. Big Five Personality Traits
Each trait is rated as Low or High:
- **Openness**: Curiosity, creativity, preference for variety
- **Conscientiousness**: Organization, dependability, self-discipline
- **Extraversion**: Sociability, assertiveness, energy
- **Agreeableness**: Compassion, cooperation, trust
- **Neuroticism**: Emotional instability, anxiety, self-consciousness

### 3. Intelligence Measures
- **Emotional Intelligence**: Understanding and managing emotions (Low/High)
- **Fluid Intelligence**: Problem-solving and reasoning ability (Low/High)

### 4. Natural Language Description
A 100-150 word first-person narrative that integrates all traits into a coherent character description. Example:

> "You are a 28-year-old software engineer living in a bustling city. With high openness and conscientiousness, you constantly seek new challenges and maintain meticulous organization in both your code and personal life..."

## Usage

These personas are randomly assigned to scenarios in the Personalized and Personalized+ conditions to test how AI responses vary with user characteristics.

### In Personalized Condition
The persona profile is included in the system prompt to provide context about the user.

### In Personalized+ Condition
The persona is used to generate deeply personal, experience-based user challenges that draw from the user's background and circumstances.

## Generation

To regenerate personas:

1. Set your OpenAI API key:
   ```bash
   export OPENAI_API_KEY="your-key-here"
   ```

2. Run the generation script:
   ```r
   source('personas/generate_personas.R')
   ```

This creates 500 random persona profiles and uses GPT-4o to generate natural language descriptions.

## Citation

If you use these personas in your research, please cite the GoalPref-Bench paper.
