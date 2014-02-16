action :run do
  converge_by("rbenv rehash: #{new_resource.name}") do
    hyone_rbenv_exec "rbenv rehash: #{new_resource.name}" do
      user       new_resource.user       if new_resource.user
      home       new_resource.home       if new_resource.home
      rbenv_root new_resource.rbenv_root if new_resource.rbenv_root
      command <<-EOC
        rbenv rehash
      EOC
    end
  end
end

def whyrun_supported?
  true
end
