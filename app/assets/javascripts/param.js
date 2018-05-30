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
