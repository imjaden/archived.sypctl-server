(function() {
  window.App = {
    showLoading: function() {
      return $(".loading").removeClass("hidden");
    },
    showLoading: function(text) {
      $(".loading").html(text);
      return $(".loading").removeClass("hidden");
    },
    hideLoading: function() {
      $(".loading").addClass("hidden");
      return $(".loading").html("loading...");
    },
    params: function(type) {
      var i, key, keys, obj, pair, pairs, value, values;
      obj = {};
      keys = [];
      values = [];
      pairs = window.location.search.substring(1).split("&");
      for (i in pairs) {
        if (pairs[i] === "") {
          continue;
        }
        pair = pairs[i].split("=");
        key = decodeURIComponent(pair[0]);
        value = decodeURIComponent(pair[1]);
        keys.push(key);
        values.push(value);
        obj[key] = value;
      }
      if (type === "key") {
        return keys;
      } else if (type === "value") {
        return values;
      } else {
        return obj;
      }
    },
    removeGlyphicon: function() {
      $(".dropdown-menu i.glyphicon").remove();
      return $(".dropdown-menu a").each(function() {
        return $(this).text($.trim($(this).text()));
      });
    },
    checkboxState: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        return false;
      } else {
        return true;
      }
    },
    checkboxChecked: function(self) {
      return $(self).attr("checked", "true");
    },
    checkboxUnChecked: function(self) {
      return $(self).removeAttr("checked");
    },
    checkboxState1: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        $(self).attr("checked", "true");
        return true;
      } else {
        $(self).removeAttr("checked");
        return false;
      }
    },
    reloadWindow: function() {
      return window.location.reload();
    },
    activeMenu: function() {
      var klass, pathname, parts;
      pathname = window.location.pathname;
      parts = pathname.split("/");

      $("li").removeClass("active");
      $("a").filter(function(inx) {
        if(pathname.indexOf($(this).attr("href")) >= 0) { 
          $(this).closest("li").addClass("active");
          $(this).closest(".dropdown").addClass("active")
        }
      })
    },
    resizeWindow: function() {
      var d, e, footer_height, g, main_height, nav_height, w, x, y;
      w = window;
      d = document;
      e = d.documentElement;
      g = d.getElementsByTagName("body")[0];
      x = w.innerWidth || e.clientWidth || g.clientWidth;
      y = w.innerHeight || e.clientHeight;
      nav_height = 80 || $("nav:first").height();
      footer_height = 100 || $("footer:first").height();
      main_height = y - nav_height - footer_height;
      if (main_height > 300) {
        return $("#main").css({
          "min-height": main_height + "px"
        });
      }
    },
    initBootstrapNavbarLi: function() {
      var navbar_lis = $(".navbar-nav:first li, .navbar-right li:lt(" + navbar_right_lis + ")"),
        navbar_right_lis = $("#navbar_right_lis").val() || 1
        path_name = window.location.pathname,
        navbar_match_index = -1,
        navbar_hrefs = navbar_lis.map(function() { return $(this).children("a:first").attr("href"); }),
        paths = path_name.split('/');

      while(paths.length > 0 && navbar_match_index === -1) {
        var temp_path = paths.join('/');
        for(var i = 0, len = navbar_hrefs.length; i < len; i++) {
          if(navbar_hrefs[i] === temp_path) {
            navbar_match_index = i;
            break;
          }
        }
        paths.pop();
      }
      navbar_lis.each(function(index) {
        navbar_match_index === index ? $(this).addClass("active") : $(this).removeClass("active");
      });
    },
    initBootstrapPopover: function() {
      return $("body").popover({
        selector: "[data-toggle=popover]",
        container: "body"
      });
    },
    initBootstrapTooltip: function() {
      return $("body").tooltip({
        selector: "[data-toggle=tooltip]",
        container: "body"
      });
    },
    breadcrumbSearch: function(ctl) {
      var keywords = (ctl.tagName === 'INPUT' ? $(ctl) : $(ctl).siblings(".breadcrumb-search-input:first")).val();
      var params = window.Param.parse();
      keywords = $.trim(keywords);
      if(keywords.length) {
        params["page"] = 1;
        params["keywords"] = keywords;
      } else {
        if(params.keywords) { delete params.keywords }
      }
      window.Param.redirectTo(params);
    },
    recordLoginOrLogout: function() {
      var params = window.App.params("object");
      if(params.login_authen_to_redirect || params.logout_authen_to_redirect) {
        if(!params.user_num) return;

        try {
          var objects = {user: { id: params.user_num, name: params.user_name, type: "user" }},
              scene = params.login_authen_to_redirect ? "user.login" : "user.logout";
              window.action_logger = {operator: objects.user};
          window.OperationLogger.record(scene, objects);
        } catch(e) { console.log(e) }

        delete params.login_authen_to_redirect;
        delete params.logout_authen_to_redirect;
        delete params.user_num;
        delete params.user_name;
        window.Param.redirectTo(params);
      }
    }
  };

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
    
    var copyInfo, currentDate;
    currentDate = new Date();
    copyInfo = "&copy; 2016-" + currentDate.getFullYear() + " " + window.location.host;
    $("#footer .footer").html(copyInfo);
    // $(".flash_area .alert").slideUp(15000);

    $('.breadcrumb-search-input').on('keypress',function(event){ 
       if(event.keyCode == 13) {  
         window.App.breadcrumbSearch(this);
       }  
    });
  });
}).call(this);
