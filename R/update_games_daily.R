#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(bigballR)
  library(dplyr)
  library(purrr)
  library(progress)
  library(glue)
})

## ---- CONFIG ---------------------------------------------------------------

season_label <- "2025-26"             # used in file names and cache folder
data_dir     <- "data"
cache_dir    <- file.path("cache", season_label)

dir.create(data_dir,  showWarnings = FALSE, recursive = TRUE)
dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)

# Teams for which you want a dedicated schedule_<Team>_<Season>.rds
teams_of_interest <- c("Arkansas")    # extend later if you like

# “Prior date games” — yesterday in UTC
target_date <- Sys.Date() - 1L
date_str    <- format(target_date, "%m/%d/%Y")

message("Updating games for ", date_str, " (", season_label, ")")

## ---- STEP 1: GET GAMES FOR YESTERDAY -------------------------------------

games_raw <- tryCatch(
  {
    bigballR::get_date_games(date = date_str)
  },
  error = function(e) {
    message("Failed to get games for ", date_str, ": ", conditionMessage(e))
    NULL
  }
)

if (is.null(games_raw) || nrow(games_raw) == 0L) {
  message("No games returned for ", date_str, ". Nothing to update.")
  quit(save = "no")
}

games_new <- games_raw %>%
  distinct(GameID, .keep_all = TRUE)

message("Games found on ", date_str, ": ", nrow(games_new))

## ---- STEP 2: UPDATE MASTER GAMES TABLE -----------------------------------

master_file <- file.path(data_dir, glue("games_master_{season_label}.rds"))

if (file.exists(master_file)) {
  games_master_old <- readRDS(master_file)
} else {
  games_master_old <- tibble()
}

games_master <- bind_rows(games_master_old, games_new) %>%
  distinct(GameID, .keep_all = TRUE)

saveRDS(games_master, master_file)
message("Master games table saved to: ",
        normalizePath(master_file, winslash = "/"))

## ---- STEP 3: UPDATE TEAM SCHEDULE FILES ----------------------------------

for (tm in teams_of_interest) {

  sched_file <- file.path(data_dir, glue("schedule_{tm}_{season_label}.rds"))

  # existing schedule (if any)
  if (file.exists(sched_file)) {
    sched_old <- readRDS(sched_file)
  } else {
    sched_old <- tibble()
  }

  # new games for this team yesterday
  sched_new <- games_new %>%
    filter(Home == tm | Away == tm) %>%
    mutate(
      opponent    = if_else(Home == tm, Away, Home),
      location    = if_else(Home == tm, "vs", "at"),
      label_game  = glue("{Date} {location} {opponent}")
      # you can add final_score later from PBP if you want
    )

  if (nrow(sched_new) == 0L) {
    message("  No games for ", tm, " on ", date_str, ".")
  } else {
    sched <- bind_rows(sched_old, sched_new) %>%
      distinct(GameID, .keep_all = TRUE)

    saveRDS(sched, sched_file)
    message("  Updated schedule for ", tm, " -> ",
            normalizePath(sched_file, winslash = "/"))
  }
}

## ---- STEP 4: CACHE PBP FOR NEW GAME IDS ----------------------------------

scrape_and_cache_game <- function(game_id, cache_dir) {
  out_file <- file.path(cache_dir, paste0(game_id, ".rds"))

  # Skip if already cached
  if (file.exists(out_file)) {
    return(invisible(FALSE))
  }

  pbp <- tryCatch(
    bigballR::get_play_by_play(game_ids = game_id),
    error = function(e) {
      message("\n  Error scraping GameID ", game_id, ": ", conditionMessage(e))
      NULL
    }
  )

  if (!is.null(pbp)) {
    saveRDS(pbp, out_file)
    return(invisible(TRUE))
  } else {
    return(invisible(FALSE))
  }
}

message("Scraping and caching play-by-play for yesterday's games...")

pb <- progress_bar$new(
  total   = nrow(games_new),
  clear   = FALSE,
  width   = 60,
  format  = "  scraping [:bar] :current/:total (:percent) eta: :eta"
)

for (gid in games_new$GameID) {
  pb$tick()
  scrape_and_cache_game(gid, cache_dir)
  Sys.sleep(0.3)  # polite delay
}

message("\nDone. Cached games are in: ",
        normalizePath(cache_dir, winslash = "/"))
