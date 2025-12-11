#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(glue)
library(purrr)
library(bigballR)

dir.create("cache", showWarnings = FALSE)

load("teamids.rda")   # or "data/teamids.rda"
# now 'teamids' is available in your script

make_schedule_cache_for_team <- function(team_id,
                                         teamids,
                                         cache_dir = "cache") {
  row <- teamids %>% dplyr::filter(ID == !!team_id)
  if (nrow(row) == 0L) {
    message(glue("ID {team_id} not found in teamids; skipping."))
    return(invisible(NULL))
  }

  team_name <- row$Team[1]
  season    <- row$Season[1]

  message("Pulling schedule for ", team_name, " (", season, ") ...")

  sched_raw <- try(
    bigballR::get_team_schedule(team.id = team_id),
    silent = TRUE
  )

  if (inherits(sched_raw, "try-error") || is.null(sched_raw) || nrow(sched_raw) == 0) {
    message("  -> failed or empty schedule; skipping ", team_name)
    return(invisible(NULL))
  }

  sched_norm <- sched_raw %>%
    mutate(
      Date       = as.character(Date),
      Home       = as.character(Home),
      Away       = as.character(Away),
      Home_Score = readr::parse_number(Home_Score),
      Away_Score = readr::parse_number(Away_Score),
      Game_ID    = as.character(Game_ID),
      isNeutral  = as.logical(isNeutral),
      Box_ID     = as.character(Box_ID),
      Detail     = as.character(Detail),
      Attendance = as.numeric(Attendance)
    ) %>%
    select(
      Date, Home, Home_Score, Away, Away_Score,
      Game_ID, isNeutral, Box_ID, Detail, Attendance
    )

  out_path <- file.path(cache_dir, glue("schedule_{team_id}.csv"))
  readr::write_csv(sched_norm, out_path, na = "")

  message("  -> wrote: ", out_path)
  invisible(out_path)
}

teamids_2526 <- teamids %>%
  filter(Season == "2025-26") %>%
  distinct(ID, .keep_all = TRUE)

purrr::walk(teamids_2526$ID, ~make_schedule_cache_for_team(.x, teamids))

