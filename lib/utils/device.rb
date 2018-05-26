# encoding: utf-8
require 'json'
require 'securerandom'

module Utils
  # development mode
  class Darwin
    class << self
      def device_uuid
        "random-#{SecureRandom.uuid}"
      end

      def memory
        'darwin'
      end

      def cpu
        'darwin'
      end

      def disk
        'darwin'
      end

      def hostname
        `hostname`.strip
      end

      def os_type
        `uname -s`.strip
      end

      def os_version
        0
      end

      def free_m
        {"total"=>"32011", "used"=>"10976", "free"=>"20174", "shared"=>"24", "buff/cache"=>"861", "available"=>"20338"}
      end

      def df_h
        [{"Filesystem":"/dev/mapper/centos_java1-root","Size":"50G","Used":"567M","Avail":"50G","Use%":"2%","MountedOn":"/"},{"Filesystem":"devtmpfs","Size":"16G","Used":"0","Avail":"16G","Use%":"0%","MountedOn":"/dev"},{"Filesystem":"tmpfs","Size":"16G","Used":"0","Avail":"16G","Use%":"0%","MountedOn":"/dev/shm"},{"Filesystem":"tmpfs","Size":"16G","Used":"25M","Avail":"16G","Use%":"1%","MountedOn":"/run"},{"Filesystem":"tmpfs","Size":"16G","Used":"0","Avail":"16G","Use%":"0%","MountedOn":"/sys/fs/cgroup"},{"Filesystem":"/dev/mapper/centos_java1-usr","Size":"100G","Used":"3.1G","Avail":"97G","Use%":"4%","MountedOn":"/usr"},{"Filesystem":"/dev/sda1","Size":"1014M","Used":"167M","Avail":"848M","Use%":"17%","MountedOn":"/boot"},{"Filesystem":"/dev/mapper/centos_java1-tmp","Size":"10G","Used":"33M","Avail":"10G","Use%":"1%","MountedOn":"/tmp"},{"Filesystem":"/dev/mapper/centos_java1-opt","Size":"10G","Used":"67M","Avail":"10G","Use%":"1%","MountedOn":"/opt"},{"Filesystem":"/dev/mapper/centos_java1-home","Size":"100G","Used":"33M","Avail":"100G","Use%":"1%","MountedOn":"/home"},{"Filesystem":"/dev/mapper/centos_java1-data","Size":"600G","Used":"35M","Avail":"600G","Use%":"1%","MountedOn":"/data"},{"Filesystem":"/dev/mapper/centos_java1-var","Size":"100G","Used":"1.4G","Avail":"99G","Use%":"2%","MountedOn":"/var"},{"Filesystem":"tmpfs","Size":"3.2G","Used":"0","Avail":"3.2G","Use%":"0%","MountedOn":"/run/user/0"}]
      end
    end
  end

  class Linux
    class << self
      # $ blkid -s UUID
      # /dev/mapper/centos_java1-var: UUID="f3a814b5-6fe3-4ecf-a53f-799520c7f932"
      # /dev/sda2: UUID="qAaXeF-RwkI-2qX8-MbUJ-CCCd-2Ta6-3GfEM8"
      # /dev/mapper/centos_java1-root: UUID="a1cae138-52d3-41e9-bfce-fcb466e32e93"
      # /dev/mapper/centos_java1-usr: UUID="7b13ba37-7cfd-4fdb-b4ce-f6a8e6cd7c30"
      # /dev/sda1: UUID="310d9b14-9a2d-415a-b6a8-e8c72facec5c"
      # /dev/mapper/centos_java1-swap: UUID="3d19a3b6-dde5-420a-a0b5-f4de1e90d42b"
      # /dev/mapper/centos_java1-data: UUID="ac3b2ef2-d3a0-458f-89ce-605f8c0afb81"
      # /dev/mapper/centos_java1-tmp: UUID="4d690f04-c4cd-4e29-be86-d4cd46e9e385"
      # /dev/mapper/centos_java1-opt: UUID="8f7236ea-97ef-4aa9-886f-9e1a50a030a1"
      # /dev/mapper/centos_java1-home: UUID="bae67bdc-1ff5-477f-ba08-11f02d2a00d2"
      def device_uuid
        _device_uuid(`blkid -s UUID`)
      end

      def _device_uuid(blkid_lines)
        device_list = blkid_lines.split(/\n/).map do |line|
           device, uuid = line.scan(/(.*?):\sUUID="(.*?)"/).flatten
           {device: device, uuid: uuid}
        end
        device_hsh, i = nil, 0

        while !device_hsh && i < 10
          device_hsh = device_list.find { |hsh| hsh[:device] == "/dev/sda#{i}" || hsh[:device] == "/dev/xvda#{i}" }
          i += 1
        end
        device_hsh = device_list.first unless device_hsh

        "#{device_hsh[:device]}-#{device_hsh[:uuid]}".gsub("/", "_")
      rescue
        "random-#{SecureRandom.uuid}"
      end

      def memory
        free_m['total']
      end

      def cpu
        'todo'
      end

      def device_disk
        'todo'
      end

      def hostname
        `hostname`.strip
      end

      def os_type
        `lsb_release -i | awk '{ print $3 }'`.strip
      end

      def os_version
        `lsb_release -r | awk '{ print $2 }' | awk -F . '{print $1 }'`.strip
      end

      # $ free -m
      #               total        used        free      shared  buff/cache   available
      # Mem:          32011       11120       20030          24         860       20193
      # Swap:         32767           1       32766
      def free_m
        titles, memory, *swap = `free -m`.split("\n").map { |line| line.split(/\s+/) }
        titles.shift if titles[0].empty?
        memory.shift while titles.length < memory.length

        titles.each_with_object({}).with_index do |(title, hsh), index|
          hsh[title] = memory[index]
        end
      end

      # $ df -h
      # Filesystem                     Size  Used Avail Use% Mounted on
      # /dev/mapper/centos_java1-root   50G  567M   50G   2% /
      # devtmpfs                        16G     0   16G   0% /dev
      # tmpfs                           16G     0   16G   0% /dev/shm
      # tmpfs                           16G   25M   16G   1% /run
      # tmpfs                           16G     0   16G   0% /sys/fs/cgroup
      # /dev/mapper/centos_java1-usr   100G  3.1G   97G   4% /usr
      # /dev/sda1                     1014M  167M  848M  17% /boot
      # /dev/mapper/centos_java1-tmp    10G   33M   10G   1% /tmp
      # /dev/mapper/centos_java1-opt    10G   67M   10G   1% /opt
      # /dev/mapper/centos_java1-home  100G   33M  100G   1% /home
      # /dev/mapper/centos_java1-data  600G   35M  600G   1% /data
      # /dev/mapper/centos_java1-var   100G  1.4G   99G   2% /var
      # tmpfs                          3.2G     0  3.2G   0% /run/user/0
      def df_h
        titles, *disks = `df -h`.sub("Mounted on", "MountedOn").split("\n").map { |line| line.split(/\s+/) }
        disks.map do |disk|
          titles.each_with_object({}).with_index do |(title, hsh), index|
            hsh[title] = disk[index]
          end
        end
      end
    end
  end

  class Device
    class << self

      def klass
        platform = `uname -s`.strip
        ['Utils', platform].inject(Object) { |obj, klass| obj.const_get(klass) }
      end

      def uuid
        uuid_tmp_path = File.join(ENV["RAKE_ROOT_PATH"] || Dir.pwd, ".device-uuid")
        unless File.exists?(uuid_tmp_path)
          File.open(uuid_tmp_path, "w:utf-8") { |file| file.puts(klass.device_uuid) }
        end
        File.read(uuid_tmp_path).strip
      end

      def memory
        klass.memory
      rescue => e
        e.message
      end

      def cpu
        klass.cpu
      rescue => e
        e.message
      end

      def disk
        klass.disk
      rescue => e
        e.message
      end

      def hostname
        klass.hostname
      rescue => e
        e.message
      end

      def os_type
        klass.os_type
      rescue => e
        e.message
      end

      def os_version
        klass.os_version
      rescue => e
        e.message
      end

      def memory_usage
        hsh = memory_usage_description
        (hsh['used'].to_f/hsh['total'].to_f*100).round(2)
      rescue => e
        e.message
      end

      def memory_usage_description
        klass.free_m
      rescue => e
        e.message
      end

      def cpu_usage
        'todo'
      end

      def cpu_usage_description
        'todo'
      end

      def disk_usage
        arr = disk_usage_description
        disk_monitor = ENV['DISK_MONITOR'] || '/'
        item = arr.find { |hsh| (hsh[:MountedOn] || hsh['MountedOn']) == disk_monitor }
        item = arr.find { |hsh| (hsh[:MountedOn] || hsh['MountedOn']) == '/home' } unless item
        item = arr.find { |hsh| (hsh[:MountedOn] || hsh['MountedOn']) == '/data' } unless item

        item[:'Use%'] || item['Use%']
      rescue => e
        e.message
      end

      def disk_usage_description
        klass.df_h
      rescue => e
        e.message
      end
    end
  end
end