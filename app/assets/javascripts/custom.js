$(document).ready(function(){
    $('form').find('input[type=text],textarea,select').filter(':visible:first').focus();

    $('.carousel').carousel({
        interval: 3000
    });
    $(".uniform").uniform();
    $('.selectpicker').selectpicker();
    slideShow();

    $('.counter-price-btn').click(function(){
        $('.counter-price-container').css('display', 'inline-block');
        $(this).css('display', 'none');
        return false;
    });

});


function slideShow() {
    setInterval('slider()',6000);
}

function slider() {
    var current = ($('#slider img.show-it')? $('#slider img.show-it') : $('#slider img:first'));
    var next = ((current.next().length) ? current.next('img') : $('#slider img:first'));

    current.addClass('hide-it').removeClass('show-it');
    setTimeout(function(){
        current.addClass('hide').removeClass('show');
        next.addClass('show').removeClass('hide');
        setTimeout(function(){
            next
            .removeClass('hide-it')
            .addClass('show-it');
        }, 100);
    }, 1500);
}