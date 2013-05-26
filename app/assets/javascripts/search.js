function book_title( message ) {
    $('#book_title').val(message);
}

function book_image(message) {
    if (message.length > 0){
        $('#uniform-book_image').parent().parent().hide();
        $(".hidden_image img").attr("src", message);
        $(".hidden_image").show();
        $('#remote_url').val(message);
    }
}

function author(message){
    $('#book_author').val(message);
}

function isbn(message){
    $('#book_isbn').val(message);
}

function publisher(message){
    $('#book_publisher').val(message);
}

$(document).ready(function(){
    var searchData;
    $('.search_field').autocomplete({
        source: function( request, response ) {
            $.ajax({
                url: "/search",
                dataType: "json",
                data: {
                    value : $('.search_field').val()
                },
                success: function( data ) {
                    searchData = data;
                    response( $.map( data, function(item) {
                        return {
                            label: item.title + " by " + item.author,
                            only_label : item.title,
                            isbn : item.isbn,
                            author : item.author,
                            publisher : item.publisher,
                            image : item.image_url
                        }
                    }));
                }
            });
        },
        minLength: 2,
        select: function( event, ui ) {
            book_title( ui.item ?
                ui.item.only_label :
                "title not found");
            book_image(ui.item ?
                ui.item.image :
                "image not found");
            author(ui.item ?
                ui.item.author :
                "image not found");
            isbn(ui.item ?
                ui.item.isbn :
                "image not found");
            publisher(ui.item ?
                ui.item.publisher :
                "image not found");
        },
        open: function() {
            $( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
        },
        open: function(){
                $('.ui-autocomplete').css('width', '290px');
        },
        close: function() {
            $( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
        }
    });
    
});