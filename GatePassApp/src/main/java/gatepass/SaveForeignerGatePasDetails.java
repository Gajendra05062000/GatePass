/*
 * To change this template, choose Tools | Templates~
 * and open the template in the editor.
 */
package gatepass;
import java.io.File;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
/**
 *
 * @author Hrishikesh
 */
@WebServlet("/saveForeignerGatePasDetails")
public class SaveForeignerGatePasDetails extends HttpServlet {
		   
		   private boolean isMultipart;
		   private String filePath;
		   private int maxFileSize = 500 * 2048;
		   private int maxMemSize = 400 * 1024;
		   File file ;
		   String fieldname;// = item.getFieldName();
		   String fieldvalue ;//= item.getString()

		   public void init( ){
			   System.out.println("SaveForeignerGatePasDetails Data Saving");
		      // Get the file location where it would be stored.
			   filePath = "d:\\"; 
			   
		   }
		   public void doPost(HttpServletRequest request, 
		               HttpServletResponse response)
		              throws ServletException, java.io.IOException {
			  
			   System.out.println("SaveForeignerGatePasDetails ");
		      // Check that we have a file upload request
		      isMultipart = ServletFileUpload.isMultipartContent(request);
		      response.setContentType("text/html");
		      java.io.PrintWriter out = response.getWriter( );
		      if( !isMultipart ){
		         out.println("<html>");
		         out.println("<head>");
		         out.println("<title>Servlet upload</title>");  
		         out.println("</head>");
		         out.println("<body>");
		         out.println("<p>No file uploaded</p>"); 
		         out.println("</body>");
		         out.println("</html>");
		         return;
		      }
		      DiskFileItemFactory factory = new DiskFileItemFactory();
		      // maximum size that will be stored in memory
		      factory.setSizeThreshold(maxMemSize);
		      // Location to save data that is larger than maxMemSize.
		      factory.setRepository(new File("c:\\"));
		//http://commons.apache.org/fileupload/apidocs/org/apache/commons/fileupload/disk/DiskFileItemFactory.html
		      // Create a new file upload handler
		      ServletFileUpload upload = new ServletFileUpload(factory);
		      // maximum file size to be uploaded.
		      upload.setSizeMax( maxFileSize );

		      try{ 
		      // Parse the request to get file items.
		      List fileItems = upload.parseRequest(request);
			
		      // Process the uploaded file items
		      Iterator i = fileItems.iterator();

		      out.println("<html>");
		      out.println("<head>");
		      out.println("<title>Servlet upload</title>");  
		      out.println("</head>");
		      out.println("<body>");
		      while ( i.hasNext () ) 
		      {
		         FileItem fi = (FileItem)i.next();
		         if ( fi.isFormField () 
		)	
		         {
		            // Get the uploaded file parameters
		        	
		        	  fieldname = fi.getFieldName();
		              fieldvalue = fi.getString();

		System.out.println("fieldname -->"+fieldname +" and fieldvalue-->"+fieldvalue);

		request.setAttribute(fieldname, fieldvalue);

		               
		            }
		         
		         
		         else{
		            	 String fieldName = fi.getFieldName();
		                 
		                 String fileName = fi.getName();
		                 System.out.println(fileName);

		                 String contentType = fi.getContentType();
		                 boolean isInMemory = fi.isInMemory();
		                 long sizeInBytes = fi.getSize();
		                 // Write the file
		                 if( fileName.lastIndexOf("\\") >= 0 ){
		                    file = new File( filePath + fileName.substring( fileName.lastIndexOf("\\"))) ;
		                    System.out.println(file);
		            }
		            fi.write( file ) ;
		            out.println("Uploaded Filename: " + fileName + "<br>");
		         }
		      }
		      out.println("</body>");
		      out.println("</html>");
		   }catch(Exception ex) {
		       System.out.println(ex);
		      
		   }
		 
		 //Getting IP of client
		   System.out.println(" Class upload file-" );
			request.getHeader("VIA");
			   String ipAddress = request.getHeader("X-FORWARDED-FOR");
			     System.out.println(" Client IP-"+ipAddress );
			   if(ipAddress == null){
			       ipAddress = request.getRemoteAddr();
			       System.out.println("In case of null Client IP-Server -"+ipAddress );
			   }
			    
			   System.out.println("IP and Country-"+ipAddress );
		   
		   
		 
		  
		 
		   //String ipAddress =  null;//"10.3.111.103";
		   
		   
		       //ipAddress = request.getRemoteAddr();
		     
		    
		       System.out.println("UploadFile  lfile function call" );
		   
		  lfile l=new lfile();
		 File fle=l.lastimage();
		 System.out.println("UploadFile -file received--"+fle);
		  request.setAttribute("image", fle);
		   
		  
		   
		   System.out.println("Image request Dispatch--image getAttribute-->"+request.getAttribute("image").toString());
		   
		 request.getRequestDispatcher("saveForeignerGatePasData").forward(request, response);
		   }
		   
		   
		   
		   public void doGet(HttpServletRequest request, 
		                       HttpServletResponse response)
		        throws ServletException, java.io.IOException {
		        
		        throw new ServletException("GET method used with " + getClass( ).getName( )+": POST method required.");
		   } 
		}