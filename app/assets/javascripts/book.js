$(document).ready(function(){
    var myRegEx = new RegExp('[0-9]+');

    $('#book_loan_daily').change(function(){
        var var1 = $.trim($('#book_loan_daily').val());
        if(var1 != myRegEx.exec(var1) || (var1 < 5)){
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(500).fadeIn(500);
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(4000).fadeOut(1500);
            $(this).val("");
        }
    });

    $('#book_loan_weekly').change(function(){
        var var2 = $.trim($('#book_loan_weekly').val());
        if(var2 != myRegEx.exec(var2) || (var2 < 5)){
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(500).fadeIn(500);
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(4000).fadeOut(1500);
            $(this).val("");
        }
    });

    $('#book_loan_monthly').change(function(){
        var var3 = $.trim($('#book_loan_monthly').val());
        if(var3 != myRegEx.exec(var3) || (var3 < 5)){
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(500).fadeIn(500);
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(4000).fadeOut(1500);
            $(this).val("");
        }
    });

    $('#book_loan_semester').change(function(){
        var var4 = $.trim($('#book_loan_semester').val());
        if(var4 != myRegEx.exec(var4) || (var4 < 5)){
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(500).fadeIn(500);
            $(this).next('.number_error').html('must be a number and equal or above 5').delay(4000).fadeOut(1500);
            $(this).val("")
        }
    })

    

    $('#new_book').submit(function(e){
        var var1 = $.trim($('#book_loan_daily').val());
        var var2 = $.trim($('#book_loan_weekly').val());
        var var3 = $.trim($('#book_loan_monthly').val());
        var var4 = $.trim($('#book_loan_semester').val());

        if($('#book_requested').val() == 'true'){
            return true;
        }else if(var1.length < 1  && var2.length < 1 && var3.length < 1 && var4.length < 1 ){
            e.preventDefault();
            $('.loan_error').html('You must specify at least one loan type and rates.')
            return false;
        }

        
    });

    $('.edit_book').submit(function(e){
        var var1 = $.trim($('#book_loan_daily').val());
        var var2 = $.trim($('#book_loan_weekly').val());
        var var3 = $.trim($('#book_loan_monthly').val());
        var var4 = $.trim($('#book_loan_semester').val());

        if($('#book_requested').val() == 'true'){
            return true;
        }
        else if(var1.length < 1  && var2.length < 1 && var3.length < 1 && var4.length < 1 ){
            e.preventDefault();
            $('.loan_error').html('You must specify at least one loan rate')
            return false;
        }

        
    });
})