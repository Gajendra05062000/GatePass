package gatepass; // Assuming this is your package

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date; // Use java.sql.Date for database insertion
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Base64;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// IMPORTANT: @MultipartConfig is necessary for decoding the Base64 data if you used a file upload field. 
// However, since the photo is passed as a Base64 string in a HIDDEN field, we DO NOT need the Part/file upload handling for the image itself.
// But since the form might technically still be multipart/form-data due to the Base64 size, 
// keeping the annotation can sometimes prevent issues, though it's technically unnecessary for text-only submission.
// I will adjust the code to handle the Base64 string directly from the request parameter.
@WebServlet("/SaveContractLabourData")
public class SaveContractLabourData extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Utility function for proper SQL String escaping (Used for PASS_IDS update)
    private String safeSql(String s) {
        if (s == null) return "NULL";
        return "'" + s.replace("'", "''") + "'";
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Ensure authentication check is in place (though JSP handles initial display)
        if (request.getSession().getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Connection connPost = null;
        PreparedStatement psPost = null;
        Statement stPost = null;
        ResultSet rsPost = null;
        File imageFile = null;
        int submittedSerNo = 0;
        String message = null;
        try {
            // 1. Retrieve form parameters
            String name = request.getParameter("name");
            String fatherName = request.getParameter("fatherName");
            String desig = request.getParameter("desig");
            String age = request.getParameter("age");
            String localAddress = request.getParameter("localAddress");
            String permanentAddress = request.getParameter("permanentAddress");
            String contrctrNameAddress = request.getParameter("contrctrNameAddress");
            String vehicleNumber = request.getParameter("vehicleNumber");
            String identification = request.getParameter("identification");
            String renwlTypeSel = request.getParameter("renwlTypeSel");
            String refNo = request.getParameter("refNo");
            String Aadhaar = request.getParameter("Aadhaar");
            String Phone = request.getParameter("phone");
            String worksite = request.getParameter("worksite");
            String contractDisplayId = request.getParameter("contractId"); // Holds "(ID) Name"
            String fromDateStr = request.getParameter("valdity_fromDate");
            String toDateStr = request.getParameter("valdity_toDate");
            String imageData = request.getParameter("imageData"); // Base64 String

            // --- Server-Side Validation and Extraction ---
            
            // Check for image data
            if (imageData == null || imageData.trim().isEmpty()) {
                message = "Submission Failed: Please capture a photo before submitting!";
                throw new Exception(message); 
            }

            // Extract Contract ID
            String contractId = "";
            if (contractDisplayId != null && contractDisplayId.startsWith("(")) {
                int endIndex = contractDisplayId.indexOf(")");
                if (endIndex > 0) {
                    contractId = contractDisplayId.substring(1, endIndex).trim();
                }
            }
            if (contractId.trim().isEmpty()) {
                message = "Submission Failed: Please select a valid Contract.";
                throw new Exception(message); 
            }
            
            // Date conversion
            Date sqlFromDate = null;
            Date sqlToDate = null;
            if (fromDateStr != null && !fromDateStr.isEmpty()) { sqlFromDate = Date.valueOf(fromDateStr); }
            if (toDateStr != null && !toDateStr.isEmpty()) { sqlToDate = Date.valueOf(toDateStr); }

            // --- Database Transaction Start ---
            gatepass.Database db = new gatepass.Database();
            connPost = db.getConnection();
            connPost.setAutoCommit(false); // Start transaction
            
            // --- Get the current SER_NO that will be used (Atomic Increment) ---
            stPost = connPost.createStatement();
            rsPost = stPost.executeQuery("SELECT NVL(MAX(SER_NO), 0) + 1 FROM GATEPASS_CONTRACT_LABOUR");
            if (rsPost.next()) {
                submittedSerNo = rsPost.getInt(1);
            } else {
                 submittedSerNo = 1;
            }
            rsPost.close();
            stPost.close();
            
            // --- Image Handling (Decode Base64 and Save to disk) ---
            
            if (imageData.startsWith("data:image"))
                imageData = imageData.substring(imageData.indexOf(",") + 1);

            byte[] imageBytes = Base64.getDecoder().decode(imageData);

            String saveDir = "C:/GatepassImages/Labour/"; 
            File folder = new File(saveDir);
            if (!folder.exists()) folder.mkdirs();

            imageFile = new File(saveDir + "Labour_" + submittedSerNo + ".png");

            try (FileOutputStream fos = new FileOutputStream(imageFile)) {
                fos.write(imageBytes);
            }
            System.out.println("📷 Labour Image saved at: " + imageFile.getAbsolutePath());
            
            // --- 1. INSERT CONTRACT LABOUR RECORD ---
            String sqlInsert = "INSERT INTO GATEPASS_CONTRACT_LABOUR(SER_NO, NAME, FATHER_NAME, DESIGNATION, \"AGE\", LOCAL_ADDRESS, PERMANENT_ADDRESS, CONTRACTOR_NAME_ADDRESS, VEHICLE_NO, IDENTIFICATION, RENEWAL_TYPE, REF_NO, VALIDITY_FROM, VALIDITY_TO, \"PHOTO\", CONTRACT_NAME_ID, \"UPDATE_DATE\", AADHAR, PHONE, WORKSITE) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,SYSDATE,?,?,?)";

            try (FileInputStream fis = new FileInputStream(imageFile)) {
                
                psPost = connPost.prepareStatement(sqlInsert);
                
                psPost.setInt(1, submittedSerNo);
                psPost.setString(2, name);
                psPost.setString(3, fatherName);
                psPost.setString(4, desig);
                psPost.setString(5, age); 
                psPost.setString(6, localAddress);
                psPost.setString(7, permanentAddress);
                psPost.setString(8, contrctrNameAddress);
                psPost.setString(9, vehicleNumber);
                psPost.setString(10, identification);
                psPost.setString(11, renwlTypeSel);
                psPost.setString(12, refNo);
                psPost.setDate(13, sqlFromDate);
                psPost.setDate(14, sqlToDate);
                psPost.setBinaryStream(15, fis, (int) imageFile.length());
                psPost.setString(16, contractDisplayId); // CONTRACT_NAME_ID (Stores full display string)
                psPost.setString(17, Aadhaar); 
                psPost.setString(18, Phone);
                psPost.setString(19, worksite);
                
                psPost.executeUpdate();
                psPost.close();
            } 

            // --- 2. UPDATE CONTRACT TABLE (Transactional Update) ---
            String sqlUpdateContract = 
                "UPDATE GATEPASS_CONTRACT " +
                "SET COUNT = NVL(COUNT, 0) + 1, " +
                "PASS_IDS = NVL(PASS_IDS, '') || CASE WHEN LENGTH(PASS_IDS) > 0 THEN ', ' ELSE '' END || " + safeSql(String.valueOf(submittedSerNo)) +
                "WHERE ID = " + safeSql(contractId);

            stPost = connPost.createStatement();
            stPost.executeUpdate(sqlUpdateContract);
            stPost.close();
            
            // --- COMMIT TRANSACTION ---
            connPost.commit();

            // Success redirection to print page
            response.sendRedirect("PrintContractLabour.jsp?srNo=" + submittedSerNo);
            return;
            
        } catch (Exception e) {
            if (connPost != null) {
                try {
                    connPost.rollback(); // Rollback transaction on error
                    System.err.println("Transaction rolled back for error: " + e.getMessage());
                } catch (SQLException ignore) {}
            }
            
            if (message == null) {
               message = "Critical Error saving data (Rollback executed): " + e.getMessage();
            }
            
            // Set attributes to send error message back to the JSP
            request.setAttribute("message", message);
            request.setAttribute("isError", true);
            
            // Forward back to the form JSP
            request.getRequestDispatcher("/ContractLabourEntry.jsp").forward(request, response);
            
        } finally {
            // Clean up resources
            if (rsPost != null) try { rsPost.close(); } catch (SQLException ignore) {}
            if (stPost != null) try { stPost.close(); } catch (SQLException ignore) {}
            if (connPost != null) try { connPost.close(); } catch (SQLException ignore) {}
            // Clean up temp image file after insertion attempt
            if (imageFile != null && imageFile.exists()) { imageFile.delete(); } 
        }
    }
}