package ObservationResolution;

import java.io.File;

import org.mindswap.pellet.KnowledgeBase;
import org.mindswap.pellet.jena.PelletInfGraph;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;

import com.clarkparsia.pellet.owlapiv3.PelletReasoner;
import com.clarkparsia.pellet.owlapiv3.PelletReasonerFactory;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFormatter;
import com.hp.hpl.jena.rdf.model.InfModel;
import com.hp.hpl.jena.rdf.model.ModelFactory;

public class UseOfTheObservationResolutionODP {
	/*
	 * Example of use of the ODP useful to characterize the spatial and temporal resolution of a single sensor observation
	 * Three libraries are required to execute this program: the Jena library, the OWL API library, and the Pellet Reasoner library
	 * Libraries (i.e. the .jar files) are found in the folder 'Java Libraries'
	 * 
	 */
	
	public static void main(String[] args) {
		
		
		System.out.println("--- Reading the OWL ontology -");

		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
		
		
		
		try {
		
	    // specify the path of the ontology
		//File owlfile = new File("C:/Users/degbelo/Desktop/thesisresources/chapter7/odp_resolution_oneObservation_withInstances.owl"); 
		//OWLOntology currentOntology = manager.loadOntologyFromOntologyDocument(owlfile);
		
		// or load the ontology using its URI 
		OWLOntology currentOntology = manager.loadOntology(IRI.create("http://purl.net/ifgi/degbelo/thesisresources/chapter7/odp_resolution_oneObservation_withInstances.owl"));
		
		System.out.println(" Loaded ontology: " + currentOntology);

		OWLDataFactory dataFactory = manager.getOWLDataFactory();
		IRI ontologyIRI = currentOntology.getOntologyID().getOntologyIRI();
		
		
		/* The ontology created using the OWL API needs to be 'made ready' for querying using Jena
	      (See more details at http://clarkparsia.com/pellet/faq/owlapi-sparql/ )
	    */
	
		
		// create a reasoner 		
		  PelletReasoner reasoner = 
			         PelletReasonerFactory.getInstance().createNonBufferingReasoner( currentOntology );
		// Get the KB from the reasoner
		KnowledgeBase kb = reasoner.getKB();
		
		// Create a Pellet graph using the KB from OWLAPI
		PelletInfGraph graph = new org.mindswap.pellet.jena.PelletReasoner().bind( kb );
		
		// Wrap the graph in a model
		InfModel model = ModelFactory.createInfModel( graph );
		
		System.out.println("...Preparing the query to be executed...");
		
		String prefixes = "PREFIX obsres: <http://www.semanticweb.org/degbelo/ontologies/observationresolution#> ";
		
		String queryString = prefixes +  "SELECT ?observation ?spatialresolution ?temporalresolution " +
									  		"WHERE {" +				  
									  		" ?observer obsres:produces ?observation. " +
									  		" ?observation obsres:hasSpatialResolution ?spatialresolution. " +
									  		" ?observation obsres:hasTemporalResolution ?temporalresolution. " +
									  		//" FILTER (?spatialresolution > 800 && ?temporalresolution <= 80) "+
									  		" }" ;	 
	 
		
		Query query = QueryFactory.create(queryString) ;			  
		QueryExecution qexec = QueryExecutionFactory.create(query, model) ;
		
		// execute the query
		ResultSet results = qexec.execSelect();
		
		// display the results of the query
		ResultSetFormatter.out(System.out, results, query) ;
		
		
		
		} catch (OWLOntologyCreationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		

		
	}
	

}
