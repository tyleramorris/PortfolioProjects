

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying from contracting COVID-19 in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE location = 'UNITED STATES' AND CONTINENT IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'UNITED STATES' AND continent IS NOT NULL
ORDER BY 1,2

--Highest Infection Rate by Country

SELECT location, population, MAX(total_cases)HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE CONTINENT IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
--Shows chances of death per Country

SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(Population) as TotalPopulation, MAX(total_deaths/population)*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE CONTINENT IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeaths DESC

--Continent Statistics

SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
AND location NOT LIKE 'WORLD'
GROUP BY location
ORDER BY TotalDeathCount DESC

--World Number

SELECT SUM(new_cases)NewCases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE CONTINENT IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations in CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVax)
as 
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingVax
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vax
	ON death.location = vax.location
	and death.date = vax.date
WHERE DEATH.continent IS NOT NULL
AND VAX.new_vaccinations IS NOT NULL
)
SELECT *, (RollingVax/Population)*100 as VaxPop
FROM PopVsVac

-- Looking at Total Population vs Vaccinations in Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vax
	ON DEATH.location = vax.location
	AND death.date = vax.date

SELECT *, (ROLLINGPEOPLEVACCINATED/POPULATION)*100
FROM #PercentPopulationVaccinated

--Creating Views

CREATE View PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vax
	ON DEATH.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

CREATE VIEW ContinentDeaths as
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
AND location NOT LIKE 'WORLD'
GROUP BY location
--ORDER BY TotalDeathCount DESC