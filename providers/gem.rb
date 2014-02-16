::Chef::Resource.send(:include, HyoneRbenv::Helper)

action :install do
  if current_resource.exists
    Chef::Log.info "#{current_resource.package} on #{current_resource.ruby_version} already exists - nothing to do."
  else
    converge_by(
      "install #{new_resource.package} #{new_resource.version} on #{new_resource.ruby_version}"
    ) do
      rbenv_gem_install
    end
  end
end

action :upgrade do
  converge_by("upgrade #{current_resource.package} on #{current_resource.ruby_version}") do
    rbenv_gem_upgrade
  end
end

def whyrun_supported?
  true
end


def load_current_resource
  @current_resource =
    Chef::Resource::HyoneRbenvGem.new(new_resource.package)
  @current_resource.user(new_resource.user)
  @current_resource.home(new_resource.home)
  @current_resource.options(new_resource.options)
  @current_resource.version(new_resource.version)
  @current_resource.rbenv_root(new_resource.rbenv_root)
  @current_resource.ruby_version(new_resource.ruby_version)

  command = exec_with_rbenv "gem which #{@current_resource.package}",
    @current_resource.rbenv_root,
    @current_resource.user,
    @current_resource.home

  if command.status.to_i == 0
    @current_resource.exists = true
  end
end


private

def rbenv_gem_install
  rehash = get_rehash_resource(
    run_context,
    new_resource.user,
    new_resource.home,
    new_resource.rbenv_root
  )

  options = new_resource.options
  options.merge!(version: new_resource.version) if new_resource.version
  options_str = parse_options(options)

  hyone_rbenv_exec "exec to install #{new_resource.package} #{new_resource.version} on #{new_resource.ruby_version}" do
    user       new_resource.user         if new_resource.user
    home       new_resource.home         if new_resource.home
    rbenv_root new_resource.rbenv_root   if new_resource.rbenv_root
    version    new_resource.ruby_version if new_resource.ruby_version
    command <<-EOC
      gem install #{options_str} #{new_resource.package}
    EOC
    notifies :run, rehash, :immediately
  end
end

def rbenv_gem_upgrade
  rehash = get_rehash_resource(
    run_context,
    current_resource.user,
    current_resource.home,
    current_resource.rbenv_root
  )

  options_str = parse_options(current_resource.options)

  hyone_rbenv_exec "exec to upgrade #{current_resource.package} on #{current_resource.ruby_version}" do
    user       current_resource.user       if current_resource.user
    home       current_resource.home       if current_resource.home
    rbenv_root current_resource.rbenv_root if current_resource.rbenv_root
    version    new_resource.ruby_version if new_resource.ruby_version
    command <<-EOC
      gem update #{options_str} #{current_resource.package}
    EOC
    notifies :run, rehash, :immediately
  end
end
