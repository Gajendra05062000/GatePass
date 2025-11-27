<%@ page import="java.sql.*, java.io.*"%>
<%@ page language="java" import="gatepass.Database"%>
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
if (session.getAttribute("username") == null) {
	response.sendRedirect("login.jsp");
	return;
}
%>
<html>
<head>
<title>Visitor Details - Table View</title>
<style>
body {
	font-family: "Segoe UI", Arial, sans-serif;
	background: #f8f9fa;
	margin: 0;
	padding: 20px;
}

h2 {
	text-align: center;
	color: #1e3c72;
	margin-bottom: 25px;
	text-transform: uppercase;
	letter-spacing: 1px;
	font-weight: 700;
}

/* 🔍 Search Bar */
.search-container {
	text-align: center;
	margin-bottom: 25px;
}

.search-bar {
	width: 90%;
	max-width: 600px;
	padding: 10px 15px;
	border: 1px solid #ced4da;
	border-radius: 25px;
	font-size: 15px;
	outline: none;
	transition: 0.3s;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.search-bar:focus {
	border-color: #007bff;
	box-shadow: 0 0 8px rgba(0, 123, 255, 0.2);
}

/* Table Styling */
.table-wrapper {
	background: #fff;
	border-radius: 12px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
	overflow-x: auto; /* Ensures responsiveness on small screens */
}

.visitor-table {
	width: 100%;
	border-collapse: collapse;
}

.visitor-table th, .visitor-table td {
	padding: 12px 15px;
	text-align: left;
	border-bottom: 1px solid #eee;
}

.visitor-table th {
	background-color: #1e3c72;
	color: #fff;
	font-weight: 600;
	text-transform: uppercase;
	font-size: 13px;
	white-space: nowrap;
}

.visitor-table tr:hover td {
	background-color: #f0f4ff;
}

.visitor-table tr:nth-child(even) {
	background-color: #f9f9f9;
}

.id-cell {
	font-weight: bold;
	color: #1e3c72;
}

.print-link {
	text-decoration: none;
	color: #fff;
	background: #007bff;
	padding: 6px 10px;
	border-radius: 4px;
	font-size: 13px;
	white-space: nowrap;
	transition: background-color 0.3s;
}

.print-link:hover {
	background: #0056b3;
}

/* 🔹 No Results Message */
#noResults {
	display: none;
	text-align: center;
	color: #888;
	font-size: 16px;
	margin-top: 20px;
}

img {
	Display: block;
	max-width: 80px;
	height: 100px;
	object-fit: cover;
	border-radius: 4px;
}
</style>
</head>
<body>

	<%
	Connection conn = null;
	Statement st = null;
	ResultSet rs = null;
	boolean recordsFound = false;

	try {
		// The file originally referenced gatepass.Database. I'll instantiate it here.
		gatepass.Database db = new gatepass.Database();
		conn = db.getConnection();

		st = conn.createStatement();
		// Fetch all necessary columns, ordered by ID DESC
		String query = "SELECT ID, NAME, FATHERNAME, AGE, ADDRESS, DISTRICT, STATE, PINCODE, PHONE, ENTRYDATE, TIME, OFFICERTOMEET, PURPOSE, MATERIAL, VEHICLE, DEPARTMENT FROM visitor ORDER BY id DESC";
		rs = st.executeQuery(query);
	%>

	<h2>All Visitor Records</h2>

	<!-- 🔍 Search Bar -->
	<div class="search-container">
		<input type="text" id="searchInput" class="search-bar"
			placeholder="Search by Name, Officer, ID, Purpose, or Department...">
	</div>

	<div class="table-wrapper">
		<table class="visitor-table" id="visitorTable">
			<thead>
				<tr>
					<th>ID</th>
					<th>PHOTO</th>
					<th>Name</th>
					<th>Officer to Meet</th>
					<th>Purpose</th>
					<th>Date / Time</th>
					<th>Contact</th>
					<th>Address (District/State)</th>
					<th>Action</th>
				</tr>
			</thead>
			<tbody id="visitorTableBody">

				<%
				while (rs.next()) {
					recordsFound = true;
					// NOTE: Photo is excluded from this table view due to size constraints.
				%>

				<tr class="search-row">
					<td class="id-cell"><%=rs.getInt("ID")%></td>
					<td><a href="ShowVisitor.jsp?id=<%=rs.getString("ID")%>"
						target="_blank"> <img
							src="ShowVisitor.jsp?id=<%=rs.getString("ID")%>"
							alt="Visitor Photo" />
					</a></td>
					<td><%=rs.getString("NAME")%><br> <small
						style="color: #6c757d;">(<%=rs.getString("FATHERNAME")%>,
							Age: <%=rs.getString("AGE")%>)
					</small></td>
					<td><%=rs.getString("OFFICERTOMEET")%><br>
					<small style="color: #6c757d;">(<%=rs.getString("DEPARTMENT")%>)
					</small></td>
					<td><%=rs.getString("PURPOSE")%></td>
					<td><%=rs.getString("ENTRYDATE")%><br> <small
						style="color: #6c757d;">@ <%=rs.getString("TIME")%></small></td>
					<td><%=rs.getString("PHONE")%><br> <small
						style="color: #6c757d;">Vehicle: <%=rs.getString("VEHICLE")%></small>
					</td>
					<td><%=rs.getString("ADDRESS")%>, <%=rs.getString("DISTRICT")%>,
						<%=rs.getString("STATE")%> - <%=rs.getString("PINCODE")%></td>
					<td><a href="print_visitor_card.jsp?id=<%=rs.getInt("ID")%>"
						class="print-link" target="_blank">View Pass</a></td>
				</tr>

				<%
				}
				%>
			</tbody>
		</table>
	</div>


	<%
	} catch (Exception ex) {
	// Output an error message to the user/console if connection fails
	out.println("<p style='color: #dc3545; text-align: center;'>Database Error: " + ex.getMessage() + "</p>");
	ex.printStackTrace();
	} finally {
	// Resource Cleanup: Ensures safe resource release
	if (rs != null)
		try {
			rs.close();
		} catch (SQLException ignore) {
		}
	if (st != null)
		try {
			st.close();
		} catch (SQLException ignore) {
		}
	if (conn != null)
		try {
			conn.close();
		} catch (SQLException ignore) {
		}
	}
	%>

	<!-- No Results Message -->
	<p id="noResults"
		style="<%=recordsFound ? "display: none;" : "display: block;"%>">No
		visitor records found in the database.</p>


	<!-- 🔍 Live Search Script -->
	<script>
		document
				.getElementById("searchInput")
				.addEventListener(
						"keyup",
						function() {
							let input = this.value.toLowerCase();
							let rows = document.getElementById(
									"visitorTableBody").getElementsByClassName(
									"search-row");
							let found = false;

							for (let i = 0; i < rows.length; i++) {
								let row = rows[i];
								// Concatenate text content of the entire row for search
								let text = row.innerText.toLowerCase();

								if (text.includes(input)) {
									row.style.display = "";
									found = true;
								} else {
									row.style.display = "none";
								}
							}

							document.getElementById("noResults").style.display = found ? "none"
									: "block";
						});
	</script>

</body>
</html>