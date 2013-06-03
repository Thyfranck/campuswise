function payment_type(){
    var payment_method_type = $('#payment_method_payment_method_type').val();
    if(payment_method_type == "Bank Account"){
        $('#payment_method_bank_name').parent().parent().show();
        $('#payment_method_bank_name').parent('.field_with_errors').parent().parent().show();
        $('#payment_method_account_holder_name').parent().parent().show();
        $('#payment_method_account_holder_name').parent('.field_with_errors').parent().parent().show();
        $('#payment_method_account_number').parent().parent().show();
        $('#payment_method_account_number').parent('.field_with_errors').parent().parent().show();
        $('#payment_method_credit_card_type').val("");
        $('#payment_method_credit_card_type').parent().parent().hide();
        $('#payment_method_credit_card_type').parent('.field_with_errors').parent().parent().hide();
        $('#payment_method_card_number').val("");
        $('#payment_method_card_number').parent().parent().hide();
        $('#payment_method_card_number').parent('.field_with_errors').parent().parent().hide();
    }
    if(payment_method_type == "Credit Card"){
        $('#payment_method_bank_name').val("");
        $('#payment_method_bank_name').parent().parent().hide();
        $('#payment_method_bank_name').parent('.field_with_errors').parent().parent().hide();
        $('#payment_method_account_holder_name').val("");
        $('#payment_method_account_holder_name').parent().parent().hide();
        $('#payment_method_account_holder_name').parent('.field_with_errors').parent().parent().hide();
        $('#payment_method_account_number').val("");
        $('#payment_method_account_number').parent().parent().hide();
        $('#payment_method_account_number').parent('.field_with_errors').parent().parent().hide();
        $('#payment_method_credit_card_type').parent().parent().show();
        $('#payment_method_credit_card_type').parent('.field_with_errors').parent().parent().show();
        $('#payment_method_card_number').parent().parent().show();
        $('#payment_method_card_number').parent('.field_with_errors').parent().parent().show();
    }
}

$(document).ready(function(){
    payment_type();
    $('#payment_method_payment_method_type').change(function(){
        payment_type();
    })
    
})
