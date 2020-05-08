new Vue({
  el: '#appVue',
  data: function() {
    return { 
      screenHeight: document.documentElement.clientHeight - 150,
      menu: {},
      records: [],
      documents: []
    }
  },
  created() {
    this.getRecords()
  },
  methods: {
    clickSideMenu(menu) {
      this.menu = menu
      this.documents = menu.documents

      window.localStorage.setItem('document-index.menu-uuid', menu.uuid)
    },
    getRecords() {
      let that = this;
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: '/api/v2/account/document/list',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          that.records = res.data
          that.documents = res.data[0].documents

          let menuUuid = window.localStorage.getItem('document-index.menu-uuid'),
              menuIndex = 0;
          if(menuUuid && [].findIndex) { menuIndex = that.records.findIndex(function(menu) { return menu.uuid == menuUuid; }) }
          if(menuIndex < 0 || menuIndex >= that.records.length) { menuIndex = 0; }
          that.menu = that.records[menuIndex]
          that.documents = that.menu.documents
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    deleteDevice(doc) {
      if(!confirm('确定删除「' + doc.title + '」?')) {
        return false;
      }

      let that = this;
      window.Loading.show("删除中...");
      $.ajax({
        type: 'delete',
        url: `/account/document/${doc.uuid}`
      }).done(function(res, status, xhr) {
        if(res.code === 201) {
          window.Loading.show("删除成功");
          that.getRecords()
          try {
            var objects = {document: { id: doc.id, name: `${doc.title}(${that.menu.name})` }}
            window.OperationLogger.record("document.delete", objects);
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