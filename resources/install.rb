actions [:install]
default_action :install

attribute :version, :kind_of => String, :name_attribute => true
attribute :configure_opts, :kind_of => String

attr_accessor :exists

# load common lazy default attributes

::Chef::Resource.send(:include, HyoneRbenv::Resource::DefaultAttribute)

def ruby_path
  ::File.join(rbenv_root, "versions/#{version}/bin/ruby")
end
