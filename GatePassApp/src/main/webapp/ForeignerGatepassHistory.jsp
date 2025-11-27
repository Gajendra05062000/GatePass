<%@ page language="java" import="java.sql.*" %>
<%@ page import="gatepass.Database" %>

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
// Define the column names for the table headers
private static final String[] HEADERS = {
    "GatePass No.","Photo", "Name", "Father Name", "Visiting Department", "Age", "Local Address", "Permanent Address", "Nationality", "Issue Date", "Action"
};
%>

<html>
<head>
<meta charset="UTF-8">
<title>Foreigner Gatepass Register</title>

 
<style>
/* Base Styling */
body { 
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
    background-color: #f4f7f6; 
    padding: 20px; 
    color: #333;
}
h2 { 
    color: #1e3c72; /* Use primary blue color */
    margin-bottom: 25px; 
    text-align: center; 
    text-transform: uppercase;
}

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
        img { display: block; max-width: 80px; height: 100px; object-fit: cover; border-radius: 4px; }

/* Professional Table Styling */
.table-wrapper {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1); 
    border-radius: 8px; 
    overflow: hidden; 
}
#registerTable { 
    border-collapse: collapse; 
    width: 100%; 
    background-color: white;
}
#registerTable th { 
    background-color: #1e3c72; /* Darker, primary header color */
    color: white; 
    padding: 12px 15px; 
    text-align: left; /* Aligned left for professionalism */
    font-size: 15px; 
    font-weight: bold;
} 
#registerTable td { 
    border: 1px solid #ddd; /* Light separator lines */
    padding: 10px 15px; 
    text-align: left; /* Aligned left for professionalism */
    font-size: 14px; 
}
#registerTable tr:nth-child(even) td {
    background-color: #f9f9f9; /* Subtle striping */
}
#registerTable tr:hover td {
    background-color: #e0f7fa; /* Highlight row on hover */
    cursor: default;
}
#registerTable td a {
    color: #007bff;
    text-decoration: none;
    font-weight: 600;
}
#registerTable td a:hover {
    text-decoration: underline;
}

/* Action Buttons */
.btn-bar {
    text-align: center;
    margin-top: 25px;
}
.btn {
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 6px;
    padding: 10px 25px;
    font-size: 15px;
    cursor: pointer;
    transition: 0.3s;
    margin: 0 10px;
}
.btn:hover {
    background-color: #0056b3;
    transform: scale(1.02);
}
.error-message {
    text-align: center;
    color: red;
    font-weight: bold;
    padding: 20px;
}
</style>

<script>
// Function to load the print page into the parent's 'right' frame
function loadPrintPageInMainFrame(srNo) { 
  const url = "PrintForeignerGatePass.jsp?srNo=" + srNo;
  
  // Check if the parent window has a frame/iframe named 'right'
  if (window.parent && window.parent.right) {
    window.parent.right.location.href = url;
  } else {
    // Fallback if not inside the frame structure
    alert("Could not load the print page in the main content frame. Loading in current window.");
    window.location.href = url;
  }
}

function filterTable() {
  const input = document.getElementById("searchInput");
  const filter = input.value.toUpperCase();
  const table = document.getElementById("registerTable");
  const tr = table.getElementsByTagName("tr");

  // Start from tr[1] to skip the header row
  for (let i = 1; i < tr.length; i++) {
    const tds = tr[i].getElementsByTagName("td");
    let show = false;

    for (let j = 0; j < tds.length; j++) {
      const td = tds[j];
      if (td) {
        const txtValue = td.textContent || td.innerText;
        if (txtValue.toUpperCase().indexOf(filter) > -1) {
          show = true;
          break;
        }
      }
    }
    tr[i].style.display = show ? "" : "none";
  }
}
</script>
</head>

<body onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode}">

<div class="container">
  <h2>FOREIGNER GATEPASS REGISTER</h2>

  <div class="search-bar">
    <input type="text" id="searchInput" onkeyup="filterTable()" 
           placeholder=" Search by Name, Nationality, or any field...">
  </div>

  <form action="ssaveForeignerGatePasDetails" method="post" 
        name="text_form" enctype="multipart/form-data"
        onsubmit="return Blank_TextField_Validator()">

    <div class="table-wrapper">
      <table id="registerTable" cellpadding="0" cellspacing="0">
        <thead>
          <tr>
            <% for (String header : HEADERS) { %>
              <th><%= header %></th>
            <% } %>
          </tr>
        </thead>
        <tbody>
          <%
          Connection conn1 = null;
          Statement st1 = null;
          ResultSet rs1 = null;
          int rowCount = 0;
          try {
            // Note: Assuming gatepass.Database is correctly imported and accessible
            gatepass.Database db1 = new gatepass.Database();	
            conn1 = db1.getConnection();
            st1 = conn1.createStatement();
            
            // Note: Updated the SELECT query to use column aliases for robustness,
            // though the original method works when columns are requested by index (1-9).
            String sql = "SELECT SER_NO, NAME, FATHER_NAME, VISIT_DEPT, AGE, LOCAL_ADDRESS, PERMANENT_ADDRESS, NATIONALITY, TO_CHAR(UPDATE_DATE,'DD-MON-YYYY') AS ISSUE_DATE " +
                         "FROM GATEPASS_FOREIGNER ORDER BY SER_NO DESC";
            
            rs1 = st1.executeQuery(sql);

            while(rs1.next()) {
                rowCount++;
          %>
          <tr>
            <td><%=rs1.getInt("SER_NO")%></td>
                         
              <td >
                <a href="ShowImageForeigner.jsp?srNo=<%=rs1.getString("SER_NO") %>" target="_blank">
                    <img src="ShowImageForeigner.jsp?srNo=<%=rs1.getString("SER_NO") %>" alt="Foreigner Photo" /> 
               </a>
              </td>
            <td><%=rs1.getString("NAME")%></td>
            <td><%=rs1.getString("FATHER_NAME")%></td>
            <td><%=rs1.getString("VISIT_DEPT")%></td>
            <td><%=rs1.getString("AGE")%></td>
            <td><%=rs1.getString("LOCAL_ADDRESS")%></td>
            <td><%=rs1.getString("PERMANENT_ADDRESS")%></td>
            <td><%=rs1.getString("NATIONALITY")%></td>
            <td><%=rs1.getString("ISSUE_DATE")%></td>
            <td>
              <a href="javascript:void(0);"
                 onclick="loadPrintPageInMainFrame(<%=rs1.getInt("SER_NO")%>); return false;">
                 View Pass
              </a>
            </td>
          </tr>
          <%
            } // end while
            
            if (rowCount == 0) {
          %>
              <tr><td colspan="<%= HEADERS.length %>" class="error-message">No foreigner gatepass records found.</td></tr>
          <%
            }
            
          } catch (Exception e) {
            out.println("<div class='error-message'>Database Error: " + e.getMessage() + "</div>");
            e.printStackTrace();
          } finally {
             // Resource Cleanup
            if (rs1 != null) try { rs1.close(); } catch (SQLException ignore) {}
            if (st1 != null) try { st1.close(); } catch (SQLException ignore) {}
            if (conn1 != null) try { conn1.close(); } catch (SQLException ignore) {}
          }
          %>
        </tbody>
      </table>
    </div>

    <div class="btn-bar">
      <button type="button" class="btn" onclick="window.location.href='ForeignerGatepass.jsp'">
         New Entry
      </button>
      <button type="button" class="btn" onclick="window.print();">
         Print Register
      </button>
    </div>
  </form>
</div>

</body>
</html>