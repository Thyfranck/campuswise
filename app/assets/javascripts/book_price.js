$(document).ready(function(){
    var isbn_number = $('#book_isbn').val()
    if(!(isbn_number === undefined)){
        $.ajax({
            url: "/search",
            dataType: "script",
            data: {
                book_isbn_for_price : $('#book_isbn').val()
            }
        });
    }


    $('#book_isbn').change(function() {
        $.ajax({
            url: "/search",
            dataType: "script",
            data: {
                book_isbn_for_price : $('#book_isbn').val()
            }
        });
    });
});

