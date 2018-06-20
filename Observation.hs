{-# LANGUAGE MultiParamTypeClasses #-} 

{- Perception-Action Ontology

An algebraic specification of observations and actions resulting from perception. 
The code is an ontology, specifying the concepts, as well as a simulation, providing an executable model.
The goal is to understand the information processing involved, not the physics or psychology of agents.

Theoretical challenges addressed:
- exploit the parallel between perception leading to observed values and perception leading to actions
- clarify status of affordances in ontology
- exploit the potential of affordances to unite realist and conceptualist views
- work toward a general theory for the locating and timing of observations
- deal with resolution and uncertainty in sensor standards
- generalize over human and technical observations 

Practical goals:
- treat sensor systems and sensor networks also as (single) sensors
- connect the sensor web to the rest of the web
- allow users to assess whether sensor services are semantically interoperable
- clarify basic terminology in sensor standards ("phenomenon", "feature of interest", sensors as processes ...)
- produce observation ontologies defining observation semantics, rather than devices and data structures

Building on ideas from:
- OGC Standards (Observations and Measurements, SensorML): terminology, sensors as processes
- Webster 1999: Measurement, Instrumentation, and Sensors Handbook (CRC)
- Probst 2008: Observations, measurements and semantic reference spaces 
- Frank 2009: Why Is Scale an Effective Descriptor for Data Quality? (chapter in Navratil book)
- Frank 2001 ontological tiers (but we make less assumptions, e.g. points need no qualities which can be measured)
- Hayes 1985: Ontology for Liquids
- DOLCE D18
- Warren 1984
- Turvey 1992
- Stoffregen 2000

Basic terminology:
- OGC Observations and Measurements: "An Observation is an action with a result which has a value describing some phenomenon."
- OGC Reference Model: "An observation is an act associated with a discrete time instant or period through which 
	a number, term or other symbol is assigned to a phenomenon."
- Wikipedia: A "stimulus (plural stimuli) is a detectable change in the internal or external environment". 

Basic ontological commitments:
1. Following DOLCE, four categories of individuals are distinguished: endurants, perdurants, abstracts, and qualities.
	- Perdurants have endurants participating in them.
	- Qualities are what agents perceive.
	- Qualities inhere in individuals of any of the four top level categories (including arbitrary sums!).
	- Qualities can be physical (inhering in endurants), temporal (inhering in perdurants), or abstract (inhering in abstracts).
2. Human and technical sensors are agentive physical objects (agents, for short).
3. Agents perceive qualities through stimuli.
4. Stimuli are perdurants with participating quality bearers and agents.
5. Agents can observe perceived qualities.
6. Agents can act on perceived affordances. 
7. Afforded actions are intentional.
8. Perceiving is not afforded, as it is not necessarily intentional. 
9. Locations are not introduced as entities. Physical endurants locate other physical endurants through image schematic relations.

Stimuli can be
- physical processes involving a bearing endurant (e.g., heat transmission from an amount of air to a thermometer)
- bearers of observed temporal qualities (e.g., an earthquake)
They can also be produced by an observer (e.g., a sonar wave to measure distance).

Stimuli are detected through 
- a changing physical quality of a participating endurant, or
- a temporal quality of the stimulus or of a perdurant coupled with it.

The detection of stimuli results in analog signals, which are called qualia here.
- the term is used here for human qualia and (metaphorically) for technical sensors
- an agent can have any number of qualia (though we model only one for now)
- there are no complex qualia for now, as it makes more sense to combine qualia when expressing values, not when perceiving multiple qualities
- hypothesis: a quale corresponds to a dimension in a conceptual space  (consistent with DOLCE)
- this implies that qualia have an order relation
- simplest model is Float (an intensity or magnitude of perception)
- use Goguen's piece on qualia (esp. keio04) to refine later
- each quale will eventually be the result of a convolution of stimuli over space and time
- qualia are not mental objects, but something like mental features (they depend on an agent).

Observation values
- according to [Fowler 1998, SensorML], they can be boolean, count, measure with a unit, or category (nominal or ordinal) 
- but O&M allows any type as value, and we clearly need more (images, URLs, ...). 	
- use base types and introduce additional types where needed
- all types require an order relation (i.e. need to be instances of Ord)
- measurement units are the subject of their own ontology under development, we consider them to inhere in result values

Sensor systems and sensor networks:
- A sensor system is a collocated aggregate of sensors. 
- A sensor network is a set of communicating sensors. 
- Sensor systems and sensor networks can act as sensors observing a (single) complex observable.

Examples of
- physical qualities: the temperature of an amount of air, the taste of a glass of wine
- temporal qualities: the moment of a sunset, the duration of an earthquake
- physical affordances: the climbability of a step, the drinkability of water
- stimuli: the flow of heat energy, sound waves traveling to a surface and back
- sensor systems: a weather station aggregating individual sensor measurements, a doctor observing a patient and describing the patient's mood
- sensor networks: ...

Formalization:
We distinguish DOLCE's four top level categories formally, based on Haskell kinds:
1.	A quality is specified as a data constructor applied to any entity (e.g., "Temperature muensterAir").
2.	A quality type (a.k.a. property) is specified as a data constructor (e.g., "Temperature").
3. 	Endurants are of types with kind *
4. 	Perdurants are of types with higher kind than *.
5.	Abstracts are of any kind and have no data constructors. (Not so sure about that yet.)

Modeling decisions:
All entities are specified only minimally, recording the ontological distinctions deemed necessary for the envisioned reasoning. 
Individual qualities are understood to exist in mind-independent reality (as "ecological facts").
For example, a room has a temperature independently of any observers, and a step has a climbability independently of any observer.
Amounts of stuff are not parameterized in the stuff (e.g., air), because DOLCE does not consider stuff as such to be a particular.
Qualia are modelled as magnitudes in a (for simplicity) one-dimensional quality space.

Gains: an ontology of observation that...
- takes the form of a simulation
- grounds the semantics of observations in semantic datums
- includes affordances
- separates sensors as agents from sensing (i.e., observing) as process
- specifies what a "phenomenon" (OGC) is, namely a quality of an endurant or perdurant
- specifies what a "feature of interest" (OGC) is, namely a physical endurant or perdurant
- distinguishes observations related to endurants from those related to perdurants
- distinguishes internal (to the observer) and external bearers of qualities
- formalizes sensor fusion by recursion (observing observation results in sensor systems and sensor networks) 
- is neutral w.r.t. the field vs object distinction (both views are compatible with the ontology)
- treats observation results (values or actions) as dependent on agents.

To Do:
- pay attention to null value for qualia so that the datum functions in observations do not produce nonsense 
- the semantic datum will have to specify the thematic resolution (a.k.a. discrimination)
- spatial and temporal datums will be shown to be just special cases
- introduce notion of virtual sensor (as observation data stream), like swiss-experiment
- Relaxing the physical law connection between observed and targeted phenomena (use correct terms)
- relate to Vanicek model for observables
- switch to dolce core?
- should affordances be gradual?
- specify Stevens (and other) scales of measurement
- hypothesis: measurement scales are determined by the admissible operations on qualia (journal 5 jan 10)
- model more affordances from the literature, including social ones
- model step climbability for a wheel chair user
- turn time and position into observations (of an observation, of an agent, of an entity)
- these have reference systems like all other observations
- reintroduce sensor observations for coordinates or a toponym or a "cloud" of positions or a function of ClockTime
- add direction as observation of orientation 
- define position relationally: support by a surface, containment by a medium, anything else?
- define time relationally: preceding or during or following an event
- link to medium, substance, surface (from which endurants, qualities, and perdurants derive)
- extend with trust and reputation measures
- treat sensor dust as a case where the individual sensors do not position themselves
- introduce time-varying endurants
- model convolutions and uncertainty (showing that the notions of "error" and "true value" are unnecessary)
- model scale transitions (see also CC Gibson paper)
- model perdurants of change as instances (types) of image schema combinations
- define kinds of perdurant couplings
- implement datum transformations
- note (JO): agents set up an ego-centric reference system by partitioning a (presumed) quality space with their own dimensions
- extend by actuators (cute example dealing with uncertainty: SchrÃ¶dinger's cat!)
- close some action-perception-action loops
- build sensorimotor loop simulations to define semantics
- specify the negotiation of semantics in action-perception cycles (the observed entity is another agent)
- specify calibration as the process to establish semantic datums
- test with geodetic datum

Haskell improvements:
- check phantom types for actual subtypes, and haddock and hls for the comments, and astypeof (prelude)
- read hlist article by Laemmel
- read GADT Simon Peyton Jones

Adding code for grounding (COSIT 2009 paper):
- instead of places as primitives, can we use regions of objects, amounts of matter, or features?
- no: we need empty places; so, only abstract (not derived from entities) regions work 

Recent changes and issues:
- dropped claim that quality constructors applied to entities represent qualia or regions in quality spaces (they do not, as the agent is missing)
- dropped commitment that a quality maps endurants or perdurants to an abstract region in a quality space (may be true, but is not needed yet)
- perceiving is now the first step in observing all qualities (including affordances)
- observations and actions require an intention (coming from outside the system) and operate on the agent holding the necessary qualia
- abandoned the explicit act abstraction, as it is strenouous and now not needed without the compositional axiom above
- qualia and values require an order relation (by their nature and to reason when converting qualia to values)
- replaced the single data types Value and Quale by specialized value and qualia types, in order to constrain operations on them (such as <)
- this is possible because we have no free standing Value or Quale operation results (they only occur in agents)
- abandoned reading qualities, as they are not needed (sensor fusion in sensor systems can access component sensor values directly)
- reintroduced labeled fields, for better readability of axioms 
- abandoned explicit type classes for DOLCE top level (ABSTRACTS, ENDURANTS, PERDURANTS, QUALITIES)
- renamed APOS to AGENTS, for readability 
- separated an ACTIONS class from the OBSERVATIONS class, to keep the terminology simple

(c) Werner Kuhn
Improved by contributions from Jens Ortmann, Krzysztof Janowicz, Andrew Frank, and Simon Scheider
and comments from Christoph Stasch, Arne Broering, and Ilka Reis
Last modified: 16 Jun 2010 (WK)
-}

module Observation where

type Id = Int -- an identifier

---------------------------------
-- Physical Endurants

class PHYSICAL_ENDURANTS physicalEndurant
class PHYSICAL_ENDURANTS amountOfMatter => AMOUNTS_OF_MATTER amountOfMatter
class PHYSICAL_ENDURANTS physicalObject => PHYSICAL_OBJECTS physicalObject
class PHYSICAL_OBJECTS agent => AGENTS agent -- agentive physical objects  

-- amounts of air have heat and moisture 
data AmountOfAir = AmountOfAir {heat:: Float, moisture:: Float} deriving (Eq, Show)
muensterAir = AmountOfAir {heat = 20.0, moisture = 70.0}

instance PHYSICAL_ENDURANTS AmountOfAir
instance AMOUNTS_OF_MATTER AmountOfAir

-- steps (of a stair) have an Id and a riser height
data Step = Step {sid:: Id, riserHeight:: Float} deriving Show
instance Eq Step where Step id1 _ == Step id2 _ = id1 == id2
ground = Step {sid = 0, riserHeight = 0.0}
step1 = Step {sid = 1, riserHeight = 0.18}
step2 = Step {sid = 2, riserHeight = 0.18}

instance PHYSICAL_ENDURANTS Step
instance PHYSICAL_OBJECTS Step

-- trees have an Id and a crown diameter
data Tree = Tree {trid:: Id, crownDiameter:: Float} deriving Show
instance Eq Tree where Tree id1 _ == Tree id2 _ = id1 == id2
thePine = Tree {trid = 1, crownDiameter = 10.0}
theCypress = Tree {trid = 2, crownDiameter = 2.0}

instance PHYSICAL_ENDURANTS Tree
instance PHYSICAL_OBJECTS Tree

-- bridges have an Id and link two endurants (represented by their ids)
data Bridge = Bridge {brid:: Id, oneEnd, otherEnd :: Id} deriving Show
instance Eq Bridge where Bridge id1 _ _ == Bridge id2 _ _ = id1 == id2
theBridge = Bridge {brid = 0, oneEnd = rbid leftBank, otherEnd = rbid rightBank}

instance PHYSICAL_ENDURANTS Bridge
instance PHYSICAL_OBJECTS Bridge

data RiverBank = RiverBank {rbid:: Id} deriving Show
instance Eq RiverBank where RiverBank id1 == RiverBank id2 = id1 == id2
leftBank = RiverBank {rbid = 1}
rightBank = RiverBank {rbid = 2}

-- a person has an id, a leg length, an id of an endurant locating it, a current quale, and an output string
data Person = Person {pid:: Id, legLength:: Float, loc:: Id, pQuale:: Float, pValue:: String} deriving Show 
ann = Person {pid = 1, legLength = 0.8, loc = 0, pQuale = 0.0, pValue = ""}

instance Eq Person where Person id1 _ _ _ _ == Person id2 _ _ _ _ = id1 == id2
instance PHYSICAL_ENDURANTS Person
instance PHYSICAL_OBJECTS Person
instance AGENTS Person  

-- a thermometer has an id, a quale, and a float temperature value
data Thermometer = Thermometer {tid:: Id, tQuale:: Float, tValue:: Float} deriving Show
fmoThermometer = Thermometer {tid = 1, tQuale = 0.0, tValue = 0.0}

instance Eq Thermometer where Thermometer id1 _ _ == Thermometer id2 _ _ = id1 == id2
instance PHYSICAL_ENDURANTS Thermometer
instance PHYSICAL_OBJECTS Thermometer
instance AGENTS Thermometer 

-- a hygrometer has an id, a quale, and a float humidity value (percentage)
data Hygrometer = Hygrometer {hid:: Id, hQuale:: Float, hValue:: Float} deriving Show 
fmoHygrometer = Hygrometer {hid = 1, hQuale = 0.0, hValue = 0.0}

instance Eq Hygrometer where Hygrometer id1 _ _  == Hygrometer id2 _ _ = id1 == id2
instance PHYSICAL_ENDURANTS Hygrometer
instance PHYSICAL_OBJECTS Hygrometer
instance AGENTS Hygrometer 

-- a weather station has an id, a thermometer, a hygrometer, and an output string value
-- the thermometer and hygrometer are the holders of the temperature and humidity qualia of the weather station
data WeatherStation = WeatherStation {wid:: Id, thermo:: Thermometer, hygro:: Hygrometer, wValue:: String} deriving Show
fmoWeatherStation = WeatherStation {wid = 1, thermo = fmoThermometer, hygro = fmoHygrometer, wValue = ""}

instance PHYSICAL_ENDURANTS WeatherStation
instance PHYSICAL_OBJECTS WeatherStation
instance AGENTS WeatherStation 

----------------------------------------------------------------------
-- Qualities
-- the class of all quality types (= properties) is a constructor class
-- its constructors can be applied to endurants, perdurants, qualities or abstracts
-- this seems to work with entities of different kinds (tested for *->*)
class QUALITIES quality entity 

-- the temperature quality
data PHYSICAL_ENDURANTS physicalEndurant => Temperature physicalEndurant = Temperature physicalEndurant deriving Show
instance QUALITIES Temperature AmountOfAir 

-- the humidity quality
data AMOUNTS_OF_MATTER amountOfAir => Humidity amountOfAir = Humidity amountOfAir deriving Show
instance QUALITIES Humidity AmountOfAir 

-- the weather quality (change bearer to place!)
data AMOUNTS_OF_MATTER amountOfAir => Weather amountOfAir = Weather amountOfAir deriving Show
instance QUALITIES Weather AmountOfAir 

-- the height of steps quality
data PHYSICAL_OBJECTS step => Height step = Height step deriving Show
instance QUALITIES Height Step 

----------------------------------------------------------------------
-- Affordances
-- the class of all affordance types is a sub-class of QUALITIES
-- the reason for introducing this sub-class is to be able to constrain ACTIONS
-- the constructors can (for now) only be applied to endurants
-- later, this may be generalized to other affording entities

class (QUALITIES affordance physicalEndurant, PHYSICAL_ENDURANTS physicalEndurant) => AFFORDANCES affordance physicalEndurant 

-- the climbability of steps affordance
data PHYSICAL_OBJECTS step => Climbability step = Climbability step deriving Show
instance QUALITIES Climbability Step 
instance AFFORDANCES Climbability Step 

-- the sheltering of trees affordance
data PHYSICAL_OBJECTS tree => Shelter tree = Shelter tree deriving Show
instance QUALITIES Shelter Tree 
instance AFFORDANCES Shelter Tree

-- the crossability of bridges affordance
data PHYSICAL_OBJECTS bridge => Crossability bridge = Crossability bridge deriving Show
instance QUALITIES Crossability Bridge 
instance AFFORDANCES Crossability Bridge 

-----------------------------------------

-- Stimuli enable agents to perceive qualities
-- their physical and physiological nature is intentionally left unspecified 
-- the simplest implementation for qualia is to set them equal to the corresponding parameters in the observed entities

class (QUALITIES quality entity, AGENTS agent) => STIMULI quality entity agent where
	perceive :: quality entity -> agent -> agent

instance STIMULI Temperature AmountOfAir Person where
	perceive (Temperature amountOfAir) person = person {pQuale = heat amountOfAir} 
ptp = perceive (Temperature muensterAir) ann

instance STIMULI Temperature AmountOfAir Thermometer where
	perceive (Temperature amountOfAir) thermometer =  thermometer {tQuale = heat amountOfAir} 
ptt = perceive (Temperature muensterAir) fmoThermometer

instance STIMULI Humidity AmountOfAir Hygrometer where
	perceive (Humidity amountOfAir) hygrometer = hygrometer {hQuale = moisture amountOfAir}
phh = perceive (Humidity muensterAir) fmoHygrometer

instance STIMULI Weather AmountOfAir WeatherStation where
	perceive (Weather amountOfAir) weatherStation = 
		weatherStation {thermo = observe (Temperature amountOfAir) (thermo weatherStation), 
						hygro = observe (Humidity amountOfAir) (hygro weatherStation)}
pww = perceive (Weather muensterAir) fmoWeatherStation

instance STIMULI Height Step Person where
	perceive (Height step) person = person {pQuale = riserHeight step}
php = perceive (Height step1) ann

instance STIMULI Climbability Step Person where
	perceive (Climbability step) person = person {pQuale = riserHeight step}
pcp = perceive (Climbability step1) ann
-- height should take current level of person into account
-- climbability could be determined more broadly, not just from height
-- the numeric equivalence of the qualia for height and climbability is only for simplicity; they are conceptually different 

instance STIMULI Shelter Tree Person where
	perceive (Shelter tree) person = person {pQuale = crownDiameter tree}
psp = perceive (Shelter thePine) ann
psc = perceive (Shelter theCypress) ann

instance STIMULI Crossability Bridge Person where
	perceive (Crossability bridge) person = person {pQuale = 1.0} -- all bridges are crossable by people, thus arbitrary value for quale
pcb = perceive (Crossability theBridge) ann


{---------------------------------------- to be done after the AO paper
-- Semantic Datums 
-- they map from qualia (for a quality) to values and back
-- agents can adopt suitable datum definitions

class QUALITIES quality entity => DATUMS quality entity quale value where
	encode :: quale -> value
	decode :: value -> quale

heat2temp1 :: Float -> Float
heat2temp1 f = f

temp2heat1 :: Float -> Float
temp2heat1 f = f

class DATUMS quality entity quale value => INTERVAL_DATUMS quality entity quale value 

instance DATUMS Temperature AmountOfAir Float Float where
	encode = heat2temp1 
	decode = temp2heat1 

-----------------------}

-- Observations
-- to observe a quality is to express the result of perceiving one or more (possibly proxy) qualities by a value (carried by an agent)
class STIMULI quality entity agent => OBSERVATIONS quality entity agent where
	observe :: quality entity -> agent -> agent

instance OBSERVATIONS Temperature AmountOfAir Person where
	observe (Temperature amountOfAir) person = person {pValue = 
		if (pQuale (perceive (Temperature amountOfAir) person)) > 15 then  "warm" else "cold"}
otp = observe (Temperature muensterAir) ann

instance OBSERVATIONS Temperature AmountOfAir Thermometer where
	observe (Temperature amountOfAir) thermometer = thermometer {tValue = tQuale (perceive (Temperature amountOfAir) thermometer)}
ott = observe (Temperature muensterAir) fmoThermometer

instance OBSERVATIONS Humidity AmountOfAir Hygrometer where
	observe (Humidity amountOfAir) hygrometer = hygrometer {hValue = hQuale (perceive (Humidity amountOfAir) hygrometer)}
ohh = observe (Humidity muensterAir) fmoHygrometer

instance OBSERVATIONS Weather AmountOfAir WeatherStation where
	observe (Weather amountOfAir) weatherStation =
		weatherStation {wValue = 
			if	((tValue (observe (Temperature amountOfAir) (thermo weatherStation))) > 18) && 
				((hValue (observe (Humidity amountOfAir) (hygro weatherStation))) < 80) 
			then "fair" else "bad"}
oww = observe (Weather muensterAir) fmoWeatherStation

instance OBSERVATIONS Height Step Person where
	observe (Height step) person = 
		person {pValue = if (pQuale (perceive (Height step) person)) / (legLength person) < 0.26 then  "low" else "high"}
ohp = observe (Height step1) ann 

-----------------------------------------------
-- Actions 
-- to act on an affordance is to enact the result of perceiving one or more (possibly proxy) affordances 

class (AFFORDANCES affordance physicalEndurant, STIMULI affordance physicalEndurant agent) => ACTIONS affordance physicalEndurant agent where
	act :: affordance physicalEndurant -> agent -> agent

instance ACTIONS Climbability Step Person where
	act (Climbability step) person =  
	  if (pQuale (perceive (Climbability step) person)) / (legLength person) < 0.88 then person {loc = sid step} else person
ac1 = act (Climbability step1) ann
ac2 = act (Climbability step2) ac1

instance ACTIONS Shelter Tree Person where
	act (Shelter tree) person =  
	  if (pQuale (perceive (Shelter tree) person)) > 2.5 then person {loc = trid tree} else person 
asp = act (Shelter thePine) ann
asc = act (Shelter theCypress) ann

instance ACTIONS Crossability Bridge Person where
	act (Crossability bridge) person = person {loc = otherEnd bridge} 
acb = act (Crossability theBridge) ann

{-
**** use later ******* 

-- mosquito eggs
-- ein Ei gleicht dem anderen
data Egg = Egg deriving (Eq, Show) 

-- a collection of mosquito eggs
data Eggs = Empty | Add Egg Eggs deriving (Eq, Show)
someEggs = Add Egg (Add Egg Empty)
countEggs Empty = 0
countEggs (Add Egg eggs) = countEggs eggs + 1

instance ENDURANTS Egg
instance PHYSICAL_ENDURANTS Egg
instance PHYSICAL_OBJECTS Egg 

instance ENDURANTS Eggs

-- the count quality: tbd (with collection)
data PHYSICAL_ENDURANTS physicalEndurant => Number physicalEndurant = Number physicalEndurant 
type EggNumber = Number Eggs

instance OBSERVERS (Sensor eggNumber) Eggs where
	observe (Sensor eggNumber agent) eggs = do 
		clockTime <- getClockTime
		let time = calendarTimeToString (toUTCTime clockTime)
		let position = getPosition agent clockTime 
		let value = Count (countEggs eggs)
		return (Observation value position time)

--------------------------------

-- features (not yet used)
class PHYSICAL_ENDURANTS feature => FEATURE feature 

-- non-physical endurants 
class ENDURANTS nonphysicalEndurant => NONPHYSICAL_ENDURANTS nonphysicalEndurant 

-- non-physical objects 
class NONPHYSICAL_ENDURANTS nonphysicalObject => NONPHYSICAL_OBJECTS nonphysicalObject 

-- social objects (not yet used)
class NONPHYSICAL_OBJECTS socialObject => SOCIAL_OBJECTS socialObject 

-- mental objects 
-- they are specifically dependent on agents (i.e., not just persons)
-- should this be stated in the context (and how)?
class NONPHYSICAL_OBJECTS mentalObject => MENTAL_OBJECTS mentalObject 


-------------------------------
-- networks of observing agents 
-- one can ask for all neighbors of a node (tbd)
-- connectivity is modeled as adjacency matrix
data AGENTS agent => Network agent = Network [[Int]] [agent] 

instance ENDURANTS (Network agent)
instance PHYSICAL_ENDURANTS (Network agent)
instance PHYSICAL_OBJECTS (Network agent) where
	getPosition (Network links agents) = Cloud (map getPosition agents)
instance AGENTS (Network agent)


**** cuts *******

True, but not really relevant:
The parametrization of quality types (e.g., temperature of any physical endurant) is possible because qualities are modeled as constructors. 
The quality parameter in an observer definition needs to refer to a specific endurant or perdurant type (thermometers are designed for air or water). 
This is only possible if it is a (polymorphic) constructor function, which has different signatures for different endurants and perdurants.
For example, the temperature of air and that of water have two signatures with the same constructor, but different input types. 
A further advantage of using constructors is that their type constructors (left-hand side) can have the same name. 


once we introduce reference systems, possibly reuse this:
data RefSys = EPSG Int | BodyRef String deriving (Eq, Show)
fmo = Coordinates [52.08, 7.41] (EPSG 4326)
eyeLevel = Coordinates [1.70] (BodyRef "Height")


-- physical qualities inhere in physical endurants
class (QUALITIES quality entity, PHYSICAL_ENDURANTS entity) => PHYSICAL_QUALITIES quality entity

instance PHYSICAL_QUALITIES Temperature AmountOfAir

-- temporal qualities inhere in perdurants
class (QUALITIES quality entity, PERDURANTS entity) => TEMPORAL_QUALITIES quality entity

-- abstract qualities inhere in abstract entities (for example, in descriptions)
class (QUALITIES quality entity, ABSTRACTS entity) => ABSTRACT_QUALITIES quality entity


-}