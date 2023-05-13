
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null;
--SELECT Data that i am going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of death if you get covid in your country
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States' and
WHERE continent is not null
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Estonia' and
WHERE continent is not null
ORDER BY 1,2

--Looking at countries with the Total Infection rate compared to population

SELECT location, population, MAX(cast(total_cases as float)) as TotalInfectionCount, Max((cast(total_cases as float)/cast(population as float)))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location = 'Estonia'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

SELECT location, MAX(cast (total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location = 'Estonia' and
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Breaking previous data by continent and income
---- Showing continents with the highest death count

SELECT location, MAX(cast (total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location = 'Estonia'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS
--New Cases, New Death and The percentage of new_deaths/new_cases daily

SELECT date, SUM(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/nullif(SUM(cast(new_cases as float)),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--New Cases, New Death and The percentage of new_deaths/new_cases globaly

SELECT SUM(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/nullif(SUM(cast(new_cases as float)),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 I need to use CTE or TempTable in order to do that
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE use case
 
 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 I need to use CTE or TempTable in order to do that
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order 2,3 cannot be used in CTE
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE use case
DROP TABLE if exists #PercentPopulationVaccinated
--So there can be done alteration without an errors
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 I need to use CTE or TempTable in order to do that
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 I need to use CTE or TempTable in order to do that
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
