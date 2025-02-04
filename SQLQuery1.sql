--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4


--Select *
--From PortfolioProject..CovidVacc
--order by 3,4

-- Looking at total case vs total deaths
select Location, date,total_cases, total_deaths,new_deaths, (total_deaths/total_cases)*100 as death_ratio
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2


--Looking at total cases vs population
--shows what percentage of populations got covid
select Location, date,total_cases, population, (total_cases/population)*100 as death_ratio
from PortfolioProject..CovidDeaths
where location = 'India' or location = 'United States'
order by 1,2

-- Looking at highest cases by population in each country
select location, max(total_cases) as highestCases, population, Max((total_cases/population))*100 as MaxInfection
from PortfolioProject..CovidDeaths
group by location, population
order by MaxInfection desc


--Showing countries with highest death count
Select location, Max(cast(total_deaths as int)) as MaxDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by MaxDeathCount desc


--Showing new death ratio by continets
select date,continent,new_cases,new_deaths
from PortfolioProject..CovidDeaths
where continent is not null
order by 2,3 desc

-- Total population vs vaccinations
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	and vac.new_vaccinations is not null
order by 2,3


-- Use CTE

with PopVsVacc (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	and vac.new_vaccinations is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/population)*100 as vaccinatedPeopleRatio
From PopVsVacc





--Temp Table
--this is tempoary table use to save the data 
drop table if exists #PercentagePeopleVaccinated
create table #PercentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentagePeopleVaccinated
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	and vac.new_vaccinations is not null
order by 2,3

Select *,(RollingPeopleVaccinated/population)*100 as vaccinatedPeopleRatio
From #PercentagePeopleVaccinated



-- Creating view of table PercentagePeopleVaccinated

Create View PercentagePeopleVacc as
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *
From PercentagePeopleVacc
