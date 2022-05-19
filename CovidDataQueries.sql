/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data types

*/

-- COVID Deaths Table
SELECT * 
FROM ['Covid Deaths$']
WHERE continent is not null
ORDER BY 3, 4

-- General Query to Compare Covid Cases vs Covid Deaths by Location and Population
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['Covid Deaths$']
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Query Shows liklihood of dying if you contracted Covid in Your Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['Covid Deaths$']
WHERE location = 'United States' AND
continent is not null
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows what Percentage of Population has contracted Covid

SELECT location, date, Population, total_cases, total_deaths, (total_cases/population)*100 as PopulationInfectedPercentage
FROM PortfolioProject..['Covid Deaths$']
Order By 1,2

-- Countries with highest Infection rate compared to population
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM PortfolioProject..['Covid Deaths$']
GROUP By Location, Population
Order By PopulationInfectedPercentage desc

-- Countries with Highest Death Count Per Population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ['Covid Deaths$']
WHERE continent is not null
Group By Location
Order By TotalDeathCount Desc

-- Continent Breakdown
-- Showing Continents with Highest Death Count per Population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ['Covid Deaths$']
WHERE continent is not null
Group By continent
Order By TotalDeathCount Desc

-- Global Breakdown
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
WHERE continent is not null
GROUP By date
ORDER BY 1, 2

-- Total Global Death Percentage
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
WHERE continent is not null
ORDER BY 1, 2

-- Total Population vs Vacinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vacinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous Query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations     
  , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated

    FROM PortfolioProject..['Covid Deaths$'] dea
  JOIN  PortfolioProject..['Covid Vacinations$'] vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinePercentage
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partion By in Previous Query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations     
  , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
    FROM PortfolioProject..['Covid Deaths$'] dea
  JOIN  PortfolioProject..['Covid Vacinations$'] vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





--VIEWS
-- Percentage Population Vaccinated View

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations     
  , SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
    FROM PortfolioProject..['Covid Deaths$'] dea
  JOIN  PortfolioProject..['Covid Vacinations$'] vac
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null

-- Global Death Percentage View
CREATE VIEW GlobalDeathPercentage as
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
WHERE continent is not null

-- United States Death Percentage View
CREATE VIEW UnitedStatesDeathPercentage as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['Covid Deaths$']
WHERE location = 'United States' AND
continent is not null

-- Rolling Infection Rate By Population View
CREATE VIEW InfectionRateByPopulation as
SELECT location, date, Population, total_cases, total_deaths, (total_cases/population)*100 as PopulationInfectedPercentage
FROM PortfolioProject..['Covid Deaths$']

-- Countries Highest Infection to Population Rate View
CREATE VIEW HighestInfectionToPopulation as
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM PortfolioProject..['Covid Deaths$']
GROUP By Location, Population

-- Country Death Count View
CREATE VIEW CountryDeathCount as
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ['Covid Deaths$']
WHERE continent is not null
Group By Location

-- Continent Death Count View
CREATE VIEW ContinentDeathCount as
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM ['Covid Deaths$']
WHERE continent is not null
Group By continent

-- Global Death Percentage Over Time View
CREATE VIEW GlobalDeathPercentageOverTime as
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ['Covid Deaths$']
WHERE continent is not null
GROUP By date
