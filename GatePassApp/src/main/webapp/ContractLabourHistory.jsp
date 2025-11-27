<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="gatepass.Database"%>

<%
// ==========================================================
// 🛡️ SECURITY HEADERS TO PREVENT CACHING THIS PAGE
// ==========================================================
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
response.setDateHeader("Expires", 0); // Proxies.

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

<%!// Define the column names for the table headers
	private static final String[] HEADERS = {"GatePass No.", "Photo", "Name", "Father Name", "Designation", "Age",
			"Local Address", "Identification", "Vehicle No.", "Issue Date", "Action"};%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Contract Labour Register</title>


<style>
/* Base Styling (Copied from template) */
body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background-color: #f4f7f6;
	padding: 20px;
	color: #333;
}

img {
	Display: block;
	max-width: 80px;
	height: 100px;
	object-fit: cover;
	border-radius: 4px;
}

h2 {
	color: #1e3c72; /* Use primary blue color */
	margin-bottom: 25px;
	text-align: center;
	text-transform: uppercase;
}

/* Search Bar Styling (Copied from template) */
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

/* Professional Table Styling (Copied from template) */
.table-wrapper {
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
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
	/* Removed sticky position as table is not in a scroll container wrapper in this code */
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

/* Action Buttons (Minor update to match new button style) */
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
// Function to load the print page into the parent's 'right' frame (Updated for Contract Labour)
function loadPrintPageInMainFrame(srNo) { 
    const url = "PrintContractLabour.jsp?srNo=" + srNo; // Use the correct print page name
    
    // Check if the parent window has a frame/iframe named 'right'
    if (window.parent && window.parent.right) {
        window.parent.right.location.href = url;
    } else {
        // Fallback if not inside the frame structure
        // Since we cannot use alert(), we'll log the error and redirect directly
        console.error("Could not load the print page in the main content frame. Redirecting.");
        window.location.href = url;
    }
}

function executeCommands(){
  try {
    var WshShell = new ActiveXObject("Wscript.Shell");
    // This command is likely blocked by modern browsers/environments and only works in IE/specific client setups.
    // It's left as is but won't execute in a standard sandbox.
    WshShell.run("C://Users/cam.exe"); 
  } catch(e) {
    console.log("Webcam execution skipped: " + e.message);
  }
}

// Real-time Search Function
function filterTable() {
    const input = document.getElementById("searchInput");
    const filter = input.value.toUpperCase();
    const table = document.getElementById("registerTable");
    const tr = table.getElementsByTagName("tr");

    // Start loop from tr[1] to skip the <thead> row
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

<body onload="executeCommands();"
	onkeydown="if(event.keyCode==13){event.keyCode=9; return event.keyCode;}">

	<div class="container">
		<h2>CONTRACT LABOUR REGISTER</h2>

		<input type="text" id="searchInput" onkeyup="filterTable()"
			placeholder="Search by Name, Vehicle No, or any detail...">

		<form action="saveContractLabourDetails" method="post"
			name="text_form" enctype="multipart/form-data"
			onsubmit="return Blank_TextField_Validator()">

			<div class="table-wrapper">
				<table id="registerTable" cellpadding="0" cellspacing="0">
					<thead>
						<tr>
							<%
							for (String header : HEADERS) {
							%>
							<th><%=header%></th>
							<%
							}
							%>
						</tr>
					</thead>
					<tbody>

						<%
						Connection conn1 = null;
						Statement st1 = null;
						ResultSet rs1 = null;
						int rowCount = 0;
						try {
							Database db1 = new Database();
							conn1 = db1.getConnection();
							st1 = conn1.createStatement();

							// Fetch data
							String sql = "SELECT SER_NO, NAME, FATHER_NAME, DESIGNATION, AGE, LOCAL_ADDRESS, "
							+ "IDENTIFICATION, VEHICLE_NO, TO_CHAR(UPDATE_DATE, 'DD-MON-YYYY') AS ISSUE_DATE "
							+ "FROM GATEPASS_CONTRACT_LABOUR ORDER BY SER_NO DESC";
							rs1 = st1.executeQuery(sql);

							while (rs1.next()) {
								rowCount++;
								// Set row alignment to left to match the template (th alignment adjusted in CSS)
								// Note: Data is accessed by column name for clarity and robustness
						%>
						<tr>
							<td><%=rs1.getInt("SER_NO")%></td>

							<td><a
								href="ShowImage.jsp?srNo=<%=rs1.getString("SER_NO")%>"
								target="_blank"> <img
									src="ShowImage.jsp?srNo=<%=rs1.getString("SER_NO")%>"
									alt="Contract labour/Trainee Photo" />
							</a></td>
							<td><%=rs1.getString("NAME")%></td>
							<td><%=rs1.getString("FATHER_NAME")%></td>
							<td><%=rs1.getString("DESIGNATION")%></td>
							<td><%=rs1.getString("AGE")%></td>
							<td><%=rs1.getString("LOCAL_ADDRESS")%></td>
							<td><%=rs1.getString("IDENTIFICATION")%></td>
							<td><%=rs1.getString("VEHICLE_NO")%></td>
							<td><%=rs1.getString("ISSUE_DATE")%></td>
							<td><a href="javascript:void(0);"
								onclick="loadPrintPageInMainFrame(<%=rs1.getInt("SER_NO")%>);">
									View pass </a></td>
						</tr>
						<%
						} // while end

						if (rowCount == 0) {
						%>
						<tr>
							<td colspan="<%=HEADERS.length%>" class="error-message">No
								contract labour records found.</td>
						</tr>
						<%
						}

						} catch (Exception e) {
						out.println("<div class='error-message'>Database Error: " + e.getMessage() + "</div>");
						e.printStackTrace();
						} finally {
						if (rs1 != null)
						try {
							rs1.close();
						} catch (Exception e) {
						}
						if (st1 != null)
						try {
							st1.close();
						} catch (Exception e) {
						}
						if (conn1 != null)
						try {
							conn1.close();
						} catch (Exception e) {
						}
						}
						%>
					</tbody>
				</table>
			</div>

			<div class="btn-bar">
				<button type="button" class="btn"
					onclick="window.location.href='ContractLabour.jsp'">New
					Entry</button>
				<button type="button" class="btn" onclick="window.print();">
					Print Register</button>
			</div>
		</form>
	</div>

</body>
</html>