
action :run do
  converge_by("Execute #{new_resource.name} with #{new_resource.version} on rbenv") do
    execute_with_rbenv
  end
end

def whyrun_supported?
  true
end


private

def execute_with_rbenv
  bash "execute #{new_resource.name}" do
    user  new_resource.user
    group new_resource.group
    cwd   new_resource.cwd   if new_resource.cwd
    environment new_resource.environment.merge(
      'HOME' => new_resource.home
    )
    code <<-EOC
      export PATH="#{ ::File.join(new_resource.rbenv_root, 'bin') }:$PATH"
      export RBENV_ROOT="#{ new_resource.rbenv_root }"
      eval "$(rbenv init -)"
      rbenv shell #{new_resource.version}
      #{new_resource.command}
    EOC
  end
end
