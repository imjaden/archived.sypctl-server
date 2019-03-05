new Vue({
  el: '#appVue',
  data: function() {
    return { 
      screenHeight: document.documentElement.clientHeight - 150,
      jobGroups: [],
      iframeWin: {},
      iframeSrc: null,
      iframeTitle: null
    }
  },
  mounted () {
    // 在外部vue的window上添加postMessage的监听，并且绑定处理函数handleMessage
    window.addEventListener('message', this.handleMessage)
    this.iframeWin = this.$refs.iframe.contentWindow
  },
  created() {
    this.getJobGroups()
  },
  methods: {
    getJobGroups() {
      window.Loading.show("获取数据中...");
      let that = this;
      $.ajax({
        type: 'get',
        url: '/api/v2/account/job_group/list',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        if(res.code === 200) {
          window.App.addSuccessNotify(res.message)
          that.jobGroups = res.data
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    copyClick(item) {
    },
    deleteClick(item) {
      if(!confirm('确定删除「' + item.title + '」?')) {
        return false;
      }

      let that = this;
      window.Loading.show("删除中...");
      $.ajax({
        type: 'post',
        url: '/api/v2/account/job_group/delete',  
        contentType: 'application/json',
        dataType: 'json',
        processData: false,
        data: JSON.stringify({uuid: item.uuid})
      }).done(function(res, status, xhr) {
        if(res.code === 201) {
          window.App.addSuccessNotify(res.message)
          let groupIndex = that.jobGroups.findIndex(function(ele) { return ele.uuid === item.uuid; });
          that.$nextTick(function() {
            that.jobGroups.splice(groupIndex, 1)
          })
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    showIframeModal(title, url) {
      console.log(title, url)
      this.iframeTitle = title
      this.iframeSrc = url
      $("#iframeModal").modal('show')
    },
    closeIframeModal() {
      $("#iframeModal").modal('hide')
      $("#iframeModal .loader").removeClass('hidden')
      $("#iframeModal iframe").addClass('hidden')
      this.iframeSrc = null
    },
    async handleMessage (event) {
      let that = this,
          cmd = event.data.cmd,
          params = event.data.params;
      switch (cmd) {
        case 'created_or_updated':
          that.closeIframeModal()
          window.App.addSuccessNotify(params.message)
          that.$nextTick(function() {
            if(that.editItemIndex >= 0) {
              params.data._class = 'success'
              params.data.icon_path = "/images/icons/" + params.data.icon
              Vue.set(that.records, that.editItemIndex, params.data)
            } else {
              that.createItemId = params.data.id
              that.getTabToolboxMenu()
            }
          })
          break
        case 'loaded': 
          setTimeout(function() {
            $("#iframeModal .loader").addClass('hidden')
            $("#iframeModal iframe").removeClass('hidden')
          }, 500)
          break
        case 'close':
          that.closeIframeModal()
          break
        default:
          console.log('unkonwn cmd, data:', event.data)
          break
      }
    },
    switchDevice(mode) {
      $("body").css({"overflow-y": "auto"})
    }
  }
})