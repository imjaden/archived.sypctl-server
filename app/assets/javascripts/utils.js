window.Param = {
  params: {},
  parse: function() {
    var params = {},
        search = window.location.search.substring(1),
        parts = search.split('&'),
        pairs = [];

    for(var i = 0, len = parts.length; i < len; i++) {
      pairs = parts[i].split('=');
      params[pairs[0]] = (pairs.length > 1 ? pairs[1] : null);
    }
    window.Param.params = params;

    return params;
  },
  toString: function(paramsHash) {
    var pairs = [];
    paramsHash['_t'] = (new Date().valueOf())
    for(var key in paramsHash) {
      pairs.push(key + "=" + paramsHash[key]);
    }
    var href = window.location.href.split("?")[0] + "?" + pairs.join("&");
    return href;
  },
  redirectTo: function(paramsHash) {
    window.location.href = window.Param.toString(paramsHash);
  }
}

window.Loading = {
  setState: function(state) {
    if(state === 'show') {
      $(".loading").removeClass("hidden");
    } else {
      setTimeout("$('.loading').addClass('hidden');", 1000);
    }
  },
  show: function(text) {
    window.Loading.makeSureLoadingExist();

    $(".loading").html(text);
    window.Loading.makeSureCenterHorizontal();
    window.Loading.setState('show');
  },
  hide: function() {
    window.Loading.setState('hide');
  },
  makeSureLoadingExist: function(type) {
    if($(".loading").length === 0) {
      $("body").append('<div class="loading hidden">loading...</div>');
    }
  },
  popup: function(text) {
    window.Loading.makeSureLoadingExist();

    $(".loading").html(text);
    window.Loading.makeSureCenterHorizontal();
    window.Loading.setState('show');
    $(".loading").slideDown(1000, function() {
      $(this).slideUp(2500);
    })
  },
  makeSureCenterHorizontal: function() {
    var w = window,
        d = document,
        e = d.documentElement,
        g = d.getElementsByTagName('body')[0],
        x = $(".container").width() || w.innerWidth || e.clientWidth || g.clientWidth,
        y = w.innerHeight|| e.clientHeight || g.clientHeight,
        loading_width = $(".loading").width(),
        left_width = (x - loading_width - 50)/2;

    // console.log({"x": x, "w": loading_width, "left": left_width, "margin-left": '0px'});
    $(".loading").css({"left": left_width, "margin-left": '0px'});
  }
}

window.Image = {
  onerror: function(img) {
    let src = $(img).attr('src'),
        src404 = '/images/404-small.png';
    console.group('图片加载异常')
    console.log('当前图片链接:', src)
    console.log('备份链接属性:', 'data-errorurl')
    console.log('加载默认图片:', src404)
    console.groupEnd()
    $(img).attr('src', src404).attr('data-errorurl', src)
  }
}
