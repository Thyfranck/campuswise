$(document).ready(function() {
    $("#credit-card input, #credit-card select").attr("disabled", false);
    $("#business_stripe_token").val("");

    $("form:has(#credit-card)").live("submit", function(e) {
        var form = this;

        var submit = $(this).find('input[type=submit][value!="Back"]');
        // if ($(e.originalEvent.explicitOriginalTarget)[0] === submit[0]) {
        var submit_prev = submit.val();
        submit.val('Please wait...').attr('disabled', true).end();

        $("#credit-card input, #credit-card select").attr("name", "");
        $("#credit-card-errors").hide();

        if (!$("#credit-card").is(":visible")) {
            $("#credit-card input, #credit-card select").attr("disabled", true);
            return true;
        }

        var exp_month = $("#_expiry_date_2i").val();
        var exp_year = $("#_expiry_date_1i").val();

        var card = {
            name : $("#card_holder_name").val(),
            number : $("#credit_card_number").val(),
            expMonth : $("#_expiry_date_2i").val(),
            expYear : $("#_expiry_date_1i").val(),
            cvc : $("#cvv").val()
        };

        Stripe.createToken(card, function(status, response) {
            if (status === 200) {
                $("#business_stripe_token").val(response.id);
                form.submit();
            } else {
                $("#error_explanation").remove();
                $("#breadcrumb").after("<div id='error_explanation'></div>")
                $("#error_explanation").html('<div class="alert-icon">!</div><h4> 1 error prohibited this business from being saved: </h4><div class="clear"></div><ul><li>' + response.error.message + '</li></ul>');
                $('body, html').animate({
                    scrollTop: 380
                }, 600);

                submit.val(submit_prev).attr('disabled', false).end();
            }
        });

		// } else {
		// $(form).append($('<input type="hidden" name="back_button" />').val("Back"));
		// form.submit();
		// }

        return false;
    });

});
