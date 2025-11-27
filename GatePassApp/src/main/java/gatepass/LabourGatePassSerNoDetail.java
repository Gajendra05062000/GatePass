package gatepass;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class LabourGatePassSerNoDetail extends HttpServlet { 

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {   
		
		String serNo = req.getParameter("refNo");

		String labourDetails = null;	
		System.out.println("LabourGatePassSerNoDetail Java Class.");
		try{
			Connection conn1 = null;
	    	Statement st1=null;
	    	int id=0;
	    	gatepass.Database db1 = new gatepass.Database();	
			conn1 = db1.getConnection();
			st1=conn1.createStatement();
			ResultSet rs1 = st1.executeQuery("select NAME,FATHER_NAME,DESIGNATION,AGE,LOCAL_ADDRESS,PERMANENT_ADDRESS,CONTRACTOR_NAME_ADDRESS,IDENTIFICATION,VEHICLE_NO from GATEPASS_CONTRACT_LABOUR where SER_NO="+serNo); // Executing the Query
			while(rs1.next()){
	    		
				labourDetails=rs1.getString(1)+"|"+rs1.getString(2)+"|"+rs1.getString(3)+"|"+rs1.getString(4)+"|"+rs1.getString(5)+"|"+rs1.getString(6)+"|"+rs1.getString(7)+"|"+rs1.getString(8)+"|"+rs1.getString(9);
	        }
			
			System.out.println("GATEPASS_CONTRACT_LABOUR Response send back to ajax function-"+labourDetails);
			PrintWriter out = res.getWriter();
			out.print(labourDetails);
			labourDetails= null;
				
			conn1.close();	


		}
		catch(Exception e){
			e.printStackTrace();
		}

	}
	
	  public void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {   
		    doPost(req, res);   
		  }  
}
