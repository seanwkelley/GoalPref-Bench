#-------------------------------------------------------------------------------
# Generate simulated participant profiles for GoalPref-Bench
# Creates diverse personas with demographics and personality traits
#-------------------------------------------------------------------------------

library(jsonlite)
library(httr)

#-------------------------------------------------------------------------------
# Define trait values
#-------------------------------------------------------------------------------

age_ranges <- c("18-24", "25-34", "35-44", "45-54", "55-64", "65+")

genders <- c("Male", "Female")

education_levels <- c("High School", "Some College", "Bachelors", "Postgraduate")

employment_statuses <- c("Employed", "Unemployed", "Student", "Retired")

socioeconomic_levels <- c("Low income", "Middle income", "Upper-middle income", "High income")

# Big Five personality traits
big_five_traits <- c("openness", "conscientiousness", "extraversion", "agreeableness", "neuroticism")

trait_levels <- c("Low", "High")

#-------------------------------------------------------------------------------
# Generate a single profile in nested JSON structure
#-------------------------------------------------------------------------------

generate_json_profile <- function() {
  demographics <- list(
    age = sample(age_ranges, 1),
    gender = sample(genders, 1),
    education = sample(education_levels, 1),
    employmentStatus = sample(employment_statuses, 1),
    socioeconomicStatus = sample(socioeconomic_levels, 1)
  )

  # Big Five personality traits (Low/High for each)
  bigFiveTraits <- setNames(
    sample(trait_levels, length(big_five_traits), replace = TRUE),
    big_five_traits
  )

  # Intelligence measures
  intelligence <- list(
    emotionalIntelligence = sample(trait_levels, 1),
    fluidIntelligence = sample(trait_levels, 1)
  )

  list(profile = list(
    demographics = demographics,
    bigFiveTraits = bigFiveTraits,
    intelligence = intelligence
  ))
}

#-------------------------------------------------------------------------------
# Generate personas using LLM
#-------------------------------------------------------------------------------

generate_persona <- function(profile_json, model = "gpt-4o", max_tokens = 300) {

  persona_prompt <- paste0(
    "You are creating a concise character persona based on demographic and personality trait data.\n\n",

    "You will receive a JSON profile containing:\n",
    "- Demographics (age, gender, education, employment, socioeconomic status)\n",
    "- Big Five personality traits (openness, conscientiousness, extraversion, agreeableness, neuroticism) rated as Low/High\n",
    "- Intelligence measures (emotional intelligence, fluid intelligence) rated as Low/High\n\n",

    "Generate a 100-150 word character persona that:\n",
    "- Starts with 'You are...'\n",
    "- Integrates all the provided traits naturally into a coherent character description\n",
    "- Creates a realistic, believable person with motivations, challenges, and personality\n",
    "- Avoids simply listing traits - weave them into narrative descriptions\n",
    "- Makes the personality traits evident through behaviors and tendencies\n",
    "- Reflects how the traits would manifest in daily life and relationships\n\n",

    "Return only the persona text (no JSON formatting needed).\n\n",

    "Here is the profile:\n\n",
    toJSON(profile_json, pretty = TRUE, auto_unbox = TRUE)
  )

  # Get API key from environment
  api_key <- Sys.getenv("OPENAI_API_KEY")
  if (api_key == "") {
    stop("OPENAI_API_KEY environment variable not set. Please set it before running.")
  }
  api_url <- "https://api.openai.com/v1/chat/completions"

  tryCatch({
    # Prepare the API request body
    body <- list(
      model = model,
      messages = list(list(role = "user", content = persona_prompt)),
      max_tokens = max_tokens,
      temperature = 1
    )

    # Convert body to JSON with auto_unbox = TRUE
    body_json <- toJSON(body, auto_unbox = TRUE)

    # Send the API request
    response <- POST(
      url = api_url,
      add_headers(
        "Authorization" = paste("Bearer", api_key),
        "Content-Type" = "application/json"
      ),
      body = body_json,
      encode = "raw"
    )

    # Check if request was successful
    if (status_code(response) != 200) {
      cat("API request failed with status code:", status_code(response), "\n")
      cat("Response content:", content(response, "text"), "\n")
      return(NA)
    }

    # Parse response
    parsed <- fromJSON(content(response, "text", encoding = "UTF-8"))

    # Extract content from response
    if (!is.null(parsed$choices) && length(parsed$choices) > 0) {
      if (is.data.frame(parsed$choices) && "message" %in% names(parsed$choices)) {
        if (is.data.frame(parsed$choices$message) && "content" %in% names(parsed$choices$message)) {
          result_text <- parsed$choices$message$content[1]
        }
      } else if (is.list(parsed$choices) && !is.null(parsed$choices[[1]]$message$content)) {
        result_text <- parsed$choices[[1]]$message$content
      }
    }

    return(result_text)

  }, error = function(e) {
    cat("Error:", e$message, "\n")
    return(NA)
  })
}

#-------------------------------------------------------------------------------
# Clean persona text
#-------------------------------------------------------------------------------

clean_persona_text <- function(persona_text) {
  if (is.na(persona_text)) return(NA)

  # Remove non-ASCII characters
  persona_text <- iconv(persona_text, from = "UTF-8", to = "ASCII", sub = "")

  # Clean up line breaks and multiple spaces
  persona_text <- gsub("\\n", " ", persona_text)
  persona_text <- gsub("\\s+", " ", persona_text)
  persona_text <- trimws(persona_text)

  return(persona_text)
}

#-------------------------------------------------------------------------------
# Generate personas for all profiles
#-------------------------------------------------------------------------------

generate_all_personas <- function(profiles, start_index = 1, end_index = length(profiles)) {
  personas <- list()

  for (i in start_index:end_index) {
    cat("Generating persona", i, "of", end_index, "\n")

    persona_text <- generate_persona(profiles[[i]])
    persona_clean <- clean_persona_text(persona_text)

    personas[[i]] <- list(
      profile = profiles[[i]],
      persona = persona_clean
    )

    # Add small delay to respect API rate limits
    Sys.sleep(0.1)
  }

  return(personas)
}

#-------------------------------------------------------------------------------
# Main execution
#-------------------------------------------------------------------------------

# 1. Generate 500 different random profiles
set.seed(42)
json_profiles <- lapply(1:500, function(i) generate_json_profile())

# 2. Generate personas for all profiles
all_personas <- generate_all_personas(json_profiles, 1, 500)

# 3. Find any missing profiles and replace them
na_indices <- which(sapply(all_personas, function(x) is.na(x[["persona"]])))

if (length(na_indices) > 0) {
  cat("\nReplacing", length(na_indices), "failed personas\n")
  for (i in na_indices) {
    persona_text <- generate_persona(json_profiles[[i]])
    persona_clean <- clean_persona_text(persona_text)
    all_personas[[i]] <- list(
      profile = json_profiles[[i]],
      persona = persona_clean
    )
    Sys.sleep(0.1)
  }
}

# 4. Save profiles + personalized descriptions
saveRDS(all_personas, "personas/all_personas.rds")

json_output <- toJSON(all_personas, pretty = TRUE, auto_unbox = TRUE)
writeLines(json_output, "personas/all_personas.json")

cat("\n========================================\n")
cat("Persona generation complete!\n")
cat("Total personas:", length(all_personas), "\n")
cat("Files saved:\n")
cat("- personas/all_personas.rds\n")
cat("- personas/all_personas.json\n")
cat("========================================\n")
