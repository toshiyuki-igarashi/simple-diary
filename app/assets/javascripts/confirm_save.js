document.addEventListener('DOMContentLoaded', function() {
  // 入力テキストを取得
  var diary_form_group = document.getElementById("input_diary");

  var get_diary_data = function() {
    var data = "";
    if (diary_form_group !== null) {
      diary_form_group.childNodes.forEach(function(element) {
        if (element.value !== undefined) {
          data = data + element.value;
        } else {
          if (element.childNodes.length != 0) {
            element.childNodes.forEach(function(child_element) {
              if (child_element.value !== undefined) {
                data = data + child_element.value;
              }
            });
          }
        }
      });
    }
    return data;
  }
  var diary_data = get_diary_data();

  var confirm_to_leave = function(e) {
    if (get_diary_data() !== diary_data) {
      e.preventDefault();
      e.returnValue = '';
    }
  }

  window.addEventListener('beforeunload', confirm_to_leave, false);

  var cancel_confirm = function(e) {
    window.removeEventListener('beforeunload', confirm_to_leave, false);
  }

  var set_confirm_to_move = function(move_date, event_name, handler) {
    if (move_date !== null) {
      move_date.addEventListener(event_name, handler, false);
    }
  }

  var diary_save = document.getElementById("diary_save");
  set_confirm_to_move(diary_save, 'click', cancel_confirm);

  var createXMLHttpRequest = function() {
    if(window.XMLHttpRequest){return new XMLHttpRequest()}
    if(window.ActiveXObject){
      try{return new ActiveXObject("Msxml2.XMLHTTP.6.0")}catch(e){}
      try{return new ActiveXObject("Msxml2.XMLHTTP.3.0")}catch(e){}
      try{return new ActiveXObject("Microsoft.XMLHTTP")}catch(e){}
    }
    return false;
  }

  var getData = function() {
    var xmlhttp = createXMLHttpRequest();
    var wait_time = 300;    // wait to reload page

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
    xmlhttp.open("GET", "/move_date?move_mode=picked_date&picked_date="+dateControl.value);
    xmlhttp.send();
  }

  var confirm_to_move = function(e) {
    if (get_diary_data() !== diary_data) {
      if (!window.confirm('変更された日記が保存されません。良いですか？')) {
        date_Get.value = date_value;
        e.preventDefault();
      } else {
        getData();
      }
    } else {
      getData();
    }
  }

  var date_Get = document.getElementById("date_Get");
  if (date_Get !== null) {
    date_value = date_Get.value;
  }
  set_confirm_to_move(date_Get, 'change', confirm_to_move);

}, false);