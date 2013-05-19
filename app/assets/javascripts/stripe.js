$(document).ready(function() {
    $("#billing_settings input, #billing_settings select").attr("disabled", false);
    $("#stripe_token").val("");

    $("#billing_settings").on("submit", function(e) {
        var form = this;
        
        var submit = $(this).find('input[type=submit]')
        var submit_prev = submit.val();
        submit.val('Please wait...').attr('disabled', true).end();

        var card = {
            name : $("#card_holder_name").val(),
            number : $("#credit_card_number").val(),
            expMonth : $("#_expiry_date_2i").val(),
            expYear : $("#_expiry_date_1i").val(),
            cvc : $("#cvv").val()
        };

        Stripe.createToken(card, function(status, response) {
            if (status === 200) {
                $("#stripe_token").val(response.id);
                form.submit();
            } else {
                $(".alert-block").html("<h4>Error!</h4>" + response.error.message).delay(500).fadeIn(500);
                $(".alert-block").delay(4000).fadeOut(1500);
                submit.val(submit_prev).attr('disabled', false).end();
            }
        });
        return false;
    });

});
