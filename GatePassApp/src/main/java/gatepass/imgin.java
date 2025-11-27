package gatepass;
import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;;

public class imgin extends HttpServlet {
  public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException
  { PrintWriter out=response.getWriter();
 /* 
  out.println("<html>");
  out.println("<head>");

  out.println("<title></title></head>");
  out.println("<body>");

  out.println("<table><tr><td width='400px' height='300px'>"); out.println("</td></tr></table>");*/
  Runtime r=Runtime.getRuntime();
  System.out.println("helllo now in imgin class");
  Process p=null;
  try {
  String s="C:/Windows/amcap.exe";
  p=r.exec(s);
  
  System.out.println("helllo now in imgin class");
  
 
  

  }
  catch(Exception e){
  System.out.println(e);
  e.printStackTrace();
  }
  }
 
 

    
	
}
