$(document).ready(function() {    
    $('body').prepend('<div id="fb-root"></div>');
    $.ajaxSetup({
        cache: true
    });
    $.getScript('//connect.facebook.net/en_UK/all.js', function(){
        window.fbAsyncInit = function() {
            FB.init({
                appId: '362079183898081'
            });
        };
    });

    $('a#sign_in').click(function(e) {
        e.preventDefault();
        FB.login(function(response) {
            if (response.authResponse) {
                console.log(response);
                FB.api('/me', function(response) {
                    $('#user_facebook').val('');
                    $('#user_facebook').val(response.link);
                    FB.logout(function(){});
                });
            } else {
                alert('Please use your correct username and password.')
            }
        });
    });
});
     