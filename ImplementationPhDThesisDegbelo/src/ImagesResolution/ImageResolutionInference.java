package ImagesResolution;

import java.io.BufferedReader;

import java.io.IOException;

import java.io.InputStreamReader;
import java.net.HttpURLConnection;

import java.net.URL;
import java.net.URLConnection;
import java.util.Iterator;
 

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.mindswap.pellet.KnowledgeBase;
import org.mindswap.pellet.jena.PelletInfGraph;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassAssertionAxiom;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLDataProperty;
import org.semanticweb.owlapi.model.OWLDataPropertyAssertionAxiom;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLObjectProperty;
import org.semanticweb.owlapi.model.OWLObjectPropertyAssertionAxiom;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLSameIndividualAxiom;

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
 
 
 /*
  * This class illustrates the use of the ontology design pattern (ODP) for the resolution of single observations to annotate
  * and retrieve Flickr photographs at different temporal resolutions. The steps followed are: 
  * 1. Retrieve the pictures contained in the Lava Shot Gallery from Flickr
  * 2. Get the exif information about each picture, and return the exposure time (if available) of the camera which produced the picture
  * 3. Populate the ODP with pictures for which the exposure time has been explicitly documented
  * 4. Infer the temporal resolution of these pictures using the Pellet Reasoner
  * 5. Retrieve pictures at a given temporal resolution using SPARQL
  * 
  * Link to the Lava Shot Gallery: https://www.flickr.com/photos/flickr/galleries/72157645265344193/ 
  * Example Link of a picture: https://www.flickr.com/photos/flickr/galleries/72157645265344193/#photo_14452299043 
  */
 

public class ImageResolutionInference {

