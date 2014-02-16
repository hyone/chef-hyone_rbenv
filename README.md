# hyone_rbenv cookbook

## Usage

```json
{
  "hyone_rbenv": {
    "user":  "hoge",
    "group": "hoge",
    "path": "/home/hoge/local/rbenv",
    "default":  "2.0.0-p353",
    "versions": [
      {
        "version": "2.0.0-p353",
        "configure_opts": "--disable-install-rdoc"
      },
      {
        "version": "2.1.0",
        "configure_opts": "--disable-install-rdoc"
      }
    ],
    "setup_bash": true
  },

  "run_list": [
    "recipe[hyone_rbenv::default]"
  ]
}
```

## Recipes

### hyone_rbenv::default

install rbenv and ruby implementations

## LWRP

install ruby implementation:

```ruby
hyone_rbenv_install '2.0.0-p159' do
  user 'root'
  rbenv_root "/usr/local/rbenv"
  configure_opts "--disable-install-rdoc"
end
```

set global ruby implementation:

```ruby
hyone_rbenv_global '1.9.3-p392' do
  user 'root'
  rbenv_root "/usr/local/rbenv"
end
```

install gems with a ruby managed by rbenv:

```ruby
hyone_rbenv_gem 'bundler' do
  user 'vagrant'
  version '1.5.1'
  ruby_version '2.1.0'
end
```

execute with a ruby managed by rbenv:

```ruby
hyone_rbenv_exec 'install application libraries' do
  user 'vagrant'
  cwd  '/app'
  command <<-EOC
    echo 'gem: --no-rdoc --no-ri' > ~/.gemrc
    bundle install --path=vendor/bundle
  EOC
  not_if { ::File.exist? ::File.join(BUNDLE_DIR, 'bundler/setup.rb') }
end
```

# Attributes

- `node['hyone_rbenv']['user']` - user of rbenv installation

- `node['hyone_rbenv']['group']` - group of rbenv installation

- `node['hyone_rbenv']['home']` - home directory of rbenv installation

- `node['hyone_rbenv']['path']` - path of rbenv installation ( if not specifed, use `~/.rbenv` )

- `node['hyone_rbenv']['versions']` - ruby implementations to install
  ```json
  [{ "version": "2.0.0-p247", "configure_opts": "--disable-install-rdoc" }]
  ```

- `node['hyone_rbenv']['setup_bash']` - whether or not add rbenv settings to `~/.bash_profile`

Either `path` or `home` must be specified.

# Author

Author:: hyone (<hyone.development@gmail.com>)
