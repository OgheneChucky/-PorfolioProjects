-- Selecting all items as reference
--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4;

--- Check the views in the database

--Select 
--OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
--FROM
--sys.objects as o
--Where
--o.type = 'V';

--Drop View if exists PopVac


-------------------------------------------------------
--Select Data that we will use
Use PortfolioProject;
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2;

-------------------------------------------------------
--Looking at Total Cases VS Total Deaths Percentage
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 As DeathPercent
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
Order By 1,2;

-------------------------------------------------------
--Looking at Total Cases VS Population Percentage 
Select location, date, population, total_cases, total_deaths, (total_cases/population) * 100 As CasesPerPopulationPercent
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
Order By 1,2;

-------------------------------------------------------
--Looking at Highest Cases VS Population Percentage 
Select location, population, Max(total_cases) As MaxCases, Max(total_cases/population) * 100 As MaxCasesPercent
From PortfolioProject..CovidDeaths
Where location  is not NULL And continent  is not NULL
Group By  location, population
Order By MaxCasesPercent Desc;

----------------------------------------------------------
--Looking at Highest Deaths Per Country
Select location, Max(Cast(total_deaths As int)) As MaxDeaths
From PortfolioProject..CovidDeaths
Where continent  is not NULL
Group By  location
Order By MaxDeaths Desc;

----------------------------------------------------------
---Breakdown by Continent 
Select continent, Max(Cast(total_deaths As int)) As MaxDeaths
From PortfolioProject..CovidDeaths
Where continent  is not NULL
Group By  continent
Order By MaxDeaths Desc; 

-------------------------------------------------------
---Global Numbers by Date
Select date, Sum(new_cases) As TotalNewCases, Sum(Cast(new_deaths As int)) As TotalNewDeaths,
(SUM(Cast(new_deaths As int))/Sum(new_cases)*100)As NewDeathPercent
From PortfolioProject..CovidDeaths
Where continent  is not NULL
Group By date
Order By date Desc; 

---------------------------------------------------
---Global Numbers Overall
Select Sum(new_cases) As TotalNewCases, Sum(Cast(new_deaths As int)) As TotalNewDeaths,
(Sum(Cast(new_deaths As int))/Sum(new_cases)*100)As NewDeathPercent
From PortfolioProject..CovidDeaths
Where continent  is not NULL;

----------------------------------------------------
--- Total Population Vs New Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not NULL
Order By 2,3;

---------------------------------------------------
--- Total Population Vs New Vaccination Rolling Sum

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations As float)) Over (Partition by dea.location order by dea.location, dea.date) 
as RollingSumVac
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not NULL
order by 2,3;

---Use CTE for Rolling Sum
With PopvsVac
As
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations As float)) Over (Partition by dea.location order by dea.location, dea.date) 
As RollingSumVac
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3;
)
Select *,(RollingSumVac/population)*100 as Percentage
From PopvsVac

---Use TEMP TABLE for Rolling Sum
Drop Table if exists #PercentPopulationVac
Create Table #PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
new_vaccinations numeric,
RollingSumVac numeric
)

insert into #PercentPopulationVac
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingSumVac
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3;

Select *,(RollingSumVac/population)*100 as Percentage
From #PercentPopulationVac


-----------------------------------------------
--Create view for data visuals
GO
CREATE VIEW PopVac 
As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingSumVac
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not NULL;
--order by 2,3;


