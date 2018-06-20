{-# LANGUAGE MultiParamTypeClasses #-} 

{-  
	 Haskell specification presented in the fifth chapter of 'Spatial and Temporal Resolution of Sensor Observations'
	 The scope of the specification is limited to the resolution of an observation collection
     +++ Main modelling choices +++ 
   - observation collections as lists
   - spatial resolution as the observed study area (i.e. portion of the study area that has been observed)
   - the observed study area is the sum of the distinct observed areas of the observations which are members of the collection
   - the observed area of an observation is the spatial region of the phenomenon of interest that has been observed. It can be estimated using the 
     spatial receptive field or the spatial location of the observer. The examples presented in this specification take 'observed area' of an 
	 observation as the spatial location of the observer
   - temporal resolution as the observed study period (i.e. portion of the study period that has been observed)
   - the observed study period is the sum of the distinct observed periods of the observations which are members of the collection
   - the observed period of an observation is the temporal region of the phenomenon of interest that has been observed. It can be estimated using the 
     temporal receptive window or the temporal location of the observer. The examples presented in this specification take 'observed period' of an 
	 observation as the temporal location of the observer
	 Last modified: August 16, 2013
-}

module ObservationCollectionResolution where

import Data.List
type Id = Int -- an identifier

type Area = Int -- spatial area as Int
type Duration = Int -- temporal duration as Int
type Value = Double -- value as Double

type ObserverName = String -- observer name as String

-- introduction of DOLCE's classes space_region and temporal_region
class ABSTRACTS abstract
class ABSTRACTS region => REGIONS region
class REGIONS temporalRegion => TEMPORAL_REGIONS temporalRegion -- a DOLCE temporal region (temporal region is a region)
class REGIONS physicalRegion => PHYSICAL_REGIONS physicalRegion
class PHYSICAL_REGIONS spaceRegion => SPACE_REGIONS spaceRegion -- a DOLCE space region (space region is a region)

-- non-physical endurants and social objects
class NON_PHYSICAL_ENDURANTS nonPhysicalEndurant
class NON_PHYSICAL_ENDURANTS nonPhysicalObject => NON_PHYSICAL_OBJECTS nonPhysicalObject
class NON_PHYSICAL_OBJECTS socialObject => SOCIAL_OBJECTS socialObject -- social object

-- a spatial region has an id and a size 
data SpatialRegion = SpatialRegion {srId:: Id, srSize :: Area} deriving Show
spatialregion1 = SpatialRegion {srId=1, srSize= 100} 
spatialregion2 = SpatialRegion {srId=2, srSize= 100}
spatialregion3 = SpatialRegion {srId=3, srSize= 100}
unknownSpatialRegion = Nothing

-- a temporal region has an id and a size 
data TemporalRegion =  TemporalRegion {trId:: Id, trSize :: Duration} deriving Show
temporalregion1 = TemporalRegion {trId=1, trSize= 60}
temporalregion2 = TemporalRegion {trId=2, trSize= 60}
temporalregion3 = TemporalRegion {trId=3, trSize= 60}
temporalregion4 = TemporalRegion {trId=4, trSize= 60}
temporalregion5 = TemporalRegion {trId=5, trSize= 60}
temporalregion6 = TemporalRegion {trId=6, trSize= 60}
temporalregion7 = TemporalRegion {trId=7, trSize= 60}
unknownTemporalRegion = Nothing

-- a spatial region is a (DOLCE) space region  
instance ABSTRACTS SpatialRegion
instance REGIONS SpatialRegion
instance PHYSICAL_REGIONS SpatialRegion
instance SPACE_REGIONS SpatialRegion

-- a temporal region is a (DOLCE) temporal region
instance ABSTRACTS TemporalRegion
instance REGIONS TemporalRegion
instance TEMPORAL_REGIONS TemporalRegion

-- an observation has an id, and a value; it was produced by an observer (the observer is identified here by its name)
data Observation =  Observation {obsId:: Id, observer:: ObserverName, obsValue:: Value} deriving Show

-- an observation is a social object
instance NON_PHYSICAL_ENDURANTS Observation
instance NON_PHYSICAL_OBJECTS Observation
instance SOCIAL_OBJECTS Observation

-- b1 is produced by the observer B and has the value of 2.8 ppm (parts per million) 
b1= Observation {obsId =1, observer = "B", obsValue = 2.8}
b2= Observation {obsId =2, observer = "B", obsValue = 2.9}
b3= Observation {obsId =3, observer = "B", obsValue = 2.5}
b4= Observation {obsId =4, observer = "B", obsValue = 2.6}
b5= Observation {obsId =5, observer = "B", obsValue = 2.3}

c1= Observation {obsId =6, observer = "C", obsValue = 4}

e1= Observation {obsId =7, observer = "E", obsValue = 3.5}
e2= Observation {obsId =8, observer = "E", obsValue = 3.3}

-- definition of location  
class LOCATED observation where
	-- spatial location as a relation between an observation and a spatial region
	spatialLocation :: observation -> SpatialRegion 
	-- temporal location as a relation between an observation and a temporal region
	temporalLocation :: observation -> TemporalRegion

-- spatial and temporal locations are assigned to the different observations (spatial/temporal location of an observation is equal to the spatial/temporal location
-- of the observer. For simplicity, the locations of the observers are not represented in this example. The functions below provide only a mechanism to 
-- ascribe a spatial/temporal region to the observation)	
instance LOCATED Observation where
	spatialLocation Observation{obsId=oId, observer=obsSensor, obsValue = oValue} =  SpatialRegion{srId = if(obsSensor == "B") then 1 else (if obsSensor == "C" then 2 else 3), srSize=100}
	temporalLocation Observation{obsId=oId, observer=obsSensor, obsValue = oValue} = TemporalRegion{trId = if (obsSensor == "B" && oId == 1) then 1 else (if (obsSensor == "B" && oId == 2) then 2 else if (obsSensor == "B" && oId == 3) then 3 else if (obsSensor == "B" && oId == 4) then 4 else if (obsSensor == "B" && oId == 5) then 5 else if (obsSensor == "C") then 3 else if (obsSensor == "E" && oId == 7) then 6 else 7), trSize = 60}
-- some examples of spatial location 
slB1 = spatialLocation b1
slB2 = spatialLocation b2
slB3 = spatialLocation b3
slB4 = spatialLocation b4
slB5 = spatialLocation b5
slC1 = spatialLocation c1
slE1 = spatialLocation e1
slE2 = spatialLocation e2
-- some examples of temporal location
tlB1 = temporalLocation b1
tlB2 = temporalLocation b2
tlB3 = temporalLocation b3
tlB4 = temporalLocation b4
tlB5 = temporalLocation b5
tlC1 = temporalLocation c1
tlE1 = temporalLocation e1
tlE2 = temporalLocation e2

-- definition of observed regions (i.e. areas and periods) for located observations
-- observed area/period is a relation between an observation and a spatial/temporal region
class LOCATED observation => OBSERVED_REGIONS observation where
	observedArea :: observation -> SpatialRegion
	observedPeriod :: observation -> TemporalRegion
	
instance OBSERVED_REGIONS Observation where
	-- the observed area is defined (in the current example) as the spatial location of the observation
	observedArea observation = spatialLocation observation
	-- the observed period is defined (in the current example) as the temporal location of the observation
	observedPeriod observation = temporalLocation observation

-- an observation collection has different observations as members
-- there is no need for an id, since an observation collection is uniquely identified by its members
data ObservationCollection = ObservationCollection {obsMembers :: [Observation]}  deriving Show

-- an observation collection is a social object
instance NON_PHYSICAL_ENDURANTS ObservationCollection
instance NON_PHYSICAL_OBJECTS ObservationCollection
instance SOCIAL_OBJECTS ObservationCollection

-- three examples of observation collections
obsCollection1 = ObservationCollection {obsMembers = [b1, b2, b3, b4, b5]}
obsCollection2 = ObservationCollection {obsMembers = [b3, c1]}
obsCollection3 = ObservationCollection {obsMembers = [e1, e2]}

-- definition of observed study regions (i.e. areas and periods) for observation collections 
class OBSERVED_STUDY_REGIONS observationcollection where
		observedStudyArea :: observationcollection -> Area
		observedStudyPeriod :: observationcollection -> Duration
		
instance OBSERVED_STUDY_REGIONS ObservationCollection where
		-- the observed study area is the sum of the (distinct) observed areas of the observations
		observedStudyArea observationcollection = srSize(observedArea(head(obsMembers observationcollection))) * (fromIntegral (length (nub (spatialregionsId observationcollection))))
		-- the observed study period is the sum of the (distinct) observed periods of the observations
		observedStudyPeriod observationcollection = trSize(observedPeriod(head(obsMembers observationcollection))) * (fromIntegral (length (nub (temporalregionsId observationcollection))))

-- the specification of the resolution of an observation collection necessitates the existence of an observed study region for the observation collection
class OBSERVED_STUDY_REGIONS observationcollection => OBSERVATION_COLLECTION_RESOLUTIONS observationcollection where
		spatialResolution :: observationcollection -> Area
		temporalResolution :: observationcollection -> Duration

instance OBSERVATION_COLLECTION_RESOLUTIONS ObservationCollection where
		 -- spatial resolution as the observed study area of the observation collection
         spatialResolution observationcollection = observedStudyArea observationcollection
		 -- temporal resolution as the observed study period of the observation collection
         temporalResolution observationcollection = observedStudyPeriod observationcollection

-- the function returns all the spatial regions which play the role of 'observed area' for each of the observation in an observation collection
spatialregionsId :: ObservationCollection -> [Id]
spatialregionsId observationcollection = if null (tail (obsMembers observationcollection))
										 then srId(observedArea(head(obsMembers observationcollection))):[]
										 else srId(observedArea(head(obsMembers observationcollection))) : spatialregionsId ObservationCollection {obsMembers = tail (obsMembers observationcollection)}
										 
-- the function returns all the temporal regions which play the role of 'observed period' for each of the observation in an observation collection							 
temporalregionsId :: ObservationCollection -> [Id]
temporalregionsId observationcollection = if null (tail (obsMembers observationcollection))
										  then trId(observedPeriod(head(obsMembers observationcollection))):[]
										  else trId(observedPeriod(head(obsMembers observationcollection))) : temporalregionsId ObservationCollection {obsMembers = tail (obsMembers observationcollection)}

-- some examples of spatial and temporal resolution for an observation collection
sr1 = spatialResolution obsCollection1
sr2 = spatialResolution obsCollection2
sr3 = spatialResolution obsCollection3

tr1 = temporalResolution obsCollection1
tr2 = temporalResolution obsCollection2
tr3 = temporalResolution obsCollection3
