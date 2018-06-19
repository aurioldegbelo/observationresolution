package LinkedBrazilianAmazonRainforestData;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.query.ResultSetFormatter;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

public class QueryOnLBARD {


	/*
	 * Example of query on the Linked Brazilian Amazon dataset 
	 * The Jena library library is required to execute this program
	 * Libraries (i.e. the .jar files) are found in the folder 'Java Libraries'
	 */
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub

		// specify the SPARQL endpoint of the dataset
		String serviceEndpoint = "http://spatial.linkedscience.org/sparql";
		
		System.out.println("...Preparing the query to be executed on LBARD ...");
 
		String prefixes = "PREFIX amazon: <http://spatial.linkedscience.org/context/amazon/> " +
						  "PREFIX rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" +
						  "PREFIX lsv: <http://linkedscience.org/lsv/ns#> ";
		
		// the construct query is useful to say that: a gridcell is equivalent to an observation, the size of the cell is 
		// equivalent to the spatial resolution of the observation, and the cellvalue is equivalent to the observation value
		String queryString = prefixes + "CONSTRUCT { ?gridcell a amazon:observation." +
				"									 ?gridcell amazon:hasSpatialResolution 625." +
												   " ?gridcell amazon:hasValue ?cellvalue." +
												   " }  " +
										" WHERE {" +
										"	 	  ?gridcell amazon:DEFOR_2008 ?cellvalue." +
									    " } ";
									 	 
	 
		Query query = QueryFactory.create(queryString) ;			  
		QueryExecution qexec = QueryExecutionFactory.sparqlService(serviceEndpoint,query);
		
		// execute the query	 		
		Model results = qexec.execConstruct();
 
		// display the results of the 'CONSTRUCT' query in TURTLE
		//results.write(System.out, "TURTLE");
		
		// specify the query to perform on the Linked Brazilian Amazon dataset
		String queryString2 = prefixes +  "SELECT ?observation ?observationvalue ?spatialresolution " +
										  " WHERE {" +
										  "	 	?observation a amazon:observation. " +
										  "		?observation amazon:hasValue ?observationvalue. " +
										  "		?observation amazon:hasSpatialResolution ?spatialresolution. " +
			    				   		  "     FILTER (?spatialresolution = 625)." +  		 			   		
			    				   		  "} " +
			    				   		  "      ORDER BY DESC (?observationvalue) "+
			    				   		  "      LIMIT 5 ";
		
		Query query2 = QueryFactory.create(queryString2) ;			  
		QueryExecution qexec2 = QueryExecutionFactory.create(query2, results) ;
		
		// execute the query
		ResultSet results2 = qexec2.execSelect();
		
		// display the results of the query
		ResultSetFormatter.out(System.out, results2, query2) ;
	}

}
