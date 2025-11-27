
//form validation  
function Blank_TextField_Validator(){

if (text_form.name.value == "")
{
   alert("Please Enter Name."); 
   text_form.name.focus();
   return (false);
}

if (text_form.fatherName.value == "")
{
   alert("Please Enter fatherName."); 
   text_form.fatherName.focus();
   return (false);
}

if (text_form.desig.value == "")
{
   alert("Please Enter desig."); 
   text_form.desig.focus();
   return (false);
}


if (text_form.age.value == "")
{
   alert("Please Enter age."); 
   text_form.age.focus();
   return (false);
}


if (text_form.localAddress.value == "")
{
   alert("Please Enter Local Address."); 
   text_form.localAddress.focus();
   return (false);
}


if (text_form.permanentAddress.value == "")
{
   alert("Please Enter permanentAddress."); 
   text_form.permanentAddress.focus();
   return (false);
}

if (text_form.contrctrNameAddress.value == "")
{
   alert("Please Enter contrctrNameAddress."); 
   text_form.contrctrNameAddress.focus();
   return (false);
}

if (text_form.identification.value == "")
{
   alert("Please Enter Identification."); 
   text_form.identification.focus();
   return (false);
}



if (text_form.valdity_fromDate.value == "")
{
   alert("Please Enter valdity From Date."); 
   text_form.valdity_fromDate.focus();
   return (false);
}

if (text_form.valdity_toDate.value == "")
{
   alert("Please Enter valdity Upto Date."); 
   text_form.valdity_toDate.focus();
   return (false);
}


return (true);
}