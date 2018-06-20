{-# LANGUAGE MultiParamTypeClasses #-} 

module ObservationCollectionResolution where

import Data.List
type Id = Int -- an identifier

-- introduction of DOLCE's classes space_region and temporal_region
class ABSTRACT abstract
class ABSTRACT region => REGION region
class REGION temporalRegion => TEMPORAL_REGION temporalRegion -- a temporal region is a region
class REGION physicalRegion => PHYSICAL_REGION physicalRegion
class PHYSICAL_REGION spaceRegion => SPACE_REGION spaceRegion -- a space region is a region

-- qualities
class QUALITY observationcollection
class QUALITY observationcollection => ABSTRACT_QUALITY observationcollection -- abstract qualities

-- non-physical endurants
class NON_PHYSICAL_ENDURANTS nonPhysicalEndurant
class NON_PHYSICAL_ENDURANTS nonPhysicalObject => NON_PHYSICAL_OBJECTS nonPhysicalObject
class NON_PHYSICAL_OBJECTS socialObject => SOCIAL_OBJECTS socialObject -- social object

-- a spatial region has an id and a size 
data SpatialRegion = SpatialRegion {srId:: Id, srSize :: Double} deriving Show
spatialregion1 = SpatialRegion {srId=1, srSize= 100} 
spatialregion2 = SpatialRegion {srId=2, srSize= 100}
spatialregion3 = SpatialRegion {srId=3, srSize= 100}
unknownSpatialRegion = Nothing

-- a temporal region has an id and a size 
data TemporalRegion =  TemporalRegion {trId:: Id, trSize :: Double} deriving Show
temporalregion1 = TemporalRegion {trId=1, trSize= 60}
temporalregion2 = TemporalRegion {trId=2, trSize= 60}
temporalregion3 = TemporalRegion {trId=3, trSize= 60}
temporalregion4 = TemporalRegion {trId=4, trSize= 60}
temporalregion5 = TemporalRegion {trId=5, trSize= 60}
temporalregion6 = TemporalRegion {trId=6, trSize= 60}
temporalregion7 = TemporalRegion {trId=7, trSize= 60}
unknownTemporalRegion = Nothing

-- a spatial region is a (DOLCE) space region  
instance ABSTRACT SpatialRegion
instance REGION SpatialRegion
instance PHYSICAL_REGION SpatialRegion
instance SPACE_REGION SpatialRegion

-- a temporal region is a (DOLCE) temporal region
instance ABSTRACT TemporalRegion
instance REGION TemporalRegion
instance TEMPORAL_REGION TemporalRegion

-- an observation has an id, and a value; it was produced by a sensor
data Observation =  Observation {obsId:: Id, sensor:: String, obsValue:: String} deriving Show

-- an observation is a social object
instance NON_PHYSICAL_ENDURANTS Observation
instance NON_PHYSICAL_OBJECTS Observation
instance SOCIAL_OBJECTS Observation

-- b1 is produced by the sensor B and has the value of 2.8 ppm (parts per million) 
b1= Observation {obsId =1, sensor = "B", obsValue = "2.8"}
b2= Observation {obsId =2, sensor = "B", obsValue = "2.9"}
b3= Observation {obsId =3, sensor = "B", obsValue = "2.5"}
b4= Observation {obsId =4, sensor = "B", obsValue = "2.6"}
b5= Observation {obsId =5, sensor = "B", obsValue = "2.3"}

c1= Observation {obsId =6, sensor = "C", obsValue = "4"}

e1= Observation {obsId =7, sensor = "E", obsValue = "3.5"}
e2= Observation {obsId =8, sensor = "E", obsValue = "3.3"}

-- location is an abstract quality
class ABSTRACT_QUALITY observation => LOCATED observation where
	-- spatial location as a relation between an observation and a spatial region
	spatialLocation :: observation -> SpatialRegion 
	-- temporal location as a relation between an observation and a temporal region
	temporalLocation :: observation -> TemporalRegion

-- spatial and temporal locations are arbitrarily assigned to the different observations	
instance LOCATED Observation where
	spatialLocation Observation{obsId=oId, sensor=obsSensor, obsValue = oValue} =  SpatialRegion{srId = if(obsSensor == "B") then 1 else (if obsSensor == "C" then 2 else 3), srSize=100}
	temporalLocation Observation{obsId=oId, sensor=obsSensor, obsValue = oValue} = TemporalRegion{trId = if (obsSensor == "B" && oId == 1) then 1 else (if (obsSensor == "B" && oId == 2) then 2 else if (obsSensor == "B" && oId == 3) then 3 else if (obsSensor == "B" && oId == 4) then 4 else if (obsSensor == "B" && oId == 5) then 5 else if (obsSensor == "C") then 3 else if (obsSensor == "E" && oId == 7) then 6 else 7), trSize = 60}
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

-- area/window of influence as abstract quality
-- area/window of influence is a relation between an observation and a spatial/temporal region
class ABSTRACT_QUALITY observation => INFLUENCE observation where
	areaOfInfluence :: observation -> SpatialRegion
	windowOfInfluence :: observation -> TemporalRegion
	
instance INFLUENCE Observation where
	-- the area of influence is defined as the spatial location of the observation
	areaOfInfluence observation = spatialLocation observation
	-- the window of influence is defined as the temporal location of the observation
	windowOfInfluence observation = temporalLocation observation

instance QUALITY Observation 
instance ABSTRACT_QUALITY Observation 

-- an observation collection has different observations as members
-- there is no need for an id, since an observation collection is uniquely identified by its members
data ObservationCollection = ObservationCollection {obsMembers :: [Observation]}  deriving Show

-- an observation collection is a social object
instance NON_PHYSICAL_ENDURANTS ObservationCollection
instance NON_PHYSICAL_OBJECTS ObservationCollection
instance SOCIAL_OBJECTS ObservationCollection

-- three examples of observation collections
obsCollection1 = ObservationCollection {obsMembers = [b1, b2, b3, b4, b5]}
obsCollection2 = ObservationCollection {obsMembers = [b3, c1] }
obsCollection3 = ObservationCollection {obsMembers = [e1, e2] }

-- resolution as an abstract quality	
class ABSTRACT_QUALITY observationcollection => RESOLUTION observationcollection where
		spatialResolution :: observationcollection -> Double
		temporalResolution :: observationcollection -> Double

instance QUALITY ObservationCollection 
instance ABSTRACT_QUALITY ObservationCollection 	

instance RESOLUTION ObservationCollection where
		 -- spatial resolution as the observed area of the observation collection
         spatialResolution observationcollection = observedArea observationcollection
		 -- temporal resolution as the observed period of the observation collection
         temporalResolution observationcollection = observedPeriod observationcollection
		 
-- the observed area is the sum of the (distinct) area of influences of the observations
observedArea :: ObservationCollection -> Double
observedArea observationcollection = srSize(areaOfInfluence(head(obsMembers observationcollection))) * (fromIntegral (length (nub (spatialregionsId observationcollection))))

-- the observed period is the sum of the (distinct) windows of influence of the observations
observedPeriod :: ObservationCollection -> Double
observedPeriod observationcollection = trSize(windowOfInfluence(head(obsMembers observationcollection))) * (fromIntegral (length (nub (temporalregionsId observationcollection))))

-- the function returns all the spatial regions which play the role of 'area of influence' for each of the observation in an observation collection
spatialregionsId :: ObservationCollection -> [Id]
spatialregionsId observationcollection = if null (tail (obsMembers observationcollection))
										 then srId(areaOfInfluence(head(obsMembers observationcollection))):[]
										 else srId(areaOfInfluence(head(obsMembers observationcollection))) : spatialregionsId ObservationCollection {obsMembers = tail (obsMembers observationcollection)}
										 
-- the function returns all the temporal regions which play the role of 'window of influence' for each of the observation in an observation collection							 
temporalregionsId :: ObservationCollection -> [Id]
temporalregionsId observationcollection = if null (tail (obsMembers observationcollection))
										  then trId(windowOfInfluence(head(obsMembers observationcollection))):[]
										  else trId(windowOfInfluence(head(obsMembers observationcollection))) : temporalregionsId ObservationCollection {obsMembers = tail (obsMembers observationcollection)}

-- some examples of spatial and temporal resolution for an observation collection
sr1 = spatialResolution obsCollection1
sr2 = spatialResolution obsCollection2
sr3 = spatialResolution obsCollection3

tr1 = temporalResolution obsCollection1
tr2 = temporalResolution obsCollection2
tr3 = temporalResolution obsCollection3