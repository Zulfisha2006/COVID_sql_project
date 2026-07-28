
-- changing data type of date in covidvaccinations

ALTER TABLE covidvaccinations
ADD COLUMN date_fixed DATE;

UPDATE covidvaccinations
SET date_fixed = STR_TO_DATE(`date`, '%d-%m-%Y');

ALTER TABLE covidvaccinations
DROP COLUMN `date`;

ALTER TABLE covidvaccinations
CHANGE COLUMN date_fixed `date` DATE;



-- changing data type of date in coviddeaths


ALTER TABLE coviddeaths
ADD COLUMN date_fixed DATE;

UPDATE coviddeaths
SET date_fixed = STR_TO_DATE(`date`, '%d-%m-%Y');

ALTER TABLE coviddeaths
DROP COLUMN `date`;

ALTER TABLE coviddeaths
CHANGE COLUMN date_fixed `date` DATE;

UPDATE coviddeaths
SET continent=null
where continent ='';

UPDATE covidvaccinations
SET continent=null
where continent ='';



SELECT location,`date`,total_cases,new_cases,total_deaths,population
FROM coviddeaths
WHERE location like '%states%'
order by 1,2;






-- Total deaths vs total cases
-- Death percentage in a specific country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM coviddeaths
WHERE location like '%India%'
ORDER BY 1,2;



-- Total cases vs population
-- Shows what percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as Percent_Population_infected
FROM coviddeaths
WHERE location like '%India%'
ORDER BY 1,2;




-- Looking at countries with highest infection rate compaerd to population

SELECT location,population,MAX(total_cases) AS highest_infection_count,MAX(total_cases/population)*100 as Infection_Rate
FROM coviddeaths
group by location,population
ORDER BY MAX(total_cases/population)*100 DESC;


-- Showing countries with highest Death Count over Population

SELECT location,MAX(total_deaths) AS Total_Deaths
FROM coviddeaths
where continent is not null       
group by location
ORDER BY Total_Deaths DESC;


-- Showing continents with highest Death Count over Population

SELECT location,MAX(total_deaths) AS Total_Deaths
FROM coviddeaths
where continent is null
group by location
ORDER BY Total_Deaths DESC;



-- Global Numbers

select `date`,SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_Percentage
from coviddeaths
where continent is not null
group by date
order by 1,2;


-- Looking at total population vs vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM coviddeaths as dea
join covidvaccinations as vac
  on dea.location=vac.location
  and dea.`date`=vac.`date`
where dea.continent is not null  
order by 2,3
;



-- vaccination rate in country


with popVSvacc (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
 as 
 (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(vac.new_vaccinations) over(partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
  
FROM coviddeaths as dea
join covidvaccinations as vac
  on dea.location=vac.location
  and dea.`date`=vac.`date`
where dea.continent is not null  


)
 select  *,(Rolling_people_vaccinated/population)*100 as vaccination_rate
 FROM popVSvacc ;





-- Temp table

DROP Table if exists  PercentPopulationVaccinated;

Create Table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
`date` date,
population bigint,
new_vaccinations varchar(255),
 Rolling_people_vaccinated int
 );

INSERT INTO PercentPopulationVaccinated
(
    continent,
    location,
    `date`,
    population,
    new_vaccinations,
    Rolling_people_vaccinated
)
SELECT
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS Rolling_people_vaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.`date` = vac.`date`;
select  *,(Rolling_people_vaccinated/population)*100 as vaccination_rate
 FROM PercentPopulationVaccinated ;
 
 
 
 -- Creating view for later visualization
 
 CREATE View PercentPopulationVaccinated_View as 
 SELECT
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vacpercentpopulationvaccinated_viewcinations) OVER (
        PARTITION BY dea.location
        ORDER BY dea.date
    ) AS Rolling_people_vaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
ON dea.location = vac.location
AND dea.`date` = vac.`date`
where dea.continent is not null;
 



