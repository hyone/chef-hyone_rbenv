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

# Generate locales to avoid warnings like:
# 'bash: warning: setlocale: LC_ALL: cannot change locale (ja_JP.UTF-8)'
case
when platform?('centos')
  execute 'generate locale' do
    command 'localedef -f UTF-8 -i ja_JP /usr/lib/locale/ja_JP.UTF-8'
    action [:run]
  end
when platform?('ubuntu')
  execute 'locale-gen' do
    command 'locale-gen ja_JP.UTF-8'
    action [:run]
  end
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
