Select *
From portfolio..CovidDeaths$
order by 3,4

Select *
From portfolio.._xlnm#_Covidvacin
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From portfolio..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as ContractedPercentage
From portfolio..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractedPercentage
From portfolio..CovidDeaths$
Group by location, population
order by ContractedPercentage desc

--Break Down by Continent (correct)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc

--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

--Showing Continents With the Highest Deathcount per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolio..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
, 
From portfolio..CovidDeaths$ dea
Join portfolio..Covidvaccine vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3
    
--CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        portfolio..CovidDeaths$ dea
    JOIN 
        portfolio..Covidvaccine vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


--Temp table

DROP Table if exists #PercentPopulationVaccinated
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

    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        portfolio..CovidDeaths$ dea
    JOIN 
        portfolio..Covidvaccine vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
 SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        portfolio..CovidDeaths$ dea
    JOIN 
        portfolio..Covidvaccine vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL


Select *
From PercentPopulationVaccinated