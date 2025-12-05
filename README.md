# README – Running the Arkansas Shift Chart Report

Basketball analytics and graphics production

This project contains a reproducible Quarto report that generates the shift-chart visualization (player on/off windows, PM per shift, and headshots) for the most recent Arkansas game.

The report is designed to run locally, without requiring live scraping, as long as the included data files are present.

1. Requirements
R

You will need R 4.2 or newer.

R Packages

Install these packages once:

```
install.packages(c(
  "dplyr","tidyr","stringr","forcats","glue","ggplot2",
  "ggimage","scales","ggtext","curl","purrr","stringdist","quarto"
))
```

If you do not have bigballR installed and want scraping capability later:

```
# optional — not required for offline version
# remotes::install_github("camlbg/bigballR")
```
# Quarto
Install Quarto from:
https://quarto.org/docs/get-started/

RStudio will automatically detect it once installed.

```
project/
│
├── shift_chart_latest_game.qmd         # Main report file
│
└── data/
    ├── mbb_rosters_25_26.rda           # Roster data
    ├── teamids.rda                     # Team ID lookup table
    └── team_sched_ark_2025-26.rds      # Pre-saved team schedule (avoids scraping)
```

