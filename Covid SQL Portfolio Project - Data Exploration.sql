/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

USE PortfolioProject
SELECT * FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM CovidVaccinations
ORDER BY 3,4

--Select the data that we will be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2


--Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
ORDER BY 1,2


 
--Total cases vs total deaths in India

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2


--Total cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
ORDER BY 1,2


--Looking at countries with Highest Infection rate compared to population

 
SELECT Location,population, MAX(total_cases)AS HighestInfectionCount ,MAX((total_cases/population))*100 
AS InfectedPercentage
FROM CovidDeaths
GROUP BY Location,population
ORDER BY InfectedPercentage DESC


--Showing Countries with Highest Death Count Per Population

SELECT Location,MAX(CAST(total_deaths AS int))AS TotalDeathCount 
FROM CovidDeaths
GROUP BY Location
ORDER BY TotalDeathCount  DESC


-- BREAKING THINGS DOWN BY CONTINENT
--Showing Continents with the Highest death count per Population

SELECT continent,MAX(CAST(total_deaths AS int))AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount  DESC


--Looking at continents with Highest Infection rate compared to population

SELECT continent,population, MAX(total_cases)AS HighestInfectionCount ,MAX((total_cases/population))*100 
AS InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent,population
ORDER BY InfectedPercentage DESC


--Global Numbers

SELECT Date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2


--Total Population vs Vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH POPVSVAC (continent, location, date, population, RollingPeopleVaccinated, new_vaccinations)  
AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths AS dea JOIN CovidVaccinations AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL) 
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/ population)*100
FROM POPVSVAC

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PPV
CREATE TABLE #PPV
(continent nvarchar(200),
location nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 INSERT INTO #PPV
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths AS dea JOIN CovidVaccinations AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 DESC
SELECT *, (RollingPeopleVaccinated/ population)*100
FROM #PPV


-- Creating View to store data for later Vistualizations

CREATE VIEW PPV AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths AS dea JOIN CovidVaccinations AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PPV


--View for Global Numbers

CREATE VIEW GlobalN AS
SELECT Date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date

SELECT * FROM GlobalN


--View for Total case vs Population

CREATE VIEW TotalCase AS
SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE Location LIKE '%India%'

SELECT * FROM TotalCase


--View for Total cases vs Total death

CREATE VIEW CaseVSDeath AS
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths

SELECT * FROM CaseVSDeath



















