package hrishi;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.imageio.ImageIO;

public class SaveImage {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		SaveImage db = new SaveImage();	
		db.savePic();
		db.retreivePic();
		
	}
	

	//save image
	public static void savePic() {
		Connection conn = null;
		SaveImage db = new SaveImage();	
		conn = db.getConnection();
	

		try{
			 PreparedStatement ps = 
			 conn.prepareStatement("INSERT INTO HRISHI_IMAGE VALUES(?,?)");
			 
				String filePath="E:/Image/nfl.jpg";
			  File binaryfile =new File(filePath);
			   FileInputStream fs = new FileInputStream(binaryfile);
			   
			   ps.setString(1,"1000");
			   ps.setBinaryStream(2,fs,(int)fs.available()) ;
			   System.out.println("Inserting image value --"+fs.toString());
			   
			   int is =(ps.executeUpdate());
			   ps.close();
			   conn.close(); 
			   if(is==1){
				   System.out.println("Data Inserted Successfully");
			   }
	}
	   catch (Exception e){
	   System.out.println(e);
	   }
	
	}

	//retreive image
	public static void retreivePic() {
		Connection conn = null;
		SaveImage db = new SaveImage();	
		conn = db.getConnection();
		String filePath="E:/Image/nfl.png";

		try{
			 //String qry = "select * from HRISHI_IMAGE where ser_no=1000";
			 String qry = "select image from PERSONNEL.visitor  where id =4361";
			 Statement st = conn.createStatement();
			 ResultSet rs=st.executeQuery(qry);  
			 
			 if(rs.next())
				{ 	
				 InputStream readImg = rs.getBinaryStream(1);
				 BufferedImage bImageFromConvert = ImageIO.read(readImg);
		         ImageIO.write(bImageFromConvert, "jpg", new File("e:/Hrishi.jpg"));

				   
				}
			   
			 //conn.close(); 
	}
	   catch (Exception e){
	   System.out.println(e);
	   }
	
	}
	
	
	
	
	public Connection getConnection() {
		Connection conn = null;
		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");

			String url = "jdbc:oracle:thin:@10.3.126.84:1521:ORCL";
			//conn = DriverManager.getConnection(url, "scott", "tiger");
			conn = DriverManager.getConnection(url, "PAYROLL", "PAYROLL");
			
			
			System.out.println("DB CONNECTED-->PERSONNEL");
			// conn.close(); 
		} catch (Exception e) {
			e.printStackTrace();
		}
		return (conn);
	}

}
