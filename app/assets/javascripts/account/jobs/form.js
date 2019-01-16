new Vue({
  el: '#jobForm',
  data: function() {
    return { 
      record: {},
      job: null,
      showJobTemplates: true,
      jobTemplates: [],
      jobTemplate: null,
      showDevices: false,
      deviceCheckedList: [],
      devices: [],
      showApps: false,
      apps: [],
      app: null,
      showVersions: false,
      versions: [],
      version: null,
      latest_version: null
    }
  },
  created() {
    let params = window.Param.parse()
    if(params.copy_from) {
      this.copyJobGroup(params.copy_from)
    } else {
      this.initJobGroup()
    }
    this.listJobTemplates(0)
  },
  watch: {
    deviceCheckedList(now, old) {
      console.log('deviceCheckedList:', now)
      let deviceList = [], 
          deviceNames = [];

      now.forEach((item) => {
        deviceList.push({name: item.human_name, uuid: item.uuid})
        deviceNames.push('<' + item.human_name + '>')
      })
      this.record.device_name = deviceNames.join(',')
      this.record.device_list = JSON.stringify(deviceList)
    }
  },
  methods: {
    initJobGroup() {
      window.Loading.show('获取数据中...')
      let that = this
      $.ajax({
        method: 'get',
        url: '/api/v2/account/job_group/new',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        that.record = res.data
        that.record.job_templates = []
      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    copyJobGroup(uuid) {
      window.Loading.show('获取数据中...')
      let that = this
      $.ajax({
        method: 'get',
        url: `/api/v2/account/job_group/copy?uuid=${uuid}`,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        that.record = res.data
        that.record.job_templates = []
      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    checkForm(el) {
      console.log(el)
      let isOk = false
      if(!this.record.title) {
        window.Loading.popup('请选择模板')
      } else if(!this.record.device_list) {
        window.Loading.popup('请选择设备')
      } else if(!this.record.command) {
        window.Loading.popup('请选择有效模板')
      } else {
        isOk = true
      }

      if(isOk) {
        /*
         * 记录模板、设备信息至浏览器缓存, 根据历史操作权重调整列表排序
         * 以此改善用户使用体验
         */
        try {
          let ue = window.localStorage.getItem('_ue_create_job'),
              ueObj = {},
              tmp;
          if(ue) { ueObj = JSON.parse(ue) }

          ueObj['devices'] = ueObj['devices'] || {}
          JSON.parse(this.record.device_list).forEach(function(device) {
            if(ueObj['devices'][device.uuid]) {
              ueObj['devices'][device.uuid] = parseInt(ueObj['devices'][device.uuid]) + 1
            } else {
              ueObj['devices'][device.uuid] = 1
            }
          })

          ueObj['job_templates'] = ueObj['job_templates'] || {}
          if(ueObj['job_templates'][this.jobTemplate.uuid]) {
            ueObj['job_templates'][this.jobTemplate.uuid] = parseInt(ueObj['job_templates'][this.jobTemplate.uuid]) + 1
          } else {
            ueObj['job_templates'][this.jobTemplate.uuid] = 1
          }

          window.localStorage.setItem('_ue_create_job', JSON.stringify(ueObj))
        } catch(e) {
          console.log(e)
        }
        
        return true
      } else {
        el.preventDefault();
      }
    },
    jobTemplateRadioClick(item) {
      this.jobTemplate = item
      let content = item.content
      if(item.content && item.content.length) {
        command = item.content.split("\n").map(function(el) {
          return $.trim(el);
        }).join("\n");
      }

      this.record.title = item.title
      this.record.command = content
      this.renderCommand(false)
    },
    jobTemplatesChange() {
      console.log(this.record.title)
    },
    listJobTemplates(page) {
      let that = this
      that.showJobTemplates = true
      that.showDevices = false
      that.showApps = false
      that.showVersions = false

      window.Loading.show('获取数据中...')
      $.ajax({
        method: 'get',
        url: '/api/v1/job_templates',
        contentType: 'application/json',
        data: {page: page, page_size: 100}
      }).done(function(res, status, xhr) {
        let ue = window.localStorage.getItem('_ue_create_job'),
            ueObj = {};
        if(ue) { ueObj = JSON.parse(ue) }
        ueObj['job_templates'] = ueObj['job_templates'] || {}

        that.jobTemplates = res.data.map((item) => {
            item.__ue_weight = ueObj['job_templates'][item.uuid] || 0
            return item
          }).sort((a, b) => {
            return b.__ue_weight - a.__ue_weight
          })

      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    listDevices(page) {
      let that = this
      that.showJobTemplates = false
      that.showDevices = true
      that.showApps = false
      that.showVersions = false

      window.Loading.show('获取数据中...')
      $.ajax({
        method: 'get',
        url: '/api/v1/devices',
        contentType: 'application/json',
        data: {page: page, page_size: 100}
      }).done(function(res, status, xhr) {
        let ue = window.localStorage.getItem('_ue_create_job'),
            ueObj = {};
        if(ue) { ueObj = JSON.parse(ue) }
        ueObj['devices'] = ueObj['devices'] || {}

        that.devices = res.data.map((item) => {
            item.__ue_weight = ueObj['devices'][item.uuid] || 0
            return item
          }).sort((a, b) => {
            return b.__ue_weight - a.__ue_weight
          })
      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    appRadioClick(item) {
      this.app = item
      this.record.app_id = item.id
      this.record.app_name = item.name
      this.record.app_uuid = item.uuid
      this.renderCommand(false)
    },
    listApps(page) {
      let that = this
      that.showJobTemplates = false
      that.showDevices = false
      that.showApps = true
      that.showVersions = false

      window.Loading.show('获取数据中...')
      $.ajax({
        method: 'get',
        url: '/api/v1/apps',
        contentType: 'application/json',
        data: {page: page, page_size: 100}
      }).done(function(res, status, xhr) {
        if(that.jobTemplate) {
          that.apps = res.data.filter(function(item) {
            return item.file_type == that.jobTemplate.template_type
          })
          if(!that.apps.length) {
            window.Loading.popup('筛选匹配模板类型为' + that.jobTemplate.template_type + '的应用为空')
          }
        } else {
          that.apps = res.data
        }
      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    versionRadioClick(item) {
      this.version = item
      this.record.version_id = item.id
      this.record.version_name = item.version
      this.renderCommand(false)
    },
    listVersions(page) {
      if(!this.record.app_id) {
        window.Loading.popup("请选择应用")
        return false;
      }

      let that = this
      that.showJobTemplates = false
      that.showDevices = false
      that.showApps = false
      that.showVersions = true
      window.Loading.show('获取数据中...')
      $.ajax({
        method: 'get',
        url: '/api/v1/app/versions?uuid=' + that.record.app_uuid,
        contentType: 'application/json',
        data: {page: page, page_size: 100}
      }).done(function(res, status, xhr) {
        that.versions = res.data

      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    getAppLatestVersion(callback) {
      let that = this
      window.Loading.show('获取数据中...')
      $.ajax({
        method: 'get',
        url: '/api/v1/app/latest_version?uuid=' + that.app.latest_version_uuid,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        window.Loading.hide()
        if(res.code == 200) {
          that.latest_version = res.data
          that.app.latest_version = res.data
        } else {
          window.Loading.popup(res.message)
        }
        callback()
      }).fail(function(res, status, xhr) {
      }).always(function(res, status, xhr) {
        window.Loading.hide()
      });
    },
    renderCommand(isPopup) {
      if(!this.record.command) {
        if(isPopup) { window.Loading.popup("请选择部署模板") }
        console.log('WARNING: 请选择部署模板')
        return false;
      }

      let that = this
      let command = that.record.command,
          matchDatas = command.match(/\{\{(.*?)\}\}/g) || [],
          varObjs = {},
          klassObj = {},
          varText, klass, obj, parts, result;

      if(!matchDatas.length) {
        console.log('INFO:  部署模板脚本中无变量')
        return false
      }

      klassObj = matchDatas.reduce((result, data) => {
        varText = data.replace(/\{|\}|\s/g, '')
        result[varText] = true
        result[varText.split('.')[0]] = true
        if(varText.indexOf('app.latest_version') == 0) { result['app.latest_version'] = true }
        return result
      }, {})

      if(klassObj['app'] && !that.app) {
        if(isPopup) { window.Loading.popup("请选择应用") }
        console.log('WARNING: 请选择应用')
        return false;
      }
      if(klassObj['version'] && !that.version) {
        if(isPopup) { window.Loading.popup("请选择应用版本") }
        console.log('WARNING: 请选择应用版本')
        return false;
      }

      try {
        let callback = () => {
          matchDatas.forEach((data) => {
            varText = data.replace(/\{|\}|\s/g, '')
            if(!varObjs[varText]) {
              parts = varText.split('.')
              klass = parts.splice(0, 1)[0]
              obj = (klass == 'app' ? that.app : that.version)
              parts.forEach((part, inx) => {
                obj = obj[part] 
              })
              varObjs[varText] = obj
              command = command.replace(new RegExp(data, 'g'), JSON.stringify(obj))
            }
            console.log(varText + ':', varObjs[varText])
          })
          that.record.command = command
        }
        if(klassObj['app.latest_version']) {
          if(!that.app.latest_version_uuid) {
            window.Loading.popup('应用关联的最新版本为空')
            return false
          }
          that.getAppLatestVersion(callback)
        } else {
          callback()
        }
      } catch(e) {
        console.log('渲染部署脚本异常:', e)
      }
    }
  }
})
