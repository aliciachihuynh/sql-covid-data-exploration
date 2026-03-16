# SQL COVID-19 Data Exploration

SQL analysis of global COVID-19 data including infection rates, death percentages, and vaccination progress.

## Project Overview

This project explores global COVID-19 data using SQL to analyze infection rates, death percentages, and vaccination progress.

## Tools Used

- SQL Server
- Excel
- Tableau

## Dataset

Our World in Data COVID-19 dataset.

## Analysis Performed

- Total cases vs total deaths
- Percentage of population infected
- Highest infection rates by country
- Global death statistics
- Vaccination progress using window functions

## Key SQL Concepts

- Joins
- CTEs
- Window Functions
- Aggregate Functions
- Temporary Tables
- Views

## Example Query

```sql
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE location = 'United States'
ORDER BY date;
