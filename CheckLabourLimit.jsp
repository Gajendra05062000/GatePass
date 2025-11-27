<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="gatepass.Database" %>
<%@ page import="org.json.JSONObject" %>
<%
    // Ensure the response is treated as JSON
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    // Initialize JSON object for response
    JSONObject jsonResponse = new JSONObject();

    String contractId = request.getParameter("contractId");

    // Check for mandatory parameter
    if (contractId == null || contractId.trim().isEmpty()) {
        jsonResponse.put("status", "error");
        jsonResponse.put("message", "Missing contractId parameter.");
        out.print(jsonResponse.toString());
        return;
    }

    gatepass.Database db = new gatepass.Database();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = db.getConnection();
        // SQL to fetch COUNT and LABOUR_SIZE
        String sql = "SELECT COUNT, LABOUR_SIZE, CONTRACT_NAME FROM GATEPASS_CONTRACT WHERE ID = ?";
        ps = conn.prepareStatement(sql);
        
        // Sanitize input before setting parameter
        int id = Integer.parseInt(contractId);
        ps.setInt(1, id);

        rs = ps.executeQuery();

        if (rs.next()) {
            int currentCount = rs.getInt("COUNT");
            int labourSize = rs.getInt("LABOUR_SIZE");
            String contractName = rs.getString("CONTRACT_NAME");

            jsonResponse.put("status", "success");
            jsonResponse.put("contractId", id);
            jsonResponse.put("contractName", contractName);
            jsonResponse.put("currentCount", currentCount);
            jsonResponse.put("labourSize", labourSize);
            
        } else {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Contract ID not found.");
        }

    } catch (NumberFormatException e) {
        jsonResponse.put("status", "error");
        jsonResponse.put("message", "Invalid Contract ID format.");
        System.err.println("Invalid Contract ID format: " + contractId);
    } catch (SQLException e) {
        jsonResponse.put("status", "error");
        jsonResponse.put("message", "Database error: " + e.getMessage());
        System.err.println("Database error in CheckLabourLimit: " + e.getMessage());
    } catch (Exception e) {
        jsonResponse.put("status", "error");
        jsonResponse.put("message", "An unexpected error occurred: " + e.getMessage());
        System.err.println("Unexpected error in CheckLabourLimit: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }

    // Print the final JSON response
    out.print(jsonResponse.toString());
%>