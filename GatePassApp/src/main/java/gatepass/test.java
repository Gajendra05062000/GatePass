package gatepass;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
public class test extends HttpServlet{
	Connection conn;
	public void init(ServletConfig config) throws ServletException {
		System.out.println("display photos");
		System.out.println("image");
   	    super.init(config);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{	
	byte[ ] imgData = null ; 

		Database dc = new Database();
		conn = dc.getConnection();
		InetAddress addr = InetAddress.getLocalHost();

	    // Get IP Address
	    byte[] ipAddr = addr.getAddress();

	    // Get hostname
	    String hostname = addr.getHostName();
System.out.println(addr+"   "+ipAddr+"   "+hostname);
		String id= request.getParameter("id");
System.out.println(id);

    
    // Set content type
           // InputStream in = null;
           // OutputStream out = null;
String image = null;
ResultSet rs;
int len ;
		try
		{		     String filename = "image.jpg";

			Statement st = conn.createStatement();
			rs= st.executeQuery("select photo from image1  where id ='"+id+"'" );
			if(rs.next())
			{ 	
				image = rs.getString(1);
			
			
			}
			rs= st.executeQuery("select photo from image1  where id ='"+id+"'" );
			if(rs.next())
			{
			       //write image on local drive
	              /*InputStream test=rs.getBinaryStream(1);              
	              OutputStream out = new FileOutputStream(new File("d:\\"+filename));
	              int read = 0;
	              byte[] bytes = new byte[1024];

	              while ((read = test.read(bytes)) != -1) {
	              	out.write(bytes, 0, read);
	              }

	              test.close();
	              out.flush();
	              out.close();*/
	              
	              
	             
				len = image.length();				
				byte [] rb = new byte[len];
               InputStream readImg = rs.getBinaryStream(1);
               int index=readImg.read(rb, 0, len);
               st.close(); 
              response.reset();
                       
         
            response.setHeader("Content-disposition","inline; filename=" +filename);
            response.getOutputStream().write(rb,0,len);
            response.getOutputStream().flush(); 
             
           
	              
	              
         //response.setContentType("image/jpg");
       
      // System.out.println("next jsp "); 
      // response.sendRedirect("show.jsp");
            
         
		
		
		
            rs.close();
            conn.close(); }}
		
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
	
}}
