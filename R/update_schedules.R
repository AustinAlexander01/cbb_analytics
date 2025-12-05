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

for (tm in teams) {
  for (ss in seasons) {

    api_season <- if (grepl("-", ss)) sub("-.*", "", ss) else ss

    message("Updating schedule for team = ", tm, ", season = ", ss,
            " (API season = ", api_season, ")")

    sched_raw <- bigballR::get_team_schedule(
      season    = api_season,
      team.name = tm
    )

    # add the helper columns your .qmd expects
    sched <- sched_raw %>%
      mutate(
        opponent    = ifelse(Home == tm, Away, Home),
        location    = ifelse(Home == tm, "vs", "at"),
        label_game  = glue("{Date} {location} {opponent}"),
        final_score = glue("{Home} {Home_Score} - {Away} {Away_Score}")
      )

    outfile <- file.path(out_dir, glue("schedule_{tm}_{ss}.rds"))
    saveRDS(sched, outfile)
    message("  -> saved ", normalizePath(outfile, winslash = "/"))
  }
}
