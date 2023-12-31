
/*
Covid Analysis on Data from 2020-2021

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Datatypes

*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

select *
from PortfolioProject..CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs. Total Deaths in Japan
--Likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%japan%'
order by 1,2

--Total Cases vs. Population
--Shows Covid Cases, Total Deaths, and Population
select location, date, total_cases, total_deaths, population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%japan%'
order by 1,2

--Countries with Highest Infection Rate Compared to Population

select location,population,MAX(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population

select location,MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Highest Death Count by Continent

select continent,MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage-- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs. Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated,
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%japan%'



Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Views for later visualizations --

--Covid and SARS Fatality Rate Comparison

select cdeaths.location, MAX(cdeaths.total_deaths) as CovidDeaths, MAX(sdeaths.[Number of deaths]) as SARSDeaths
from CovidDeaths cdeaths
join sars_2003_complete_dataset sdeaths
on cdeaths.location = sdeaths.location
group by cdeaths.location
order by SARSDeaths desc
  

--Covid and SARS Infection Rate Comparison
  
select ccases.location, MAX(ccases.total_cases) as CovidCases, MAX([Cumulative number of case(s)]) as SARSCases
from CovidDeaths ccases
join sars_2003_complete_dataset scases
on ccases.location = scases.location
group by ccases.location
order by SARSCases desc
  
  
--Covid Death Percentage

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as CovidDeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2


--SARS Death Percentage 
select SUM([Cumulative number of case(s)]) as total_cases, SUM(cast([Number of deaths]as int)) as total_deaths, SUM(cast([Number of deaths] as int))/SUM([Cumulative number of case(s)]) *100 as SarsDeathPercentage
from sars_2003_complete_dataset
order by 1, 2


--SARS Global Cases

select location,SUM([Cumulative number of case(s)]) as SarsCases
from sars_2003_complete_dataset
group by location
order by SarsCases desc


--Countries with Highest Infection Rate Compared to Population

select location,population,MAX(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc
