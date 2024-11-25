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

  var diary_save_bottom = document.getElementById("diary_save_bottom");
  set_confirm_to_move(diary_save_bottom, 'click', cancel_confirm);

  var getData = function() {
    var dateControl = document.querySelector('input[type="date"]');
    var formIdx = document.querySelector('input[id="form_idx"]');
    location.href = "/move_date?move_mode=picked_date&picked_date="+dateControl.value+"&form_idx="+formIdx.value;
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
