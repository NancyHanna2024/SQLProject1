--select the data that we are going to use 
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeath
--where continent is not null
order by 1,2
--Looking at total cases vs total deaths
select location,date,total_cases,total_deaths,iif (total_cases=0,'',(total_deaths/total_cases)*100) as DeathPercentage
from PortfolioProject.dbo.CovidDeath
order by 1,2
--Looking at total cases vs total deaths in United States
select location,date,total_cases,total_deaths,iif (total_cases=0,'',(total_deaths/total_cases)*100) as DeathPercentage
from PortfolioProject.dbo.CovidDeath
where continent like '%North America%'
order by 1,2
--Shows what percentage of population got covid
select location,date,population,total_cases,iif (population=0,'',(total_cases/population)*100) as GotCovidPercentage
from PortfolioProject.dbo.CovidDeath
order by 1,2

--Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PopulationInfectedPercentage
from PortfolioProject.dbo.CovidDeath
group by location,population
order by PopulationInfectedPercentage DESC

--Showing  countries with  highest death count per population
select location,max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by location
order by TotalDeathCount DESC
 
 --Let's break things down by continent
select continent,max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by continent
order by TotalDeathCount DESC
--Global Numbers,New Cases In World Per Day
select date,sum(new_cases)as NewCasesInWorldPerDay,sum(cast(new_deaths as int))as NewDeaths 
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by date
order by 1
--Global Numbers, DeathPercent per day
select date,sum(new_cases)as NewCasesInWorldPerDay,sum(cast(new_deaths as int))as NewDeaths, iif(SUM(new_cases)=0,'',SUM(new_deaths)/SUM(new_cases)*100 )as DeathPercent
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by date
order by 1
--Global Numbers Total Cases and Total Death in the whole world
select sum(new_cases)as TotalCases,sum(cast(new_deaths as int))as TotalDeaths, iif(SUM(new_cases)=0,'',SUM(new_deaths)/SUM(new_cases)*100 )as DeathPercent
from PortfolioProject.dbo.CovidDeath
where continent is not null

--Looking at Total Population vs Vaccination
--Creating A Rolling Count
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidVaccinations vac 
join PortfolioProject.dbo.CovidDeath dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 2,3
--Rolling People Vaccinated/Population *100
--USING CTE
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidVaccinations vac 
join PortfolioProject.dbo.CovidDeath dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
--order by 2,3
)
Select *,IIF(population =0,'',RollingPeopleVaccinated/population*100)as VaccinatedPercentage from PopvsVac
--TEMP TABLE,,Second method return the same previous results
drop table if exists #PercentPopulationVaccinated --to avoid the error of multiple running 
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidVaccinations vac 
join PortfolioProject.dbo.CovidDeath dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated
--Creating View to store data for later visualizations
--create view PopulationVaccinatedPercent 
--as
--select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
--SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--from PortfolioProject.dbo.CovidVaccinations vac 
--join PortfolioProject.dbo.CovidDeath dea
--on vac.location=dea.location
--and vac.date=dea.date
--where dea.continent is not null

select * from PopulationVaccinatedPercent
