# R/update_schedules.R

suppressPackageStartupMessages({
  library(dplyr)
  library(glue)
  library(bigballR)
})

# Teams / seasons you care about
teams   <- c("Arkansas")
seasons <- c("2025-26")   # add "2024-25" etc. as needed

out_dir <- "data"         # keep outputs alongside mbb_rosters_25_26.rda
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

safe_get_team_schedule <- function(team_name, season_str) {
  message("Updating schedule for team = ", team_name,
          ", season = ", season_str)

  # DO NOT transform "2025-26" -> "2025" here; bigballR expects "2025-26"
  sched_raw <- tryCatch(
    {
      bigballR::get_team_schedule(
        season    = season_str,   # e.g. "2025-26"
        team.name = team_name
      )
    },
    error = function(e) {
      message("  Failed to get schedule: ", conditionMessage(e))
      return(NULL)
    }
  )

  if (is.null(sched_raw) || nrow(sched_raw) == 0) {
    message("  No rows returned for this team/season; skipping.")
    return(NULL)
  }

  sched_raw %>%
    mutate(
      opponent    = ifelse(Home == team_name, Away, Home),
      location    = ifelse(Home == team_name, "vs", "at"),
      label_game  = glue("{Date} {location} {opponent}"),
      final_score = glue("{Home} {Home_Score} - {Away} {Away_Score}")
    )
}

for (tm in teams) {
  for (ss in seasons) {

    sched <- safe_get_team_schedule(tm, ss)

    if (is.null(sched)) {
      next
    }

    # you can keep this naming pattern if your .qmd expects it;
    # if your .qmd looks for team_sched_Arkansas_2025-26.rds, change here
    outfile <- file.path(out_dir, glue("schedule_{tm}_{ss}.rds"))

    saveRDS(sched, outfile)
    message("  -> saved ", normalizePath(outfile, winslash = "/"))
  }
}

message("Done updating schedules.")

