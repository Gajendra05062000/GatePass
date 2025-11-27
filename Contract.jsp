<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="gatepass.Database" %>

<%
    /* SECURITY HEADERS */
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    /* SESSION CHECK */
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    /* Generate next Contract ID */
    int id = 1;
    try (Connection conn = new Database().getConnection();
         Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery("SELECT NVL(MAX(ID), 0) + 1 FROM GATEPASS_CONTRACT")) {
        if (rs.next()) id = rs.getInt(1);
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html>
<head>
<title>Contract Registration</title>
<meta charset="UTF-8">

<style>
/* =============== THEME =============== */
:root {
    --primary-navy: #1e3c72;
    --accent-blue: #007bff;
    --accent-red: #dc3545;
    --bg-light: #f8f9fa;
    --input-border: #ced4da;
    --shadow-light: 0 4px 12px rgba(0,0,0,0.08);
}

body {
    font-family: "Segoe UI", Tahoma, sans-serif;
    background: var(--bg-light);
    margin: 0;
    padding: 30px;
}

.container {
    background: #fff;
    width: 95%;
    max-width: 1200px;
    margin: auto;
    padding: 30px 40px;
    border-radius: 15px;
    box-shadow: 0 6px 25px rgba(0,0,0,0.14);
}

h2 {
    text-align: center;
    color: var(--primary-navy);
    font-weight: 700;
    margin-bottom: 25px;
    padding-bottom: 8px;
    border-bottom: 2px solid #e9ecef;
}

/* =============== GRID LAYOUT =============== */
.main-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 35px;
}

/* =============== FORM GRID =============== */
.form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 18px 25px;
}
.full-width { grid-column: span 2; }

/* =============== INPUT STYLING =============== */
label {
    font-weight: 600;
    margin-bottom: 4px;
    color: #333;
}
.mandatory { color: var(--accent-red); margin-left: 4px; }

input[type="text"], input[type="date"], select {
    padding: 10px 12px;
    border-radius: 6px;
    border: 1px solid var(--input-border);
    width: 100%;
    background: #fff;
    box-sizing: border-box;
}
input[readonly] {
    background: #e9ecef;
    color: #444;
}

/* =============== BUTTONS =============== */
input[type="submit"], input[type="reset"], button {
    padding: 10px 20px;
    border-radius: 6px;
    border: none;
    font-size: 15px;
    cursor: pointer;
    font-weight: 600;
    box-shadow: var(--shadow-light);
    transition: 0.25s;
}

