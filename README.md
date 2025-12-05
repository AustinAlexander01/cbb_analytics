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


# 3. Running the Report
Step 1 — Open the .qmd file

In RStudio:

File → Open File

Select shift_chart_latest_game.qmd

# Step 2 — Render the report

Click the Render button (top ribbon in RStudio).

This will:

Load required data from the /data folder

Compute the shift windows

Attach headshots

Generate the shift chart

Save a PNG in the project folder named:
```
YYYY.MM.DD_Opponent__shift_chart.png
```
# Step 3 — View the HTML output

After rendering, an HTML file with the same name will open automatically:
```
shift_chart_latest_game.html
```
You can share this or the PNG with coaches/staff.

# 4. Changing Teams or Seasons (Optional)

At the top of the .qmd file:
```
params:
  team_name: "Arkansas"
  season: "2025-26"
```
Edit these values, then click Render again.

Note: If using other teams/seasons, the scraping functions may require additional pre-saved RDS files just like team_sched_ark_2025-26.rds.

# 5. Troubleshooting
“subscript out of bounds” in get_team_schedule()

This occurs when the source website layout changes.
Use the included .rds schedule file instead of live scraping (already configured in this report).

Missing data objects

Make sure all files in the /data folder remain in place and keep the same names.

Headshots not appearing

Roster names rely on fuzzy matching; mismatches may require adding extra name aliases.

# 6. Contact / Modifications

If you need:

support for additional teams

redesigned visuals

batch processing of multiple games

integration with internal scouting workflows

the script can be extended easily. Just ask Austin.




