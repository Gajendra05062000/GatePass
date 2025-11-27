package gatepass;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse; 
 
public class login extends HttpServlet { 
    public void doGet(HttpServletRequest aRequest, 
      HttpServletResponse aResponse) 
    throws IOException, ServletException { 
    	
    	
        //String username = aRequest.getParameter("username"); 
        //String password = aRequest.getParameter("password"); 
        //PrintWriter out = aResponse.getWriter(); 
        //if ((username==null) || (password==null)) { 
          //  showLoginForm("Please login:", out); 
        //} else if (username.equals(password)) { 
            //HttpSession session = aRequest.getSession(); 
          //  session.setAttribute("USER", username); 
          aResponse.sendRedirect("My.jsp"); 
      //  } else { 
          //  showLoginForm("Invalid login! Try again:", out); 
        //} 
    //} 
 
    //public void doPost(HttpServletRequest aRequest, 
      //  HttpServletResponse aResponse) 
    //throws IOException, ServletException { 
      //  doGet(aRequest, aResponse); 
    //} 
 
    //private void showLoginForm( 
      //      String aCaptionText, PrintWriter aOutput) { 
       // aOutput.println( 
         //   "Dimly<title>Login</title><body>\n" + 
           // "<form method='POST' action='login'>\n" + 
            //aCaptionText + "<br>\n" + 
            //"<input type='text' name='username'><br>\n" + 
            //"<input type='password' name='password'><br>\n" + 
            //"<input type='submit' value='Login'>\n" + 
            //"</body></form></html>" 
        //); 
    }} 
