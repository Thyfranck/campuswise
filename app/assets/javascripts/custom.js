$(document).ready(function(){
    $("select").uniform();
    slideShow();
    setInterval('fixSliderHeight()',1000);
});

function fixSliderHeight(){
    var height = $("#slider img").height();
    $("#slider").height(height+"px");
    $("#slider-container").height(height+"px");
    var top = parseInt(height / 1.3);
    $("#renting_text_row").css('margin-top', "-"+ top + 'px');
}

function slideShow() {
    $('#slider img').css({
        opacity: 0.0
    });
    $('#slider img:first').css({
        opacity: 1.0
    });
    setInterval('slider()',6000);
}

function slider() {
    var current = ($('#slider img.show')?  $('#slider img.show') : $('#slider img:first'));
    var next = ((current.next().length) ? current.next('img') : $('#slider img:first'));

    next.css({
        opacity: 0.0
    })
    .removeClass('hide')
    .addClass('show')
    .animate({
        opacity: 1.0
    }, 1000);

    current.animate({
        opacity: 0.0
    }, 1000)
    .addClass('hide')
    .removeClass('show');
}