--Select *
--from [PortfolioProject].[dbo].['info-vaccination']
--Order by 3,4

--Select *
--from [PortfolioProject].[dbo].[info-death]
--order by 3,4

Select *
from [PortfolioProject].[dbo].['info-vaccination']

Select location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject].[dbo].[info-death] 
order by 1,2

--Let's look at total cases vs total deaths
Select location, date, total_cases, total_deaths, CONVERT(Decimal(38, 2), total_deaths) / CONVERT(Decimal(38, 2), total_cases)*100 AS DeathPercentage
from [PortfolioProject].[dbo].[info-death]
WHERE location like '%Nigeria%'
order by 1,2

--Let's look at population vs total cases
Select location, date, population, total_cases, CONVERT(Decimal(38, 2), total_cases) / CONVERT(Decimal(38, 2), population)*100 AS InfectedPercentage
from [PortfolioProject].[dbo].[info-death]
WHERE location like '%Nigeria%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionRate, MAX(CONVERT(Decimal(38, 2), total_deaths) / CONVERT(Decimal(38, 2), total_cases))*100 AS DeathPercentage
from [PortfolioProject].[dbo].[info-death]
Group by location, population
order by HighestInfectionRate desc

--Showing Countries with highest deathcount per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [PortfolioProject].[dbo].[info-death]
Where continent is not null
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
from [PortfolioProject].[dbo].[info-death]
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, NULLIF(SUM(new_deaths), 0) / NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
from [PortfolioProject].[dbo].[info-death]
Where continent is not null
order by 1,2

Select date, new_cases, new_deaths
from [PortfolioProject].[dbo].[info-death]
Where continent is not null
order by 1,2

-- Looking at Total Population VS Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS bigint)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinatrd
From [PortfolioProject].[dbo].[info-death] dea
join [PortfolioProject].[dbo].['info-vaccination'] vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	 Order by 2,3


--USE CTE

With popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations AS bigint)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [PortfolioProject].[dbo].[info-death] dea
join [PortfolioProject].[dbo].['info-vaccination'] vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	 )
	 select* , (RollingPeopleVaccinated/population)*100
	 from popVSvac

Create view TheDeathPecentage as
Select Location, DATE, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, NULLIF(SUM(new_deaths), 0) / NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
from [PortfolioProject].[dbo].[info-death]
Where continent is not null
Group by Location, DATE

Select *
From TheDeathPecentage