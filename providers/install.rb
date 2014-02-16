::Chef::Provider.send(:include, HyoneRbenv::Helper)


action :install do
  if current_resource.exists
    Chef::Log.info "#{current_resource.ruby_path} already exists - nothing to do."
  else
    converge_by("Install #{new_resource.version} on rbenv") do
      rbenv_install_ruby
    end
  end
end


def whyrun_supported?
  true
end

def load_current_resource
  @current_resource =
    Chef::Resource::HyoneRbenvInstall.new(new_resource.version)
  @current_resource.user(new_resource.user)
  @current_resource.home(new_resource.home)
  @current_resource.rbenv_root(new_resource.rbenv_root)
  @current_resource.configure_opts(new_resource.configure_opts)

  if ::File.exists? @current_resource.ruby_path
    @current_resource.exists = true
  end
end


private

def rbenv_install_ruby
  # fetch via svn if ruby version is 1.8.x and before
  if new_resource.version.to_f < 1.9
    pkg = Chef::Resource::Package.new('subversion', run_context)
    pkg.run_action(:install)
  end

  _command = "rbenv install #{new_resource.version}"
  if new_resource.configure_opts
    _command = %|CONFIGURE_OPTS='#{new_resource.configure_opts}' | + _command
  end

  rehash = get_rehash_resource(
    run_context,
    new_resource.user,
    new_resource.home,
    new_resource.rbenv_root
  )

  hyone_rbenv_exec "install ruby implementation #{new_resource.version}" do
    user       new_resource.user
    home       new_resource.home
    rbenv_root new_resource.rbenv_root
    command    _command
    notifies :run, rehash, :immediately
  end
end
