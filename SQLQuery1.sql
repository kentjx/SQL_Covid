SELECT * FROM PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2 

-- Looking at Total Cases vs Total Deaths 
-- Likelihood of dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' -- wild card factor
and continent is not null 
order by 1,2 

-- Since I am from Singapore, I would like to take look at Singapore's data! 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Singapore'
order by 1,2 
-- As of 28th August, the Death Rate is 0.081% in Singapore. Very low fatality. 

-- Looking at Total Cases vs Population 
-- Shows the % of population that contracted Covid-19.
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Singapore'
order by 1,2 
-- 1.139% 

--Lets compare it to the United States 
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS ContractedCovid
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
order by 1,2 
-- whooping 11.641%! 

-- Looking at Country with Highest Infection Rate compared to Population rate
SELECT Location, Population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS ContractedCovid
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
order by ContractedCovid DESC

-- Showing Countries with Highest Death Count per Population 
SELECT Location, 
MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY Location
ORDER BY TOtalDeathCount DESC

SELECT Location, 
MAX(cast(total_deaths as int)) AS TotalDeathCount, MAX((total_deaths/population)) * 100 AS Deathrate_per_population
FROM PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY Location, population
ORDER BY Deathrate_per_population DESC


-- USE CTE
With DeathRate (Location, Population, TotalDeaths, Highest_infection_count)
AS
(
SELECT Location, Population, MAX(convert(int, total_deaths)) AS TotalDeaths, MAX(total_cases) AS Highest_infection_count
FROM PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY Location, Population
)
SELECT *, (TotalDeaths/Highest_infection_count)*100 AS death_rate
FROM DeathRate
Where Location = 'Singapore' 
OR
Location = 'Israel'
ORDER BY death_rate DESC
-- Break things down by continent 

SELECT continent, 
MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY continent
ORDER BY TOtalDeathCount DESC

SELECT location, 
MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population 
SELECT continent, 
MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY continent
ORDER BY TOtalDeathCount DESC

-- GLOBAL NUMBERS --
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null 
--Group by date
order by 1,2 

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
-- SUM over partition by location, abd order them by their location & date. 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null 
ORDER BY 2,3

-- USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, TotalVaccinated) 
AS
(
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
-- SUM over partition by location, abd order them by their location & date. 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
--Where dea.continent is not null 
-- ORDER BY 2,3
)
SELECT *, (TotalVaccinated/Population)*100 AS VaccinationRate
FROM PopvsVac







-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
-- SUM over partition by location, and order them by their location & date. 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null 
-- ORDER BY 2,3
SELECT *, (TotalVaccinated/Population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 


Create View PercentPopulationVaccinated as 
SELECT dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
-- SUM over partition by location, and order them by their location & date. 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null 
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated