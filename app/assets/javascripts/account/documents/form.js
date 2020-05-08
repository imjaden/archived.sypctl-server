var editor;
var markdownStyle = "摘自: [markdown-写作规范](https://github.com/carwin/markdown-styleguide) \n\
\n\
# markdown 写作规范格指南\n\
\n\
## 目的\n\
\n\
1. 统一内部工作日志等 markdown 写作规范。\n\
2. 为了提高内部 markdown 文本的可读性、统一性。\n\
\n\
## 基本约束\n\
\n\
- 每行字数限制在 80 个以内。\n\
- ~~表示换行时，强制使用两个或两个以上的空格。~~\n\
- 表示 **我黑** 样式时，使用星号表达式: `**我黑**`。\n\
- 表示 _我倒_ 样式，时使用下划线表达式: `_我倒_`。\n\
\n\
## 标题\n\
\n\
- 标题内容文本使用非闭合的 `# ` 字符表达式。\n\
- `#` 与标题内容间使用一个空格。\n\
\n\
    ```\n\
    # 标题一\n\
    ## 标题二\n\
    ### 标题三\n\
    ```\n\
\n\
- 标题内容超出 80 个字数时，需要重新设计。\n\
- 除在文档开头外，标题内容前后都需用空行隔开。\n\
\n\
## 水平分隔符\n\
\n\
水平分隔符约定使用 `-` 符（而非 `*` 或 `_`），`-` 数量在 3 - 80 之间。\n\
\n\
```\n\
------\n\
```\n\
\n\
## 列表\n\
\n\
- **列表项** 约定相对父级使用 4 个空格缩进。\n\
- 无序列表使用 `-`。\n\
\n\
    ```\n\
    这是一段随笔，下面的无序列表需要间隔一行。\n\
\n\
        - 无序列表项一 \n\
        - 无序列表项二 \n\
            - 子列表项 \n\
    ```\n\
\n\
- 一级列表块前后必须空一行。\n\
- 子列表块与父列表项无空行。\n\
\n\
    ```\n\
    处理列表的一些注意事项。\n\
\n\
            - 列表项一\n\
            - 列表项二\n\
                1. 子列表项一\n\
                2. 子列表项二\n\
\n\
            - 列表项三\n\
            - 列表项四\n\
\n\
    子列表后面的任何文字都需要与之间隔一行。\n\
    ```\n\
\n\
- 列表项内容超出 80 字时，相对该列表项开头垂直缩进（省略 80 个字）\n\
对齐即可。（注：渲染的结果会在新行与结束之间添加一个空格）\n\
\n\
    ```\n\
        - (省略 80 个字）继\n\
        续唠嗑\n\
    ```\n\
\n\
## 代码\n\
\n\
- **内联代码** 使用单反引号括起来，内容与单反引号之间没有空格。\n\
\n\
    ```\n\
    # 扔砖\n\
    ` 有空格-不紧凑 `\n\
\n\
    # 鼓励\n\
    `这样写-很舒服`\n\
    ```\n\
\n\
- **代码块** 前后都需要空行隔开。\n\
- 在 _列表项_ 内，**代码块** 相对父级列表项缩进 4 个空格。\n\
\n\
    ```\n\
    - 本列表会包含代码块\n\
    - 下面来展示如何让代码块看起来是列表项子级。\n\
\n\
        ```\n\
        .code-example {\n\
            property: value;\n\
        }\n\
        ```\n\
\n\
    本段落前面的空格，不仅因为在列表之后，也是因为在代码块之后。\n\
    ```\n\
\n\
## 字母、数字、特殊符号\n\
\n\
中文与字母、数字及特殊符号之间用空格隔开，这样阅读体验更佳。\n\
\n\
比如:\n\
\n\
住在美国的英国人 “屠腾罕” 发起拒说 “awesome 运动”, 这件事本身就很 awesome。";
(function() {
  $(function() {
    // marked
    var markedRender = new marked.Renderer();
    marked.setOptions({
      renderer: markedRender,
      gfm: true,
      tables: true,
      breaks: true,  // '>' 换行，回车换成 <br>
      pedantic: false,
      sanitize: true,
      smartLists: true,
      smartypants: false
    });

    // codemirror editor
    editor = CodeMirror.fromTextArea(document.getElementById('hash_content'), {
      height: "550px",
      width: "400px",
      mode: 'markdown',
      lineNumbers: true,
      autoCloseBrackets: true,
      matchBrackets: true,
      showCursorWhenSelecting: true,
      lineWrapping: true,  // 长句子折行
      theme: "material",
      keyMap: 'sublime',
      extraKeys: {"Enter": "newlineAndIndentContinueMarkdownList"}
    });
    console.log("editor01", editor)
  });
})()

