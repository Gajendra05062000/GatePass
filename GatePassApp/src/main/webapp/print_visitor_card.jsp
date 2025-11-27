<%@ page import="java.sql.*,gatepass.Database"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Visitor Gate Pass Report - ID <%=request.getParameter("id")%></title>

<style>
/* Base Reset and Typography */
body {
	margin: 0;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background-color: #f0f4f7; /* Light background */
	color: #333;
}

/* Report Container (Full Report/Document Layout) */
.card {
	width: 100%; /* Take up most of the page width */
	max-width: 850px;
	padding: 35px;
	margin: 20px auto;
	border: 1px solid #cce;
	font-size: 14px;
	background-color: #fff;
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
	/* Stronger shadow for screen view */
	border-radius: 12px;
}

/* --- PROFESSIONAL HEADER STRUCTURE --- */
.header-report {
	border-bottom: 3px solid #1e3c72; /* Dark blue primary line */
	padding-bottom: 15px;
	margin-bottom: 25px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.logo-container {
	width: 80px;
	text-align: center;
}

.logo-container img {
	width: 65px; /* Slightly larger logo */
	height: 65px;
	display: block;
	margin: 0 auto;
	object-fit: contain;
}

.header-title-area {
	flex-grow: 1;
	text-align: center;
	padding: 0 10px;
}

.header-title-area h3 {
	margin: 0;
	font-size: 24px; /* Largest title */
	color: #1e3c72;
	text-transform: uppercase;
	letter-spacing: 1.5px;
	font-weight: 700;
}

.header-title-area p {
	margin: 5px 0 0 0;
	font-size: 15px;
	color: #555;
	font-weight: 500;
}
/* --- END HEADER STRUCTURE --- */

/* Photo & Signature Section (renamed to content-top-section for clarity) */
/* ➡️ MODIFIED: Flex order changed to put photo on right, aligned vertically */
.content-top-section {
	display: flex;
	justify-content: space-between;
	align-items: flex-start; /* Align items to the top */
	margin-bottom: 20px;
	/* Added background for visual cohesion with identification data */
	/*  background-color: #e3f2fd; /* Same as data-group-header */ */
	border-radius: 8px; /* Match card radius */
	padding: 15px; /* Internal padding */
	border: 1px solid #d4e8f7; /* Lighter border for this section */
}

/* Photo container on the right */
.photo-container-right {
	flex-shrink: 0; /* Don't shrink photo */
	margin-left: 30px; /* Space from text */
	padding-top: 5px; /* Adjust vertical alignment if needed */
}

.photo {
	margin-top: 30px;
	width: 140px; /* Larger photo size */
	height: 180px;
	border: 4px solid #1e3c72; /* Official border */
	object-fit: cover;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
	border-radius: 6px;
}

/* Data Table Styling */
.data-table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 15px;
}

.data-table td {
	padding: 10px 15px; /* Increased padding */
	vertical-align: top;
	border-bottom: 1px dashed #ddd; /* Light separator */
}

/* Grouping Header (For Entry Details) */
.data-group-header {
	background-color: #e3f2fd; /* Light blue background for grouping */
	font-weight: bold;
	color: #1e3c72;
	padding: 8px 15px !important;
	border-bottom: 2px solid #1e3c72 !important;
	font-size: 16px;
	-webkit-print-color-adjust: exact; /* Ensure background prints */
	color-adjust: exact;
}

/* Field Names (First Column) */
.data-table td:first-child {
	font-weight: 600;
	color: #444;
	width: 25%;
	background-color: #f7f7f7; /* Light shading for labels */
	-webkit-print-color-adjust: exact; /* Ensure background prints */
	color-adjust: exact;
}
/* Field Values (Second Column) */
.data-table td:nth-child(2) {
	color: #000;
	font-weight: 500;
}

/* Highlighting Key Pass Number */
.pass-number {
	font-size: 18px;
	font-weight: 800;
	color: #cc0000; /* Red emphasis */
}

/* Signature Area */
.signature-row {
	height: 60px; /* Space for signatures */
	border-top: 2px solid #ccc;
	margin-top: 40px;
	padding-top: 15px;
	display: flex;
	justify-content: space-between;
}

.signature-box {
	width: 45%;
	text-align: center;
	font-size: 14px;
	font-weight: 600;
	color: #333;
}

.signature-line {
	border-top: 1px solid #000;
	margin-bottom: 5px;
	height: 1px; /* Ensure line visibility */
}

.instructions {
	font-size: 12px;
	margin-top: 30px;
	padding: 15px;
	border: 1px solid #1e3c72;
	background-color: #f0f5ff;
	border-radius: 4px;
	-webkit-print-color-adjust: exact; /* Ensure background prints */
	color-adjust: exact;
}

/* Print Control */
.print-container {
	text-align: center;
	margin-bottom: 20px;
}

.print-button {
	background-color: #007bff;
	color: #fff;
	border: none;
	padding: 10px 20px;
	border-radius: 5px;
	cursor: pointer;
	font-size: 16px;
	transition: background-color 0.3s;
}

/* --- PRINT OPTIMIZATION --- */
@media print {
	.print-container {
		display: none;
	}
	body {
		background-color: white;
		padding: 0;
	}
	.card {
		box-shadow: none;
		border: none;
		width: 100%;
		max-width: none;
		margin: 0;
		padding: 0;
	}
	/* Ensure shaded backgrounds print */
	.data-table td:first-child, .data-group-header, .instructions,
		.content-top-section {
		background-color: #f7f7f7 !important;
		/* Keep shading for print contrast */
		-webkit-print-color-adjust: exact;
		color-adjust: exact;
	}
	@page {
		size: A4;
		margin: 15mm;
	}
	footer {
		position: relative;
		/* Allow it to flow naturally at the end of the report */
		margin-top: 30px;
	}
}

