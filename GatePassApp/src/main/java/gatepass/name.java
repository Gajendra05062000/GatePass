package gatepass;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
public class name extends HttpServlet{
	Connection conn;
	ResultSet rs;
	public void init(ServletConfig config) throws ServletException {
		System.out.println("Inside class name--display photos");
		
   	    super.init(config);
	}

public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{	
	byte[ ] imgData = null ; 

		Database dc = new Database();
		conn = dc.getConnection();
		InetAddress addr = InetAddress.getLocalHost();

	    
String id= request.getParameter("id");

    
System.out.println("In Name class -- value of id-"+id);   
String image = "";

Blob img ;

int len ;
		try
		{		     String filename = "image.jpg";

			Statement st = conn.createStatement();
		/*	rs= st.executeQuery("select image from visitor  where id ='"+id+"'" );
			if(rs.next())
			{ 	
				image = rs.getString(1);				
			}*/
			rs= st.executeQuery("select image from visitor  where id ='"+id+"'" );
			if(rs.next())
			{ 
				imgData = rs.getBytes(1);
			       
	    		
			    
			       // display the image
			        response.setContentType("image/gif");
			        OutputStream o = response.getOutputStream();
			        o.write(imgData);
			        o.flush(); 
			        o.close();
				
				
				/*len = image.length();				
				byte [] rb = new byte[len];
               InputStream readImg = rs.getBinaryStream(1);
               int index=readImg.read(rb, 0, len);
               st.close(); 
              response.reset();
                       
   
            response.setHeader("Content-disposition","inline; filename=" +filename);
            response.getOutputStream().write(rb,0,len);
            response.getOutputStream().flush(); */
            
            	}
			rs.close();
            conn.close(); 
				}
		
		catch(Exception e)
		{
			System.out.println("Error-"+e.toString());  
			e.printStackTrace();
		}
		
		
		
}

  }
