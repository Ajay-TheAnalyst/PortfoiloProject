
select*
from CovidDeaths
where continent is not null and location = 'india'
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

select location, date, total_cases, total_deaths
from CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Showing Likehood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'india' and continent is not null
order by 1,2



--Looking at Total Cases vs Populations
--Showing what percentage of population got Covid 

select location, date,population, total_cases,(total_cases/population)*100 as Percent_Population_infected
from CovidDeaths
where continent is not null
--where location like 'india'
order by 1,2


--Looking at the highest infection Rate compared to Population

select location, population,MAX (total_cases) as Higest_infection_count, MAX(total_cases/population)*100 as Percent_Population_infected
from CovidDeaths
--where location like 'india'
Group by location, population
order by  Percent_Population_infected desc


-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int )) as Total_Death_Count
from CovidDeaths
--where location like 'india'
where continent is not null
Group by location
order by Total_Death_Count desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing Continent with the highest death count per Population

select continent, MAX(cast(total_deaths as int )) as Total_Death_Count
from CovidDeaths
--where location like 'india'
where continent is not null
Group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS

select  sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'india' 
where continent is not null
--group by date
order by 1,2 


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date  = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE

WITH PopvsVacc ( continent, location, date, population,new_vaccinations, Rolling_People_Vaccinated)

As
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date  = vac.date
where dea.continent is not null
--order by 2,3
)

select*,(Rolling_People_Vaccinated/population)*100
from PopvsVacc



--Temp Table
drop table if exists  #percent_Population_Vaccinated
Create Table #percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_People_Vaccinated numeric,
)

Insert into  #percent_Population_Vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date  = vac.date
--where dea.continent is not null
--order by 2,3


select*,(Rolling_People_Vaccinated/population)*100
from #percent_Population_Vaccinated


-- Creating view to store data for later visualization

create view percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
 as Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date  = vac.date
where dea.continent is not null
--order by 2,3


select*
from percent_Population_Vaccinated