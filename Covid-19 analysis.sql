/* Covid 19 data analysis

Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting data types

*/


--Viewing the datasets


Select * 
from SqlPortfolioProject.dbo.CovidDeaths


Select * 
from SqlPortfolioProject.dbo.CovidVaccinations


-- Top 10 countries most affected by covid

Select Top 10 location, SUM(total_cases) as TotalCases, SUM(cast(total_deaths as int)) AS TotalDeaths
from SqlPortfolioProject.dbo.CovidDeaths
where continent is not null 
Group by location
Order by TotalDeaths Desc


--Total deaths due to covid

Select Location, SUM(CAST(total_deaths as int)) as TotalDeaths
From SqlPortfolioProject.dbo.CovidDeaths
where Location = 'World'
Group by Location


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From SqlPortfolioProject.dbo.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SqlPortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SqlPortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SqlPortfolioProject.dbo.CovidDeaths dea
Join SqlPortfolioProject.dbo.CovidDeaths vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by dea.location, dea.date


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SqlPortfolioProject.dbo.CovidDeaths dea
Join SqlPortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationsPerPopulation
From PopvsVac

