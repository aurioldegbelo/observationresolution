{-# LANGUAGE MultiParamTypeClasses, DatatypeContexts #-} 

{-  
	 Haskell specification presented in the fourth chapter of 'Spatial and Temporal Resolution of Sensor Observations'
	 The scope of the specification is limited to the resolution of a *single* sensor observation
     +++ Main modelling choices +++ 
   - spatial resolution as the spatial receptive field of the observer participating in the observation process
   - temporal resolution as the temporal receptive window of the observer participating in the observation process
   - an observer has a certain number of receptors that participate in an observation process
   - spatial receptive field is modelled as the spatial region covered by the receptors which have been triggered during the observation process
   - temporal receptive window is modelled as the amount of time needed by the observer to detect the stimuli and produce analog signals based on them 
	 Last modified: August 16, 2013
	 Author: Auriol Degbelo
-}

module ObservationResolution where

type Id = Int -- an identifier
type Area = Int -- spatial area as Int
type Duration = Int -- temporal duration as Int
type Description = String -- description in natural language as String
type Quale = Double -- quale as Double
type Value = Double -- value as Double

-- Physical Endurants
class PHYSICAL_ENDURANTS physicalEndurant
class PHYSICAL_ENDURANTS amountOfMatter => AMOUNTS_OF_MATTER amountOfMatter -- amount of matters
class PHYSICAL_ENDURANTS physicalObject => PHYSICAL_OBJECTS physicalObject
class PHYSICAL_OBJECTS agent => AGENTIVE_OBJECTS agent -- agentive physical objects  
class PHYSICAL_OBJECTS nonAgent => NON_AGENTIVE_OBJECTS nonAgent -- non-agentive physical objects

-- a receptor has an id, a size, a processing time for incoming stimuli, and a certain function
data Receptor = Receptor {receptorId :: Id, size:: Area, processingTime:: Duration, function :: Description} deriving Show
measuringProbe = Receptor {receptorId = 1, size = 500, processingTime = 360, function = "detection of CO molecules"}

-- a receptor is a non-agentive physical object
instance PHYSICAL_ENDURANTS Receptor
instance PHYSICAL_OBJECTS Receptor
instance NON_AGENTIVE_OBJECTS Receptor

-- an observer has an id, a number of receptors of a certain type, a temporal receptive window, a quale, an observation value, and has its receptors activated or not.
--(for simplicity it is assumed that none of the receptors misfunctions, that is, either all the receptors functionned or none of them)
data Observer = Observer {observerId :: Id, numberOfReceptors :: Int, temporalReceptiveWindow :: Duration, receptor :: Receptor, quale :: Quale, receptorTriggered:: Bool, observationValue :: Value} deriving Show
coAnalyzer = Observer {observerId = 1, numberOfReceptors = 1, temporalReceptiveWindow = 0, receptor = measuringProbe, quale = 0.0, receptorTriggered = False, observationValue = 0}

-- an observer is an agentive physical object 
instance PHYSICAL_ENDURANTS Observer
instance PHYSICAL_OBJECTS Observer
instance AGENTIVE_OBJECTS Observer

-- an amount of air has an id, and contains a certain amount of carbon monoxide
data AmountOfAir = AmountOfAir {airId :: Id, carbonMonoxide :: Double} deriving Show
cityAir = AmountOfAir {airId = 1, carbonMonoxide = 2.8}

-- an amount of air is an amount of matter(and also a physical endurant) 
instance PHYSICAL_ENDURANTS AmountOfAir
instance AMOUNTS_OF_MATTER AmountOfAir
 
-- Qualities
-- Qualities have hosts in which they inhere
class QUALITIES quality entity where
	host :: quality entity -> entity
	
--class QUALITIES quality entity => ABSTRACT_QUALITIES quality entity-- an abstract quality is a quality 

-- definition of the quality carbon monoxide
data PHYSICAL_ENDURANTS physicalEndurant => CarbonMonoxide physicalEndurant = CarbonMonoxide physicalEndurant deriving Show
instance QUALITIES CarbonMonoxide AmountOfAir where
	-- the host of the carbon monoxide quality is the amount of air
	host (CarbonMonoxide amountOfAir) = amountOfAir
	
-- Stimulus as a process which involves a quality and an agent
class (QUALITIES quality entity, AGENTIVE_OBJECTS agent) => STIMULI quality entity agent where
	perceive :: quality entity -> agent -> agent

instance STIMULI CarbonMonoxide AmountOfAir Observer where
	perceive (CarbonMonoxide amountOfAir) observer = observer {receptorTriggered = True, quale = carbonMonoxide amountOfAir, temporalReceptiveWindow = processingTime (receptor observer)}

-- Observation as a process which involves a quality and an agent
class STIMULI quality entity agent => OBSERVATIONS quality entity agent where
	observe :: quality entity -> agent -> agent

instance OBSERVATIONS CarbonMonoxide AmountOfAir Observer where
	observe (CarbonMonoxide amountOfAir) observer = observer{quale = quale (perceive (CarbonMonoxide amountOfAir) observer), observationValue = quale (perceive (CarbonMonoxide amountOfAir) observer), temporalReceptiveWindow = temporalReceptiveWindow (perceive (CarbonMonoxide amountOfAir) observer), receptorTriggered = receptorTriggered (perceive (CarbonMonoxide amountOfAir) observer)}

-- the specification of the resolution of an observation necessitates the occurence of the observation	
class OBSERVATIONS quality entity agent => OBSERVATION_RESOLUTIONS quality entity agent where
-- spatial resolution of an observation value (with reference to a certain quality) is an area
	spatialResolutionObservation :: quality entity -> agent -> Area
-- temporal resolution of an observation value (with reference to a certain quality) is a duration
	temporalResolutionObservation :: quality entity -> agent -> Duration

instance OBSERVATION_RESOLUTIONS CarbonMonoxide AmountOfAir Observer where 
	-- spatial resolution of an observation is equal to the spatial receptive field of the observer
	spatialResolutionObservation (CarbonMonoxide amountOfAir) observer = spatialReceptiveField (perceive (CarbonMonoxide amountOfAir) observer)
	-- temporal resolution of an observation is equal to the temporal receptive window of the observer
	temporalResolutionObservation (CarbonMonoxide amountOfAir) observer = temporalReceptiveWindow (perceive (CarbonMonoxide amountOfAir) observer)

-- spatial receptive field as the size of all receptors triggered during the observation process
-- spatial receptive field is undefined when no receptor has been triggered during the observation process		
spatialReceptiveField :: Observer -> Area
spatialReceptiveField observer = if (receptorTriggered observer == True)
						         then (numberOfReceptors observer) * size (receptor observer)
						         else undefined		
 						 
-- some tests
testInitialObservation = coAnalyzer  -- initial observation: no value for the quale, no observation value, no value for the temporal receptive window, and the receptors have not been triggered
testPerception = perceive (CarbonMonoxide cityAir) coAnalyzer  -- after a perception operation: there is a value for the quale, the temporal receptive window is initialized, and the receptors have been triggered; there is no observation value
testObservation = observe (CarbonMonoxide cityAir) coAnalyzer -- after an observation: there is a value for the quale, the receptors have been triggered, and there is one observation value 
testSpatialResolution =  spatialResolutionObservation (CarbonMonoxide cityAir) coAnalyzer -- only information about the perception operation is required to estimate the spatial resolution of the observation 
testTemporalResolution =  temporalResolutionObservation (CarbonMonoxide cityAir) coAnalyzer -- only information about the perception operation is required to estimate the temporal resolution of the observation
