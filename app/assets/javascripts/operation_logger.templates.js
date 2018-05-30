window.OperationLoggerTemplates = {
  user: {
    login: "{{ user.at }} 登录系统",
    logout: "{{ user.at }} 登出系统"
  },
  device: {
    new: "{{ operator.at }} 创建了主机 {{ device.at.text }}",
    edit: "{{ operator.at }} 编辑了主机 {{ device.at }}",
    delete: "{{ operator.at }} 删除了主机  {{ device.at.text.strike }}"
  },
  device_group: {
    new: "{{ operator.at }} 创建了主机分组 {{ device_group.at.text }}",
    edit: "{{ operator.at }} 编辑了主机分组 {{ device_group.at }}",
    delete: "{{ operator.at }} 删除了主机分组 {{ device_group.at.text.strike }}",
    move_device_into: "{{ operator.at.link }} 把主机 {{ device.at }} 添加至分组 {{ device_group.at }}",
    move_device_out: "{{ operator.at }} 把主机 {{ device.at }} 从分组 {{ device_group.at }} 中移出"
  },
  app: {
    new: "{{ operator.at }} 创建了应用 {{ app.at.text }}",
    edit: "{{ operator.at }} 编辑了应用 {{ app.at }}",
    delete: "{{ operator.at }} 删除了应用 {{ app.at.text.strike }}",
    upload_version: "{{ operator.at }} 上传了应用 {{ app.at }} 版本 {{ version.at }}",
  },
  app_group: {
    new: "{{ operator.at }} 创建了应用分组 {{ app_group.at.text }}",
    edit: "{{ operator.at }} 编辑了应用分组 {{ app_group.at }}",
    delete: "{{ operator.at }} 删除了应用分组 {{ app_group.at.text.strike }}",
    move_device_into: "{{ operator.at.link }} 把应用 {{ app.at }} 添加至分组 {{ app_group.at }}",
    move_device_out: "{{ operator.at }} 把应用 {{ app.at }} 从分组 {{ app_group.at }} 中移出"
  },
  job: {
    new: "{{ operator.at }} 给主机 {{ device.at }} 分配了任务 {{ job.at }}",
    edit: "{{ operator.at }} 编辑了任务 {{ job.at }}",
    delete: "{{ operator.at }} 删除了任务  {{ job.at.text.strike }}"
  },
  job_template: {
    new: "{{ operator.at }} 创建了任务模板 {{ job_template.at.text }}",
    edit: "{{ operator.at }} 编辑了任务模板 {{ job_template.at }}",
    delete: "{{ operator.at }} 删除了任务模板 {{ job_template.at.text.strike }}"
  }
};