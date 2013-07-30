$(document).ready(function(){

    accept_exchange_button();

    if($('#exchange_counter_offer').is(':visible')){
    }
    else{
        $('#exchange_counter_offer').val("");
    }
    
    if($('#exchange_package_day').is(':checked')){
        $('.exchange_amount').show();
        $('.amount_text').html('days');
        $('.exchange_submit_section').show();
    }

    if($('#exchange_package_week').is(':checked')){
        $('.exchange_amount').show();
        $('.amount_text').html('weeks');
        $('.exchange_submit_section').show();
    }

    if($('#exchange_package_month').is(':checked')){
        $('.exchange_amount').show();
        $('.amount_text').html('months');
        $('.exchange_submit_section').show();
    }

    $('#exchange_package_day').change(function(){
        if($('#exchange_package_day').is(':checked')){
            $('.exchange_amount').show();
            $('.amount_text').html('days');
            $('.exchange_submit_section').show();
        }
    })

    if($('#exchange_package_semester').is(':checked')){
        $('.exchange_amount').hide();
        $('.exchange_submit_section').show();
    }

    if($('#exchange_package_buy').is(':checked')){
        $('.exchange_amount').hide();
        $('.exchange_submit_section').show();
    }

    $('#exchange_package_week').change(function(){
        if($('#exchange_package_week').is(':checked')){
            $('.exchange_amount').show();
            $('.amount_text').html('weeks');
            $('.exchange_submit_section').show();
        }
    })

    $('#exchange_package_month').change(function(){
        if($('#exchange_package_month').is(':checked')){
            $('.exchange_amount').show();
            $('.amount_text').html('months');
            $('.exchange_submit_section').show();
        }
    })

    $('#exchange_package_semester').change(function(){
        if($('#exchange_package_semester').is(':checked')){
            $('.exchange_amount').hide();
            $('.exchange_submit_section').show();
        }
    })

    $('#continue').click(function(){     
        var day_rate = parseFloat($('input#day_rate').val());
        var week_rate = parseFloat($('input#week_rate').val());
        var month_rate = parseFloat($('input#month_rate').val());
        var semester_rate = parseFloat($('input#semester_rate').val());
        var duration = parseFloat($('input#exchange_duration').val());
        var total_amount = 'Invalid';
        var counter_offer_price = '';
        var counter_offer_type = '';

        if(duration >= 1){
            if($('#exchange_package_day').is(':checked')){
                total_amount = '$' + day_rate + ' * ' + duration + ' day(s) = ' + '$' + (day_rate * duration);
                counter_offer_price = '$' + (day_rate * duration);
                counter_offer_type = '/ day';
            }
            else if($('#exchange_package_week').is(':checked')){
                total_amount = '$' + week_rate + ' * ' + duration + ' week(s) = ' + '$' + (week_rate * duration);
                counter_offer_price = '$' + (week_rate * duration);
                counter_offer_type = '/ week';
            }
            else if($('#exchange_package_month').is(':checked')){
                total_amount = '$' + month_rate + ' * ' + duration + ' month(s) = ' + '$' + (month_rate * duration);
                counter_offer_price = '$' + (month_rate * duration);
                counter_offer_type = '/ month';
            }
        }

        if($('#exchange_package_semester').is(':checked')){
            total_amount = '$' + semester_rate;
            counter_offer_price = '$' + semester_rate;
            counter_offer_type = '/ semester';
        }

        $('#total_amount_to_pay').html(total_amount);
        $('#counter-offer-price').html(counter_offer_price);
        $('#counter-offer-type').html(counter_offer_type);
    });

    $('#new_exchange').submit(function(e){
        if($('.exchange_amount').is(":visible")){
            var amount = $.trim($('#exchange_duration').val());
            var myRegEx = new RegExp('[0-9]+');

            if(amount.length < 1 || amount != myRegEx.exec(amount)){
                e.preventDefault();
                $('.amount_error').html('You must set duration.').delay(500).fadeIn(500);
                $('.amount_error').delay(4000).fadeOut(1500);
                return false;
            }
        }
        else {
            return true
        }
    });
    
    $("#agree").change(function(){
        accept_exchange_button();
    })

    function accept_exchange_button(){
        if($("#agree").is(':checked')) {
            $('.exchange_button').attr("disabled", false);
        } else {
            $('.exchange_button').attr("disabled", true);
        }
    }
    
})