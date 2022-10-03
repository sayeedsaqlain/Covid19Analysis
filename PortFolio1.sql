
-- Viewing the dataset
select * from PortfolioProject..coviddeaths$
where continent is not null
order by 3,4;


--select * from PortfolioProject..covidvcc$
--order by 3,4;

-- Shows selected columns of interest
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths$
order by 1,2

--Loking at Total cases vs Death Rate
-- Shows the likelihood of dying if you contract covid
select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..coviddeaths$ 
where location like '%Canada' order by 1,2

-- Comapare Total Cases vs Population
-- Shows the percentage of Covid +ve people
select Location,date, population, total_cases, (total_cases/population)*100 as PositivityRate
from PortfolioProject..coviddeaths$ 
where location like '%Canada' order by 1,2


-- Looking at countries with highest Infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedRate
from PortfolioProject..coviddeaths$  
group by location,population
order by InfectedRate asc


-- Showing Countries with highest Death count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's Break this down by Continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing Continents with highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select SUM(new_cases),SUM(cast(new_deaths as integer)),SUM(cast(new_deaths as integer))/SUM(new_cases)*100 as DeathRate
from PortfolioProject..coviddeaths$  
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,
 vcc.new_vaccinations, SUM(cast(vcc.new_vaccinations as bigint)) over 
 (partition by dea.location order by dea.Location, dea.date) as RollingPplVaccinated
 --,(RollingPplVaccinated/population)*100
 from PortfolioProject..coviddeaths$ dea
 join PortfolioProject..covidvcc$ vcc
	on dea.location = vcc.location
	and dea.date = vcc.date
 where dea.continent is not null
 order by 2,3


 -- Use CTE

With PopvsVcc (Continent, Location, Date, Population, new_vaccinations, RollingPplVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population,
 vcc.new_vaccinations, SUM(cast(vcc.new_vaccinations as bigint)) over 
 (partition by dea.location order by dea.Location, dea.date) as RollingPplVaccinated
 from PortfolioProject..coviddeaths$ dea
 join PortfolioProject..covidvcc$ vcc
	on dea.location = vcc.location
	and dea.date = vcc.date
 where dea.continent is not null
 --order by 2,3
 )	
 select *,(RollingPplVaccinated/population)*100 as PctVaccinated from PopvsVcc


 -- TEMP TABLE

 Create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPplVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population,
 vcc.new_vaccinations, SUM(cast(vcc.new_vaccinations as bigint)) over 
 (partition by dea.location order by dea.Location, dea.date) as RollingPplVaccinated
 from PortfolioProject..coviddeaths$ dea
 join PortfolioProject..covidvcc$ vcc
	on dea.location = vcc.location
	and dea.date = vcc.date
 where dea.continent is not null
 --order by 2,3
 
select *,(RollingPplVaccinated/population)*100 as PctVaccinated from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create	View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population,
 vcc.new_vaccinations, SUM(cast(vcc.new_vaccinations as bigint)) over 
 (partition by dea.location order by dea.Location, dea.date) as RollingPplVaccinated
 from PortfolioProject..coviddeaths$ dea
 join PortfolioProject..covidvcc$ vcc
	on dea.location = vcc.location
	and dea.date = vcc.date
 where dea.continent is not null
 --order by 2,3