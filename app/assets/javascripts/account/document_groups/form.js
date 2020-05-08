new Vue({
  el: '#appVue',
  data: function() {
    return {
      uuid: '',
      title: '',
      description: '',
      formAction: '',
    }
  },
  created() {
    const that = this
    that.formAction = ('/account/document_groups/new' === window.location.pathname ? 'create' : 'update')
    if(that.formAction === 'update') {
      that.uuid = window.App.params()['uuid']
      if(!that.uuid) { 
        alert("获取 UUID 失败") 
        return false
      }
      that.queryGroupAction()
    }
  },
  methods: {
    btnClickHandler() {
      let that = this;
      let api = that.formAction === 'create' ? '/api/v2/account/document_group/create' : `/api/v2/account/document_group/update?uuid=${that.uuid}`;
      let type = that.formAction === 'create' ? 'post' : 'put'
      window.Loading.show("处理中...");
      $.ajax({
        type: type,    
        cache: false,
        dataType: 'json',
        url: api,
        contentType: 'application/json',
        data: JSON.stringify({
          document_group: {
            title: that.title,
            description: that.description
          }
        })
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          if(window.confirm('创建成功，请刷新选择列表')) {
            that.closeBrowserTag()
          }
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    queryGroupAction() {
      let that = this;
      window.Loading.show("处理中...");
      $.ajax({
        type: 'get',
        url: `/api/v2/account/document_group/query?uuid=${that.uuid}`,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        if(res.code !== 200) {
          console.error(res.data)
          return
        }

        that.title = res.data.title
        that.content = res.data.content
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    closeBrowserTag() {
    if (navigator.userAgent.indexOf("MSIE") > 0) {
        if (navigator.userAgent.indexOf("MSIE 6.0") > 0) {
            window.opener = null;
            window.close();
        } else {
            window.open('', '_top');
            window.top.close();
        }
    } else if (navigator.userAgent.indexOf("Firefox") > 0) {
        window.location.href = 'about:blank ';
    } else {
        window.opener = null;
        window.open('', '_self', '');
        window.close();
    }
}
  }
})