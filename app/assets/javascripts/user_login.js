$(function() {
    function smartLoginForm() {
        var w = window,
            d = document,
            e = d.documentElement,
            g = d.getElementsByTagName('body')[0],
            x = w.innerWidth || e.clientWidth || g.clientWidth,
            y = w.innerHeight|| e.clientHeight || g.clientHeight,
            alertHeight = $(".alert").height() || 0,
            restHeight = (y - 52 - 402 - alertHeight)/4 - 52;
        if(restHeight >= 0) {
          $(".bs-docs-masthead .bs-docs-booticon").css({opacity: 0, display: 'block'});
          $(".bs-docs-masthead .bs-docs-booticon").animate({'margin-top': restHeight + 'px', opacity: 1}, 'slow');
        } else {
          $(".bs-docs-masthead .bs-docs-booticon").animate({opacity: 0}, 'slow', 'swing', function() {
            $(this).css({'display': 'none'});
          }); 
        }
    }
    smartLoginForm();
    window.onresize = function() { smartLoginForm(); }

    var handlerPopup = function (captchaObj) {
        captchaObj.onSuccess(function () {
            var validate = captchaObj.getValidate(),
                $captcha = $('input[name=captcha]');
            $.ajax({
                url: '/geetest3/validate',
                type: 'post',
                dataType: 'json',
                data: {
                    geetest_challenge: validate.geetest_challenge,
                    geetest_validate: validate.geetest_validate,
                    geetest_seccode: validate.geetest_seccode
                },
                success: function (data) {
                  $captcha.val('successfully');
                  captchaObj.hide();

                  $('input[type=submit]').removeAttr('disabled')
                },
                error: function (xhr, status, error) {
                  $captcha.val('failed');
                }
            });
        });
        $('input[type=submit]').click(function () {
            captchaObj.show();
        });
        captchaObj.appendTo('#popup-captcha');
    };

    $('input[type=submit]').val('加载插件...');
    $.ajax({
        url: '/geetest3/register?avoid_cache_token=' + (new Date()).getTime(),
        type: 'get',
        dataType: 'json',
        success: function (data) {
            initGeetest({
                gt: data.gt,
                challenge: data.challenge,
                product: 'float', // 产品形式，包括：float，embed，popup。注意只对PC版验证码有效
                offline: !data.success // 表示用户后台检测极验服务器是否宕机，一般不需要关注
            }, handlerPopup);
            $('input[type=submit]').val('登录');
        }
    });
});
