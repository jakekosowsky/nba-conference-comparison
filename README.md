# NBA Conference Comparison

A reusable NBA data pipeline for comparing team performance across the Eastern and Western Conferences. The project retrieves schedules and team statistics, transforms home/road results into consistent game-level features, and prepares a panel suitable for conference-level analysis.

## Analysis goals

- Compare conference strength across a season.
- Separate home-court effects from overall performance.
- Track cumulative win percentage and point differential.
- Create a reproducible dataset for team and conference visualizations.

## Repository structure

- `notebooks/conference_comparison.ipynb` — NBA API collection and feature engineering
- `data/` — optional local cache; generated files are not committed

## Tools

Python, pandas, NumPy, `nba_api`, Requests, and Jupyter.

## Running the notebook

Install the dependencies, open the notebook, select the season, and run the collection cells. NBA endpoints may rate-limit automated requests, so the pipeline includes retry behavior and should be run conservatively.

## Status

The repository contains the reusable collection and transformation foundation. The next release will add final conference summary tables, uncertainty-aware comparisons, and polished figures.
