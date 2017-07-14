package ImagesResolution;

/* This class is useful to represent pictures from Flickr. The picture's attributes which are of interest in this context are: 
 * its id, its title, the associated description to the picture, the camera which produced the picture and the camera's exposure time
 * while producing the picture 
 */

public class Picture {

	String pictureId;
	String pictureTitle; 
	Double pictureExposureTime;
	String pictureDescription;
	String pictureCamera; 
	
	// constructor
	public Picture() {

	}
	
	
	public String getPictureId() {
		return pictureId;
	}
	public void setPictureId(String pictureId) {
		this.pictureId = pictureId;
	}
	public String getPictureTitle() {
		return pictureTitle;
	}
	public void setPictureTitle(String pictureTitle) {
		this.pictureTitle = pictureTitle;
	}
	public Double getPictureExposureTime() {
		return pictureExposureTime;
	}
	
	// set the exposure time of the pictures
	public void setPictureExposureTime(String exposureTime) {
		
		if (exposureTime == null)
		{
			 this.pictureExposureTime = null; 
			
		}
		else
		{
		 String[] split=exposureTime.split("/");
		 /*
		  * Exposure times in Flickr are returned as String. Fractions contain a "/" 
		  * 
		  */
		 // if there is no "/", convert the String to Double
		 if(split[0].equalsIgnoreCase(exposureTime))
		 {
			 this.pictureExposureTime  = Double.parseDouble(split[0]); 
			 //System.out.println ("The exposure time is: "+exposureTime);
   	 
		 }
		 // otherwise, return the Double value associated with the fraction represented as String
		 else
		 {	        		 
			 this.pictureExposureTime  = Double.parseDouble(split[0])/Double.parseDouble(split[1]); 
			// System.out.println ("The exposure time is: "+exposureTime);
 	 
		 }
		}
 
	}
	public String getPictureDescription() {
		return pictureDescription;
	}
	public void setPictureDescription(String pictureDescription) {
		this.pictureDescription = pictureDescription;
	}
	
	public String getPictureCamera() {
		return pictureCamera;
	}


	public void setPictureCamera(String pictureCamera) {
		this.pictureCamera = pictureCamera;
	}

	
	
}
