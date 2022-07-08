CREATE DATABASE CovidIndonesia
USE CovidIndonesia


SELECT * FROM DataCovidIndonesia
ORDER BY Date

SELECT * FROM CovidWorld
WHERE location = 'Indonesia'
ORDER BY Date 

SELECT * FROM DataVaccinations
WHERE location = 'Indonesia'
ORDER BY Date 

-- Percentege Total Case vs Population in Indonesia
SELECT [Date] = CAST(cw.date AS date), [Country] = cw.location, [Population] = CAST(dv.population AS BIGINT), [Total_Cases] = CAST(total_cases AS BIGINT), 
[%PeopleInfected] = (total_cases/dv.population) * 100
FROM CovidWorld cw
JOIN DataVaccinations dv
	ON cw.location = dv.location
WHERE cw.location = 'Indonesia'
GROUP BY cw.date, cw.location, dv.population, total_cases
ORDER BY date

CREATE VIEW IndonesianCase AS 
SELECT [Date] = CAST(cw.date AS date), [Country] = cw.location, [Population] = CAST(dv.population AS BIGINT), [Total_Cases] = CAST(total_cases AS BIGINT), 
[%PeopleInfected] = (total_cases/dv.population) * 100
FROM CovidWorld cw
JOIN DataVaccinations dv
	ON cw.location = dv.location
WHERE cw.location = 'Indonesia'
GROUP BY cw.date, cw.location, dv.population, total_cases
--ORDER BY date


-- Percentege Total Case vs Death in Indonesia
SELECT [Date] = CAST(date AS date), [Country] = location, [Total_Cases] = CAST(total_cases AS BIGINT),[Total_Deaths] = CONVERT(BIGINT,total_deaths), 
[%Deaths] = (total_deaths/total_cases) * 100
FROM CovidWorld
WHERE location = 'Indonesia'
ORDER BY Date

CREATE VIEW PercentegeIndonesianDeath AS
SELECT [Date] = CAST(date AS date), [Country] = location, [Total_Cases] = CAST(total_cases AS BIGINT),[Total_Deaths] = CONVERT(BIGINT,total_deaths), 
[%Deaths] = (total_deaths/total_cases) * 100
FROM CovidWorld
WHERE location = 'Indonesia'
--ORDER BY Date

-- Comparison Total Case and %Death in ASEAN
SELECT [Date] = CAST(date AS date), [Country] = location, [Total_Cases] = CAST(total_cases AS BIGINT), [Total_Deaths] = CONVERT(BIGINT,total_deaths), 
[%Deaths] = (total_deaths/total_cases) * 100
FROM CovidWorld
WHERE location IN ('Indonesia','Brunei', 'Cambodia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
ORDER BY location, date

CREATE VIEW PercentegeAseanDeaths AS
SELECT [Date] = CAST(date AS date), [Country] = location, [Total_Cases] = CAST(total_cases AS BIGINT), [Total_Deaths] = CONVERT(BIGINT,total_deaths), 
[%Deaths] = (total_deaths/total_cases) * 100
FROM CovidWorld
WHERE location IN ('Indonesia','Brunei', 'Cambodia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')
--ORDER BY location, date

-- Check the country

SELECT location
FROM CovidWorld
WHERE continent = 'Asia'
GROUP BY location

-- Looking at province with the highest total case
SELECT Province, SUM(Cumulative_Case) AS CumulativeCase, [%PeopleInfected] = (SUM(Cumulative_Case)/Population)*100 
FROM DataCovidIndonesia
GROUP BY Province, Population
ORDER BY CumulativeCase DESC

CREATE VIEW CaseInProvince AS
SELECT Province, SUM(Cumulative_Case) AS CumulativeCase, [%PeopleInfected] = (SUM(Cumulative_Case)/Population)*100 
FROM DataCovidIndonesia
GROUP BY Province, Population
--ORDER BY CumulativeCase DESC

-- Vaccination in Indonesia
SELECT [Date] = CAST(date AS date), [Country] = location, [Population] = population, [1DoseVaccine] = people_vaccinated, 
[%PeopleDose1] = (people_vaccinated/population) * 100,[PeopleFullyVaccinated] = people_fully_vaccinated,
[%PeopleFullyVaccinated] = (people_fully_vaccinated/population)*100
FROM DataVaccinations
WHERE location = 'Indonesia'
GROUP BY date, location, people_vaccinated, people_fully_vaccinated, population 
ORDER BY date

CREATE VIEW Vaccination AS
SELECT [Date] = CAST(date AS date), [Country] = location, [Population] = population, [1DoseVaccine] = people_vaccinated, 
[%PeopleDose1] = (people_vaccinated/population) * 100,[PeopleFullyVaccinated] = people_fully_vaccinated,
[%PeopleFullyVaccinated] = (people_fully_vaccinated/population)*100
FROM DataVaccinations
WHERE location = 'Indonesia'
GROUP BY date, location, people_vaccinated, people_fully_vaccinated, population 
--ORDER BY date

-- Total Case and Death in Indonesia
SELECT [TotalCase] = SUM(new_cases), [TotalDeaths] = SUM(CAST(new_deaths AS BIGINT)), 
[DeathPercentege] = SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases)*100
FROM CovidWorld
WHERE location = 'Indonesia'
ORDER BY 1,2

CREATE VIEW TotalCaseIndonesia AS
SELECT [TotalCase] = SUM(new_cases), [TotalDeaths] = SUM(CAST(new_deaths AS BIGINT)), 
[DeathPercentege] = SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases)*100
FROM CovidWorld
WHERE location = 'Indonesia'
--ORDER BY 1,2

SELECT * FROM TotalCaseIndonesia

SELECT * FROM Vaccination

SELECT * FROM CaseInProvince

SELECT * FROM PercentegeAseanDeaths

SELECT * FROM PercentegeIndonesianDeath

SELECT * FROM IndonesianCase