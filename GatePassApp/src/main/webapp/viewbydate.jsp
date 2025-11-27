<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="gatepass.Database" %>
<%@ page import="java.io.*" %> 
<%@ page import="java.text.*" %> 

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
<%!
// Define the date format mask for Oracle, matching the YYYY-MM-DD input
private static final String DATE_FORMAT_MASK = "YYYY-MM-DD"; 
%>

<!DOCTYPE HTML>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Visitor Records by Date</title>
    <style>
        /* Base Styling */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; padding: 20px; }
        h2 { color: #1e3c72; margin-bottom: 20px; text-align: center; }
        
        /* Search Bar Styling */
        #searchInput {
            width: 100%;
            padding: 12px 20px;
            margin-bottom: 20px;
            box-sizing: border-box;
            border: 2px solid #ccc;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        #searchInput:focus {
            border-color: #007bff;
            outline: none;
        }

        /* Professional Table Styling */
        #visitorTable { 
            border-collapse: collapse; 
            width: 100%; 
            margin-top: 20px; 
            box-shadow: 0 4px 8px rgba(0,0,0,0.1); /* Subtle shadow for depth */
            border-radius: 8px; /* Apply to container for overall rounding */
            overflow: hidden; /* Ensures borders/shadows conform to border-radius */
        }
        #visitorTable th { 
            background-color: #1e3c72; /* Darker, primary header color */
            color: white; 
            padding: 12px 15px; 
            text-align: left; 
            font-size: 15px; 
            font-weight: bold;
            border: none; /* Remove inner borders on header */
        } 
        #visitorTable td { 
            border: 1px solid #ddd; /* Light separator lines */
            padding: 10px 15px; 
            text-align: left; 
            font-size: 14px; 
            background-color: #ffffff; /* White background for rows */
            color: #333;
        }
        #visitorTable tr:nth-child(even) td {
            background-color: #f9f9f9; /* Subtle striping for readability */
        }
        #visitorTable tr:hover td {
            background-color: #e0f7fa; /* Highlight row on hover */
            cursor: default;
        }
        #visitorTable td a {
            color: #007bff;
            text-decoration: none;
        }
        #visitorTable td a:hover {
            text-decoration: underline;
        }
        
        img { display: block; max-width: 100px; height: 70px; object-fit: cover; border-radius: 4px; }
    </style>
</head>
<body>

