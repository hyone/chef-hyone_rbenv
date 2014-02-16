module HyoneRbenv
  module Helper

    def user_home(user)
      case user
      when 'root' then '/root'
      else File.join('/home', user)
      end
    end

    def get_user(attr)
      attr['hyone_rbenv']['user'] ||
        (attr.has_key?('main') && attr['main']['user']) ||
        'root'
    end

    def get_group(attr, user = nil)
      attr['hyone_rbenv']['group'] ||
        (attr.has_key?('main') && attr['main']['group']) ||
        user || get_user(attr)
    end

    def get_home(attr, user = nil)
      attr['hyone_rbenv']['home'] ||
        (attr.has_key?('main') && attr['main']['home']) ||
        user_home(user || get_user(attr))
    end

    def get_rbenv_root(attr, user = nil)
      attr['hyone_rbenv']['path'] || ::File.join(get_home(attr, user), '.rbenv')
    end


    def get_rehash_resource(run_context, _user, _home = nil, _rbenv_root = nil)
      rehash = begin
        run_context.resource_collection.find(:hyone_rbenv_rehash => 'rehash')
      rescue Chef::Exceptions::ResourceNotFound => e
        hyone_rbenv_rehash _user do
          user _user
          home _home if home
          rbenv_root _rbenv_root if rbenv_root
          action :nothing
        end
      end
      rehash
    end

    def exec_with_rbenv(command_str, rbenv_root, user, home, version = nil)
      # NOTE: 'command.environment['PATH'] = ...' causes error 'bash not found'
      #       so, put 'export PATH=...' inline in command string
      _commandline = <<-EOC
        export RBENV_ROOT="#{rbenv_root}"
        export PATH="#{ ::File.join(rbenv_root, 'bin') }:$PATH"
        eval "$(rbenv init -)"
        #{ "rbenv shell #{version}" if version }
        #{command_str}
      EOC
      command = Mixlib::ShellOut.new(_commandline)
      command.user = user
      command.environment['HOME'] = home
      command.run_command
      return command
    end

    def global_ruby_version(resource)
      command = exec_with_rbenv "rbenv version | cut -d ' ' -f 1",
        resource.rbenv_root,
        resource.user,
        resource.home
      command.stdout.chomp
    end

    def parse_options(options)
      options.map { |k, v|
        option = k.to_s.gsub('_', '-')
        case
        when v == true  then "--#{option}"
        when v == false then "--no-#{option}"
        else "--#{option} #{v}"
        end
      }.join(' ')
    end

  end

  # define attribute's lazy default value

  module Resource
    module DefaultAttribute
      include ::HyoneRbenv::Helper

      def user(arg = nil)
        if @user.nil?
          arg ||= get_user(node)
        end
        set_or_return(:user, arg, :kind_of => String)
      end

      def group(arg = nil)
        if @group.nil?
          arg ||= get_group(node, user)
        end
        set_or_return(:group, arg, :kind_of => String)
      end

      def home(arg = nil)
        if @home.nil?
          arg ||= get_home(node, user)
        end
        set_or_return(:home, arg, :kind_of => String)
      end

      def rbenv_root(arg = nil)
        if @rbenv_root.nil?
          arg ||= get_rbenv_root(node, user)
        end
        set_or_return(:rbenv_root, arg, :kind_of => String)
      end

    end
  end
end
