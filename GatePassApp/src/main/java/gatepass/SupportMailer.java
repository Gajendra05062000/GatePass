package gatepass;
import java.io.IOException;
import java.util.Properties;

// Jakarta/Java Mail Imports
import jakarta.mail.Authenticator; // Must be jakarta.mail.Authenticator
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

// Jakarta Servlet Imports
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// Map this Servlet to the URL action used in your form
@WebServlet("/SupportMailer")
public class SupportMailer extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // --- 🚨 Configuration Variables - UPDATE THESE! ---
    // NOTE: If using Gmail, you MUST use an App Password, not your login password.
    private static final String SMTP_HOST = "smtp.gmail.com"; 
    private static final String SMTP_PORT = "587"; 
    private static final String SENDER_EMAIL = "gagendra2@gmail.com";
    private static final String SENDER_PASSWORD = "Brijendra@1"; 
    // ----------------------------------------------------

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get parameters from the JSP form
        String toEmail = request.getParameter("toEmail");
        String subjectType = request.getParameter("supportSubject");
        String messageBody = request.getParameter("messageBody");
        String fromUser = request.getParameter("fromUser"); 

        String finalSubject = "[Gate Pass Support] " + subjectType;
        String fullBody = "Support Request from User: " + fromUser + "\n\n" + messageBody;
        
        boolean emailSent = false;
        String resultMessage = "";

        try {
            // 2. Setup Mail Properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            // Required for some servers (like Gmail)
            props.put("mail.smtp.ssl.protocols", "TLSv1.2"); 

            // 3. Create Session with Authentication
            // Explicitly use jakarta.mail.Session
            jakarta.mail.Session session = jakarta.mail.Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                }
            });
            
            // 4. Create and Send Message
            // Explicitly use jakarta.mail.Message
            jakarta.mail.Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Gate Pass System Support"));
            message.setRecipients(jakarta.mail.Message.RecipientType.TO, InternetAddress.parse(toEmail));
            
            // Optionally, set the user as Reply-To
            message.setReplyTo(new InternetAddress[] { new InternetAddress(SENDER_EMAIL, fromUser) }); 
            
            message.setSubject(finalSubject);
            message.setText(fullBody);

            Transport.send(message);
            emailSent = true;
            resultMessage = "Support request sent successfully! We will respond shortly.";
            
        } catch (MessagingException e) {
            System.err.println("Messaging Exception during email send: " + e.getMessage());
            e.printStackTrace();
            resultMessage = "Failed to send request. Mail Server Error: " + e.getMessage();
        } catch (Exception e) {
            System.err.println("General Exception during email send: " + e.getMessage());
             e.printStackTrace();
            resultMessage = "Failed to send request. System Error: " + e.getMessage();
        }

        // 5. Redirect back to the JSP with a status message
        request.setAttribute("mailStatus", resultMessage);
        request.setAttribute("mailSuccess", emailSent);
        
        // Forward to the result page
        request.getRequestDispatcher("/support_result.jsp").forward(request, response);
    }
}