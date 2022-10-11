Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL -- remove the higher grouping by continent or world
ORDER BY 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Selecting data to be used

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL -- remove the higher grouping by continent or world
ORDER BY 1,2

-- Look at total cases vs total deaths
--Likelihood of dying in US if contract covid in US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
WHERE continent is not NULL -- remove the higher grouping by continent or world
ORDER BY 1,2

-- total cases vs population
-- shows what percentage of population has gotten covid
Select location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
WHERE continent is not NULL -- remove the higher grouping by continent or world
ORDER BY 1,2


-- Countries with highest infection rate compared to population (but note there is no recorded for reinfected individuals)
Select location, MAX(total_cases) AS HighestInctionCount, population, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL -- remove the higher grouping by continent or world
GROUP By location, population
ORDER BY PercentPopulationInfected desc

-- Countries with highest death count per population

Select location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL -- remove the higher grouping by continent or world
GROUP By location
ORDER BY TotalDeathCount desc

--Look at data by continent, but this has errors b/c noth america doesn't have numbers from canada, only usa

Select location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is NULL -- look only at the higher grouping by continent or world, but this has income as well...might want to take that out
GROUP By location
ORDER BY TotalDeathCount desc


Select continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is NOT NULL -- this doesn't tally correctly, north america only has USA and not Canada (might be other errors)
GROUP By continent
ORDER BY TotalDeathCount desc

-- continents with highest death count per population

Select continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount, Max((total_deaths/population)) AS DeathCountPopulation
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL -- remove the higher grouping by continent or world, north america only has USA and not Canada (might be other errors)
GROUP By continent
ORDER BY DeathCountPopulation desc

-- continents with highest death count per population

Select location, MAX(cast(total_deaths AS int)) AS TotalDeathCount, Max((total_deaths/population)) AS DeathCountPopulation
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is NULL -- this should be correct, but new entries added for income...
GROUP By location
ORDER BY DeathCountPopulation desc

-- Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- total population vs vaccinations
-- cannot use int, must use bigint.  While all your sizes can fit into INT (up to 2^31 - 1), their SUM cannot.  So use bigint instead!  If you use int this error is thrown: Arithmetic overflow error converting expression to data type int.
-- Warning: Null value is eliminated by an aggregate or other SET operation. 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated --equvalent to cast is: CONVERT(int, vac.new_vaccinations) ALSO need to order by location and date, date is what separates it out
--, (RollingPeopleVaccinated/population)*100 using the total vaccinations per country (location) = RollingPeopleVaccinated, divide by population to get vaccination percentage, but can't do this, need a CTE or temp table because you can't make new variabl on new variable
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- maybe make a change

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent is not null
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create a view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated --equvalent to cast is: CONVERT(int, vac.new_vaccinations) ALSO need to order by location and date, date is what separates it out
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3

--Can select data from our view
Select *
From PercentPopulationVaccinated