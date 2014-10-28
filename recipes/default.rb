#
# Cookbook Name:: hyone_rbev
# Recipe:: default
#
# Copyright (C) 2013 hyone
# 
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, HyoneRbenv::Helper)


case node['platform_family']
when 'rhel', 'fedora'
  package 'openssl-devel'
  package 'readline-devel'
  package 'zlib-devel'
when 'debian'
  package 'libssl-dev'
  package 'libreadline-dev'
  package 'zlib1g-dev'
end
package 'tar'

include_recipe 'build-essential'
include_recipe 'git'


# install rbenv

_user       = get_user(node)
_group      = get_group(node, _user)
_home       = get_home(node, _user)
_rbenv_root = get_rbenv_root(node, _user)

git 'rbenv' do
  repository 'git://github.com/sstephenson/rbenv.git'
  reference 'master'
  destination _rbenv_root
  action :sync
  user  _user
  group _group
end

directory ::File.join(_rbenv_root, 'plugins') do
  user  _user
  group _group
  mode 0755
  action :create
end

git 'ruby-build' do
  repository 'git://github.com/sstephenson/ruby-build.git'
  reference 'master'
  destination ::File.join _rbenv_root, 'plugins/ruby-build'
  action :sync
  user  _user
  group _group
end

hyone_rbenv_rehash "rehash" do
  user _user
  rbenv_root _rbenv_root
  action :nothing
end


# setup bash

if node['hyone_rbenv']['setup_bash']
  rbenv_search_path = ::File.join _rbenv_root, 'bin'
  rc_file = ::File.join _home, '.bash_profile'

  file rc_file do
    user  _user
    group _group
    action [:create]
  end

  ruby_block 'setup rbenv settings for rc' do
    block do
      file = Chef::Util::FileEdit.new(rc_file)
      file.insert_line_if_no_match \
        /^\s*#{ Regexp.escape 'eval "$(rbenv init -)"'}\s*$/, <<-EOC.undent
          export PATH="#{rbenv_search_path}:$PATH"
          export RBENV_ROOT="#{_rbenv_root}"
          eval "$(rbenv init -)"
        EOC
      file.write_file
    end
  end
end


# install ruby implementations

node['hyone_rbenv']['versions'].each do |ruby|
  hyone_rbenv_install ruby['version'] do
    user _user
    rbenv_root _rbenv_root
    configure_opts ruby['configure_opts'] if ruby['configure_opts']
  end

  # install bundler
  hyone_rbenv_gem 'bundler' do
    user _user
    rbenv_root _rbenv_root
    ruby_version ruby['version']
  end
end


# set default implementation

default_version = node['hyone_rbenv']['default']

hyone_rbenv_global default_version do
  user _user
  rbenv_root _rbenv_root
end
