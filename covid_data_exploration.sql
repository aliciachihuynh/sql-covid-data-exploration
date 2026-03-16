SELECT DB_NAME() AS CurrentDatabase; 
USE PortfolioProject 
GO

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

-- Select *
-- From PortfolioProject01..CovidVaccinations
-- order by 3,4 
 
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2 

-- Total Cases vs. Total Deaths 
-- Shows likelihood of death by COVID-19 if contracted in a country 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
order by 1,2 

-- Total Cases vs. Population 
-- Shows total amount of cases in a country's population
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
order by 1,2 

-- Tableu Table #3
-- Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/cast(population as float))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by PopulationInfectedPercentage desc

-- Tableu Table #4
-- Countries with highest infection rate compared to population w/ date
Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/cast(population as float))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Group by location, population, date
order by PopulationInfectedPercentage desc 

-- Countries with the highest COVID-19 death rate relative to population
Select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(total_deaths/cast(population as float))*100 as DeathPerPopulationPercentage 
From PortfolioProject..CovidDeaths
Group by location, population
order by DeathPerPopulationPercentage desc

-- Countries and regions with the highest total COVID-19 death counts
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by HighestDeathCount desc

-- Continent Data
-- Showing continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by HighestDeathCount desc

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by HighestDeathCount desc

-- Global Numbers 
-- Showing global COVID death percentages by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2 

-- Tableu Table #1
-- Showing total global death count and percentage 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2 

-- Tableu Table #2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

-- Joined CovidDeaths and CovidVaccinations
Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date

 -- Total Population vs. Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- Adding a rolling count of vaccinations by date of countries
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinatedByDate,
-- (TotalVaccinatedByDate/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- USE CTE 
-- CTE approach: Create temporary dataset to calculate vaccination progress by country
With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinatedByDate)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinatedByDate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
) 
Select *, (TotalVaccinatedByDate/population)*100
From PopvsVac 
ORDER BY location, date

-- TEMP TABLE 
-- Temp table approach: Save vaccination totals temporarily to analyze percent vaccinated
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent NVARCHAR(225),
location NVARCHAR(225),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
TotalVaccinatedByDate numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinatedByDate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Select *, (TotalVaccinatedByDate/population)*100
From #PercentPopulationVaccinated 
ORDER BY location, date 

-- Creating View to store data for later visualizations
GO
CREATE OR ALTER VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalVaccinatedByDate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
GO 

 -- Total Population vs. Reproduction Rate 
Select dea.continent, dea.location, dea.date, dea.population, vac.reproduction_rate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3 

-- Adding a moving average reproduction rate 
Select dea.continent, dea.location, dea.date, dea.population, dea.reproduction_rate, 
ROUND(AVG(dea.reproduction_rate) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 3) AS RollingAvgReproRates
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- CTE: Population vs reproduction rate (with 7-day moving average)
With ReproRatesVsPops 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, dea.reproduction_rate, 
ROUND(AVG(dea.reproduction_rate) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 3) AS RollingAvgReproRates
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
) 
Select *
From ReproRatesVsPops 
ORDER BY location, date

-- Temp table: reproduction rate trend by population
DROP TABLE if exists #ReproRatesVsPops
Create Table #ReproRatesVsPops
(
continent NVARCHAR(225),
location NVARCHAR(225),
date DATETIME,
population NUMERIC,
reproduction_rate FLOAT,
RollingAvgReproRate FLOAT
);

Insert into #ReproRatesVsPops
Select dea.continent, dea.location, dea.date, dea.population, dea.reproduction_rate, 
ROUND(AVG(dea.reproduction_rate) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 3) AS RollingAvgReproRates
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Select *
From #ReproRatesVsPops
ORDER BY location, date; 

-- Creating View to store data for later visualizations
GO
CREATE OR ALTER VIEW ReproRatesVsPops as
Select dea.continent, dea.location, dea.date, dea.population, dea.reproduction_rate, 
ROUND(AVG(dea.reproduction_rate) OVER (PARTITION BY dea.location ORDER BY dea.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 3) AS RollingAvgReproRates
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL;
GO 
