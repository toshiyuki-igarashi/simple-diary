document.addEventListener('DOMContentLoaded', function() {
  // 入力テキストを取得
  var diary_form_group = document.getElementById("input_diary");

  var get_diary_data = function() {
    var data = "";
    if (diary_form_group !== null) {
      diary_form_group.childNodes.forEach(function(element) {
        if (element.value !== undefined) {
          data = data + element.value;
        }
      });
    }
    return data;
  }
  var diary_data = get_diary_data();

  // 移動ボタンを取得
  var confirm_to_move = function(move_date, event_name) {
    if (move_date !== null) {
      move_date.addEventListener(event_name, function(e) {
        if (get_diary_data() !== diary_data) {
          if (!window.confirm('変更された日記が保存されません。良いですか？')) {
            e.preventDefault();
          }
        }
      }, false);
    }
  }

  var prev_date = document.getElementById("prev_date");
  confirm_to_move(prev_date, 'click');
  var next_date = document.getElementById("next_date");
  confirm_to_move(next_date, 'click');
//   var select_date = document.getElementById("date_Get");
//   confirm_to_move(select_date, 'onchange');
  var new_diary = document.getElementById("new_diary");
  confirm_to_move(new_diary, 'click');
  var show_diary = document.getElementById("show_diary");
  confirm_to_move(show_diary, 'click');
  var search_diary = document.getElementById("search_diary");
  confirm_to_move(search_diary, 'click');
  var user_profile = document.getElementById("user_profile");
  confirm_to_move(user_profile, 'click');

  window.addEventListener('beforeunload', function(e) {
    if (get_diary_data() !== diary_data) {
      e.preventDefault();
      e.returnValue = '';
    }
  }, false);
}, false);