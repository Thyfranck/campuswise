$(document).ready(function(){
    setInterval('notification_count()',5000);
})

function notification_count(){
    if($('#notification_box_gray').is(':visible')){
        var current =  $('#notification_box_gray').html();
        $.ajax({
            url: "/notification",
            dataType: "json",
            success: function(data) {
                if(!(data == current)){
                    $('#notification_box_gray').attr('id', 'notification_box_red');
                    if(data < 10){
                        $('#notification_box_red').html('0'+ data);
                    }
                    if (data > 10){
                        $('#notification_box_red').html(data);
                    }
                }   
            }
        })
    }

    if($('#notification_box_red').is(':visible')){
        $.ajax({
            url: "/notification",
            dataType: "json",
            success: function(data) {
                if(data < 10){
                    $('#notification_box_red').html('0'+ data);
                }
                if (data > 10){
                    $('#notification_box_red').html(data);
                }

            }
        })
    }
}