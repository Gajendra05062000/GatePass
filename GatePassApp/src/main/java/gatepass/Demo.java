package gatepass;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;


public class Demo {
	public Connection conn = null;
	Statement st=null;

		
		
	
/*public int getid() 
{
    try
    { 
    	Connection conn = null;
    	Statement st=null;
    
    	Database db = new Database();	
    	conn = db.getConnection();
		st=conn.createStatement();
    int id=0;
    	ResultSet rs = st.executeQuery("select max(id) from visitor"); // Executing the Query
    	while(rs.next()){
    		System.out.println("hellooo");
    	id=rs.getInt(1);
        }
    	return id;
    }
    catch (Exception e)
    {String amit="amit";
        System.out.println(e); // Incase of Error, Print the error
        return 0;
    }
}*/

public int getmaxid() 
{
    try
    { 
    	Connection conn = null;
    	Statement st=null;
    	Database dc = new Database();
		conn = dc.getConnection();
		st=conn.createStatement();
    int id=0;
    	ResultSet rs = st.executeQuery("select max(id) from visitor"); // Executing the Query
    	while(rs.next()){
    	
    	id=rs.getInt(1);
    	System.out.println("Class Get Max Id--"+id);
    	
        }
    	conn.close(); 
    	return id;
    	
    }
    catch (Exception e)
    {
        System.out.println("Getting Max id Error Occured-->"+e); // Incase of Error, Print the error
        return 0;
    }
}

}


