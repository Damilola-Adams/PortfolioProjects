Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4



-- SELECT DATA THAT WILL BE USED

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2


-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'Nigeria' 
and continent is not null
Order by 1, 2



-- LOOKING AT THE TOTAL CASES VS POPULATION

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
--where location = 'Nigeria'
Order by 1, 2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPAERED TO POPULATION

Select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'Nigeria'
Group by location, population
Order by PercentPopulationInfected desc



--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select location,  max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location = 'Nigeria'
where continent is not null
Group by location
Order by TotalDeathCount desc


-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location = 'Nigeria'
where continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS



Select date, sum(new_cases)as TotalCases, sum(cast (new_deaths as int))as TotalCases, sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location = 'Nigeria' 
where continent is not null
Group by date
Order by 1, 2



-- LOOKING AT TOTAL POPULATION VS VACCINATION


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum (cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as CumulativePopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE


Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum (cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as CumulativePopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated





--CREATING VIEW TO STORE DATA FOR LATER VISUALIATION



Use PortfolioProject
Go
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum (cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as CumulativePopulation
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3


Select *
From PercentPopulationVaccinated