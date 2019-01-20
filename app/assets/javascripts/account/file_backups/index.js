new Vue({
  el: '#appVue',
  data: function() {
    return { 
      records: [],
      file: {
        file_path: '',
        description: '',
        message: ''
      }
    }
  },
  created() {
    this.getRecords()
  },
  methods: {
    getRecords() {
      window.Loading.show("获取数据中...");
      let that = this;
      $.ajax({
        type: 'get',
        url: '/api/v2/account/file_backup/list',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        if(res.code === 200) {
          window.App.addSuccessNotify(res.message)
          that.records = res.data
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    createSubmit(el) {
      if(!this.file.file_path.length) {
        this.file.message = '请输入文件路径'
      } else if(!this.file.description.length) {
        this.file.message = '请输入文件描述'
      } else {
        let that = this;
        $.ajax({
          type: 'post',
          url: '/api/v2/account/file_backup/create',  
          contentType: 'application/json',
          dataType: 'json',
          processData: false,
          data: JSON.stringify({file: {file_path: that.file.file_path, description: that.file.description}})
        }).done(function(res, status, xhr) {
          window.App.addSuccessNotify(res.message)
          $("#newModal").modal('hide')
          if(res.code === 201) {
            that.$nextTick(function() {
              that.getRecords()
            })
          }
        }).fail(function(xhr, status, error) {
        }).always(function(res, status, xhr) {
        });
      }
      el.preventDefault();
    }
  }
})