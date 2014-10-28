require 'spec_helper'


_user       = 'root'
_rbenv_root = '/usr/local/rbenv'
_versions = %w{
  2.1.0
}
_default_version = '2.1.0'

set :path, "#{::File.join(_rbenv_root, 'bin')}:#{::File.join(_rbenv_root, 'shims')}:$PATH"


# rbenv installed
describe command('rbenv') do
  its(:exit_status) { should eq 0 }
end

# each ruby version installed
_versions.each do |version|
  ruby_command = ::File.join(_rbenv_root, 'versions', version, 'bin/ruby')
  keyword = version.gsub('-', '')

  describe command(ruby_command + ' --version') do
    its(:stdout) { should =~ /#{ Regexp.escape keyword }/ }
  end
end

# default version
describe command('ruby --version') do
  its(:stdout) { should =~ /#{ Regexp.escape _default_version.sub(/-/, '') }/ }
end
