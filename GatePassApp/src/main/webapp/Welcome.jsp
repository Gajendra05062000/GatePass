<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page import="java.sql.*" %>
<%@page import="java.lang.*" %>
<%@page import="gatepass.Database" %>
<%@page import="java.io.*" %>
<%@ page import="java.util.Base64" %>

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
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp"); // Redirect to the login form
        return; 
    }
%>

<%
// Get current date and time for dynamic display
LocalDateTime now = LocalDateTime.now();
DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEEE, MMMM dd, yyyy");
DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a");
String currentDate = now.format(dateFormatter);
String currentTime = now.format(timeFormatter);

// --- Initialization ---
int VisitorsToday = 0;
int TotalVisitors = 0;
int TodayContractLabour = 0;
int TotalContractLabour = 0;
int TodayContract = 0;
int ActiveContract = 0;
int TodayForeigner = 0;
int ActiveForeigner = 0;

// Date format for SQL comparison (Ensuring matching date masks)
DateTimeFormatter sqlDateFormatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
String todayDateString = now.format(DateTimeFormatter.ofPattern("dd-MM-yyyy"));

String sqlTodayCondition =
    "TO_CHAR(ENTRYDATE, 'DD-MM-yyyy') = '" + todayDateString + "'";

String sqlTodayConditionUpdate =
    "TO_CHAR(UPDATE_DATE, 'DD-MM-yyyy') = '" + todayDateString + "'";


Connection conn = null;
Statement st = null;
ResultSet rs = null;

