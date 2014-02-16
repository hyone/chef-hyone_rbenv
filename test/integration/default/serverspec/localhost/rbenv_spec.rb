require 'spec_helper'


_user = 'hoge'
_rbenv_root = ::File.join('/home', _user, '.rbenv')
_versions = %w{
  2.0.0-p353
}
_default_version = '2.0.0-p353'

# rbenv installed
describe command('rbenv') do
  let(:path) { ::File.join _rbenv_root, 'bin' }
  it { should return_exit_status 0 }
end

# each ruby version installed
_versions.each do |version|
  ruby_command = ::File.join(_rbenv_root, 'versions', version, 'bin/ruby')
  keyword = version.gsub(/-p\d+$/, '')

  describe command(ruby_command + ' --version') do
    it { should return_stdout /#{ Regexp.escape keyword }/ }
  end
end

# default version
describe command('ruby --version') do
  let(:path) { ::File.join _rbenv_root, 'shims' }
  it { should return_stdout /#{ Regexp.escape _default_version.sub(/-/, '') }/ }
end
