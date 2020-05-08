new Vue({
  el: '#appVue',
  data: function() {
    return { 
      app: {},
      action: null,
      data: {},
      md5: null,
      support_types: 'png',
      images: []
    }
  },
  created() {
    this.action = '/api/v2/account/image/upload'
    this.data = {}
    this.getImageList()
  },
  methods: {
    getImageList() {
      let that = this;
      window.Loading.show("获取数据中...");
      $.ajax({
        type: 'get',
        url: '/api/v2/account/image/list',
        contentType: 'application/json'
      }).done(function(res, status, xhr) {
        console.log(res)
        if(res.code === 200) {
          that.images = res.data
        } else {
          window.App.addDangerNotify(res.message)
        }
        setTimeout(() => {
          $("img.img-lazy-load").lazyload({ 
          　　effect : "fadeIn", 
          　　threshold : 180,
          　　event: 'scroll',
          　　container: $("#container"),
          　　failure_limit: 2 
          });
        }, 1000)
      }).fail(function(xhr, status, error) {
      }).always(function(res, status, xhr) {
        window.Loading.hide();
      });
    },
    uploadOnPreview(file) {
      console.log('file', file)
    },
    uploadOnError(err, file, fileList) {
      console.log('uploadOnError', err, file, fileList)
    },
    uploadOnSuccess(response, file, fileList) {
      console.log('uploadOnSuccess', response, file, fileList)
      console.log(fileList[0].raw)
      if(response.code == 201) {
        this.caculateFileMd5(fileList[0].raw, response.data)
        this.getImageList()
      } else {
        window.Loading.popup('上传失败，' + response.message)
      }
    },
    uploadOnChange(file, fileList) {
      console.log('uploadOnChange', file, fileList)
    },
    caculateFileMd5(file, redirectUrl) {
      var blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice,
          chunkSize = 2097152,                             // Read in chunks of 2MB
          chunks = Math.ceil(file.size / chunkSize),
          currentChunk = 0,
          spark = new SparkMD5.ArrayBuffer(),
          fileReader = new FileReader(),
          that = this;

      window.Loading.show('计算文件哈希...')
      fileReader.onload = function (e) {
          console.log('read chunk nr', currentChunk + 1, 'of', chunks);
          spark.append(e.target.result);                   // Append array buffer
          currentChunk++;

          if (currentChunk < chunks) {
              loadNext();
          } else {
              that.md5 = spark.end()
              window.Loading.hide()
              console.log('finished loading');
              console.info('computed hash', that.md5);  // Compute hash
          }
      };

      fileReader.onerror = function () {
          console.warn('oops, something went wrong.');
      };

      function loadNext() {
        var start = currentChunk * chunkSize,
            end = ((start + chunkSize) >= file.size) ? file.size : start + chunkSize;

        fileReader.readAsArrayBuffer(blobSlice.call(file, start, end));
      }

      loadNext();
    },
    copyOnSuccess: function (e) {
      window.Loading.popup('拷贝成功！')
    },
    copyOnError: function (e) {
      alert('Failed to copy texts')
    },
    copyImageUrl(item) {
      return `![${item.origin_file_name}](http://localhost:4567/images/documents/${item.file_name})`
    }
  }
})