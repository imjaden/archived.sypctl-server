new Vue({
  el: '#appVue',
  data: function() {
    return { 
      screenHeight: document.documentElement.clientHeight - 150,
      menu: {},
      records: [],
      devices: []
    }
  },
  created() {
    this.getRecords()

  },
  methods: {
    clickSideMenu(menu) {
      this.menu = menu
      this.devices = menu.devices

      window.localStorage.setItem('device.index.menu.name', menu.name)
    },
    getRecords() {
      let that = this;
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: '/api/v2/account/device/list',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          that.records = res.data
          that.devices = res.data[0].devices


          let menuName = window.localStorage.getItem('device.index.menu.name'),
              menuIndex = 0;
          if(menuName && [].findIndex) { menuIndex = that.records.findIndex(function(menu) { return menu.name == menuName; }) }
          if(menuIndex < 0 || menuIndex >= that.records.length) { menuIndex = 0; }
          that.menu = that.records[menuIndex]
          that.devices = that.menu.devices
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    setMonitorState(device) {
      $.ajax({
        type: 'post',
        url: `/account/devices/monitor-state?id=${device.id}`
      }).done(function(res, status, xhr) {
          console.log(res);
        if(res.code === 201) {
          device.monitor_state = res.data
        } else {
          console.log(res);
        }
      }).fail(function(xhr, status, error) {
        console.log(xhr);
      }).always(function(res, status, xhr) {
        console.log(res);
      });
    },
    deleteDevice(device) {
      if(!confirm('确定删除「' + device.human_name + '」?')) {
        return false;
      }

      let that = this;
      window.Loading.show("删除中...");
      $.ajax({
        type: 'delete',
        url: `/account/devices/${device.uuid}`
      }).done(function(res, status, xhr) {
        if(res.code === 201) {
          window.Loading.show("删除成功");
          that.getRecords()
          try {
            var objects = {device: { id: device.id, name: `${device.human_name}(${that.menu.name})` }}
            window.OperationLogger.record("device.delete", objects);
          } catch(e) { console.log(e) }
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