--select *
--from Covid_Data_Exploration..Covid_Deaths$
--order by 3,4

--select *
--from Covid_Data_Exploration..Covid_Vaccinations$
--order by 3,4

ALTER TABLE Covid_Data_Exploration..Covid_Deaths$
ALTER COLUMN total_deaths float

ALTER TABLE Covid_Data_Exploration..Covid_Vaccinations$
ALTER COLUMN new_vaccinations float

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM Covid_Data_Exploration..Covid_Deaths$
ORDER BY 1,2;

-- Looking at the Total Cases v/s Total Deaths
-- Shows the likeliehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM Covid_Data_Exploration..Covid_Deaths$
--WHERE location = 'India'
ORDER BY 1,2 ;

-- Looking at the Total Cases v/s Population
-- Shows what percentage of the population has covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as ContractPercentage
FROM Covid_Data_Exploration..Covid_Deaths$
--WHERE location = 'India'
ORDER BY 1,2 ;

-- Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population)*100) as PercentPopulation
FROM Covid_Data_Exploration..Covid_Deaths$
GROUP BY Location, Population
ORDER BY PercentPopulation DESC;

-- Showing the countries with the highest Death Count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Covid_Data_Exploration..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Let's break it down by continents

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Covid_Data_Exploration..Covid_Deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
FROM Covid_Data_Exploration..Covid_Deaths$
--WHERE location = 'India'
WHERE continent IS NOT NULL AND new_deaths != 0
GROUP BY date
ORDER BY 1,2 ;

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
FROM Covid_Data_Exploration..Covid_Deaths$
--WHERE location = 'India'
WHERE continent IS NOT NULL AND new_deaths != 0
--GROUP BY date
ORDER BY 1,2 ;


-- Looking at Total Population v/s Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
		, SUM(new_vaccinations) OVER(Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Data_Exploration..Covid_Deaths$ dea
JOIN Covid_Data_Exploration..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 ;

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
		, SUM(new_vaccinations) OVER(Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Data_Exploration..Covid_Deaths$ dea
JOIN Covid_Data_Exploration..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 ;
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
		, SUM(new_vaccinations) OVER(Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Data_Exploration..Covid_Deaths$ dea
JOIN Covid_Data_Exploration..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 ;

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later Visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
		, SUM(new_vaccinations) OVER(Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Data_Exploration..Covid_Deaths$ dea
JOIN Covid_Data_Exploration..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 ;







--1
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
--INTO Covid_Data_Exploration..DeathPercentage
FROM Covid_Data_Exploration..Covid_Deaths$
WHERE continent IS NOT NULL 
ORDER BY 1,2 ;

--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
--INTO Covid_Data_Exploration..TotalDeathCount
From Covid_Data_Exploration..Covid_Deaths$
--Where location = 'India'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--INTO Covid_Data_Exploration..TotalCases
From Covid_Data_Exploration..Covid_Deaths$
--Where location = 'India'
Group by Location, Population
order by PercentPopulationInfected desc

--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--INTO Covid_Data_Exploration..PercentPopulationInfected
From Covid_Data_Exploration..Covid_Deaths$
--Where location = 'India'
Group by Location, Population, date
order by PercentPopulationInfected desc



select * from DeathPercentage
select * from PercentPopulationInfected 
select * from TotalDeathCount
select * from TotalCases
