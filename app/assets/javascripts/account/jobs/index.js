new Vue({
  el: '#appVue',
  data: function() {
    return { 
      jobGroups: []
    }
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
    }
  }
})