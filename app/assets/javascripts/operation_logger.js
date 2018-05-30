window.OperationLogger = {
  templates: window.OperationLoggerTemplates || {},
  objects: {},
  template: "",
  modifier: function(string) {
    var parts = string.split("."),
        property = {};
    for(var i = 0, len = parts.length; i < len; i ++) {
        property[i === 0 ? 'model' : parts[i]] = parts[i];
    }
    if(!property.text) { property.link = true; }

    return property;
  },
  renderVariable: function(string) {
    var property = window.OperationLogger.modifier(string),
        objects = window.OperationLogger.objects,
        variable = objects[property.model],
        output = variable.name;
    if(property.at) { output = "@" + output; }
    if(property.strike) { output = "<strike>" + output + "</strike>"; }
    if(property.link) { output = "<a href='/notify/router?obj_type=" + variable.type + "&obj_id=" + variable.id + "&obj_name=" + variable.name + "'>" + output + "</a>"; }
    
    return output;
  },
  renderField: function(config) {
    var matchDatas = config.match(/\{\{(.*?)\}\}/g),
        varText;
    for(var i = 0, len = matchDatas.length; i < len; i ++) {
      varText = window.OperationLogger.renderVariable(matchDatas[i].replace(/\{|\}|\s/g, ''));
      config = config.replace(matchDatas[i], varText)
    }
    
    return config;
  },
  renderRecord: function(template) {
    var description =  window.OperationLogger.renderField(template),
        objects = window.OperationLogger.objects;

    $.ajax({
      type: "post",
      url: "/api/v1/operation/logger",
      data: {
        api_token: '25629ca6c97051ddf0128342b70f360b',
        operation_log: {
          operator: objects.operator.id,
          description: description,
          template: template,
          objects: JSON.stringify(objects),
          tags: window.OperationLogger.template || 'default'
        }
      }
    }).done(function(res, xhr, status) {
      console.log(res);
    }).fail(function(res, xhr, status) {
      console.log(res);
    }).always(function(res, xhr, status) {
    })
  },
  record: function(template, objects) {
    // try {
      if(!objects.operator && window.action_logger.operator) { objects.operator = window.action_logger.operator; }
      window.OperationLogger.template = template;
      
      var nodes = template.split("."),
          template = window.OperationLogger.templates;

      window.OperationLogger.objects = objects;
      for(var i = 0, len = nodes.length; i < len; i ++) {
        template = template[nodes[i]]
        if(!template) { throw("调用了不存在的日志模板：" + nodes.join(".")); }
      }
      window.OperationLogger.renderRecord(template);
    // } catch(e) { console.log(e) }
  }
}
