package gatepass;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class OracleExample {
public static void main (String[] args) {
try{
	Connection conn = null;	
	Class.forName("oracle.jdbc.driver.OracleDriver");
	String url = "jdbc:oracle:thin:@10.3.126.84:1521:ORCL";
	conn = DriverManager.getConnection(url, "PERSONNEL", "PERSONNEL");
	System.out.println("****PERSONNEL******* DATABASE CONNECTED");


	PreparedStatement ps=conn.prepareStatement("insert into image values(?,?)");
	ps.setInt(1, 4);
	ps.setString(2, "oso");
	int i =(ps.executeUpdate());
	conn.close();  
	   if(i!=0){
	   System.out.println("Data Inserted Successfully");
	   }
	   else{
	   System.out.println("Problem in Data Insertion");
	   }  
conn.close();
}
catch(Exception e){System.out.print(e);}
}
}