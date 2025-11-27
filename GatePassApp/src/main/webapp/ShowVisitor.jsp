<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" import="java.io.*" %>
<%@ page language="java" import="gatepass.Database.*" %>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" >
<html>
<script language="javascript" src="print.js">

		</script>
<head>


<%
String id=request.getParameter("id").toString();
System.out.println("Showing image for  SerNo--"+id);
	Connection conn = null;
    	Statement st=null;
    	Blob img ;
     byte[] imgData = null ;
     
     try{
 	gatepass.Database db = new gatepass.Database();	
	conn = db.getConnection();
	String ip = db.getServerIp();
		st=conn.createStatement();
		ResultSet rs = st.executeQuery("SELECT IMAGE FROM VISITOR where ID='"+id+"'"); // Executing the Query
		while(rs.next()){
    	
    	//img = rs.getBlob(2);
    	imgData = rs.getBytes(1);
       
    		
    
       // display the image
        response.setContentType("image/gif");
        OutputStream o = response.getOutputStream();
        o.write(imgData);
        o.flush(); 
        o.close();
        
      
     
    	}
    	rs.close();      
        conn.close();
    	}
    	catch(Exception e){
    	System.out.println("Error-"+e.toString());
    	e.printStackTrace();
    	}
    		

		
    		
    		
    		
%>
</html>