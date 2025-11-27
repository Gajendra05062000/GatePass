package gatepass;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Calendar;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;



public class starting extends HttpServlet {

	Connection conn;
	public void init(ServletConfig config) throws ServletException {
		System.out.println("Inside class starting--upload photos--------------------------------------------------------------");
		
   	    super.init(config);
	
	}
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{	
	

try{
	response.setContentType("text/html");
	PrintWriter out=response.getWriter();
	System.out.println("Image");
	Demo d=new Demo();
	
	int i=d.getmaxid();
	System.out.print("id*********"+i);
	int id=i+1;
	
	response.reset();
	Connection conn = null;
	Database db = new Database();	
	conn = db.getConnection();
	
		 PreparedStatement ps = 
		 conn.prepareStatement("INSERT INTO visitor VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

		String sss=request.getAttribute("image").toString();
		
		//String sss=db.imageSavingPath();
		
		 System.out.println("Image file into String-->"+sss);
		   File binaryfile =new File(sss);
		   FileInputStream fs = new FileInputStream(binaryfile);
		   System.out.println("Image inserting in table as binary file-->"+fs);
		   
		  ps.setString(1,request.getAttribute("text_name").toString());
		
		  ps.setString(2,request.getAttribute("line1").toString());
		 
		  ps.setString(3,request.getAttribute("material").toString());
		
		  ps.setString(4,request.getAttribute("vehicle").toString());
		 
		  ps.setString(5,request.getAttribute("officertomeet").toString());
		

		  ps.setString(6,"dd");
		  ps.setString(7,request.getAttribute("purpose").toString());
		  
		  
		  

		 Calendar calendar = Calendar.getInstance();                                
		  int hour = calendar.get(Calendar.HOUR);
		  int minute = calendar.get(Calendar.MINUTE);
		  int second = calendar.get(Calendar.SECOND);
		 int year=calendar.get(Calendar.YEAR);
		 int mon=calendar.get(Calendar.MONTH);
		 int month=mon+1;
		 
		 
		 String mm=null;
		 if((month>0&&(month<9))){mm="0"+month;}
		 else{mm=""+month;}
		
		 
		 int date=calendar.get(Calendar.DATE);
		 String dd=null;
		 if((date>0&&(date<9))){dd="0"+date;}
		 else{dd=""+date;}
			 
		 
		  java.sql.Date x = new java.sql.Date(new java.util.Date().getTime());
		  java.sql.Time y = new java.sql.Time(new java.util.Date().getTime() );
		  
		 
		  //for image
		  ps.setBinaryStream(8,fs,(int)fs.available()) ;
		  System.out.println("Inserting image value --"+fs.toString());
		  
			  
		  
		  String xx=dd+"-"+mm+"-"+year;
		  ps.setDate(9,x);
		  
		  String t=hour+":"+minute+":"+second;
		
		  ps.setString(10,t);
		  ps.setInt(11,id);
		  ps.setString(12,xx);
		
		  ps.setString(13,request.getAttribute("state").toString());
		 
		  ps.setString(14,request.getAttribute("district").toString());
		  
		  ps.setString(15,request.getAttribute("pincode").toString());
		  System.out.println("pincode is ++++++++++++++"+request.getAttribute("pincode").toString());
		  ps.setString(16,request.getAttribute("number").toString());
		

		  request.setAttribute("image",null);   
		
		  
		  
		   int is =(ps.executeUpdate());
		   ps.close();
		   
		   if(is==1){
			   System.out.println("Data Inserted Successfully");
			   
			   /********delete all the files from the directory***********/
			   request.getHeader("VIA");
			   String ipAddress = request.getHeader("X-FORWARDED-FOR");
			   if(ipAddress == null){
			       ipAddress = request.getRemoteAddr();
			       System.out.println("Incase of null IP -"+ipAddress );
			   }
			    
			   System.out.println("IP and Country-"+ipAddress );
			   
			   
			   //File file = new File("////10.3.111.103//Users//bank");   
			   File file = new File(db.imageSavingPath());  
		        String[] myFiles;      
		            if(file.isDirectory()){  
		                myFiles = file.list();  
		                for (int in=0; in<myFiles.length; in++) {  
		                    File myFile = new File(file, myFiles[in]);   
		                    myFile.delete();  
		                    System.out.println("Data deleted Successfully");
		                    }}  
			   
		            
		    /* ************************************************** */
		          
			String name=request.getAttribute("text_name").toString();
			String line1=request.getAttribute("line1").toString();
			String material=request.getAttribute("material").toString();
			String vehicle=request.getAttribute("vehicle").toString();
			String officertomeet=request.getAttribute("officertomeet").toString();
			String department="dddd";
			String purpose=request.getAttribute("purpose").toString();
			String state=request.getAttribute("state").toString();
			String district=request.getAttribute("district").toString();
			String pincode=request.getAttribute("pincode").toString();
			String number=request.getAttribute("number").toString();

			
			
			
			String date1=x.toString();
			String time=t.toString();
			request.setAttribute("name", name);
			request.setAttribute("material", material);
			request.setAttribute("line1", line1);
			request.setAttribute("vehicle", vehicle);
			request.setAttribute("officertomeet", officertomeet);
			request.setAttribute("department", department);
			request.setAttribute("purpose", purpose);
			request.setAttribute("date", xx);
			request.setAttribute("time", time);
			request.setAttribute("state", state);
			request.setAttribute("district", district);
			request.setAttribute("pincode", pincode);
			request.setAttribute("number", number);
			
		
			
			 request.getRequestDispatcher("kk.jsp").forward(request, response);
			 
			conn.close();  }
		   else{
			   out.println("Problem in Data Insertion");
		   
		   }  
		   }
		   catch (Exception e){
		   System.out.println(e);
		   }
		 
		   }
}
