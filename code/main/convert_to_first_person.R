#-------------------------------------------------------------------------------
# Convert Goal-Preference Scenarios to First Person Using LLM
# Part of GoalPref-Bench
#-------------------------------------------------------------------------------

setwd("D:/Northeastern/personalization_simulation/GoalPref-Bench")

library(dplyr)
library(jsonlite)
library(httr)

#-------------------------------------------------------------------------------
# Load the scenarios
#-------------------------------------------------------------------------------

all_scenarios <- readRDS('data/goal_preference_scenarios.rds')

#-------------------------------------------------------------------------------
# Function to convert to first person using LLM
#-------------------------------------------------------------------------------

convert_to_first_person_llm <- function(goal_text, preference_text, model, verbose = FALSE) {

  prompt <- paste0(
    "Convert the following statements from second person to first person perspective.\n\n",
    "GOAL: ", goal_text, "\n\n",
    "PREFERENCE: ", preference_text, "\n\n",
    "Instructions:\n",
    "- Convert 'You' to 'I' and adjust verb conjugations appropriately\n",
    "- Convert 'your' to 'my'\n",
    "- Maintain the exact meaning and all specific details\n",
    "- Keep the same sentence structure and length\n",
    "- Do not add explanations or commentary\n\n",
    "Respond with valid JSON only in this exact format:\n",
    "{\n",
    '  "goal_first_person": "...",\n',
    '  "preference_first_person": "..."\n',
    "}\n"
  )

  # Clean the prompt
  cleaned_prompt <- prompt %>%
    gsub("[^\x20-\x7E\n]", " ", .) %>%
    trimws()

  # Get API key from environment variable
  api_key <- Sys.getenv("OPENROUTER_API_KEY")
  if (api_key == "") {
    stop("Please set OPENROUTER_API_KEY environment variable")
  }
  api_url <- "https://openrouter.ai/api/v1/chat/completions"

  # Make API request with retry logic
  max_retries <- 3
  retry_count <- 0

  while (retry_count < max_retries) {
    tryCatch({
      body <- list(
        model = model,
        messages = list(list(role = "user", content = cleaned_prompt)),
        max_tokens = 500,
        temperature = 0.1
      )

      response <- suppressMessages(
        POST(
          url = api_url,
          add_headers(
            "Authorization" = paste("Bearer", api_key),
            "Content-Type" = "application/json",
            "HTTP-Referer" = "https://your-site.com",
            "X-Title" = "First Person Conversion"
          ),
          body = toJSON(body, auto_unbox = TRUE),
          encode = "json",
          timeout(60)
        )
      )

      # Handle rate limiting
      if (response$status_code == 429) {
        retry_count <- retry_count + 1
        if (retry_count < max_retries) {
          wait_time <- 2^retry_count
          cat("Rate limited. Waiting", wait_time, "seconds...\n")
          Sys.sleep(wait_time)
        } else {
          cat("Max retries reached for rate limiting.\n")
          return(list(goal = NA, preference = NA))
        }
      } else if (response$status_code == 200) {
        content <- suppressWarnings(fromJSON(rawToChar(response$content)))

        # Extract message content
        message_content <- NULL

        if (is.list(content) && "choices" %in% names(content)) {
          choices <- content$choices

          if (is.data.frame(choices) && nrow(choices) > 0 && "message" %in% names(choices)) {
            message_df <- choices$message
            if (is.data.frame(message_df) && "content" %in% names(message_df)) {
              message_content <- message_df$content[1]
            }
          }
        }

        if (is.null(message_content) || is.na(message_content) || message_content == "") {
          cat("Could not extract message content\n")
          return(list(goal = NA, preference = NA))
        }

        if (verbose) {
          cat("\n--- Raw Response ---\n")
          cat(message_content, "\n")
          cat("--- End Raw Response ---\n\n")
        }

        # Try to extract JSON if wrapped in markdown code blocks
        if (grepl("```json", message_content, fixed = TRUE)) {
          message_content <- gsub("```json\\s*", "", message_content)
          message_content <- gsub("```\\s*$", "", message_content)
        } else if (grepl("```", message_content, fixed = TRUE)) {
          message_content <- gsub("```\\s*", "", message_content)
          message_content <- gsub("```\\s*$", "", message_content)
        }

        message_content <- trimws(message_content)

        # Parse the JSON response
        converted <- tryCatch({
          parsed <- fromJSON(message_content)

          if (!all(c("goal_first_person", "preference_first_person") %in% names(parsed))) {
            cat("Missing required fields\n")
            return(list(goal = NA, preference = NA))
          }

          list(
            goal = parsed$goal_first_person,
            preference = parsed$preference_first_person
          )
        }, error = function(e) {
          cat("Failed to parse JSON response. Error:", e$message, "\n")
          return(list(goal = NA, preference = NA))
        })

        return(converted)

      } else {
        cat("API error. Status code:", response$status_code, "\n")
        return(list(goal = NA, preference = NA))
      }

    }, error = function(e) {
      cat("Error occurred:", e$message, "\n")
      retry_count <- retry_count + 1
      if (retry_count < max_retries) {
        cat("Retrying in 2 seconds...\n")
        Sys.sleep(2)
      } else {
        return(list(goal = NA, preference = NA))
      }
    })
  }

  return(list(goal = NA, preference = NA))
}

