select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4
--select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
order by 1,2
--Looking at total cases Vs total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases , total_deaths, (Total_deaths / Cast(total_cases as float))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2
--looking at Total cases vs population
-- shows what percentage of population got covid
Select Location, date,  population, total_cases , (Cast(total_cases as float) / population )*100 as PopulationInfected
From PortfolioProject..CovidDeaths
where location like '%Morocco%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select Location, population, Max(Cast(total_cases as float)) as HighestInfectionCount, Max(Cast(total_cases as float) / population )*100 as PopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%morocco%'
Group by Location, population
order by PopulationInfected desc

--Showing countries with highest death count per population

Select Location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%morocco%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's Break it things down by Continent

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%morocco%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing  continents with highest death count per population

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%morocco%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select  Sum(new_cases) as Total_cases, Sum(new_deaths) as Total_deaths,Sum(new_deaths)/Nullif(Sum(new_cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where continent is not null
--Group by date
order by 1,2
------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As Roaling_People_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (continent, Location, Date, Population,New_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As Roaling_People_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Roaling_People_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As Roaling_People_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (Roaling_People_vaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) As Roaling_People_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated 