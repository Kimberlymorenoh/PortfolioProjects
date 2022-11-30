select *
From [Portfolioversion1.0] ..coviddeaths

select Location,date, total_cases, new_cases, total_deaths, population
From [Portfolioversion1.0] ..coviddeaths
Where continent is not null
order by 1,2

--Total cases vs Total Deaths in USA

select Location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolioversion1.0] ..coviddeaths
where location like '%state%'
Where continent is not null
order by 1,2

--Loking at Total Cases Vs Population
-- Show what Percentahe of Population got Covid
select Location,date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
From [Portfolioversion1.0] ..coviddeaths
Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

Select Location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max(total_cases/population)*100  as PercentPopulationInfected
From [Portfolioversion1.0] ..coviddeaths
Group by Location, Population
Order by PercentPopulationInfected desc


-- Showing Countries With Highest Death Count per Population


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolioversion1.0] ..coviddeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's break things down by Continent 

--Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolioversion1.0] ..coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolioversion1.0] ..coviddeaths
Where continent is not null
--group by date
order by 1,2

Select *
From [Portfolioversion1.0] ..covidVaccionation

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolioversion1.0] ..coviddeaths dea 
join [Portfolioversion1.0] ..covidVaccionation vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

	 --USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolioversion1.0] ..coviddeaths dea 
join [Portfolioversion1.0] ..covidVaccionation vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolioversion1.0] ..coviddeaths dea 
join [Portfolioversion1.0] ..covidVaccionation vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolioversion1.0]..coviddeaths dea
Join [Portfolioversion1.0]..covidVaccionation vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated
