--Covid Deaths Analysis
-----------------------

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
order by 1,2;

-- Total Cases vs Total Deaths and Calculating %age of Deaths.
select sum(total_cases) Total_cases , sum(total_deaths) Total_Deaths,
concat(round(sum(total_deaths)/sum(total_cases)*100,2),'%') Death_Percentage
from PortfolioProject..CovidDeaths
order by Death_Percentage desc;

-- Analysis for India
select sum(total_cases) Total_cases , sum(total_deaths) Total_Deaths,
concat(round(sum(total_deaths)/sum(total_cases)*100,2),'%') Death_Percentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by Death_Percentage desc;

--- Querying max cases and deaths for India as on date.
Select location, MAX(total_cases) as MaximumCases from PortfolioProject..CovidDeaths
where location = 'india' group by location; --44696984

Select location,MAX(total_deaths) as MaximumDeaths from PortfolioProject..CovidDeaths
where location = 'india' group by location;  --530808

-- Looking at Total Cases vs Population
Select Location, date, total_cases, population
from PortfolioProject..CovidDeaths
order by 1,2;

-- First Covid Case was found on 30/1/2020 in India.
Select Location, date, total_cases
from PortfolioProject..CovidDeaths where location='india' and total_cases = 1;

-- First Death from Covid hapenned on 13/3/2020 in India.
Select Location, date, total_deaths
from PortfolioProject..CovidDeaths where location='india' and total_deaths = 1;

-- %age of Population who got Covid in India.

Select Location, Date, Population, total_cases, concat(round((total_cases/population)*100,2),'%') as PercentPopulationInfected
from PortfolioProject..CovidDeaths where location='india' and total_cases!=''
order by 2;

-- Countries with Highest Infection Rate as compared to Population.
Select Location, Population, max(total_cases) as HighestInfectionCount, 
concat(round(max(total_cases/population)*100,2),'%') as PercentPopulationInfected
from PortfolioProject..CovidDeaths group by location,population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population.
Select Location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc;	

-- Continent wise Analysis.

Select Continent, max(total_cases) as TotalCaseCount,
max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by Continent
order by TotalCaseCount desc;

-- Global Numbers

Select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, concat(round(sum(new_deaths)/sum(new_cases)*100,2),'%') as
DeathPercentage from PortfolioProject..CovidDeaths 
where continent is not null order by 1,2;

-- Query shows addition of new_cases and new_deaths of all countries and death %age.

--------------------------------------------------------------------------------------------------------------------
-- Joining both tables Covid Deaths & Covid Vaccination

Select * from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date;

-- Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Showing Countries having Vaccinations,Cases and Deaths (New & Cumulative) data.

Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Cumulative_Vaccinations,
dea.new_cases, sum(dea.new_cases) over(partition by dea.location order by dea.location, dea.date) as Cumulative_Cases,
dea.new_deaths, sum(dea.new_deaths) over(partition by dea.location order by dea.location, dea.date) as Cumulative_Deaths
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Highest infection count and death count Country wise.

select Location, Population, max(total_cases) as Highest_Infection_Count,
max(total_deaths) as Highest_Death_Count,
max((total_cases/population)*100) as PercentInfectedRate,
max((total_deaths/population)*100) as PercentDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
group by Location,Population
order by Highest_Infection_Count desc;

-- Showing Global Numbers: World’s total cases, total deaths, total population, death percentage, and case percentage. 

select sum(new_cases) as TotalCases,
sum(new_deaths) as TotalDeaths,
sum(population) as TotalPopulation,
concat(round(sum(new_deaths)/sum(new_cases)*100,2),'%') as WorldsDeathPercentage,
concat(round(sum(new_cases)/sum(population)*100,2),'%') as WorldsCasesPercentage
from PortfolioProject..CovidDeaths
where continent is not null;

-- Looking at TotalCases vs TotalDeaths Continent wise


-- Temp Table

Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
Cumulative_Vaccinations numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Cumulative_Vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;
----------------------------------------------------------------------------------------------------------------------

--Covid Vaccinations Analysis
-----------------------------
-- %age of Population who got Vaccinated in India.

Select Location,Date,Population, total_vaccinations, (total_vaccinations/population)*100 as PercentPeopleVaccinated
from PortfolioProject..CovidVaccinations where location = 'india'
order by 2;

-- Showing Percentage of people vaccinated Country wise.

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,Cumulative_Vaccinations)
as
(Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Cumulative_Vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
select *,concat(round((Cumulative_Vaccinations/Population)*100,2),'%') as Percent_People_Vaccinated
from PopvsVac order by 1,2;

-- Countries with Highest Vaccination Count per Population.
Select Location, max(total_vaccinations) as TotalVaccinationCount
from PortfolioProject..CovidVaccinations
where continent is not null
group by location
order by TotalVaccinationCount desc;

-- Total Tests vs Total Vaccinations
select location, sum(total_tests) Total_Tests , sum(total_vaccinations) Total_Vaccinations
from PortfolioProject..CovidVaccinations
where continent is not null
group by location;

-- Continent wise Analysis.

Select Continent, max(total_tests) as TotalTestCount,
max(total_vaccinations) as TotalVaccinationCount
from PortfolioProject..CovidVaccinations
where continent is not null
group by Continent
order by TotalVaccinationCount desc;
