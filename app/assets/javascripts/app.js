window.App = {
  addNotify: function(message, type) {
    let html = '<div class="alert alert-' + type + ' alert-dismissible" role="alert">' +
      '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' + 
      message +
    '<br><span class="alert-date" data-date="' +new Date().valueOf() + '"></span>' +
    '</div>';

    $(".system-notify").prepend(html)
    let tmpDate, interval, text;
    $(".system-notify .alert-date").each(function(ctl) {
      tmpDate = $(this).data("date")
      if(tmpDate) {
        interval = (new Date().valueOf() - parseInt(tmpDate))/1000
        if(interval < 5) {
          text = '刚刚'
        } else if(interval < 60 ) {
          text = parseInt(interval) + '秒前'
        } else if(interval < 60*60) {
          interval = interval/60
          text = parseInt(interval) + '分钟前'
        } else if(interval < 24*60*60) {
          interval = interval/24*60*60
          text = parseInt(interval) + '天前'
        }
        $(this).html(text)
      }
    })
  },
  addSuccessNotify: function(message) {
    window.App.addNotify(message, 'success')
  },
  addWarningNotify: function(message) {
    window.App.addNotify(message, 'warning')
  }, 
  addInfoNotify: function(message) {
    window.App.addNotify(message, 'info')
  }, 
  addDangerNotify: function(message) {
    window.App.addNotify(message, 'danger')
  }, 
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

    $(".navbar-nav li").removeClass("active");
    $(".navbar-nav .menu-" + parts[1]).addClass("active");
    $(".navbar-nav a").filter(function(inx) {
      if(pathname === ($(this).attr("href") || "").split("?")[0]) { 
        $(this).closest("li").addClass("active");

        /*
         * 记录菜单使用频率至浏览器缓存, 提供最近访问菜单功能
         * 以此改善用户使用体验
         */
        try {
          let ue = window.localStorage.getItem('_ue_visit_menu'),
              ueObj = {},
              tmp;
          if(ue) { ueObj = JSON.parse(ue) }

          if(!ueObj[pathname]) { 
            ueObj[pathname] = {
              weight: 0,
              path: pathname
            }
          }
          ueObj[pathname]['title'] = $(this).text().replace(/\n|\s/g, '')
          ueObj[pathname]['weight'] = ueObj[pathname]['weight'] + 1
          ueObj[pathname]['timestamp'] = new Date().valueOf()
          window.localStorage.setItem('_ue_visit_menu', JSON.stringify(ueObj))
        } catch(e) {
          console.log(e)
        }
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
    let navbar_right_lis = $("#navbar_right_lis").val() || 1,
        navbar_lis = $(".navbar-nav:first li, .navbar-right li:lt(" + navbar_right_lis + ")"),
        path_name = window.location.pathname,
        navbar_match_index = -1,
        navbar_hrefs = navbar_lis.map(function() { return $(this).children("a:first").attr("href"); }),
        paths = path_name.split('/');

    while(paths.length > 0 && navbar_match_index === -1) {
      let temp_path = paths.join('/');
      for(var i = 0, len = navbar_hrefs.length; i < len; i++) {
        if(navbar_hrefs[i] === temp_path) {
          navbar_match_index = i;
          break;
        }
      }
      paths.pop();
    }
    navbar_lis.each(function(index) {
      if(navbar_match_index === index) {
        $(this).addClass("active")
      } else {
        $(this).removeClass("active");
      }
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
      delete params.bsession;
      window.Param.redirectTo(params);
    }
  },
  toggleDisplayVisitMenus: function() {
    if($('.visit-menus').hasClass('hidden')) {
      let ue = window.localStorage.getItem('_ue_visit_menu'),
          ueObj = {},
          menus = [],
          lis, ul;
      if(ue) { ueObj = JSON.parse(ue) }
      menus = Object.values(ueObj).sort((a, b) => { return b.timestamp - a.timestamp; })
      lis = menus.map((menu) => {
        return '' + 
          '<li class="list-group-item">' + 
            '<span class="badge">' + menu.weight + '</span>' + 
             '<a href="' + menu.path + '">' + menu.title + '</a>' +
          '</li>';
      })
      lis.unshift(
        '<li class="list-group-item active">' + 
           '最近访问:' +
        '</li>'
      )
      ul = '<ul class="list-group">' + lis.join('') + '</ul>'
      $('.visit-menus').html(ul);

      $('.visit-menus').removeClass('hidden')
      $('.system-notify').addClass('hidden')
    } else {
      $('.visit-menus').addClass('hidden')
      $('.system-notify').removeClass('hidden')
    }
  },
  getScrollTop: function(){
  　　var scrollTop = 0, bodyScrollTop = 0, documentScrollTop = 0;
  　　if(document.body){
  　　　　bodyScrollTop = document.body.scrollTop;
  　　}
  　　if(document.documentElement){
  　　　　documentScrollTop = document.documentElement.scrollTop;
  　　}
  　　scrollTop = (bodyScrollTop - documentScrollTop > 0) ? bodyScrollTop : documentScrollTop;
  　　return scrollTop;
  },
  getScrollHeight: function(){
  　　var scrollHeight = 0, bodyScrollHeight = 0, documentScrollHeight = 0;
  　　if(document.body){
  　　　　bodyScrollHeight = document.body.scrollHeight;
  　　}
  　　if(document.documentElement){
  　　　　documentScrollHeight = document.documentElement.scrollHeight;
  　　}
  　　scrollHeight = (bodyScrollHeight - documentScrollHeight > 0) ? bodyScrollHeight : documentScrollHeight;
  　　return scrollHeight;
  },
  getWindowHeight: function(){
  　　var windowHeight = 0;
  　　if(document.compatMode == "CSS1Compat"){
  　　　　windowHeight = document.documentElement.clientHeight;
  　　}else{
  　　　　windowHeight = document.body.clientHeight;
  　　}
  　　return windowHeight;
  }
};