source 'https://rubygems.org'

gem 'chef', '~> 12.2.0'
gem 'berkshelf'

group :test do
 gem 'chefspec'
 gem 'foodcritic', '~> 4.0.0'
 gem 'tailor'
end

group :integration do
  gem 'test-kitchen'
  gem 'serverspec'
end

group :docker do
  gem 'kitchen-docker'
end

group :vagrant do
  gem 'kitchen-vagrant'
end