	/**
	 * @param args
	 * @throws FlickrException 
	 * @throws IOException 
	 * @throws ParseException 
	 * @throws OWLOntologyCreationException 
	 * @throws ImageProcessingException 
	 */
	public static void main  (String[] args) throws IOException, ParseException, OWLOntologyCreationException  {
		// TODO Auto-generated method stub

		String baseurl = "https://api.flickr.com/services/rest/?";
		String method = "&method=flickr.galleries.getPhotos";
	    String apiKey = "&api_key=8504e82ddf56be9b4dcc9bb36075ac5a"; 
		String galleryId = "&gallery_id=6065-72157645265344193";  
		String params = "&format=json";
	
		String galleryQuery = baseurl+method+apiKey+galleryId+params; 
		System.out.println ("The Query to retrieve the gallery in Flickr is: "+galleryQuery);  
		
		
		// get all ids of the photos in the Flickr gallery
		String [] listOfPhotoIds = IdsOfPhotosInTheGallery(queryFlickr(galleryQuery)); 
		
		Picture [] pictures = new Picture [listOfPhotoIds.length];
        int u =0; 
		
        System.out.println ("The number of photos in the gallery is: "+listOfPhotoIds.length); 
        
        // for each photo in the gallery
        for (int i=0; i<listOfPhotoIds.length; i++)
        {
          // create a new picture	
          Picture pic = new Picture();	
          pic.setPictureId(listOfPhotoIds[i]);	
         // System.out.print ("Id: "+listOfPhotoIds[i]+ " - "); 
 		  
          // get exif info about the picture
          method = "&method=flickr.photos.getExif";
 		  String photoId = "&photo_id="+listOfPhotoIds[i]; 
          String exifQuery = baseurl+method+apiKey+photoId+params; 
          //System.out.println ("The Query to retrieve the exif data of a picture is: "+ exifQuery); 
          String[] cameraAndExposureTime = getCameraAndExposureTime (queryFlickr(exifQuery)); 
          pic.setPictureCamera(cameraAndExposureTime[0]);
          pic.setPictureExposureTime(cameraAndExposureTime[1]);
        //  System.out.print ("Exposure time: "+exposureTime); 
 		   
          // get title and description of the picture
 		  method = "&method=flickr.photos.getInfo"; 
 		  String infoQuery = baseurl+method+apiKey+photoId+params; 
 		 // System.out.println("The Query to retrieve infos about the picture is "+infoQuery);
 		  String [] titleAndDescription = getTitleAndDescription (queryFlickr(infoQuery)); 
 		  pic.setPictureTitle(titleAndDescription[0]);
 		  pic.setPictureDescription(titleAndDescription[1]);
 		//  System.out.println(" - The title is: "+titleAndDescription[0]+ " - The description is: "+titleAndDescription[1]); 
 		  
 		  pictures[u] = pic; 
 		  u++;
        }
		
       /*
        // display infos about pictures
        for(int i=0; i<pictures.length; i++)
        {
        	System.out.println("----------------"); 
        	
        	Picture pic = pictures[i]; 
        	System.out.println ("Id: "+pic.getPictureId());
        	System.out.println ("Camera: "+pic.getPictureCamera()); 
        	System.out.println ("ExposureTime: "+pic.getPictureExposureTime()); 
        	System.out.println ("Title: "+pic.getPictureTitle()); 
        	System.out.println ("Description: "+pic.getPictureDescription()); 

        	
        }
      */
       
		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
		
		// get the ODP for the resolution of a single observation using the URI
		OWLOntology resolutionODP = manager.loadOntology(IRI.create("http://purl.net/ifgi/degbelo/thesisresources/chapter7/odp_resolution_oneObservation.owl"));

		System.out.println(" Loaded ontology: " + resolutionODP);

		OWLDataFactory dataFactory = manager.getOWLDataFactory();
		IRI ontologyIRI = resolutionODP.getOntologyID().getOntologyIRI();
		 
	
        // populate the ODP with the different pictures in the gallery
        for (int i=0; i<pictures.length; i++)
        {
        	Picture pic = pictures[i]; 
        	
        	// only add to the ODP, pictures for which information about the exposure time of the cameras is available
        	// (inference of temporal resolution is only possible when the exposure time has been recorded)
        	if(pic.getPictureExposureTime() != null)
        	{

            	// create an observation
        		String flickIRI = "https://www.flickr.com/photos/flickr/galleries/72157645265344193/";
        		String pictureName = "#photo_"+pic.getPictureId(); 	
				OWLNamedIndividual picture = dataFactory.getOWLNamedIndividual(IRI.create(flickIRI + pictureName));
			
	        	// get the "Observation" class from the ODP
				OWLClass observationClass = dataFactory.getOWLClass(IRI.create("http://www.semanticweb.org/degbelo/ontologies/observationresolution#Observation")); 
				
				// a picture is an instance of the class "Observation"
				OWLClassAssertionAxiom classAssertion1 =
						dataFactory.getOWLClassAssertionAxiom(observationClass, picture);
				
				// create an observer 
				String cameraName = "#camera_"+pic.getPictureCamera().replaceAll(" ", "_"); 
				OWLNamedIndividual camera = dataFactory.getOWLNamedIndividual(IRI.create(ontologyIRI + cameraName));
				 
				// get the "Observer" class from the ODP
				OWLClass observerClass = dataFactory.getOWLClass(IRI.create("http://www.semanticweb.org/degbelo/ontologies/observationresolution#Observer")); 
				
				// a camera is an instance of the class "Observer"
				OWLClassAssertionAxiom classAssertion2 =
						dataFactory.getOWLClassAssertionAxiom(observerClass, camera);
				
				// a camera produces a picture
				OWLObjectProperty produces = dataFactory.getOWLObjectProperty(IRI.create("http://www.semanticweb.org/degbelo/ontologies/observationresolution#produces")); 
				OWLObjectPropertyAssertionAxiom objectPropertyAssertion =
						dataFactory.getOWLObjectPropertyAssertionAxiom(produces, camera, picture);
				
				// temporal receptive window of a camera
				OWLDataProperty hasTemporalReceptiveWindow = dataFactory.getOWLDataProperty(IRI.create("http://www.semanticweb.org/degbelo/ontologies/observationresolution#hasTemporalReceptiveWindow"));
				OWLDataPropertyAssertionAxiom dataPropertyAssertionAxiom = dataFactory.getOWLDataPropertyAssertionAxiom(hasTemporalReceptiveWindow, camera,pic.getPictureExposureTime()); 
				
				manager.addAxiom(resolutionODP, classAssertion1);
				manager.addAxiom(resolutionODP, classAssertion2);
				manager.addAxiom(resolutionODP, objectPropertyAssertion);
				manager.addAxiom(resolutionODP, dataPropertyAssertionAxiom);
        	}
			
        }
		
       System.out.println(" Modified ontology: " + resolutionODP);
		
        // do some reasoning
        // create a reasoner 		
		  PelletReasoner reasoner = 
			         PelletReasonerFactory.getInstance().createNonBufferingReasoner( resolutionODP );
		// Get the KB from the reasoner
		KnowledgeBase kb = reasoner.getKB();
		
		// Create a Pellet graph using the KB from OWLAPI
		PelletInfGraph graph = new org.mindswap.pellet.jena.PelletReasoner().bind( kb );
		
		// Wrap the graph in a model
		InfModel model = ModelFactory.createInfModel( graph );
		
		System.out.println("...Preparing the query to be executed...");
		
		String prefixes = "PREFIX obsres: <http://www.semanticweb.org/degbelo/ontologies/observationresolution#> "+
						  "PREFIX flickr: <https://www.flickr.com/photos/flickr/galleries/72157645265344193/#> ";
		
		/*
        // retrieve the pictures with a temporal resolution lower than 0.4 seconds
		String queryString = prefixes +  "SELECT ?observer ?observation ?temporalresolution " +
									  		"WHERE {" +				  
									  		" ?observer obsres:produces ?observation. " +
									  		" ?observation obsres:hasTemporalResolution ?temporalresolution. " +
									  		" FILTER (?temporalresolution <= 0.4) "+
									  		" }" ;	 
		
		*/
         //retrieve the pictures with their corresponding (quantitative and qualitative) temporal resolution
		String queryString = prefixes +  "SELECT ?observer ?observation ?qualTresolution ?quanTresolution " +
									  		"WHERE {" +				  
									  		" ?observer obsres:produces ?observation. " +
									  		" ?observation obsres:hasTemporalResolution ?quanTresolution. " +
									        "  BIND(IF(?quanTresolution <= 0.4 , 'high', 'low' ) AS ?qualTresolution). " +
									  		" }" ;	 
		
		
		Query query = QueryFactory.create(queryString) ;			  
		QueryExecution qexec = QueryExecutionFactory.create(query, model) ;
		
		// execute the query
		ResultSet results = qexec.execSelect();
		
		// display the results of the query
		ResultSetFormatter.out(System.out, results, query) ;
		

	}
	
	
	// method to get the title and the description of a picture
	public static String[] getTitleAndDescription (String flickrInfoJson) throws ParseException
	{
		String [] titleAndDescription = new String [2]; 
		flickrInfoJson = flickrInfoJson.replace("jsonFlickrApi(", "");
		flickrInfoJson = flickrInfoJson.substring(0, flickrInfoJson.length()-1);
        
	     
        JSONParser parser=new JSONParser();
       
        Object obj = parser.parse(flickrInfoJson);
        JSONObject jsonObject = (JSONObject) obj;
        
      
        JSONObject photoInfos = (JSONObject) jsonObject.get("photo");
        
        JSONObject titleInfos = (JSONObject) photoInfos.get("title");
        String title = (String) titleInfos.get("_content"); 
        
       // System.out.print ("The title is: "+ title); 
        titleAndDescription[0] = title; 
        JSONObject descriptionInfos = (JSONObject) photoInfos.get("description");
        String description = (String) descriptionInfos.get("_content"); 
        titleAndDescription[1] = description; 
        //System.out.println (" - The description is: "+ description); 
   
		return titleAndDescription; 
	}
	
