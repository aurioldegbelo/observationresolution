{-# LANGUAGE MultiParamTypeClasses, DatatypeContexts #-} 

-- MultiParamTypeClasses: this Haskell extension allows the definition of type classes with multiple parameters
-- DatatypeContexts: this Haskell extension allows the use of contexts in data type declarations

{-
	 Haskell specification presented in the fourth chapter of 'Spatial and Temporal Resolution of Sensor Observations'
	 The scope of the specification is limited to the resolution of a *single* sensor observation
     +++ Main modelling choices +++ 
   - spatial resolution as the spatial receptive field of the observer participating in the observation process
   - temporal resolution as the temporal receptive window of the observer participating in the observation process
   - an observer has a certain number of receptors that participate in an observation process
   - spatial receptive field is modelled as the size of the spatial region covered by the receptors which have been stimulated during the observation process
   - temporal receptive window is modelled as the amount of time needed by the observer to detect the stimuli and produce analog signals based on them
   - A value can have one of four types (drawing on ideas from [1],[2],[3] and [4])
     * numerical discrete (resulting from a counting process)
     * numerical continuous (resulting from a measurement process. What is measured is the magnitude of a certain quality, and measurement results always come with an associated measurement unit)
     * categorical nominal (cannot be organized in a logical sequence)
     * categorical ordinal (can be logically ordered or ranked)
		-- References --
		[1] Australian Bureau of Statistics (2014). Statistics Language - What are variables? (http://www.abs.gov.au/websitedbs/a3121120.nsf/home/statistical+language+-+what+are+variables)
		[2] Winters et al (2010). Statistics: A Brief Overview. The Ochsner Journal, 10(3), 213–216
		[3] Massey University (2014). Type variable (http://www-ist.massey.ac.nz/dstirlin/CAST/CAST/Hstructures/structures_a2.html)
		[4] Ryan (2014). The Chi Square Statistic (http://math.hws.edu/javamath/ryan/ChiSquare.html)
	
	Author: Auriol Degbelo <degbelo@uni-muenster.de>
	Last modified: May 23, 2014
-}

module ObservationResolution where

type Id = String -- an identifier
type Area = Int -- spatial area as Int
type Duration = Int -- temporal duration as Int
type Description = String -- description in natural language as String
type Unit = String -- measurement unit as String

-- A magnitude in this context is the size of a certain region in a quality space (magnitude as Double)
-- This is in line with (Probst 2008) who views magnitudes as regions in a certain quality space and calls them atomic quality regions
type Magnitude = Double -- magnitude as Double

-- Definition of the datatype Quale 
data Quale = Quale Magnitude deriving Show

-- Definition of the datatype for observation values
data ObsValue = Count Int | Measure Magnitude Unit | Category String | Ordinal String deriving Show

-- Physical Endurants
class PHYSICAL_ENDURANTS physicalEndurant
class PHYSICAL_ENDURANTS amountOfMatter => AMOUNTS_OF_MATTER amountOfMatter -- amount of matters
class PHYSICAL_ENDURANTS physicalObject => PHYSICAL_OBJECTS physicalObject
class PHYSICAL_OBJECTS agent => AGENTIVE_OBJECTS agent -- agentive physical objects  
class PHYSICAL_OBJECTS nonAgent => NON_AGENTIVE_OBJECTS nonAgent -- non-agentive physical objects

-- a receptor has an id, a size, a processing time for incoming stimuli, and a certain role
data Receptor = Receptor {receptorId :: Id, receptorSize :: Area, processingTime:: Duration, role :: Description} deriving Show
measuringProbe = Receptor {receptorId = "re1", receptorSize = 1500, processingTime = 60, role = "detection of CO molecules"}

-- a receptor is a non-agentive physical object
instance PHYSICAL_ENDURANTS Receptor
instance PHYSICAL_OBJECTS Receptor
instance NON_AGENTIVE_OBJECTS Receptor

-- an observer has an id, a number of receptors of a certain type. It carries a quale and an observation value
-- the measurement unit used below for observation values is 'ppm' standing for parts per million
data Observer = Observer {observerId :: Id,  receptor :: Receptor, numberOfReceptors :: Int, quale :: Quale, observationValue :: ObsValue} deriving Show
coAnalyzer = Observer {observerId = "ob1", receptor = measuringProbe, numberOfReceptors = 1, quale = Quale 0.0, observationValue = Measure 0.0 "ppm"}

-- an observer is an agentive physical object
instance PHYSICAL_ENDURANTS Observer
instance PHYSICAL_OBJECTS Observer
instance AGENTIVE_OBJECTS Observer

-- an amount of air contains a certain amount (i.e. magnitude) of carbon monoxide
data AmountOfAir = AmountOfAir {carbonMonoxideMagnitude :: Magnitude} deriving Show
cityAir = AmountOfAir {carbonMonoxideMagnitude = 2.8}

-- an amount of air is an amount of matter (and also a physical endurant)
instance PHYSICAL_ENDURANTS AmountOfAir
instance AMOUNTS_OF_MATTER AmountOfAir

-- Qualities
-- Qualities have hosts in which they inhere
class QUALITIES quality entity where
	host :: quality entity -> entity

-- definition of the quality carbon monoxide
data PHYSICAL_ENDURANTS physicalEndurant => CarbonMonoxide physicalEndurant = CarbonMonoxide physicalEndurant deriving Show
instance QUALITIES CarbonMonoxide AmountOfAir where
	-- the host of the carbon monoxide quality is the amount of air
	host (CarbonMonoxide amountOfAir) = amountOfAir

-- Stimulus as a process which involves a quality and an agent
class (QUALITIES quality entity, AGENTIVE_OBJECTS agent) => STIMULI quality entity agent where
-- perception as a behaviour, that takes as input a stimulus, and returns as output a quale that is carried by an agent
	perceive :: quality entity -> agent -> agent

instance STIMULI CarbonMonoxide AmountOfAir Observer where
	perceive (CarbonMonoxide amountOfAir) observer = observer {quale = magnitudeToQuale(carbonMonoxideMagnitude amountOfAir)}

-- Observation as a process which involves a quality and an agent
class STIMULI quality entity agent => OBSERVATIONS quality entity agent where
	observe :: quality entity -> agent -> agent

instance OBSERVATIONS CarbonMonoxide AmountOfAir Observer where
	observe (CarbonMonoxide amountOfAir) observer = observer{quale = quale (perceive (CarbonMonoxide amountOfAir) observer), observationValue = qualeToMeasure (quale (perceive (CarbonMonoxide amountOfAir) observer))}

-- the specification of the resolution of an observation necessitates the occurrence of the observation
class OBSERVATIONS quality entity agent => OBSERVATION_RESOLUTIONS quality entity agent where
-- spatial resolution of an observation value (with reference to a certain quality) is an area. The observation value is carried by the agent
	spatialResolutionObservation :: quality entity -> agent -> Area
-- temporal resolution of an observation value (with reference to a certain quality) is a duration. The observation value is carried by the agent
	temporalResolutionObservation :: quality entity -> agent -> Duration

instance OBSERVATION_RESOLUTIONS CarbonMonoxide AmountOfAir Observer where 
	-- spatial resolution of an observation is equal to the spatial receptive field of the observer
	spatialResolutionObservation (CarbonMonoxide amountOfAir) observer = spatialReceptiveField (perceive (CarbonMonoxide amountOfAir) observer)
	-- temporal resolution of an observation is equal to the temporal receptive window of the observer
	temporalResolutionObservation (CarbonMonoxide amountOfAir) observer = temporalReceptiveWindow (perceive (CarbonMonoxide amountOfAir) observer)

-- spatial receptive field as the size of all receptors which were stimulated during the observation process
-- for simplicity, the current example assumes that there is no malfunction, that is all receptors (detecting the CO molecules) were stimulated 
spatialReceptiveField :: Observer -> Area
spatialReceptiveField observer = numberOfReceptors observer * receptorSize (receptor observer)
					  
-- temporal receptive window as the processing time of the receptors stimulated during the observation process 
temporalReceptiveWindow :: Observer -> Duration
temporalReceptiveWindow observer =  processingTime (receptor observer)
				 
{- approximation of the absolute magnitude of the observed quality is introduced during the observation process at two stages : the mapping from a magnitude to a quale, the mapping from the quale to a value. 
   The approximation factor introduced below is intended to reflect this fact. For simplicity, the value of the approximation factor is set to 0.9, and the same value is used for both mappings : magnitude to value
   and quale to value. A thorough treatment would generate two approximation factors *randomly* from *an interval*, say [0.9, 1.1], to account for the facts that :
   (i) observers (especially humans) at times overestimate, at time underestimate the intensity of the quality they are observing
   (ii) the estimation of the absolute magnitude by a given observer can vary (from one observation to another) even if the observing conditions remain unchanged
   (iii) mapping processes from magnitude to quale, and from quale to value may yield different approximation factors for the observed magnitude
-}
aFactor = 0.9 :: Double

-- this function establishes a mapping from a certain magnitude to the corresponding quale
-- the approximation factor is introduced to reflect the fact that qualia approximate absolute magnitudes
magnitudeToQuale :: Magnitude -> Quale
magnitudeToQuale magnitude = Quale (magnitude * aFactor)

-- this function establishes a mapping between a quale and an observation value (resulting from a measurement process). The unit associated with observation values in this example is "ppm".
-- there is a further approximation of the magnitude during this process
qualeToMeasure :: Quale -> ObsValue 
qualeToMeasure (Quale magnitude) = Measure (magnitude * aFactor) "ppm"
									
-- some tests
testInitialObservation = coAnalyzer  -- initial observation: no value for the quale, no observation value
testPerception = perceive (CarbonMonoxide cityAir) coAnalyzer  -- after a perception operation: there is a value for the quale, there is no observation value
testObservation = observe (CarbonMonoxide cityAir) coAnalyzer -- after an observation: there is a value for the quale, and there is one observation value 
testSpatialResolution =  spatialResolutionObservation (CarbonMonoxide cityAir) coAnalyzer -- only information about the perception operation is required to estimate the spatial resolution of the observation 
testTemporalResolution =  temporalResolutionObservation (CarbonMonoxide cityAir) coAnalyzer -- only information about the perception operation is required to estimate the temporal resolution of the observation