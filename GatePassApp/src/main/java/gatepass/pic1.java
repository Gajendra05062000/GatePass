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

public class pic1 extends HttpServlet{
	Connection conn;
	public void init(ServletConfig config) throws ServletException {
		System.out.println("upload photos");
   	    super.init(config);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{
	
		String Sr_No = request.getParameter("Sr_No");
		String Image = request.getParameter("Image");
		String Name = request.getParameter("Name");
		String Address = request.getParameter("Address");
		String Other_Persons = request.getParameter("Other_Persons");
		String Material = request.getParameter("Material");
		String Vehicle_No = request.getParameter("Vehicle_No");
		String Officer_Whom_To_Meet = request.getParameter("Officer_Whom_To_Meet");
		String Department = request.getParameter("Department");
		String Purpose = request.getParameter("Purpose");
		String Current_Date = request.getParameter("Current_Date");
		String Time_In = request.getParameter("Time_In");
		String Time_Out = request.getParameter("Time_Out");
		//System.out.println("Form values are--"+Image_id +"and"+Image);
		Database dc = new Database();
		conn = dc.getConnection();
		//Statement st1;
		PrintWriter pw = response.getWriter();
		
		try{
		 //st1=conn.createStatement();
		 
		 //ResultSet rs = st1.executeQuery("INSERT INTO image VALUES('"+Image_id+"',rawtohex('"+Image+"'))");
		 
		 PreparedStatement ps = 
			  conn.prepareStatement("INSERT INTO newvisit VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)");
		
			
			  File file =new File(Image);
			  
		   FileInputStream fs = new FileInputStream(file);
		   ps.setString(1,Sr_No);
		   ps.setBinaryStream(2,fs,fs.available());
		   ps.setString(3, Name);
		   ps.setString(4, Address);
		   ps.setString(5, Other_Persons);
		   ps.setString(6, Material);
		   ps.setString(7, Vehicle_No);
		   ps.setString(8, Officer_Whom_To_Meet);
		   ps.setString(9, Department);
		   ps.setString(10, Purpose);
		   ps.setString(11, Current_Date);
		   ps.setString(12, Time_In);
		   ps.setString(13, Time_Out);
		   System.out.println("Form values are--");
		   int i =(ps.executeUpdate());
		 conn.close(); 
		   if(i!=0){
		   pw.println("Data Inserted Successfully");
		   }
		   else{
		   pw.println("Problem in Data Insertion");
		   }  
		   }
		   catch (Exception e){
		   System.out.println(e);
		   }
		   }
		 } 
		