<%
    // 1. Get and log parameters
	String fromdate = request.getParameter("datum1");
	System.out.println("JSP View By Date --fromdate-" + fromdate);
	String todate = request.getParameter("datum");
	System.out.println("JSP View By Date --todate-" + todate);
    
    // Check for null or empty dates before proceeding
    if (fromdate == null || fromdate.isEmpty() || todate == null || todate.isEmpty()) {
%>
        <h2>Error: Please select both a From Date and a To Date.</h2>
<%
        return; // Stop execution
    }

    Connection conn = null;
    PreparedStatement ps = null; 
    ResultSet rs = null;

    try {
        // 2. Establish connection
        gatepass.Database db = new gatepass.Database();	
        conn = db.getConnection();
        System.out.println("DB CONNECTED-->PERSONNEL");

        // 3. CORRECT SQL QUERY: Use TO_DATE with a format mask matching the input (YYYY-MM-DD)
        String sql = "SELECT * FROM visitor WHERE entrydate BETWEEN TO_DATE(?, ?) AND TO_DATE(?, ?) ORDER BY id DESC";
        
        System.out.println("JSP View By Date --SQL Query Structure: " + sql.replace("?", "DATE_LITERAL"));	 

        ps = conn.prepareStatement(sql);
        
        // Set parameters for the Prepared Statement
        ps.setString(1, fromdate);
        ps.setString(2, DATE_FORMAT_MASK);
        ps.setString(3, todate);
        ps.setString(4, DATE_FORMAT_MASK);

        // 4. Execute Query
        rs = ps.executeQuery();
%>
    
    <h2>Details of Visitors from: <%=fromdate %> to: <%=todate %></h2>
    
    <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search by name, ID, contact, officer, or purpose...">

    <TABLE id="visitorTable" cellpadding="0" cellspacing="0">		
        <thead>
            <TR> 
                <th>VISITOR ID</th>
                <th>NAME</th>
                <th>FATHER NAME</th>
                <th>ADDRESS</th>
                <th>CONTACT NUMBER</th>
                <th>DATE OF VISIT</th>
                <th>TIME OF VISIT</th>
                <th>PHOTO</th>
                <th>OFFICER TO MEET</th>
                <th>PURPOSE</th>
                <th>MATERIAL</th>
            </TR>
        </thead>
        <tbody>
        
        <%
            // 5. Process Results
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                System.out.println("View By Date result Id is -->" + rs.getString("id"));
        %>
        
        <TR>    
            <td><a href="print_visitor_card.jsp?id=<%= rs.getString("id") %>" target="blank" > <%=rs.getString("id") %> </a></td>
            
            <TD><%=rs.getString("NAME") != null ? rs.getString("NAME").toUpperCase() : "" %></TD>
            <td><%=rs.getString("FATHERNAME") %></td>
            <TD>
                <%=rs.getString("ADDRESS")%><br>
                <%=rs.getString("DISTRICT")%><BR>
                <%=rs.getString("STATE")%><br>
                <%=rs.getString("PINCODE") %>
            </TD>
            <TD><%=rs.getString("PHONE")%></TD>
            
            <TD><%=rs.getString("ENTRYDATE")%></TD>
            <TD><%=rs.getString("TIME")%></TD>
            <td >
                <a href="ShowVisitor.jsp?id=<%=rs.getString("id") %>">
                    <img src="ShowVisitor.jsp?id=<%=rs.getString("id") %>" alt="Visitor Photo" /> 
                </a>
            </td>
            <TD><%=rs.getString("OFFICERTOMEET")%></TD>
            <TD><%=rs.getString("PURPOSE")%></TD>
            <TD><%=rs.getString("MATERIAL")%></TD>
        </TR>

        <%    } // end while loop %>
        
        <% if (rowCount == 0) { %>
            <tr><td colspan="11" style="text-align: center; color: #cc0000; font-weight: bold;">No records found for the selected date range.</td></tr>
        <% } %>
        </tbody>
    </TABLE>
    
    <script>
        function filterTable() {
            // Declare variables
            var input, filter, table, tr, td, i, j, txtValue;
            input = document.getElementById("searchInput");
            filter = input.value.toUpperCase();
            table = document.getElementById("visitorTable");
            tr = table.getElementsByTagName("tr");

            // Loop through all table rows, starting after the header (tr[1])
            for (i = 1; i < tr.length; i++) {
                // Assume the row is hidden unless a match is found
                var rowMatch = false;
                
                // Loop through all table cells (td) in the current row
                td = tr[i].getElementsByTagName("td");
                for (j = 0; j < td.length; j++) {
                    if (td[j]) {
                        // Extract text value from the cell
                        txtValue = td[j].textContent || td[j].innerText;
                        
                        // Check if the cell content matches the filter
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            rowMatch = true;
                            break; // Stop checking cells in this row once a match is found
                        }
                    }
                }
                
                // Show or hide the row based on whether a match was found
                if (rowMatch) {
                    tr[i].style.display = "";
                } else {
                    tr[i].style.display = "none";
                }
            }
        }
    </script>

<%
    } catch (SQLException ex) {
        // Log SQL errors to console and display a generic message to the user
        System.err.println("SQL Error in View by date: " + ex.getMessage());
        if (ex.getErrorCode() == 1861) {
%>
            <h2>⚠️ Database Error: Date format mismatch. The system tried to query dates from <%=fromdate %> to <%=todate %>, but the database rejected the format.</h2>
<%
        } else {
%>
            <h2>An unexpected database error occurred. Please check system logs.</h2>
<%
        }
    } catch (Exception ex) {
        // Catch all other exceptions 
        System.err.println("General Error in View by date: " + ex.getMessage());
%>
        <h2>A general error occurred: <%= ex.getMessage() %></h2>
<%
    } finally {
        // 6. Resource Cleanup (Crucial!)
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>	
</body>
</html>