package gatepass;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.Arrays;
import java.util.Comparator;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class lastmodifiedfile  extends HttpServlet{
	Connection conn;
	public void init(ServletConfig config) throws ServletException {
		System.out.println("upload photos");
   	    super.init(config);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{
		
		
		PrintWriter pw = response.getWriter();
	
		
		        File dir = new File("C:/Users/win 7/Desktop/bank");
		        File [] files  = dir.listFiles();
		        Arrays.sort(files, new Comparator(){
		            public int compare(Object o1, Object o2) {
		            	System.out.println("cpmpare output"+compare( (File)o1, (File)o2));
		                return compare( (File)o1, (File)o2);
		            }
		            private int compare( File f1, File f2){
		                long result = f2.lastModified() - f1.lastModified();
		            	System.out.println("resultt"+result);

		                
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
		       }
	}
		 } 
	

