select *
from dbo.CovidDeaths
where continent is not NULL
order by 3,4

--select *
--from dbo.CovidVaccinations
--order by 3,4


---Data to be used:
select Location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

-- total cases vs total deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
order by 1,2

-- countries with highest infection rates compared to population	
select Location, Population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/Population))*100 as PercentofPopulationInfected
from dbo.CovidDeaths
---where location like '%states%'
group by Location, Population
order by PercentofPopulationInfected desc


---showing countries with highest death counts per population
select location,  MAX(cast(Total_deaths as int)) as TotalDeathsCount
from dbo.CovidDeaths
where continent is not NULL
group by location
order by TotalDeathsCount desc


---showing continents with highest death counts 
select continent,  MAX(cast(Total_deaths as int)) as TotalDeathsCount
from dbo.CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathsCount desc

---Showing continents with highest death counts per population

select continent,  MAX(cast(Total_deaths as int)) as TotalDeathsCount
from dbo.CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathsCount desc


---show continents with highest death counts HACERRRRRR!!!!!!!!
select continent,  MAX(cast(Total_deaths as int)) as TotalDeathsCount
from dbo.CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathsCount desc


-- global numbers
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not NULL
group by date 
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not NULL
--group by date 
order by 1,2


-- use CTE

with PopvsVac(Continent, Location, Date, Population ,  New_Vaccinations , RollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations 
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac 




--TEMP TABLE
drop table if exists #PercentPopulationVaccinated -- to avoid errors after modifying something	
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into	#PercentPopulationVaccinated
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations 
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated 



---Creating VIEW to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent , dea.location, dea.date , dea.population, vac.new_vaccinations 
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated

--, RollingPeopleVaccinated/

from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated