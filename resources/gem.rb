actions [:install, :upgrade]
default_action :install

attribute :package, :kind_of => String, :name_attribute => true
attribute :version, :kind_of => String
# NOTE: :options only support long name options:
#       { :ri => true, :rdoc => false, :bin_dir => "/path/to/hoge" }
#       => --ri --no-rdoc --bin-dir "/path/to_hoge"
attribute :options, :kind_of => Hash, :default => {}
attribute :ruby_version, :kind_of => String

attr_accessor :exists

# load common lazy default attributes

::Chef::Resource.send(:include, HyoneRbenv::Resource::DefaultAttribute)


def ruby_version(arg = nil)
  if @ruby_version.nil?
    arg ||= global_ruby_version(self)
  end

  set_or_return(:ruby_version, arg, :kind_of => String)
end

def options(arg = nil)
  default_options = { ri: false, rdoc: false }
  if arg or @options.nil?
    arg = default_options.merge(arg || {})
  end

  set_or_return(:options, arg, :kind_of => Hash)
end
