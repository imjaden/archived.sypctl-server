new Vue({
  el: '#appVue',
  data: function() {
    return { 
      record: {},
      sideMenus: [
        {label: '基本信息', id: 'basic'},
        {label: '设备信息', id: 'device'},
        {label: '服务状态', id: 'service'},
        {label: '备份状态', id: 'backup'},
        {label: 'SSH 信息', id: 'ssh'}
      ],
      currentSideMenu: {},
      file_backups: []
    }
  },
  created() {
    this.getRecord()
    this.currentSideMenu = this.sideMenus[0]
  },
  methods: {
    clickSideMenu(menu) {
      this.currentSideMenu = menu
    },
    getRecord() {
      let that = this,
          uuid = window.location.pathname.split('/').reverse()[0],
          data, file_backups;
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: '/api/v2/account/device/query?uuid=' + uuid,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          data = res.data
          window.App.addSuccessNotify(res.message)
          try {
            file_backups = JSON.parse(data.file_backup_monitor)
            that.file_backups = Object.keys(file_backups).map(function(key) { return file_backups[key]; })

            data.file_backup_config = JSON.stringify(JSON.parse(data.file_backup_config), null, 4)
            data.file_backup_monitor = JSON.stringify(JSON.parse(data.file_backup_monitor), null, 4)
            data.service_config = JSON.stringify(JSON.parse(data.service_config), null, 4)
            data.service_monitor = JSON.stringify(JSON.parse(data.service_monitor), null, 4)
            console.log(data)
            console.log(that.file_backups)
          } catch(e) {
            console.log(e)
          }
          that.record = res.data
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    deleteClick() {
      if(!confirm('确定删除「' + this.record.human_name + '」?')) {
        return false;
      }

      let that = this,
          uuid = window.location.pathname.split('/').reverse()[0];
      window.Loading.show("删除中...");
      $.ajax({
        type: 'delete',
        url: '/account/devices/' + uuid,
      }).done(function(res, status, xhr) {
        if(res.code === 201) {
          window.Loading.show("删除成功");

          try {
            var objects = {device: { id: that.record.id, name: that.record.human_name }}
            window.OperationLogger.record("device.delete", objects);
          } catch(e) { console.log(e) }

          window.location.href = '/account/devices'
        } else {
          window.Loading.show("删除失败");
        }
      }).fail(function(xhr, status, error) {
          window.Loading.show("删除失败");
      }).always(function(res, status, xhr) {
          window.Loading.hide();
      });
    }
  }
})