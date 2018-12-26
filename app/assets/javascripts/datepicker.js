function getData() {
  var xmlhttp = createXMLHttpRequest(); //旧バージョンのIEなどに対応する場合
  //var xmlhttp = new XMLHttpRequest();
  var wait_time = 300;  // wait to reload page

  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4) {
      if (xmlhttp.status == 200) {
        document.open();
        document.write(xmlhttp.responseText);
        document.close();
      } else {
        alert("select date error : status = " + xmlhttp.status);
      }
    }
  }

  var dateControl = document.querySelector('input[type="date"]');
  xmlhttp.open("GET", "/date/"+dateControl.value);
  xmlhttp.send();
}

function createXMLHttpRequest(){
  if(window.XMLHttpRequest){return new XMLHttpRequest()}
  if(window.ActiveXObject){
    try{return new ActiveXObject("Msxml2.XMLHTTP.6.0")}catch(e){}
    try{return new ActiveXObject("Msxml2.XMLHTTP.3.0")}catch(e){}
    try{return new ActiveXObject("Microsoft.XMLHTTP")}catch(e){}
  }
  return false;
}