footer {
	text-align: center;
	font-size: 10px;
	color: #777;
	margin-top: 30px;
	padding-top: 5px;
	border-top: 1px solid #eee;
}
</style>
<script>
	function printPage() {
		const btn = document.getElementById("printPageButton");
		btn.style.display = 'none';
		window.print();
		btn.style.display = 'inline-block';
	}
</script>
</head>

<body>
	<%
	String id = request.getParameter("id");

	if (id == null || id.trim().isEmpty()) {
	%>
	<p style="color: red; text-align: center;">Error: Missing or
		invalid Visitor Pass Number</p>
	<%
	} else {
	Connection conn = null;
	Statement st = null;
	ResultSet rs = null;
	try {
		Database db = new Database();
		conn = db.getConnection();
		st = conn.createStatement();

		String query = "SELECT NAME, FATHERNAME, TO_CHAR(ENTRYDATE, 'DD-MON-YYYY') AS ENTRYDATE, VEHICLE, DISTRICT, STATE, PINCODE, PHONE, PURPOSE, "
		+ "TO_CHAR(SYSDATE, 'DD-MON-YYYY') AS CURR_DATE,AGE , TIME,OFFICERTOMEET " + "FROM visitor WHERE ID=" + id;

		rs = st.executeQuery(query);
		if (rs.next()) {
	%>


	<div class="card">
		<!-- DUAL LOGO HEADER -->
		<div class="header-report">
			<!-- LEFT LOGO (NFL) -->
			<div class="logo-container">
				<img src="logo1.png" alt="NFL Logo">
			</div>

			<!-- CENTERED TITLE AREA -->
			<div class="header-title-area">
				<h3>VISITOR GATE PASS</h3>
				<p>CISF Gate Pass Management System | NFL Panipat</p>
			</div>

			<!-- RIGHT LOGO (CISF) -->
			<div class="logo-container">
				<img src="logo2.png" alt="CISF Logo">
			</div>
		</div>
		<!-- END HEADER -->
		<!-- PHOTO & DATA SECTION -->
		<!-- ➡️ MODIFIED: Flex order reversed, photo moved to right -->
		<div class="content-top-section">
			<!-- 1. CORE DETAILS TABLE (now on left) -->
			<div style="flex-grow: 1; padding-right: 30px;">
				<table class="data-table">
					<tr>
						<td class="data-group-header" colspan="2">Visitor
							Identification Details</td>
					</tr>
					<tr>
						<td>Pass No:</td>
						<td><span class="pass-number"><%=id%></span></td>
					</tr>
					<tr>
						<td>Name:</td>
						<td><%=rs.getString("NAME")%></td>
					</tr>
					<tr>
						<td>Father Name:</td>
						<td><%=rs.getString("FATHERNAME")%></td>
					</tr>
					<tr>
						<td>Age:</td>
						<td><%=rs.getString("AGE")%></td>
					</tr>
					<tr>
						<td>Contact No:</td>
						<td><%=rs.getString("PHONE")%></td>
					</tr>
				</table>
			</div>

			<!-- 2. PHOTO (now on right) -->
			<div class="photo-container-right">
				<img src="ShowVisitor.jsp?id=<%=id%>" class="photo"
					alt="Visitor Photo">
			</div>
		</div>

		<!-- ENTRY & ADDRESS DETAILS TABLE -->
		<table class="data-table"
			style="margin-top: 25px; border: 1px solid #d4e8f7; border-radius: 8px; overflow: hidden;">
			<tr>
				<td class="data-group-header" colspan="2">Entry and Purpose
					Details</td>
			</tr>
			<tr>
				<td>Officer To Meet:</td>
				<td><%=rs.getString("OFFICERTOMEET")%></td>
			</tr>
			<tr>
				<td>Address:</td>
				<td><%=rs.getString("DISTRICT")%>, <%=rs.getString("STATE")%>
					- <%=rs.getString("PINCODE")%></td>
			</tr>
			<tr>
				<td>Vehicle No:</td>
				<td><%=rs.getString("VEHICLE")%></td>
			</tr>
			<tr>
				<td>Entry Date/Time:</td>
				<td><%=rs.getString("ENTRYDATE")%> at <%=rs.getString("TIME")%></td>
			</tr>
			<tr>
				<td>Purpose of Visit:</td>
				<td><%=rs.getString("PURPOSE")%></td>
			</tr>
		</table>

		<!-- SIGNATURE AREA -->
		<div class="signature-row">
			<div class="signature-box">
				<br>
				<br>
				<div class="signature-line"></div>
				Visitor's Signature (Card Holder)
			</div>
			<div class="signature-box">
				<br>
				<br>
				<div class="signature-line"></div>
				Issuing Authority Signature
			</div>
		</div>

		<div class="instructions">
			<b>Important Instructions:</b><br> 1. This pass must be shown to
			security staff on demand.<br> 2. This pass is non-transferable
			and valid only for the specified period.<br> 3. Report loss or
			damage immediately to the issuing authority.
		</div>
	</div>
	<div class="print-container">
		<button id="printPageButton" class="print-button"
			onclick="printPage()">Print Visitor Gate Pass</button>
	</div>

	<%
	} else {
	out.println("<p style='color:red;text-align:center;'>Record Not Found</p>");
	}
	} catch (SQLException e) {
	out.println("<p style='color:red;text-align:center;'>Database Error: " + e.getMessage() + "</p>");
	} finally {
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
	}
	%>
	<footer>
		Printed on
		<%=new java.util.Date()%>
		| © 2025 Gate Pass Management System | NFL Panipat
	</footer>
</body>
</html>