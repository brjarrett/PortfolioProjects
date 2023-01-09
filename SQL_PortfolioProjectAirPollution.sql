-- Air pollution, population, and deaths over time

-- Select pollution types, by country and year

Select Country, Year, [Nitrogen oxide (NOx)], [Sulphur dioxide (SO2)], [Carbon monoxide (CO)], [Organic carbon (OC)], NMVOCs, [Black carbon (BC)], [Ammonia (NH3)]
FROM PortfolioProjectAirPollution..AirPollution 
ORDER BY Country, Year

-- Select cardiac, respiratory, neurological diseases by country and year
Select Country, Year, DeathsAlzheimers, DeathsParkinsons, DeathsTuberculosis, DeathsCardiovascularDiseases, DeathsLowerRespiratoryInfections, DeathsDiabetesMellitus, DeathsChronicKidneyDisease, DeathsChronicRespiratoryDiseases
FROM PortfolioProjectAirPollution..AnnualDeathsbyCause
ORDER BY Country, Year

-- Compare total pollution output (metric tons, i.e. 1 ton = 1000 kg) to population by country over time

Select air.Country, air.Year, pop.Population, air.[Nitrogen oxide (NOx)], air.[Sulphur dioxide (SO2)], air.[Carbon monoxide (CO)], air.[Organic carbon (OC)], air.NMVOCs, air.[Black carbon (BC)], air.[Ammonia (NH3)]
FROM PortfolioProjectAirPollution..AirPollution  air
JOIN PortfolioProjectAirPollution..WorldPopulationbyRegion pop
	ON air.Country = pop.Country
	AND air.Year = pop.Year
WHERE pop.Code is not null
ORDER BY Country, Year

-- Compare normalized pollution output (kg/person) to population by country over time

Select air.Country, air.Year, pop.Population, (air.[Nitrogen oxide (NOx)]/pop.Population)*1000 AS NOxperPerson, (air.[Sulphur dioxide (SO2)]/pop.Population)*1000 AS SO2perPerson
, (air.[Carbon monoxide (CO)]/pop.Population)*1000 AS COperPerson, (air.[Organic carbon (OC)]/pop.Population)*1000 AS OCperPerson
, (air.NMVOCs/pop.Population)*1000 AS NMVOCperPerson, (air.[Black carbon (BC)]/pop.Population)*1000 AS BCperPerson, (air.[Ammonia (NH3)]/pop.Population)*1000 AS NH3perPerson
FROM PortfolioProjectAirPollution..AirPollution  air
JOIN PortfolioProjectAirPollution..WorldPopulationbyRegion pop
	ON air.Country = pop.Country
	AND air.Year = pop.Year
WHERE pop.Code is not null
ORDER BY Country, Year

--Compare deaths (per 100,000 people) and normalized pollution output (kg/person) to population by country over time
Select air.Country, air.Year, pop.Population, (air.[Nitrogen oxide (NOx)]/pop.Population)*1000 AS NOxperPerson, (air.[Sulphur dioxide (SO2)]/pop.Population)*1000 AS SO2perPerson
, (air.[Carbon monoxide (CO)]/pop.Population)*1000 AS COperPerson, (air.[Organic carbon (OC)]/pop.Population)*1000 AS OCperPerson
, (air.NMVOCs/pop.Population)*1000 AS NMVOCperPerson, (air.[Black carbon (BC)]/pop.Population)*1000 AS BCperPerson, (air.[Ammonia (NH3)]/pop.Population)*1000 AS NH3perPerson
, (death.DeathsAlzheimers/pop.Population)*100000 AS DeathAlzheimper100k, (death.DeathsParkinsons/pop.Population)*100000 AS DeathParkinsonper100k, (death.DeathsTuberculosis/pop.Population)*100000 AS DeathTubercper100k
, (death.DeathsCardiovascularDiseases/pop.Population)*100000 AS DeathCardiovascper100k, (death.DeathsLowerRespiratoryInfections/pop.Population)*100000 AS DeathLowerRespInfper100k
, (death.DeathsDiabetesMellitus/pop.Population)*100000 AS DeathDiabetesper100k, (death.DeathsChronicKidneyDisease/pop.Population)*100000 AS DeathChronicKidneyper100k
, (death.DeathsChronicRespiratoryDiseases/pop.Population)*100000 AS DeathChronicRespper100k 
FROM PortfolioProjectAirPollution..AirPollution  air
JOIN PortfolioProjectAirPollution..WorldPopulationbyRegion pop
	ON air.Country = pop.Country
	AND air.Year = pop.Year