new Vue({
  el: '#appVue',
  data: function() {
    return {
      screenHeight: document.documentElement.clientHeight - 150,
      uuid: '',
      groups: [],
      groupUuid: '',
      title: '',
      content: '',
      html: '',
      tags: '',
      formAction: '',
    }
  },
  created() {
    const that = this
    that.formAction = ('/account/documents/new' === window.location.pathname ? 'create' : 'update')

    that.queryGroupAction()
    if(that.formAction === 'update') {
      that.uuid = window.App.params()['uuid']
      if(!that.uuid) { 
        alert("获取 UUID 失败") 
        return false
      }
      that.queryDocumentAction()
    } else {
      setTimeout(() => {
        editor.on('change', that.editorOnChange);
        editor.getDoc().setValue(markdownStyle)
      }, 500)
    }
  },
  methods: {
    editorOnChange(cm, co) {
      this.content = cm.getValue()
      this.html = marked(cm.getValue())
      $('.markdown-body').html(this.html);
      $('.markdown-body pre code').each(function(i, block) {
        Prism.highlightElement(block);
      });
    },
    btnClickHandler() {
      let that = this;
      if(!that.title.length) {
        window.Loading.popup("请填写标题");
        return false
      }
      if(!that.content.length) {
        window.Loading.popup("请填写内容");
        return false
      }
      if(!that.tags.length) {
        window.Loading.popup("请选择文档属性");
        return false
      }
      
      let api = that.formAction === 'create' ? '/api/v2/account/document/create' : `/api/v2/account/document/update?uuid=${that.uuid}`;
      let type = that.formAction === 'create' ? 'post' : 'put'
      window.Loading.show("处理中...");
      $.ajax({
        type: type,    
        cache: false,
        dataType: 'json',
        url: api,
        contentType: 'application/json',
        data: JSON.stringify({
          document: {
            group_uuid: that.groupUuid,
            title: that.title,
            content: that.content,
            html: that.html,
            tags: that.tags
          }
        })
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          window.location.href = '/account/documents'
        } else {
          window.App.addDangerNotify(res.message)
        }
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    queryGroupAction() {
      let that = this;
      window.Loading.show("处理中...");
      $.ajax({
        type: 'get',
        url: '/api/v2/account/document_group/list',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        if(res.code !== 200) {
          console.error(res.data)
          return
        }

        that.groups = res.data // .map((item) => { return [item.uuid, item.title] })
        if(that.groupUuid) {
          return
        }
        let cacheMenuUuid = window.localStorage.getItem('document-index.menu-uuid')
        if(cacheMenuUuid) { 
          that.groupUuid = cacheMenuUuid
          return
        }
        if(that.groups.length) {
          that.groupUuid = that.groups[0].uuid
        }
        console.log('that.groups', that.groups)
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    queryDocumentAction() {
      let that = this;
      window.Loading.show("处理中...");
      $.ajax({
        type: 'get',
        url: `/api/v2/account/document/query?uuid=${that.uuid}`,
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        if(res.code !== 200) {
          console.error(res.data)
          return
        }

        that.groupUuid = res.data.group_uuid
        that.title = res.data.title
        that.content = res.data.content
        that.tags = res.data.tags

        editor.on('change', that.editorOnChange);
        editor.getDoc().setValue(that.content)
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    }
  }
});
