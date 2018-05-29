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
      $(this).slideUp(1500);
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

    console.log({"x": x, "w": loading_width, "left": left_width, "margin-left": '0px'});
    $(".loading").css({"left": left_width, "margin-left": '0px'});
  }
}
