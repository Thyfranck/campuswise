$(document).ready(function(){
    //setInterval('notification_count()',5000);
})

function notification_count(){
    if($('#notification_box').is(':visible')){
        var current =  $('#notification_box').html();
        $.ajax({
            url: "/notification",
            dataType: "json",
            success: function(data) {
                if(!(data == current)){
                    $('#notification_box').attr('style', 'background-color:red');
                    if(data < 10){
                        $('#notification_box').html('0'+ data);
                    }
                    if (data > 10){
                        $('#notification_box').html(data);
                    }
                }
            }
        })
    }
}