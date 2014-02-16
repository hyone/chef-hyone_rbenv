::Chef::Node.send(:include, HyoneRbenv::Helper)


default['hyone_rbenv']['user']  = nil
default['hyone_rbenv']['group'] = nil
default['hyone_rbenv']['home']  = nil
default['hyone_rbenv']['path']  = nil

default['hyone_rbenv']['versions'] = [
  { :version => '2.0.0-p247', :configure_opts => '--disable-install-rdoc' }
]
default['hyone_rbenv']['setup_bash'] = false