	// parse the exif file (if available) and return the exposure time
	public static String[] getCameraAndExposureTime (String flickrExifJson) throws ParseException
	{
		 String [] cameraAndExposureTime = new String[2];
 
		 flickrExifJson = flickrExifJson.replace("jsonFlickrApi(", "");
         flickrExifJson = flickrExifJson.substring(0, flickrExifJson.length()-1);
        
	     
        JSONParser parser=new JSONParser();
       
        Object obj = parser.parse(flickrExifJson);
        
        JSONObject jsonObject = (JSONObject) obj;  
       // System.out.println (jsonObject.toJSONString()); 
        if (jsonObject.toJSONString().indexOf("\"stat\":\"fail\"") != -1)
        {
        	//System.out.println("Json infos about the picture cannot be retrieved"); 
        	
        }
        else
        {
	        JSONObject photoInfos = (JSONObject) jsonObject.get("photo");
	        
	        cameraAndExposureTime[0] = (String) photoInfos.get("camera");
 
	        if(photoInfos.toJSONString().indexOf("exif") != -1)
	        {
	        	 //System.out.println ("Yes, there is some exif"); 
	        }
	        
	        JSONArray exifOfPhoto = (JSONArray) photoInfos.get("exif"); 
	        	   
	        if (exifOfPhoto == null)
	        {
	       	 
	        	//System.out.println("There is no exif information available for this picture"); 
	        }
	        else
	        {
		         Iterator<JSONObject> iterator = exifOfPhoto.iterator();  
		         while (iterator.hasNext()) {  
		        	 
		        	 JSONObject currentExifInfo = (JSONObject) iterator.next();
		        	 String currentlabel = (String) currentExifInfo.get("label"); 
		        	  if (currentlabel.equalsIgnoreCase("Exposure"))
		        	  {
		        		 JSONObject _raw = (JSONObject) currentExifInfo.get("raw");
		        		 String _content = (String) _raw.get("_content"); 
		        		// System.out.println ("CONTENT " + _content); 
		        		 cameraAndExposureTime[1] = _content; 
	        			 break;	

		        	  }
	
	           }
		         
	        }     	
        }
        return cameraAndExposureTime; 
	}
	
	
	// get the ids of all photos available in the gallery
	public static String[] IdsOfPhotosInTheGallery (String flickrJsonResults) throws ParseException
	
