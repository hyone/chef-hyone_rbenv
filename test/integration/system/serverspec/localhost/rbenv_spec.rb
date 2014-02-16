require 'spec_helper'


_user       = 'root'
_rbenv_root = '/usr/local/rbenv'
_versions = %w{
  2.1.0
}
_default_version = '2.1.0'

# rbenv installed
describe command('rbenv') do
  let(:path) { ::File.join _rbenv_root, 'bin' }
  it { should return_exit_status 0 }
end

# each ruby version installed
_versions.each do |version|
  ruby_command = ::File.join(_rbenv_root, 'versions', version, 'bin/ruby')
  keyword = version.gsub('-', '')

  describe command(ruby_command + ' --version') do
    it { should return_stdout /#{ Regexp.escape keyword }/ }
  end
end

# default version
describe command('ruby --version') do
  let(:path) { ::File.join _rbenv_root, 'shims' }
  it { should return_stdout /#{ Regexp.escape _default_version.sub(/-/, '') }/ }
end
