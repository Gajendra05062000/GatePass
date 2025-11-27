<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page language="java" import="java.util.*, gatepass.Database" %>
<%@ page import="java.sql.*,java.time.*,java.time.format.DateTimeFormatter,java.io.*,java.util.Base64,gatepass.CommonService"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Gate Pass Login</title>
<link rel="stylesheet" href="index2.css">
<script src="login.js"></script>

<style>
/* === GLOBAL RESET === */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* === BODY === */
html, body {
    height: 100%;
    overflow: hidden; /* 🚫 Prevent scrolling */
}

body {
    background-color: #fff;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.error-label {
    color: #c0392b; /* Bright red for visibility */
    font-size: 14px;
    font-weight: bold;
    margin-top: 15px; /* Spacing from buttons */
    padding: 8px;
    border: 1px solid #e74c3c;
    background-color: #fceae9; /* Light background for contrast */
    border-radius: 5px;
}

/* === HEADER === */
.header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: 110px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 15px 50px;
    background: #303f9f;
    color: white;
    box-shadow: 0 3px 10px rgba(0,0,0,0.2);
    z-index: 1000;
}

.logo {
    height: 80px;
}

.center-text {
    text-align: center;
    flex: 1;
    color: #ffffff;
}

.center-text h1 {
    font-size: 28px;
    font-weight: bold;
    letter-spacing: 1px;
    margin-bottom: 5px;
}

.center-text h2 {
    font-size: 18px;
    font-weight: 500;
    opacity: 0.9;
}

/* === LOGIN SCREEN === */
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: calc(100vh - 160px);
    width: 100%;
}

.login-form {
    background: #fff;
    border-radius: 15px;
    padding: 40px 50px;
    max-width: 420px;
    width: 90%;
    text-align: center;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
    animation: fadeIn 0.5s ease;
    margin-top: 120px;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}

/* Flash title */
.flash {
    animation: flash 1s linear infinite alternate;
}

@keyframes flash {
    from { color: #1e3c72; }
    to { color: #2ecc71; }
}



/* === INPUTS === */
input[type="text"],
input[type="password"] {
    width: 100%;
    padding: 10px 12px;
    margin: 5px 0;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 15px;
    transition: 0.3s;
}

input[type="text"]:focus,
input[type="password"]:focus {
    border-color: #1e3c72;
    box-shadow: 0 0 6px rgba(30, 60, 114, 0.4);
    outline: none;
}

/* === BUTTONS === */
.button-container {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-top: 20px;
}

input[type="submit"],
input[type="reset"] {
    width: 45%;
    padding: 10px;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    color: #fff;
    font-weight: bold;
    cursor: pointer;
    transition: 0.3s ease;
}

input[type="submit"] {
    background-color: #1e3c72;
}

input[type="submit"]:hover {
    background-color: #344fa1;
}

input[type="reset"] {
    background-color: #c0392b;
}

input[type="reset"]:hover {
    background-color: #e74c3c;
}

/* === FOOTER === */

</style>
</head>

<body onload="document.login?.username?.focus()">

<header class="header">
    <img src="logo1.png" class="logo" alt="Logo 1">
    <div class="center-text">
        <h1>CISF GATE PASS MANAGEMENT SYSTEM</h1>
        <h2>NATIONAL FERTILIZERS LIMITED, PANIPAT UNIT</h2>
    </div>
    <img src="logo2.png" class="logo" alt="Logo 2">
</header>

<!-- === LOGIN FORM === -->
<div class="login-container">
    <div class="login-form">
        <form name="login" action="login.jsp" method="post">
            <input type="hidden" name="formSubmitted" value="true">
            <img src="logo1.png" alt="NFL Logo" height="160" width="150">
            <h1 class="flash">CISF GATEPASS MANAGEMENT SYSTEM</h1>
            <h2>NFL PANIPAT UNIT</h2>

            <div class="table-container">
                <table>
                    <tr>
                        <td><label for="username">Username:</label></td>
                        <td><input type="text" id="username" name="username" required></td>
                    </tr>
                    <tr>
                        <td><label for="password">Password:</label></td>
                        <td><input type="password" id="password" name="password" required></td>
                    </tr>
                </table>
            </div>

            <div class="button-container">
                <input type="submit" value="Login">
                <input type="reset" value="Cancel">
            </div>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <p class="error-label"><%= error %></p>
            <% } %>
        </form>
    </div>
</div>

<!-- === FOOTER === -->
<div class="footer">
    &copy; <%= java.time.Year.now() %>, IT Department NFL, Panipat
</div>

<script>
console.log("Designed and Developed by Tawrej Ansari");
</script>

</body>
</html>
