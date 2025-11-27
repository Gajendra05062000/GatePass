package gatepass;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class pic extends HttpServlet{
	Connection conn;
	public void init(ServletConfig config) throws ServletException {
		System.out.println("upload photos");
   	    super.init(config);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{
	
		String Image_id = request.getParameter("Image_id");
		String Image = request.getParameter("Image");
		//System.out.println("Form values are--"+Image_id +"and"+Image);
		Database dc = new Database();
		conn = dc.getConnection();
		//Statement st1;
		PrintWriter pw = response.getWriter();
		
		try{
		 //st1=conn.createStatement();
		 
		 //ResultSet rs = st1.executeQuery("INSERT INTO image VALUES('"+Image_id+"',rawtohex('"+Image+"'))");
		 
		 PreparedStatement ps = 
			  conn.prepareStatement("INSERT INTO sar VALUES(?,?)");
		
			
			  File file =new File(Image);
			  
		   FileInputStream fs = new FileInputStream(file);
		   ps.setString(1,Image_id);
		   ps.setBinaryStream(2,fs,fs.available());
		   System.out.println("Form values are--");
		   int i =(ps.executeUpdate());
		   conn.close(); 
		   if(i!=0){
		   pw.println("image inserted successfully");
		   }
		   else{
		   pw.println("problem in image insertion");
		   }  
		   }
		   catch (Exception e){
		   System.out.println(e);
		   }
		   }
		 } 
		

