package gatepass;

import java.io.InputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part; // Essential for file handling

@WebServlet("/saveContract")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class SaveContract extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        System.out.println("➡ SaveContract.doPost invoked");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        Connection conn = null;
        PreparedStatement ps = null;
        
        Part filePart = null;
        String fileName = null;
        InputStream fileContent = null; 

        try {
            
            // --- 1. Retrieve Form Fields ---
            int id = parseIntOrDefault(request.getParameter("id"), 0); 
            if (id == 0) {
                 throw new IllegalArgumentException("Contract Serial No (ID) is missing or invalid.");
            }
            
            int renewal_id = parseIntOrDefault(request.getParameter("renewal_id"), -1);
            String worksite = getParam(request, "worksite", "");
            String name = getParam(request, "name", "");
            String ContractorName = getParam(request, "Contractor", "");
            String dept = getParam(request, "dept", "");
            String address = getParam(request, "address", "");
            String phone = getParam(request, "phone", "");

            // Get Adhar as String (Correct for ORA-01461 when Adhar is a VARCHAR2 field)
            String adhar = request.getParameter("adhar"); 
            String reg = getParam(request, "reg", "");
            String desp = getParam(request, "desp", "");
            String valdity_fromDate = getParam(request, "valdity_fromDate", "");
            String valdity_toDate = getParam(request, "valdity_toDate", "");
            String type = getParam(request, "type", "");
            int laboursize = parseIntOrDefault(request.getParameter("laboursize"), 20);
            
            
            // --- 2. Retrieve File ---
            // ⚠️ FIX: Use the correct parameter name from the JSP form ('contractDocument')
            // I'm assuming the JSP uses 'contractDocument' as specified in previous steps
            filePart = request.getPart("Document"); 
            
            if (filePart != null) {
                fileName = filePart.getSubmittedFileName();
                fileContent = filePart.getInputStream();
            } else {
                System.out.println("Contract Document file is missing.");
            }
            
            // --- 3. DB Connection ---
            Database db = new Database();
            conn = db.getConnection();

            // --- 4. Define SQL (17 Columns, 17 Placeholders) ---
            String sql = "INSERT INTO GATEPASS_CONTRACT ("
                        + "ID, RENEWAL_ID, CONTRACT_NAME, CONTRACTOR_NAME, DEPARTMENT, "
                        + "CONTRACTOR_ADDRESS, WORKSITE, DESCRIPTION, CONTRACTOR_ADHAR, "
                        + "VALIDITY_FROM, VALIDITY_TO, CONTRACT_TYPE, "
                        + "DOCUMENT1, REGISTRATION, UPDATE_DATE, UPDATE_BY,PHONE,LABOUR_SIZE) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, "
                        + "TO_DATE(?, 'YYYY-MM-DD'), TO_DATE(?, 'YYYY-MM-DD'), " 
                        + "?, ?, ?, ?, ?, ?, ?)"; 

            ps = conn.prepareStatement(sql);

            // --- 5. Set Parameters (1 to 17) ---
            
            ps.setInt(1, id);
            
            // RENEWAL_ID (Index 2)
            if (renewal_id == -1)
                ps.setNull(2, java.sql.Types.INTEGER);
            else
                ps.setInt(2, renewal_id);

            ps.setString(3, name);
            ps.setString(4, ContractorName);
            ps.setString(5, dept);
            ps.setString(6, address);
            ps.setString(7, worksite); 
            ps.setString(8, desp);
            
            // CONTRACTOR_ADHAR (Index 9) - Stays as String
            ps.setString(9, adhar); 

            // VALIDITY DATES (Index 10 & 11)
            ps.setString(10, valdity_fromDate); 
            ps.setString(11, valdity_toDate);
            
            ps.setString(12, type); 
 

            // DOCUMENT (Index 13 - BLOB)
            if (fileContent != null) {
                ps.setBinaryStream(13, fileContent, filePart.getSize());
            } else {
                ps.setNull(13, java.sql.Types.BLOB);
            }
            
            ps.setString(14, reg); 
            
            // UPDATE_DATE (Index 16) - If this fails, check column size or use ps.setTimestamp
            CommonService cs = new CommonService();
            ps.setString(15, cs.selectDateTime().toString()); 
            ps.setString(16, "NA"); // UPDATE_BY 
            ps.setString(17, phone); 
            ps.setInt(18, laboursize);
            
            // --- 6. Execute Update ---
            int result = ps.executeUpdate();
            
            if (result == 1) {
                System.out.println("✅ Data Inserted successfully. Contract ID: " + id);
                request.getRequestDispatcher("PrintContract.jsp?srNo=" + id).forward(request, response);
            } else {
                out.println("<h3>❌ Failed to Insert Data. Zero rows affected.</h3>");
            }

        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            out.println("<h3>Database Error: Please check server logs for details.</h3>");
            
            // Provide specific advice for ORA-01461
            if (e.getErrorCode() == 1461) {
                out.println("<h4>Action Required: ORA-01461 suggests one of your string columns (e.g., ADHAR, DOCUMENT1, ADDRESS) is too small for the data provided. Check and increase the size of the corresponding VARCHAR2 column in the GATEPASS_CONTRACT table.</h4>");
            } else {
                 out.println("<h4>Error Details: " + e.getMessage() + "</h4>");
            }
        } catch (Exception e) {
            System.err.println("General Error: " + e.getMessage());
            out.println("<h3>General Error: " + e.getMessage() + "</h3>");
        } finally {
            // --- 7. Resource Cleanup ---
            if (fileContent != null) try { fileContent.close(); } catch (IOException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }

    // Utility
    private int parseIntOrDefault(String val, int def) {
        try { 
            // NOTE: Using name="srNo" in JSP and retrieving here, not name="id"
            return (val == null || val.trim().isEmpty()) ? def : Integer.parseInt(val.trim()); 
        } catch (NumberFormatException e) { 
            return def; 
        }
    }

    private String getParam(HttpServletRequest req, String key, String def) {
        String v = req.getParameter(key);
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }
}