<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, gatepass.Database" %>
<%
    // ==========================================================
    // 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
    // ==========================================================
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
    response.setHeader("Pragma", "no-cache");    // HTTP 1.0.
    response.setDateHeader("Expires", 0);        // Proxies.

    // ==========================================================
    // 🔑 SESSION AUTHENTICATION CHECK
    // ==========================================================
    // Check if the "username" session attribute exists (set during successful login)
    if (session.getAttribute("username") == null) {
        // If not authenticated, redirect to the main login page
        response.sendRedirect("login.jsp");
        return; // Stop processing the rest of the page
    }
%>
<%
    // --- SERVER-SIDE PROCESSING ---
    String message = null;
    String messageClass = "info"; // Default message class
    
    // Check if the form was submitted
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String oldPassword = request.getParameter("old_password");
        String newPassword = request.getParameter("new_password");
        String confirmPassword = request.getParameter("confirm_password");
        String user = (String) session.getAttribute("username");
        
        // Basic Server-side validation
        if (oldPassword == null || oldPassword.isEmpty() || 
            newPassword == null || newPassword.isEmpty() || 
            confirmPassword == null || confirmPassword.isEmpty()) {
            
            message = "All fields are required.";
            messageClass = "error";
            
        } else if (!newPassword.equals(confirmPassword)) {
            
            message = "New password and confirmation password do not match.";
            messageClass = "error";
            
        } else {
            
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            boolean updateSuccessful = false;
            
            try {
                gatepass.Database db = new gatepass.Database();
                conn = db.getConnection();

                // 1. AUTHENTICATE OLD PASSWORD
                String authSql = "SELECT PASSWD FROM GATEPASS_PASSWORD_MANAGER WHERE USERNAME = ?";
                ps = conn.prepareStatement(authSql);
                ps.setString(1, user);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    String storedPassword = rs.getString("PASSWD");
                    
                    if (storedPassword.equals(oldPassword)) {
                        
                        // 2. UPDATE PASSWORD
                        String updateSql = "UPDATE GATEPASS_PASSWORD_MANAGER SET PASSWD = ? WHERE USERNAME = ?";
                        if (ps != null) ps.close(); // Close previous statement
                        ps = conn.prepareStatement(updateSql);
                        ps.setString(1, newPassword);
                        ps.setString(2, user);
                        
                        int rowsAffected = ps.executeUpdate();
                        
                        if (rowsAffected > 0) {
                            updateSuccessful = true;
                        }
                    } else {
                        message = "Failed to change password: Current password is incorrect.";
                        messageClass = "error";
                    }
                } else {
                    // Should not happen for a logged-in user
                    message = "Error: User account not found.";
                    messageClass = "error";
                }

            } catch (SQLException e) {
                message = "Database Error: Failed to update password.";
                messageClass = "error";
                System.err.println("SQL Error during password change for " + user + ": " + e.getMessage());
            } catch (Exception e) {
                message = "System Error: Failed to change password.";
                messageClass = "error";
                System.err.println("General Error during password change for " + user + ": " + e.getMessage());
            } finally {
                // Resource Cleanup (Crucial)
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
            
            // 3. SET MESSAGE (NO REDIRECT ON SUCCESS)
            if (updateSuccessful) {
                // Successful update! Set message to be displayed on this page.
                message = "Your password has been changed successfully!";
                messageClass = "success";
            } else if (message == null) {
                 // Fallback message if a generic failure occurred
                message = "Failed to change password. Please check your current password and try again.";
                messageClass = "error";
            }
        }
    }
    // ------------------------------------------
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Change Password</title>

    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background-color: #f4f7f6; 
            padding: 20px; 
            color: #333; 
        }
        
        .form-container {
            max-width: 500px;
            margin: 50px auto;
            padding: 35px;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        h2 {
            color: #1e3c72;
            margin-bottom: 30px;
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #555;
            font-size: 15px;
        }

        .form-group input {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
            transition: border-color 0.3s;
        }

        .form-group input:focus {
            border-color: #1e3c72;
            outline: none;
        }

        button.submit-btn {
            width: 100%;
            padding: 12px;
            background-color: #1e3c72;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 17px;
            font-weight: bold;
            transition: background-color 0.3s, transform 0.1s;
        }

        button.submit-btn:hover {
            background-color: #0056b3;
            transform: translateY(-1px);
        }
        
        /* Message Styling */
        .message {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
            font-weight: bold;
            text-align: center;
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .message.info {
            background-color: #cce5ff;
            color: #004085;
            border: 1px solid #b8daff;
        }
    </style>
</head>
<body onload="document.getElementById('old_password').focus();">

    <div class="form-container">
        <h2>🔑 Change Your Password</h2>
        
        <% 
        // 1. Render server-side message or client-side placeholder
        if (message != null) { 
        %>
            <div id="statusMessage" class="message <%= messageClass %>">
                <%= message %>
            </div>
        <% } else { %>
            <!-- Placeholder for client-side JS messages -->
            <div id="statusMessage" class="message" style="display: none;"></div>
        <% } %>

        <form id="changePasswordForm" method="POST" action="<%= request.getRequestURI() %>" onsubmit="return validateForm()">
            <div class="form-group">
                <label for="old_password">Current Password:</label>
                <input type="password" id="old_password" name="old_password" required>
            </div>
            
            <div class="form-group">
                <label for="new_password">New Password:</label>
                <input type="password" id="new_password" name="new_password" required>
            </div>
            
            <div class="form-group">
                <label for="confirm_password">Confirm New Password:</label>
                <input type="password" id="confirm_password" name="confirm_password" required>
            </div>
            
            <button type="submit" class="submit-btn">Update Password</button>
        </form>
    </div>

    <script>
        function validateForm() {
            const newPass = document.getElementById('new_password').value;
            const confirmPass = document.getElementById('confirm_password').value;
            const messageDiv = document.getElementById('statusMessage');

            // Client-side validation for password match
            if (newPass !== confirmPass) {
                // Display error message using the existing UI element
                messageDiv.style.display = 'block';
                messageDiv.className = 'message error';
                messageDiv.innerHTML = 'Error: New Password and Confirmation do not match!';
                document.getElementById('new_password').focus();
                return false;
            }

            // Clear potential old server errors and show "processing" before POST
            messageDiv.style.display = 'block';
            messageDiv.className = 'message info';
            messageDiv.innerHTML = 'Processing request...';
            
            // Client-side validation successful, allow form submission
            return true;
        }
    </script>
</body>
</html>