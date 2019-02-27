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
        {label: '文档备份', id: 'file_backup'},
        {label: '代理行为', id: 'behavior_log'},
        {label: 'SSH 信息', id: 'ssh'}
      ],
      currentSideMenu: {},
      file_backups: [],
      file_backups_not_exist: [],
      behavior_logs: [],
      modal: {
        title: '标题',
        body: '加载中...',
      }
    }
  },
  created() {
    this.getRecord(() => {
      let menuId = window.localStorage.getItem('device.show.menu.id'),
          menuIndex = 0;
      if(menuId && [].findIndex) { menuIndex = this.sideMenus.findIndex(function(menu) { return menu.id == menuId; }) }
      if(menuIndex < 0 || menuIndex >= this.sideMenus.length) { menuIndex = 0; }
      this.currentSideMenu = this.sideMenus[menuIndex]
      if(this.currentSideMenu.id == 'behavior_log') {
        this.getAgentBehaviorLogs()
      }
    })
  },
  methods: {
    clickSideMenu(menu) {
      this.currentSideMenu = menu
      window.localStorage.setItem('device.show.menu.id', menu.id)
      if(this.currentSideMenu.id == 'behavior_log') {
        this.getAgentBehaviorLogs()
      }
    },
    getRecord(callback) {
      let that = this,
          uuid = window.location.pathname.split('/').reverse()[0],
          data, service_monitor, file_backups, file_backups_keys, array;
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

          // data.file_backup_config = data.file_backup_config
          // data.file_backup_monitor = data.file_backup_monitor
          // data.service_config = data.service_config

          try {
            array = []
            file_backups = JSON.parse(data.file_backup_monitor)
            file_backups_keys = Object.keys(file_backups)
            file_backups_keys.forEach(function(key) {
              if(file_backups[key]['file_list']) {
                Object.keys(file_backups[key]['file_list']).forEach(function(k) {
                  file_backups[key]['file_list'][k]['uuid'] = file_backups[key]['uuid']
                  file_backups[key]['file_list'][k]['file_path'] = file_backups[key]['file_path'] + '/' + k
                  array.push(file_backups[key]['file_list'][k])
                })
              } else {
                 array.push(file_backups[key])
              } 
            })
            that.file_backups = array.sort((a, b) => { return (b['file_mtime'] || 0) - (a['file_mtime'] || 0); })
            that.file_backups_not_exist = JSON.parse(data.file_backup_config).filter(function(item) { return file_backups_keys.indexOf(item.uuid) < 0;})

            service_monitor = JSON.parse(data.service_monitor)
            service_monitor.widths = ['30%', '20%', '10%', '10%', '30%'],
            data.service_monitor = service_monitor
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
        if(callback) {
          callback()
        }
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
        this.modal.title = '备份配置档'
        this.modal.body = JSON.stringify(JSON.parse(this.record.file_backup_config), null, 4)
      } else if(type == 'backupOutput') {
        this.modal.title = '备份状态'
        this.modal.body = JSON.stringify(JSON.parse(this.record.file_backup_monitor), null, 4)
      } else if(type == 'serviceConfig') {
        this.modal.title = '监控配置档'
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
    getAgentBehaviorLogs() {
      let that = this,
          url = `/api/v2/account/agent_behavior_log/list?device_uuid=${that.record.uuid}`;
      
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: url,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        that.$nextTick(() => {
          that.behavior_logs = res.data
        })

      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    formatDate(timestamp) {
      try {
        if(!timestamp || String(timestamp).length != 10) { return '-' }
        let date = new Date(parseInt(timestamp) * 1000),
            y = date.getFullYear(),
            MM = date.getMonth() + 1,
            d = date.getDate(),
            h = date.getHours(),
            m = date.getMinutes(),
            s = date.getSeconds();

        MM = MM < 10 ? ('0' + MM) : MM;
        d = d < 10 ? ('0' + d) : d;
        h = h < 10 ? ('0' + h) : h;
        m = m < 10 ? ('0' + m) : m;
        s = s < 10 ? ('0' + s) : s;
        return y + '/' + MM + '/' + d + ' ' + h + ':' + m + ':' + s;
      } catch(e) {
        console.log(e)
        return timestamp
      }
    }
  }
})