# Select all records from CovidDeaths where continent is not NULL, sorted by columns 3 and 4
SELECT *
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

# Data to be used:
# Select specific columns from CovidDeaths table sorted by Location and Date
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2;

# Calculate Death Percentage (total deaths / total cases * 100) for locations containing "states" in their name
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

# Calculate the highest infection rate compared to population for each location
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / Population)) * 100 AS PercentofPopulationInfected
FROM dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected DESC;

# Show the location with the highest death counts per population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC;

# Show continents with the highest death counts
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC;

# Show continents with the highest death counts per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC;

# Calculate global numbers for total cases, total deaths, and death percentage
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
#GROUP BY date
ORDER BY 1, 2;

# Use Common Table Expression (CTE) to calculate RollingPeopleVaccinated
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
           SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM dbo.CovidDeaths dea
    JOIN dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PopvsVac;

# Temporary table to avoid errors when modifying data
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

# Create and populate a temporary table
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
#ORDER BY 2, 3;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated;

# Create a VIEW to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
