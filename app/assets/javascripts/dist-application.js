/*
= require 'jquery.min.js'
= require 'jquery.lazyload.js'
= require 'bootstrap.min.js'
= require 'utils.js'
= require 'operation_logger.templates.js'
= require 'operation_logger.js'
= require 'nprogress.js'
= require 'vue_2.5.17.js'
= require 'app.js'
*/

(function() {
  NProgress.configure({speed: 500});
  $(function() {
    App.recordLoginOrLogout();
    NProgress.start();
    App.resizeWindow();
    NProgress.set(0.2);
    App.initBootstrapPopover();
    NProgress.set(0.4);
    App.initBootstrapTooltip();
    NProgress.set(0.8);
    App.activeMenu();
    NProgress.done(true);
    
    let copyInfo, currentDate;
    currentDate = new Date();
    copyInfo = "&copy;" + currentDate.getFullYear() + "&nbsp;<a href='http://www.miibeian.gov.cn' target='_blank'><i></i>沪ICP备11033154号</a>";
    // $("#footer .footer").html(copyInfo);

    // 图片懒加载
    $("img.img-lazy-load").lazyload({ 
    　　effect : "fadeIn", 
    　　threshold : 180,
    　　event: 'scroll',
    　　container: $("#container"),
    　　failure_limit: 2 
    });

    $('.breadcrumb-search-input').on('keypress',function(event){ 
       if(event.keyCode == 13) {  
         window.App.breadcrumbSearch(this);
       }  
    });
  });
}).call(this);
