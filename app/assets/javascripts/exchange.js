$(document).ready(function(){
    
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
        var myRegEx = new RegExp('[0-9]+');       
        var rate1 = parseFloat($('input#day_rate').val());
        var rate2 = parseFloat($('input#week_rate').val());
        var rate3 = parseFloat($('input#month_rate').val());
        var rate4 = parseFloat($('input#semester_rate').val());
        
        var amount = $.trim($('#exchange_duration').val());          
        
        if($('#exchange_package_day').is(':checked')){
            if(amount.length >= 1 && amount == myRegEx.exec(amount)){
                $('.total_amount_to_pay').html('$'+rate1*amount);
            }else{
                $('.total_amount_to_pay').html('Invalid');
            }              
        }
        if($('#exchange_package_week').is(':checked')){
            if(amount.length >= 1 && amount == myRegEx.exec(amount)){
                $('.total_amount_to_pay').html('$'+rate2*amount);
            }else{
                $('.total_amount_to_pay').html('Invalid');
            }
        }
        if($('#exchange_package_month').is(':checked')){
            if(amount.length >= 1 && amount == myRegEx.exec(amount)){
                $('.total_amount_to_pay').html('$'+rate3*amount);
            }else{
                $('.total_amount_to_pay').html('Invalid');
            }
        }
        if($('#exchange_package_semester').is(':checked')){
            $('.total_amount_to_pay').html('$'+rate4);
        }
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
            return true;
        }        
    });
    
})