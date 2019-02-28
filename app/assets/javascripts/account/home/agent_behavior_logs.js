new Vue({
  el: '#appVue',
  data: function() {
    return { 
      screenHeight: document.documentElement.clientHeight - 150,
      behaviorLogs: [],
      pageIndex: 0,
      iframeWin: {},
      iframeSrc: null,
      iframeTitle: null
    }
  },
  mounted () {
    // 在外部vue的window上添加postMessage的监听，并且绑定处理函数handleMessage
    // window.addEventListener('message', this.handleMessage)
    // this.iframeWin = this.$refs.iframe.contentWindow
  },
  created() {
    this.getBehaviorLogs()
  },
  methods: {
    getBehaviorLogs() {
      window.Loading.show("获取数据中...");
      let that = this;
      $.ajax({
        type: 'get',
        url: `/api/v2/account/agent_behavior_log/list?page=${that.pageIndex}`,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        if(res.code === 200) {
          window.App.addSuccessNotify(res.message)
          that.$nextTick(function() {
            that.behaviorLogs = that.behaviorLogs.concat(res.data)
            if(!res.data.length) { that.pageIndex = -1 }
          })
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    getMoreBehaviorLogs() {
      this.pageIndex = this.pageIndex + 1
      this.getBehaviorLogs()
    }
  }
})