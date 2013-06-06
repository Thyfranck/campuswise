$(document).ready(function(){
    if($('#book_available').is(':checked')){
        $('.available_for').show();
    }


    if($('#book_available_for_both').is(':checked')){
        $('.available_dates').show();
    }


    if($('#book_available_for_rent').is(':checked')){
        $('.available_dates').show();
    }
    
    $('#book_available').change(function(){
        if($('#book_available').is(':checked')){
            $('.available_for').show();
        }
        else{
            $('.available_for').hide();
        }
    })

    $('#book_available_for_rent').change(function(){
        if($(this).is(':checked')){
            $('.available_dates').show();
        }
    })

    $('#book_available_for_sell').change(function(){
        if($(this).is(':checked')){
            $('.available_dates').hide();
        }
    })

    $('#book_available_for_both').change(function(){
        if($(this).is(':checked')){
            $('.available_dates').show();
        }
    })
})