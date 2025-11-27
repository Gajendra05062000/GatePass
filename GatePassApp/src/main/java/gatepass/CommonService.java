package gatepass;

import java.sql.ResultSet;
import java.sql.Statement;
public class CommonService {

	java.sql.Connection myConnection;
	public String selectDateTime(){	
		String mmYyyy = null;
		Database db = new Database();	
		myConnection = db.getConnection();
		
			
		String qryString = "select to_char(sysdate,'DD-MON-YYYY') from dual";
			
			try{			
				Statement stmt = myConnection.createStatement();
				ResultSet rset = stmt.executeQuery(qryString);
				while (rset.next()){
					mmYyyy = rset.getString(1);
				}
				myConnection.close();
				
			}
			catch(Exception e){
				e.printStackTrace();
				
			}
			return mmYyyy;
		}
}