input[type="submit"] { background: var(--accent-blue); color: #fff; }
input[type="submit"]:hover { background: #0056b3; }

input[type="reset"] { background: var(--accent-red); color: #fff; }
input[type="reset"]:hover { background: #b21f2d; }

.button-container {
    grid-column: span 2;
    text-align: center;
    padding-top: 15px;
    border-top: 1px solid #eee;
}

/* =============== DOCUMENT UPLOAD RIGHT PANEL =============== */
.upload-panel {
    background: var(--bg-light);
    padding: 20px;
    border-radius: 12px;
    box-shadow: var(--shadow-light);
    border: 1px solid #dcdcdc;
}

.upload-panel h3 {
    color: var(--primary-navy);
    text-align: center;
    margin-bottom: 10px;
}

.upload-box {
    border: 1px solid #d4e8f7;
    background: #f0f5ff;
    padding: 14px;
    border-radius: 8px;
}

/* File preview */
.file-preview-area {
    margin-top: 10px;
    padding: 12px;
    border-radius: 8px;
    background: #fff;
    border: 1px solid #ddd;
    min-height: 90px;
    display:flex;
    flex-direction:column;
    align-items:center;
    justify-content:center;
}

.preview-thumbnail {
    max-width: 90px;
    border: 1px solid #ccc;
    border-radius: 4px;
    margin-bottom: 6px;
}

.file-name {
    font-weight: 600;
    color: var(--primary-navy);
    font-size: 14px;
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Alerts */
.custom-alert {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    padding: 12px 20px;
    font-weight: 700;
    display:none;
    border-radius: 8px;
    color: #fff;
    z-index: 2000;
}
.custom-alert.success { background: #28a745; }
.custom-alert.error { background: #dc3545; }

/* Responsive */
@media (max-width: 900px) {
    .main-grid { grid-template-columns: 1fr; }
}
</style>

<script>
function capLtr(val,id){ document.getElementById(id).value = val.toUpperCase(); }

function displayCustomAlert(msg,type){
    const box=document.getElementById("customAlertBox");
    box.innerText=msg;
    box.className="custom-alert "+type;
    box.style.display="block";
    setTimeout(()=> box.style.display="none",3500);
}

/* FORM VALIDATION */
function ValidateForm2(form){
    let f=form.valdity_fromDate.value;
    let t=form.valdity_toDate.value;
    if(!f||!t){ displayCustomAlert("Select both validity dates","error"); return false; }
    if(new Date(f)>new Date(t)){
        displayCustomAlert("'From' cannot be later than 'To'","error");
        return false;
    }
    return true;
}
function validateForm(f){ return ValidateForm2(f); }

/* DOCUMENT UPLOAD PREVIEW */
let tempSelectedFile=null;
function handleDocumentAdd(){
    const fileInput=document.getElementById("DocumentFile");
    const file=fileInput.files[0];
    if(!file){ displayCustomAlert("Select a file","error"); return; }
    if(file.size > 5*1024*1024){ displayCustomAlert("Max size 5MB","error"); fileInput.value=""; return; }

    tempSelectedFile=file;
    previewDocument(file);
    displayCustomAlert("Document added successfully","success");
}

function previewDocument(file){
    const area=document.getElementById("documentPreview");
    const name=file.name;
    const type=file.type;
    if(type.startsWith("image/")){
        const r=new FileReader();
        r.onload=function(e){
            area.innerHTML=`<img class="preview-thumbnail" src="${e.target.result}">
                            <div class="file-name">${name}</div>`;
        }
        r.readAsDataURL(file);
    } else if (type.includes("pdf")){
        area.innerHTML=`<div style="font-size:30px;">📄</div>
                        <div class="file-name">${name}</div>`;
    } else {
        area.innerHTML=`<div style="font-size:30px;">📎</div>
                        <div class="file-name">${name}</div>`;
    }
}
</script>

</head>

<body>

<div id="customAlertBox" class="custom-alert"></div>

<div class="container">
    <h2>Contract Registration</h2>

    <div class="main-grid">

        <!-- LEFT SIDE FORM -->
        <div>
            <form action="saveContract" method="post" enctype="multipart/form-data" onsubmit="return validateForm(this)">
                <input type="hidden" name="Document" id="FinalDocument"/>

                <div class="form-grid">

                    <div class="input-group">
                        <label>WorkSite <span class="mandatory">*</span></label>
                        <input type="text" name="worksite" value="NFL Panipat" readonly/>
                    </div>

                    <div class="input-group">
                        <label>Contract No. <span class="mandatory">*</span></label>
                        <input type="text" name="id" value="<%=id%>" readonly/>
                    </div>

                    <div class="input-group">
                        <label>Contract Name <span class="mandatory">*</span></label>
                        <input type="text" id="name" name="name" onkeyup="capLtr(this.value,'name')" required/>
                    </div>

                    <div class="input-group">
                        <label>Contract Type <span class="mandatory">*</span></label>
                        <input type="text" id="type" name="type" onkeyup="capLtr(this.value,'type')" required/>
                    </div>

                    <div class="input-group">
                        <label>Registration No.</label>
                        <input type="text" id="reg" name="reg" onkeyup="capLtr(this.value,'reg')"/>
                    </div>
					<div class="input-group">
                        <label>Contract Department</label>
                        <input type="text" id="dept" name="dept" onkeyup="capLtr(this.value,'dept')"/>
                    </div>
                    <div class="input-group">
                        <label>Validity From <span class="mandatory">*</span></label>
                        <input type="date" id="valdity_fromDate" name="valdity_fromDate" required/>
                    </div>

                    <div class="input-group">
                        <label>Validity To <span class="mandatory">*</span></label>
                        <input type="date" id="valdity_toDate" name="valdity_toDate" required/>
                    </div>
                    <div class="input-group">
                        <label>Labour Size <span class="mandatory">*</span></label>
                        <input type="text" id="laboursize" name="laboursize" required/>
                    </div>
                    
                    <div class="input-group">
                        <label>Contractor Name <span class="mandatory">*</span></label>
                        <input type="text" id="ContractorName" name="Contractor" onkeyup="capLtr(this.value,'ContractorName')" required/>
                    </div>

                    

                    <div class="input-group">
                        <label>Contractor Mobile No. <span class="mandatory">*</span></label>
                        <input type="text" id="phone" name="phone" maxlength="10" onkeypress="return /[0-9]/.test(event.key)" required/>
                    </div>
                   
                    <div class="input-group">
                        <label>Contractor Aadhar No. <span class="mandatory">*</span></label>
                        <input type="text" id="adhar" name="adhar" maxlength="12" onkeypress="return /[0-9]/.test(event.key)" required/>
                    </div>
					<div class="input-group full-width">
                        <label>Contractor Address <span class="mandatory">*</span></label>
                        <input type="text" id="address" name="address" onkeyup="capLtr(this.value,'address')" required/>
                    </div>
					
                    

                    <div class="input-group full-width">
                        <label>Description</label>
                        <input type="text" id="desp" name="desp" onkeyup="capLtr(this.value,'desp')"/>
                    </div>

                    <div class="button-container">
                        <input type="submit" value="Register Contract"/>
                        <input type="reset" value="Clear Form"
                               onclick="document.getElementById('documentPreview').innerHTML='<p>No document selected.</p>';"/>
                    </div>

                </div>
            </form>
        </div>

        <!-- RIGHT SIDE DOCUMENT UPLOAD -->
        <div>
            <div class="upload-panel">
                <h3>Contract Document Upload</h3>

                <div class="upload-box">
                    <div style="display:flex; gap:10px;">
                        <input type="file" id="DocumentFile" name="DocumentFile"
                               accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" style="flex:1;">
                        <button type="button" onclick="handleDocumentAdd()">Add</button>
                    </div>

                    <div id="documentPreview" class="file-preview-area">
                        <p>No document selected.</p>
                    </div>

                    <div style="margin-top:12px; font-size:13px;">
                        <b>Save Location:</b><br>
                        <span style="font-family:monospace;">C:\GatepassImages\contract</span><br>
                        <span style="color:#666;">Max size 5MB</span>
                    </div>
                </div>

            </div>
        </div>

    </div>
</div>

</body>
</html>
