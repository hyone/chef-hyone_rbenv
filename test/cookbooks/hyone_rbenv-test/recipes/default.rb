::Chef::Recipe.send(:include, HyoneRbenv::Helper)

_user       = get_user(node)
_group      = get_user(node)
_home       = get_home(node, _user)
_rbenv_root = get_rbenv_root(node, _user)

## user and group
user _user do
  home _home
  supports manage_home: true
  shell '/bin/bash'
  action [:create]
end

group _group do
  members [_user]
  action [:create]
end

case
when platform?('ubuntu')
  include_recipe 'apt'
end

# rbenv

include_recipe 'hyone_rbenv::default'

node['hyone_rbenv']['versions'].each do |ruby|
  hyone_rbenv_gem 'bundler' do
    rbenv_root _rbenv_root
    ruby_version ruby['version']
    version '1.3.5'
    action [:install]
  end

  hyone_rbenv_gem 'bundler' do
    rbenv_root _rbenv_root
    ruby_version ruby['version']
    action [:upgrade]
  end
end
