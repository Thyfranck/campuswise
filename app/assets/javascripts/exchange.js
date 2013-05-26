$(document).ready(function(){
    
    if($('#exchange_package_daily').is(':checked')){
        $('.exchange_amount').show();
        $('.amount_text').html('days');
        $('.exchange_submit_section').show();
    }

    if($('#exchange_package_weekly').is(':checked')){
        $('.exchange_amount').show();
        $('.amount_text').html('weeks');
        $('.exchange_submit_section').show();
    }

    if($('#exchange_package_monthly').is(':checked')){
        $('.exchange_amount').show();
        $('.amount_text').html('months');
        $('.exchange_submit_section').show();
    }

    $('#exchange_package_daily').change(function(){
        if($('#exchange_package_daily').is(':checked')){
            $('.exchange_amount').show();
            $('.amount_text').html('days');
            $('.exchange_submit_section').show();
        }
    })

    if($('#exchange_package_semester').is(':checked')){
        $('.exchange_amount').hide();
        $('.exchange_submit_section').show();
    }

    $('#exchange_package_weekly').change(function(){
        if($('#exchange_package_weekly').is(':checked')){
            $('.exchange_amount').show();
            $('.amount_text').html('weeks');
            $('.exchange_submit_section').show();
        }
    })

    $('#exchange_package_monthly').change(function(){
        if($('#exchange_package_monthly').is(':checked')){
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
        var rate1 = ($('#day_rate').html());
        var rate3 = ($('#month_rate').html());
        var rate2 = ($('#week_rate').html());
        var rate4 = ($('#semester_rate').html());
        var amount = $.trim($('#exchange_duration').val());          
        
        if($('#exchange_package_daily').is(':checked')){
            if(amount.length >= 1 && amount == myRegEx.exec(amount)){
                $('.total_amount_to_pay').html('$'+rate1*amount);
            }else{
                $('.total_amount_to_pay').html('Invalid');
            }              
        }
        if($('#exchange_package_weekly').is(':checked')){
            if(amount.length >= 1 && amount == myRegEx.exec(amount)){
                $('.total_amount_to_pay').html('$'+rate2*amount);
            }else{
                $('.total_amount_to_pay').html('Invalid');
            }
        }
        if($('#exchange_package_monthly').is(':checked')){
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
                $('.amount_error').html('You must provide a number.').delay(500).fadeIn(500);
                $('.amount_error').html('You must provide a number.').delay(4000).fadeOut(1500);
                return false;
            }
        }
        else {
            return true;
        }        
    });
    
})