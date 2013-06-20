$(document).ready(function(){
    if($('#book_available').is(':checked')){
        $('.available_for').show();
    }

    if($('#book_title').length != 0){
        if ($('#book_title').val().length > 0 || $('#book_isbn').val().length > 0 || $('#book_author').val().length > 0 || $('#book_publisher').val().length > 0 || $('#book_purchase_price').val().length > 0){
            $('.book_info').show();
        }
    }
    


    if($('#book_available_for_both').is(':checked')){
        $('.available_dates').show();
        $('.purchase_price').show();
        $('.loan_rates').show();
    }


    if($('#book_available_for_rent').is(':checked')){
        $('.available_dates').show();
        $('.loan_rates').show();
    }

    if ($('#book_available_for_sell').is(':checked')){
        $('.purchase_price').show();
    }
    
    $('#book_available').change(function(){
        if($('#book_available').is(':checked')){
            $('.available_for').show();
            if($('#book_available_for_rent').is(':checked')){
                $('.available_dates').show();
                $('.loan_rates').show();
            }
            if($('#book_available_for_both').is(':checked')){
                $('.available_dates').show();
                $('.purchase_price').show();
                $('.loan_rates').show();
            }
            if ($('#book_available_for_sell').is(':checked')){
                $('.purchase_price').show();
            }
        }
        else{
            $('.available_for').hide();
            $('.available_dates').hide();
            $('.purchase_price').hide();
            $('.loan_rates').hide();
        }
    })

    $('#book_available_for_rent').change(function(){
        if($(this).is(':checked')){
            $('.available_dates').show();
            $('.loan_rates').show();
            $('.purchase_price').hide();
        }
    })

    $('#book_available_for_sell').change(function(){
        if($(this).is(':checked')){
            $('.available_dates').hide();
            $('.purchase_price').show();
            $('.loan_rates').hide();
        }
    })

    $('#book_available_for_both').change(function(){
        if($(this).is(':checked')){
            $('.available_dates').show();
            $('.loan_rates').show();
            $('.purchase_price').show();
        }
    })

    $('.add_manually').click(function(){
        $('.book_info').show();
        $('#book_title').val("");
        $('#book_isbn').val("");
        $('#book_author').val("");
        $('#book_publisher').val("");
        $('#uniform-book_image').parent().parent().show();
        $(".hidden_image img").attr("src", "");
        $(".hidden_image").hide();
        $('#remote_url').val("");
    })
})