try {
    Database db = new Database();
    conn = db.getConnection();
    st = conn.createStatement();

    // 1. VISITORS
    rs = st.executeQuery("SELECT Count(ID) FROM VISITOR WHERE " + sqlTodayCondition);
    if (rs.next()) {
        VisitorsToday = rs.getInt(1);
    }
    if (rs != null) rs.close(); 
    
    rs = st.executeQuery("SELECT Count(ID) FROM VISITOR");
    if (rs.next()) {
        TotalVisitors = rs.getInt(1);
    }
    if (rs != null) rs.close();

    // 2. CONTRACT LABOUR
    rs = st.executeQuery("SELECT Count(SER_NO) FROM GATEPASS_CONTRACT_LABOUR WHERE " + sqlTodayConditionUpdate);
    if (rs.next()) {
        TodayContractLabour = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
    rs = st.executeQuery("SELECT COUNT(SER_NO) FROM GATEPASS_CONTRACT_LABOUR WHERE TRUNC(SYSDATE) BETWEEN TRUNC(VALIDITY_FROM) AND TRUNC(VALIDITY_TO);");
    if (rs.next()) {
        TotalContractLabour = rs.getInt(1);
    }
    if (rs != null) rs.close();

    // 3. CONTRACT REGISTRATION
    rs = st.executeQuery("SELECT Count(ID) FROM GATEPASS_CONTRACT WHERE " + sqlTodayConditionUpdate);
    if (rs.next()) {
        TodayContract = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
    rs = st.executeQuery("SELECT Count(ID) FROM GATEPASS_CONTRACT WHERE TRUNC(SYSDATE) BETWEEN TRUNC(VALIDITY_FROM) AND TRUNC(VALIDITY_TO)");
    if (rs.next()) {
        ActiveContract = rs.getInt(1);
    }
    if (rs != null) rs.close();

    // 4. FOREIGNER PASS
    rs = st.executeQuery("SELECT Count(SER_NO) FROM GATEPASS_FOREIGNER WHERE " + sqlTodayConditionUpdate);
    if (rs.next()) {
        TodayForeigner = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
    rs = st.executeQuery("SELECT Count(SER_NO) FROM GATEPASS_FOREIGNER WHERE TRUNC(SYSDATE) BETWEEN TRUNC(VALIDITY_FROM) AND TRUNC(VALIDITY_TO)");
    if (rs.next()) {
        ActiveForeigner = rs.getInt(1);
    }
    if (rs != null) rs.close();
    
} catch (SQLException e) {
    System.err.println("Database Error on Dashboard Load: " + e.getMessage());
} catch (Exception e) {
    System.err.println("General Error on Dashboard Load: " + e.getMessage());
} finally {
    // Crucial: Resource Cleanup
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (st != null) try { st.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
%>

<!DOCTYPE html>

<html>
<head>
<meta charset="UTF-8">
<title>Welcome Dashboard</title>
<style>
:root {
--primary-navy: #1e3c72;
--accent-blue: #007bff;
--accent-green: #2ecc71;
--background-light: #f8f9fa;
--card-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: var(--background-light);
        padding: 20px;
        color: #343a40;
    }

    .dashboard-container {
        max-width: 1200px;
        margin: auto;
    }

    /* --- Welcome Banner --- */
    .welcome-banner {
        background: linear-gradient(90deg, var(--primary-navy) 0%, #2a5298 100%);
        color: white;
        padding: 25px 35px;
        border-radius: 12px;
        box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
        margin-bottom: 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .welcome-banner h1 {
        font-size: 28px;
        font-weight: 700;
        margin: 0;
        letter-spacing: 0.5px;
    }

    .welcome-banner p {
        font-size: 14px;
        opacity: 0.9;
        margin-top: 5px;
    }

    .date-time {
        text-align: right;
        font-size: 16px;
        font-weight: 500;
    }
    .date-time .time {
        font-size: 20px;
        font-weight: 600;
    }


    /* --- Key Stats Cards --- */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 25px;
        margin-bottom: 30px;
    }

    .stat-card {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: var(--card-shadow);
        border-left: 5px solid;
    }
    
    /* Make the entire link block behave like the card */
    .stat-card a {
        text-decoration: none; /* Remove underline from card link */
        color: inherit;
        display: block;
        padding: 0;
        margin: -20px; /* Counteract parent padding to cover full area */
        cursor: pointer;
        transition: transform 0.3s, box-shadow 0.3s;
    }

    .stat-card a:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
    }

    .stat-card-data {
        padding: 5px 20px; /* Restore padding lost by anchor margin trick */
    }
    .stat-card-data:first-child {
        border-bottom: 1px dashed #e0e0e0;
        margin-bottom: 10px;
        padding-bottom: 10px;
    }


    .stat-card.red { border-color: #dc3545; }
    .stat-card.blue { border-color: var(--accent-blue); }
    .stat-card.green { border-color: var(--accent-green); }
    .stat-card.orange { border-color: #f39c12; }

    .stat-card .value {
        font-size: 36px;
        font-weight: 700;
        margin-bottom: 5px;
        color: var(--primary-navy);
    }

    .stat-card .label {
        font-size: 15px;
        color: #6c757d;
        font-weight: 500;
    }

    /* --- Quick Actions and Guide --- */
    .content-grid {
        display: grid;
        grid-template-columns: 2fr 1fr; /* Guide takes up 1/3, Actions 2/3 */
        gap: 25px;
    }
    
    .section-header {
        font-size: 22px;
        font-weight: 600;
        color: var(--primary-navy);
        margin-bottom: 15px;
        border-bottom: 2px solid #e9ecef;
        padding-bottom: 5px;
    }

    .quick-actions-box, .system-guide-box {
        background-color: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: var(--card-shadow);
    }

    /* Quick Action Buttons */
    .action-buttons {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 15px;
    }
    .action-button {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        border-radius: 8px;
        font-weight: 600;
        text-decoration: none;
        color: white;
        transition: opacity 0.3s, transform 0.2s;
        box-shadow: 0 2px 5px rgba(0,0,0,0.15);
        font-size: 16px;
    }
    .action-button:hover {
        opacity: 0.9;
        transform: translateY(-2px);
    }
    .action-button span {
        margin-right: 8px;
        font-size: 20px;
    }

    .btn-visitor { background-color: var(--accent-blue); }
    .btn-contract { background-color: var(--primary-navy); }
    .btn-foreigner { background-color: #f39c12; }
    .btn-history { background-color: #348757; }
    
    /* System Guide */
    .system-guide-box ul {
        list-style: none;
        padding: 0;
    }
    .system-guide-box li {
        padding: 10px 0;
        border-bottom: 1px dashed #e9ecef;
        font-size: 14px;
        color: #5a6268;
        cursor: pointer;
        transition: color 0.2s;
    }
    .system-guide-box li:hover {
        color: var(--accent-blue);
    }
    .system-guide-box li:last-child {
        border-bottom: none;
    }

    @media (max-width: 768px) {
        .content-grid {
            grid-template-columns: 1fr;
        }
        .action-buttons {
            grid-template-columns: 1fr;
        }
    }
</style>
<script>
    // Function to load links into the right iframe (main content area)
    function loadContent(url) {
        // Find the iframe named 'right' in the parent window
        const iframe = window.parent.document.getElementsByName('right')[0];
        if (iframe) {
            iframe.src = url;
        } else {
            console.error("Iframe 'right' not found.");
            window.location.href = url; // Fallback
        }
    }
</script>


</head>
<body>

<div class="dashboard-container">

<!-- Welcome Banner -->
<div class="welcome-banner">
    <div>
        <h1>Welcome, CISF GATE PASS!</h1>
        <p>CISF Gate Pass Management System: NFL Panipat Unit</p>
    </div>
    <div class="date-time">
        <span class="time"><%= currentTime %></span>
        <br>
        <span class="date"><%= currentDate %></span>
    </div>
</div>

<!-- Key Statistics Grid -->
<div class="stats-grid">
    
    <!-- 1. Visitors (Now Clickable) -->
    <div class="stat-card red">
        <a href="javascript:loadContent('viewall.jsp');">
            <div class="stat-card-data">
                <div class="value"><%= VisitorsToday %></div>
                <div class="label">Visitors Pass Issued Today</div>
            </div>
            <div class="stat-card-data">
                 <div class="value"><%= TotalVisitors %></div>
                <div class="label">Total Registered Visitors</div>
            </div>
        </a>
    </div>
    
    <!-- 2. Contract Labour -->
    <div class="stat-card blue">
        <a href="javascript:loadContent('ContractLabourHistory.jsp');">
            <div class="stat-card-data">
                 <div class="value"><%= TodayContractLabour %></div>
                <div class="label">Labour/Trainee Passes Issued Today</div>
            </div>
            <div class="stat-card-data">
                <div class="value"><%= TotalContractLabour %></div>
                <div class="label">Total Active Labour/Trainee</div>
            </div>
        </a>
    </div>
    
    <!-- 3. Contract Registration -->
    <div class="stat-card green">
        <a href="javascript:loadContent('Contract_History.jsp');">
            <div class="stat-card-data">
                 <div class="value"><%= TodayContract %></div>
                <div class="label">Contracts Registered  Today</div>
            </div>
            <div class="stat-card-data">
                <div class="value"><%= ActiveContract %></div>
                <div class="label">Total Active Contracts</div>
            </div>
        </a>
    </div>
    
    <!-- 4. Foreigner Pass -->
    <div class="stat-card orange">
        <a href="javascript:loadContent('ForeignerGatepassHistory.jsp');">
           <div class="stat-card-data">
                 <div class="value"><%= TodayForeigner %></div>
                <div class="label">Foreigner Pass Issued Today</div>
            </div>
            <div class="stat-card-data">
                <div class="value"><%= ActiveForeigner %></div>
                <div class="label">Total Active Foreigner</div>
            </div>
        </a>
    </div>
</div>

<div class="content-grid">
    <!-- Quick Actions -->
    <div class="quick-actions-box">
        <h2 class="section-header">Quick Actions</h2>
        <div class="action-buttons">
            <a href="javascript:loadContent('visitor.jsp');" class="action-button btn-visitor">
                <span>&#128100;</span> New Visitor Pass
            </a>
            <a href="javascript:loadContent('ContractLabour.jsp');" class="action-button btn-contract">
                <span>&#128736;</span> Labour/Trainee Pass
            </a>
            <a href="javascript:loadContent('ForeignerGatepass.jsp');" class="action-button btn-foreigner">
                <span>&#127760;</span> Foreigner Pass
            </a>
            <a href="javascript:loadContent('Contract.jsp');" class="action-button" style="background-color:#4CAF50;">
                <span>&#128196;</span> Contract Registration
            </a>
            <a href="javascript:loadContent('viewall.jsp');" class="action-button btn-history">
                <span>&#128203;</span> View All Visitor History
            </a>
            <a href="javascript:loadContent('Report Technical Issues.jsp');" class="action-button" style="background-color:#5c5c5c;">
                <span>&#9881;</span> Technical Support
            </a>
        </div>
    </div>
    
    <!-- System Guide -->
    <div class="system-guide-box">
        <h2 class="section-header">System Guide</h2>
        <ul>
            <li onclick="loadContent('view.jsp')">Review Visitors by Date</li>
            <li onclick="loadContent('Contract_History.jsp')">Check Contract Registration Validity</li>
            <li onclick="loadContent('ForeignerGatepassHistory.jsp')">Search Foreigner Pass Records</li>
            <li onclick="loadContent('change_password.jsp')">Update User Credentials</li>
            <li onclick="loadContent('Report Technical Issues.jsp')">Report Technical Issues (Contact IT Dept.)</li>
        </ul>
    </div>
</div>


</div>

</body>
</html>