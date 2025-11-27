package gatepass;
import java.io.File;
 
public class DeleteDirectoryExample
{
   
    public static void main(String[] args)
    {	
    	File file = new File("C:/Users/win 7/Desktop/bank/");        
        String[] myFiles;      
            if(file.isDirectory()){  
                myFiles = file.list();  
                for (int i=0; i<myFiles.length; i++) {  
                    File myFile = new File(file, myFiles[i]);   
                    myFile.delete();  
                }  
             }  
    }
}