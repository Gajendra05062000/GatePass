function validDate(date){
var mes=['Date is valid','Invalid date!'];
var d=date.split('-');
var D=[];
var DT=new Date(d[0]+'/'+d[1]+'/'+d[2]);//construct
D[2]=DT.getYear();D[1]=DT.getMonth()+1;D[0]=DT.getDate();//de-construct
for(var i=0;i<d.length;i++){
if(d[i]!=D[i]){alert(mes[1]);return}
}
alert(mes[0]);
document.date.focus()
}