JOIN PortfolioProjectAirPollution..AnnualDeathsbyCause death
	ON air.Country = death.Country
	AND air.Year = death.Year
WHERE pop.Code is not null
ORDER BY Country, Year

-- Next, do a time series correlation analysis, but will do this in Python (didn't work well, remake the table

--Compare cardiac deaths (per 100,000 people) and chronic respiratory disease (per 100,000) and normalized pollution output (kg/person) to population OR particulate matter (PM2.5) by country over time
-- note that PM2.5 is particles 2.5 microns or less and is measured as mean annual exposure (micrograms per cubic meter), so this too is basically per person
Select air.Country, air.Year, pop.Population, part.PM25, (air.[Nitrogen oxide (NOx)]/pop.Population)*1000 AS NOxperPerson, (air.[Sulphur dioxide (SO2)]/pop.Population)*1000 AS SO2perPerson
, (air.[Carbon monoxide (CO)]/pop.Population)*1000 AS COperPerson, (air.[Organic carbon (OC)]/pop.Population)*1000 AS OCperPerson
, (air.NMVOCs/pop.Population)*1000 AS NMVOCperPerson, (air.[Black carbon (BC)]/pop.Population)*1000 AS BCperPerson, (air.[Ammonia (NH3)]/pop.Population)*1000 AS NH3perPerson
, (death.DeathsCardiovascularDiseases/pop.Population)*100000 AS DeathCardiovascper100k
, (death.DeathsChronicRespiratoryDiseases/pop.Population)*100000 AS DeathChronicRespper100k
FROM PortfolioProjectAirPollution..AirPollution  air
JOIN PortfolioProjectAirPollution..WorldPopulationbyRegion pop
	ON air.Country = pop.Country
	AND air.Year = pop.Year
JOIN PortfolioProjectAirPollution..AnnualDeathsbyCause death
	ON air.Country = death.Country
	AND air.Year = death.Year
JOIN PortfolioProjectAirPollution..PM25airpollution part
	ON air.Country = part.Country
	AND air.Year = part.Year
WHERE pop.Code is not null
ORDER BY Country, Year

-- order by highest cardiovascular deaths
Select air.Country, air.Year, pop.Population, part.PM25, (air.[Nitrogen oxide (NOx)]/pop.Population)*1000 AS NOxperPerson, (air.[Sulphur dioxide (SO2)]/pop.Population)*1000 AS SO2perPerson
, (air.[Carbon monoxide (CO)]/pop.Population)*1000 AS COperPerson, (air.[Organic carbon (OC)]/pop.Population)*1000 AS OCperPerson
, (air.NMVOCs/pop.Population)*1000 AS NMVOCperPerson, (air.[Black carbon (BC)]/pop.Population)*1000 AS BCperPerson, (air.[Ammonia (NH3)]/pop.Population)*1000 AS NH3perPerson
, (death.DeathsCardiovascularDiseases/pop.Population)*100000 AS DeathCardiovascper100k
, (death.DeathsChronicRespiratoryDiseases/pop.Population)*100000 AS DeathChronicRespper100k
FROM PortfolioProjectAirPollution..AirPollution  air
JOIN PortfolioProjectAirPollution..WorldPopulationbyRegion pop
	ON air.Country = pop.Country
	AND air.Year = pop.Year
JOIN PortfolioProjectAirPollution..AnnualDeathsbyCause death
	ON air.Country = death.Country
	AND air.Year = death.Year
JOIN PortfolioProjectAirPollution..PM25airpollution part
	ON air.Country = part.Country
	AND air.Year = part.Year
WHERE pop.Code is not null
ORDER BY NOxperPerson desc