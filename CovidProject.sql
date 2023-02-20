SELECT *
From PortfolioProject1..CovidDeats
order by 3,4

SELECT *
From PortfolioProject1..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject1..CovidDeats
order by 1,2

-- looking at total cases vs total deaths
-- Shows likelihood of death if you contract covid in United Kingdom

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject1..CovidDeats
Where location like '%United Kingdom%'
order by 1,2

--Looking at total cases vs total population
--Shows percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 AS PercentOfPopulationInfected
from PortfolioProject1..CovidDeats
Where location like '%United Kingdom%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) as PercentOfPopulationInfected
from PortfolioProject1..CovidDeats
Group By location, population
order by PercentOfPopulationInfected Desc


--Showing highest death count per population

select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeats
Where continent is not null
Group By location
order by TotalDeathCount Desc


--Breaking by Continent

select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeats
where continent is null
Group By location
order by TotalDeathCount Desc

--Looking at total population vs total vaccinations


Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (partition by dae.location Order By dae.location, dae.date)
AS RollingPeopleVaccinated
 From CovidVaccinations vac
 Join CovidDeats dae
     On dae.location = vac.location
	 and dae.date = vac.date
	 where dae.continent is not null
	 Order By 1,2,3


--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As 

(
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (partition by dae.location Order By dae.location, dae.date)
AS RollingVacCount
 From CovidVaccinations vac
 Join CovidDeats dae
     On dae.location = vac.location
	 and dae.date = vac.date
	 where dae.continent is not null
	
	 )
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Use Temp Table
DROP Table if exists #PercentPopulationVaccinted
Create Table #PercentPopulationVaccinted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinted
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (partition by dae.location Order By dae.location, dae.date)
AS RollingVacCount
 From CovidVaccinations vac
 Join CovidDeats dae
     On dae.location = vac.location
	 and dae.date = vac.date
	 where dae.continent is not null



Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinted


Create View PercentPopulationVaccinated as 
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (partition by dae.location Order By dae.location, dae.date)
AS RollingPeopleVaccinated
 From CovidVaccinations vac
 Join CovidDeats dae
     On dae.location = vac.location
	 and dae.date = vac.date
	 where dae.continent is not null
	 

Select *
From PercentPopulationVaccinated