#-------------------------------------------------------------------------------
# Process all scenarios
#-------------------------------------------------------------------------------

# Choose your model
model_name_full <- "openai/gpt-4o"
model_name <- sub(".*/", "", model_name_full)

# Create dataframe to store results
scenarios_df <- data.frame(
  scenario_id = seq_along(all_scenarios),
  conflict_domain = character(length(all_scenarios)),
  human_goal_original = character(length(all_scenarios)),
  human_preference_original = character(length(all_scenarios)),
  human_goal_first_person = character(length(all_scenarios)),
  human_preference_first_person = character(length(all_scenarios)),
  stringsAsFactors = FALSE
)

cat("\n========================================\n")
cat("Converting", length(all_scenarios), "scenarios to first person\n")
cat("Using model:", model_name_full, "\n")
cat("========================================\n\n")

for (i in seq_along(all_scenarios)) {
  cat("Processing scenario", i, "of", length(all_scenarios), "\n")

  scenario <- all_scenarios[[i]]
  scenarios_df$conflict_domain[i] <- scenario$conflict_domain

  if (!is.null(scenario$scenario_data) && !is.na(scenario$scenario_data)) {
    goal_orig <- scenario$scenario_data$human_goal
    pref_orig <- scenario$scenario_data$human_preference

    if (!is.null(goal_orig) && !is.null(pref_orig)) {
      scenarios_df$human_goal_original[i] <- goal_orig
      scenarios_df$human_preference_original[i] <- pref_orig

      # Convert using LLM
      converted <- convert_to_first_person_llm(
        goal_orig,
        pref_orig,
        model = model_name_full,
        verbose = FALSE
      )

      scenarios_df$human_goal_first_person[i] <- converted$goal
      scenarios_df$human_preference_first_person[i] <- converted$preference

      if (!is.na(converted$goal)) {
        cat("✓ Success\n")
      } else {
        cat("✗ Failed\n")
      }
    } else {
      cat("✗ Missing original data\n")
    }
  } else {
    cat("✗ No scenario data\n")
  }

  # Rate limiting delay
  Sys.sleep(1)
}

#-------------------------------------------------------------------------------
# Retry failed conversions
#-------------------------------------------------------------------------------

failed_indices <- which(is.na(scenarios_df$human_goal_first_person) &
                          !is.na(scenarios_df$human_goal_original))

if (length(failed_indices) > 0) {
  cat("\n========================================\n")
  cat("Retrying", length(failed_indices), "failed conversions\n")
  cat("========================================\n\n")

  for (idx in failed_indices) {
    cat("Retrying scenario", idx, "\n")

    converted <- convert_to_first_person_llm(
      scenarios_df$human_goal_original[idx],
      scenarios_df$human_preference_original[idx],
      model = model_name_full,
      verbose = FALSE
    )

    scenarios_df$human_goal_first_person[idx] <- converted$goal
    scenarios_df$human_preference_first_person[idx] <- converted$preference

    Sys.sleep(1)
  }
}

#-------------------------------------------------------------------------------
# Display sample results
#-------------------------------------------------------------------------------

cat("\n========================================\n")
cat("Sample Conversions (First 3):\n")
cat("========================================\n\n")

for (i in 1:min(3, nrow(scenarios_df))) {
  if (!is.na(scenarios_df$human_goal_first_person[i])) {
    cat("Scenario", i, "\n")
    cat("Domain:", substr(scenarios_df$conflict_domain[i], 1, 60), "...\n\n")

    cat("GOAL (Original):\n", scenarios_df$human_goal_original[i], "\n\n")
    cat("GOAL (1st Person):\n", scenarios_df$human_goal_first_person[i], "\n\n")

    cat("PREFERENCE (Original):\n", scenarios_df$human_preference_original[i], "\n\n")
    cat("PREFERENCE (1st Person):\n", scenarios_df$human_preference_first_person[i], "\n")
    cat("\n---\n\n")
  }
}

#-------------------------------------------------------------------------------
# Save final results
#-------------------------------------------------------------------------------

# Save as CSV
write.csv(scenarios_df, 'data/scenarios_first_person.csv', row.names = FALSE)

# Save as RDS
saveRDS(scenarios_df, 'data/scenarios_first_person.rds')

# Save as JSON
json_output <- toJSON(scenarios_df, pretty = TRUE)
writeLines(json_output, 'data/scenarios_first_person.json')

cat("\n========================================\n")
cat("Conversion complete!\n")
cat("Files saved:\n")
cat("- data/scenarios_first_person.csv\n")
cat("- data/scenarios_first_person.rds\n")
cat("- data/scenarios_first_person.json\n")
cat("========================================\n")
