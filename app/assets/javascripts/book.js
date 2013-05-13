function book_price_validation() {
    var var1 = $('#book_loan_daily').val();
    var myRegEx = new RegExp('[0-9]+'); //make sure the var is a number

    if (var1 != myRegEx.exec(var1)) {
        alert("var1 failed");
        return false;
    }
}

$(document).ready(function(){

    $('#new_book').submit(function(e){
        var var1 = $('#book_loan_daily').val();
        var var2 = $('#book_loan_weekly').val();
        var var3 = $('#book_loan_monthly').val();
        var var4 = $('#book_loan_semister').val();
        var myRegEx = new RegExp('[0-9]+');
        
        if(var1 != myRegEx.exec(var1) || (var1 < 5)){
            e.preventDefault();
            $('#book_loan_daily').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_daily').next('.number_error').hide();
        }
        

        if(var2 != myRegEx.exec(var2) || (var2 < 5)){
            e.preventDefault();
            $('#book_loan_weekly').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_weekly').next('.number_error').hide();
        }

        if(var3 != myRegEx.exec(var3) || (var3 < 5)){
            e.preventDefault();
            $('#book_loan_monthly').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_monthly').next('.number_error').hide();
        }


        if(var4 != myRegEx.exec(var4) || (var4 < 5)){
            e.preventDefault();
            $('#book_loan_semister').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_semister').next('.number_error').hide();
        }
    });

    $('.edit_book').submit(function(e){
        var var1 = $('#book_loan_daily').val();
        var var2 = $('#book_loan_weekly').val();
        var var3 = $('#book_loan_monthly').val();
        var var4 = $('#book_loan_semister').val();
        var myRegEx = new RegExp('[0-9]+');

        if(var1 != myRegEx.exec(var1) || (var1 < 5)){
            e.preventDefault();
            $('#book_loan_daily').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_daily').next('.number_error').hide();
        }


        if(var2 != myRegEx.exec(var2) || (var2 < 5)){
            e.preventDefault();
            $('#book_loan_weekly').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_weekly').next('.number_error').hide();
        }

        if(var3 != myRegEx.exec(var3) || (var3 < 5)){
            e.preventDefault();
            $('#book_loan_monthly').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_monthly').next('.number_error').hide();
        }


        if(var4 != myRegEx.exec(var4) || (var4 < 5)){
            e.preventDefault();
            $('#book_loan_semister').next('.number_error').html('Must be a number and equal or above 5')
            return false;
        }
        else {
           $('#book_loan_semister').next('.number_error').hide();
        }
    });
});