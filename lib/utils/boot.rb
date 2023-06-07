# encoding: utf-8
# Boot Assitant Methods

module Utils
  module Boot
    def traverser_settings_yaml_to_env
      root_path = ENV['APP_ROOT_PATH']
      settings_path = File.join(root_path, 'config/setting.yaml')
      settings_hash = YAML.load(IO.read(settings_path))
      settings_mtime = File.mtime(settings_path).to_i
      settings_json_path = File.join(root_path, "config/setting-#{ENV['RACK_ENV']}-#{settings_mtime}.json")
      unless File.exist?(settings_json_path)
        result_hash = {}
        _traverser_settings_yaml_to_env(result_hash, settings_hash[ENV['RACK_ENV']])
        File.open(settings_json_path, "w:utf-8") { |file| file.puts(result_hash.to_json) }
      end
      ENV['settings.json.path'] = settings_json_path
      json_obj = JSON.parse(File.read(settings_json_path))
      json_obj.each_pair do |key, value|
        ENV[key] = value
      end
    end

    def _traverser_settings_yaml_to_env(result_hash = {}, hsh = {}, ancestors_hash = {}, parent_item = nil)
      hsh.each_pair do |k, v|
        uuid = SecureRandom.uuid
        # puts "k: #{k}, parent: #{parent_item}, uuid: #{uuid}"
        ancestors_hash[uuid] = parent_item ? Marshal.load(Marshal.dump(ancestors_hash[parent_item])) : []
        ancestors_hash[uuid].push(k)
        if v.is_a?(Hash)
          _traverser_settings_yaml_to_env(result_hash, v, ancestors_hash, uuid)
        else
          result_hash[ancestors_hash[uuid].join(".")] = "#{v}"
          # puts "#{ancestors_hash[uuid].join(".")}:#{v}"
        end
      end
    end

    def recursion_require(dir_path, regexp, base_path = ENV['APP_ROOT_PATH'], sort_rules = [])
      dir_path_on_base = format('%s/%s', base_path, dir_path)
      partition = Dir.entries(dir_path_on_base)
                     .reject { |dir_name| %w(. ..).include?(dir_name) }
                     .partition { |dir_name| File.file?(%(#{dir_path_on_base}/#{dir_name})) }
      temp_files, temp_dirs = *partition

      unless sort_rules.empty?
        temp_files = sort_by_rules(temp_files, sort_rules)
      end
      temp_files.each do |dir_name|
        file_path = %(#{dir_path_on_base}/#{dir_name})
        warn_info = %(warning not match #{regexp.inspect} - #{file_path.sub(base_path, '.')})
        dir_name.scan(regexp).empty? ? (warn warn_info) : (require file_path)
      end unless temp_files.empty?

      temp_dirs.each do |dir_name|
        recursion_require(%(#{dir_path}/#{dir_name}), regexp, base_path, sort_rules)
      end unless temp_dirs.empty?
    end

    def sort_by_rules(array, rules)
      flatten_array = rules.inject([]) do |tmp, rule|
        tmp.push(array.grep(rule))
      end.flatten!
      flatten_array.push(array - flatten_array).flatten!
    end
  end
end
