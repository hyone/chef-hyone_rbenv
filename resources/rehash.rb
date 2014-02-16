actions [:run]
default_action :run

attribute :name, :kind_of => String, :name_attribute => true

# load common lazy default attributes

::Chef::Resource.send(:include, HyoneRbenv::Resource::DefaultAttribute)
