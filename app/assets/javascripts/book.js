$(document).ready(function(){
    if($('#book_available').is(':checked')){
        $('.available_for').show();
        $('.book_info').show();
        books_dynamic_container();
    }

    if($('#book_title').length != 0){
        if ($('#book_title').val().length > 0 || $('#book_isbn').val().length > 0 || $('#book_author').val().length > 0 || $('#book_publisher').val().length > 0){
            $('.book_info').show();
        }
    }

    $('#book_available_for_rent, #book_available_for_sell, #book_available_for_both').change(function(){
        books_dynamic_container();
    });

    
    $('#book_available').change(function(){
        if($('#book_available').is(':checked')){
            $('.available_for').show();
            $('#books-dynamic-container').show();
            books_dynamic_container();
        }
        else{
            $('.available_for').hide();
            $('#books-dynamic-container').hide();
        }
    });


    $('.add_manually').click(function(){
        $('.book_info').show();
        $("#book_title").val("");
        $("#book_isbn").val("");
        $("#book_author").val("");
        $("#book_publisher").val("");
        $('#uniform-book_image').parent().parent().show();
        $(".hidden_image img").attr("src", "");
        $(".hidden_image").hide();
        return false;
    });
});

function books_dynamic_container(){
    if($('#book_available_for_rent').is(':checked')){
        $('#books-dynamic-container .hide').hide();
        $('#books-dynamic-container .rent').show();
    }
    else if ($('#book_available_for_sell').is(':checked')){
        $('#books-dynamic-container .hide').hide();
        $('#books-dynamic-container .sell').show();
    }
    else if($('#book_available_for_both').is(':checked')){
        $('#books-dynamic-container .hide').hide();
        $('#books-dynamic-container .both').show();
    }
}