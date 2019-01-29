new Vue({
  el: '#appVue',
  data: function() {
    return { 
      screenHeight: document.documentElement.clientHeight - 150,
      record: {},
      sideMenus: [
        {label: '基本信息', id: 'basic'},
        {label: '设备信息', id: 'device'},
        {label: '服务状态', id: 'service'},
        {label: '备份状态', id: 'backup'},
        {label: 'SSH 信息', id: 'ssh'}
      ],
      currentSideMenu: {},
      file_backups: [],
      modal: {
        title: '标题',
        body: '加载中...',
      }
    }
  },
  created() {
    this.getRecord()

    let menuId = window.localStorage.getItem('device.show.menu.id'),
        menuIndex = 0;
    if(menuId && [].findIndex) { menuIndex = this.sideMenus.findIndex(function(menu) { return menu.id == menuId; }) }
    if(menuIndex < 0 || menuIndex >= this.sideMenus.length) { menuIndex = 0; }
    this.currentSideMenu = this.sideMenus[menuIndex]
  },
  methods: {
    clickSideMenu(menu) {
      this.currentSideMenu = menu
      window.localStorage.setItem('device.show.menu.id', menu.id)
    },
    getRecord() {
      let that = this,
          uuid = window.location.pathname.split('/').reverse()[0],
          data, file_backups;
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: `/api/v2/account/device/query?uuid=${uuid}`,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          data = res.data
          window.App.addSuccessNotify(res.message)
          try {
            file_backups = JSON.parse(data.file_backup_monitor)
            that.file_backups = Object.keys(file_backups).map(function(key) { return file_backups[key]; })

            data.file_backup_config = data.file_backup_config
            data.file_backup_monitor = data.file_backup_monitor
            data.service_config = data.service_config 
            
            let table = JSON.parse(data.service_monitor)
            table.widths = ['30%', '20%', '10%', '10%', '30%'],
            data.service_monitor = table
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
    },
    displayModal(type) {
      $("#infoModal").modal('show')
      if(type == 'backupConfig') {
        this.modal.title = '备份服务配置档'
        this.modal.body = JSON.stringify(JSON.parse(this.record.file_backup_config), null, 4)
      } else if(type == 'backupOutput') {
        this.modal.title = '备份状态'
        this.modal.body = JSON.stringify(JSON.parse(this.record.file_backup_monitor), null, 4)
      } else if(type == 'serviceConfig') {
        this.modal.title = '监控服务配置档'
        this.modal.body = JSON.stringify(JSON.parse(this.record.service_config), null, 4)
      }
    },
    getBackupFile(type, device_uuid, file_uuid, archive_file_name, file_path) {
      let that = this,
          url = `/api/v2/account/file_backup/${type}?device_uuid=${device_uuid}&file_uuid=${file_uuid}&archive_file_name=${archive_file_name}`;
      
      if(type == 'download') {
        window.open(url, 'blank')
        return false
      }
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: url,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        that.modal.title = file_path
        that.modal.body = res.code == 200 ? res.data : res.message
        $("#infoModal").modal('show')
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
  }
})