	{
		
		 flickrJsonResults = flickrJsonResults.replace("jsonFlickrApi(", "");
		 flickrJsonResults = flickrJsonResults.substring(0, flickrJsonResults.length()-1);
		 //System.out.println(flickrJsonResults);
     
         JSONParser parser=new JSONParser();
         
         Object obj = parser.parse(flickrJsonResults);
         
         JSONObject jsonObject = (JSONObject) obj;   
         
         JSONObject infos = (JSONObject) jsonObject.get("photos"); 
         Long numberofPhotos = (Long) infos.get("total"); 
       //  System.out.println ("Number of photos: "+numberofPhotos); 
         
         String [] listOfPhotoIds = new String[numberofPhotos.intValue()];
 		
         
         JSONArray photos = (JSONArray) infos.get("photo"); 
         //System.out.println ("Photos: "+photos); 
         
         int u = 0; 
         
         Iterator<JSONObject> iterator = photos.iterator();  
         while (iterator.hasNext()) {  
        	 
        	 JSONObject aPhoto = (JSONObject) iterator.next(); 
        	 String aPhotoId = (String) aPhoto.get("id"); 
        	 listOfPhotoIds[u] = aPhotoId;  
        	 u++; 
        	 
        	 //System.out.println("---"+ aPhotoId);  
         }  

		
		
		return listOfPhotoIds; 
	}	
	
	// send a query (in the form of a url) to flickr and get as result a string (in json)
	public static String queryFlickr (String query) throws IOException
	{
	  
		 URL url = new URL(query);
         URLConnection urlConnection = url.openConnection();
         HttpURLConnection connection = null;
         if(urlConnection instanceof HttpURLConnection)
         {
            connection = (HttpURLConnection) urlConnection;
         }
         else
         {
            System.out.println("Please enter an HTTP URL.");
            // no result when there is a malformed query
            return "";
         }
         BufferedReader in = new BufferedReader(
         new InputStreamReader(connection.getInputStream()));
         String result = "";
         String current;
         while((current = in.readLine()) != null)
         {
        	 result += current;
         }
 
	 return result;	
	
	}
	

}
