package gatepass;
import java.io.File;
import java.util.Arrays;
import java.util.Comparator;


public class lfile {
	public File lastimage() {
		
		File x=null;
		try{
			
			gatepass.Database db = new gatepass.Database();	
			String ip = db.getImageSavingIp();	
	    	
			
			String imgSavingPath=db.imageSavingPath();
			//String imgSavingPath="////"+ip+"//Users//bank";
	    	File dir = new File(imgSavingPath);
	    	
			//File dir = new File("////"+ip+"//Users//Public//Pictures//Sample Pictures");
	    	
	    	System.out.println("Image Saving path is  --"+imgSavingPath);
	    	System.out.println("lastimage -Latest file searching in directory of --"+dir);
	    	if(dir==null){
	    		System.out.println("Dir value is null--"+dir);
	    	}
	    	else{
	    		System.out.println("Dir value is NOT NULL--"+dir);
	    		
	    	}
	    
	
	    	System.out.println("Dir value is NOT NULL toString--"+dir.toString());
	    	System.out.println("Dir value is NOT NULL exists--"+dir.exists());
	    	System.out.println("Dir value is NOT NULL getAbsoluteFile--"+dir.getAbsoluteFile());
	    	
	    	  File [] files  = dir.listFiles();
	    	 // File [] files  = dir.
	    	  
	    	
	 // System.out.println("dir files--"+files);

	    	  
	    //	  System.out.println("dir.listFiles() --"+dir.listFiles());
	      
	       // System.out.println("last file --"+files[0]);
	        Arrays.sort(files, new Comparator(){
	            public int compare(Object o1, Object o2) {
	            	 System.out.println("compare( (File)o1, (File)o2) --"+compare( (File)o1, (File)o2));
	                return compare( (File)o1, (File)o2);
	               
	            }
	            private int compare( File f1, File f2){
	                long result = f2.lastModified() - f1.lastModified();
	                if( result > 0 ){
	                    return 1;
	                } else if( result < 0 ){
	                    return -1;
	                } else {
	                    return 0;
	                }
	            }
	        });
	        for(int i=0, length=Math.min(files.length, 1); i<length; i++){
		           System.out.println(files[i]);
		         x=files[i];
		       }
	        
		}catch(Exception ex){
			System.out.println("exception --"+ex.toString());
		}
		
		 System.out.println("lastimage -Returning file --"+x);
        return x;
	}

}
