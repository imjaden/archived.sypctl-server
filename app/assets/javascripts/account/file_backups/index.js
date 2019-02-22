new Vue({
  el: '#appVue',
  data: function() {
    return { 
      records: [],
      file: {
        type: 'new',
        title: '添加文件',
        file_path: '',
        description: '',
        message: ''
      },
      modal: {
        title: '标题',
        body: '加载中...',
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
    displayModal() {
      window.Loading.show("获取数据中...");
      let that = this;
      $.ajax({
        type: 'get',
        url: '/api/v2/account/file_backup/db_info',  
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        window.App.addSuccessNotify(res.message)

        $("#infoModal").modal('show')
        that.modal.title = '备份配置档'
        that.modal.body = JSON.stringify(res.data, null, 4)
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    refreshDbInfo() {
      window.Loading.show("刷新...");
      let that = this;
      $.ajax({
        type: 'post',
        url: '/api/v2/account/file_backup/db_info',  
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        window.App.addSuccessNotify(res.message)

        that.modal.title = '备份配置档'
        that.modal.body = JSON.stringify(res.data, null, 4)
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    newClick() {
      this.file = {
        type: 'new',
        title: '添加文件',
        file_path: '',
        description: ''
      }
      $("#newOrEditModal").modal('show')
    },
    editClick(file) {
      this.file.type = 'edit'
      this.file.title = '编辑文件'
      this.file.uuid = file.uuid
      this.file.file_path = file.file_path
      this.file.description = file.description
      $("#newOrEditModal").modal('show')
    },
    deleteClick(file) {
      this.file.type = 'delete'
      this.file.title = '确认删除文件？'
      this.file.uuid = file.uuid
      this.file.file_path = file.file_path
      this.file.description = file.description
      $("#newOrEditModal").modal('show')
    },
    createSubmit(el) {
      if(!this.file.file_path.length) {
        this.file.message = '请输入文件路径'
      } else if(!this.file.description.length) {
        this.file.message = '请输入文件描述'
      } else {
        let that = this,
            file = {file_path: that.file.file_path, description: that.file.description},
            action = 'create';
        if(that.file.type != 'new') { file.uuid = that.file.uuid }
        if(that.file.type == 'new') { action = 'create' }
        if(that.file.type == 'edit') { action = 'update' }
        if(that.file.type == 'delete') { action = 'delete' }

        $.ajax({
          type: 'post',
          url: `/api/v2/account/file_backup/${action}`,  
          contentType: 'application/json',
          dataType: 'json',
          processData: false,
          data: JSON.stringify({file: file})
        }).done(function(res, status, xhr) {
          window.App.addSuccessNotify(res.message)
          $("#newOrEditModal").modal('hide')
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
    },
  }
})