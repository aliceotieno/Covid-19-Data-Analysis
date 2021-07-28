
/*
COVID 19 Data Exploration

skills used: joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions,Creating Views ,Converting Data Types

*/

--Getting a glance at the Covid deaths table
SELECT *
FROM [Portfolio project]..Covid_Deaths
WHERE continent IS NOT NULL 
--Where location='kenya'
ORDER BY  3,4

--Getting a glance at the covid vaccinations table 
SELECT*
FROM [Portfolio project]..Covid_Vaccinations
WHERE continent IS NOT NULL 
ORDER BY 3,4


--total cases vs total deaths
--this shows the likelihood of dying if you contract covid 19 in kenya
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio project]..Covid_Deaths
WHERE location LIKE '%kenya%'
ORDER BY 1, 2



--A view for the percentage death in kenya 
CREATE VIEW DeathPercentageVieww AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio project]..Covid_Deaths
WHERE location LIKE '%kenya%'
--ORDER BY 1, 2

SELECT *
FROM DeathPercentageVieww


--looking at total cases vs population
 --showing the percentage population infected with covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM [Portfolio project]..Covid_Deaths
--WHERE location='kenya'
ORDER BY 1, 2


--A view for the percentage of infectected people by location
CREATE VIEW PercentagePopulationInfectedView AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM [Portfolio project]..Covid_Deaths
--WHERE location='kenya'
--ORDER BY 1, 2

SELECT *
FROM PercentagePopulationInfectedView



--looking at countries with the highest infecion rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio project]..Covid_Deaths
--WHERE location='kenya'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


--Breaking tings down by location
--Showing countries with the highest death count per population

SELECT location,MAX(cast(total_deaths AS int)) AS TotalDeathCount  --the cast clause converts the total deaths datatype from varchar to integer.so it reads and arranges orderly as intended
FROM [Portfolio project]..Covid_Deaths
WHERE continent IS NOT NULL    --the where clause that ensures thst continents is not null,stops the continents from appearing in this list,i.e Africa,Asia etc
GROUP BY location
ORDER BY TotalDeathCount DESC


--Breaking things down by continent
--showing continents with the highest death count per population

SELECT continent,MAX(cast(total_deaths AS int)) AS TotalDeathCount  --the cast clause converts the total deaths datatype from varchar to integer.so itreads and arranges orderly as intended
FROM [Portfolio project]..Covid_Deaths
WHERE continent IS NOT NULL    --the where clause that ensures thst continents is not null,stops the continents from appearing in this list,i.e Africa,Asia etc
GROUP BY continent
ORDER BY TotalDeathCount DESC


CREATE VIEW TotalDeathCountView AS
SELECT continent,MAX(cast(total_deaths AS int)) AS TotalDeathCount  --the cast clause converts the total deaths datatype from varchar to integer.so itreads and arranges orderly as intended
FROM [Portfolio project]..Covid_Deaths
WHERE continent IS NOT NULL    --the where clause that ensures thst continents is not null,stops the continents from appearing in this list,i.e Africa,Asia etc
GROUP BY continent
--ORDER BY TotalDeathCount DESC

SELECT *
FROM TotalDeathCountView


--GLOBAL NUMBERS 

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) As total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio project]..Covid_Deaths 
--WHERE location LIKE '%kenya%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


CREATE VIEW PercentageDeathsView AS
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) As total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio project]..Covid_Deaths 
--WHERE location LIKE '%kenya%'
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY 1, 2

SELECT *
FROM PercentageDeathsView


-- SUM(CAST(new_deaths AS int))  we put cast because the new deaths datatype is varchar and we want it as an ineger. the cast function changes the datatype
--to get the total cases, total deaths and percentage deathS globally

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) As total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio project]..Covid_Deaths 
WHERE continent IS NOT NULL
ORDER BY 1, 2


--lets join the 2 tables
--looking at total population vs vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM [Portfolio project]..Covid_Deaths dea
JOIN [Portfolio project]..Covid_Vaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


CREATE VIEW NewVaccinationsView AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM [Portfolio project]..Covid_Deaths dea
JOIN [Portfolio project]..Covid_Vaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
SELECT *
FROM NewVaccinationsView


--showing percentage of people that has received at least onecovid vaccine (rolling people vaccinated)
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM [Portfolio project]..Covid_Deaths dea
JOIN [Portfolio project]..Covid_Vaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


--we want to use the maximum rolling number in a population  to find out how many People in a country are vaccinated.

--USING CTE (Common Table Expresions) to perform alculation on Partition By in previous query
with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio project]..Covid_Deaths dea
JOIN [Portfolio project]..Covid_Vaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *,(RollingPeopleVaccinated/population) *100 AS PercentageRollingPeopleVaccinated
FROM  PopVsVac 
--WHERE continent= 'Africa'



--Using TEMP TABLE to perform alculation on Partition By in previous query
DROP TABLE IF EXISTS  #PercentagePopullationVaccinated;
--The DROP TABLE IF EXISTS statement enables a check to see that the table exists prior to attempting the dropping (deletion) of the table. If the table does not exists then the DROP TABLE statement is not executed so no error occurs.
CREATE TABLE #PercentagePopullationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)--define the outer query referencing the CTE name
INSERT INTO #PercentagePopullationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM [Portfolio project]..Covid_Deaths dea
JOIN [Portfolio project]..Covid_Vaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *,(RollingPeopleVaccinated/population) *100
FROM  #PercentagePopullationVaccinated



--creating view for percent population vaccinated view
--the view is created to store data for our visualization


CREATE VIEW PercentagePopullationVaccinatedView AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio project]..Covid_Deaths dea
JOIN [Portfolio project]..Covid_Vaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 


SELECT *
FROM PercentagePopullationVaccinatedView