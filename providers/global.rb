action :run do
  converge_by("rbenv global #{new_resource.version}") do
    rehash = get_rehash_resource(
      run_context,
      new_resource.user,
      new_resource.home,
      new_resource.rbenv_root
    )

    hyone_rbenv_exec "rbenv global #{new_resource.version}" do
      user       new_resource.user       if new_resource.user
      home       new_resource.home       if new_resource.home
      rbenv_root new_resource.rbenv_root if new_resource.rbenv_root
      command <<-EOC
        rbenv global #{new_resource.version}
      EOC
      notifies :run, rehash, :immediately
    end
  end
end

def whyrun_supported?
  true
end
