source "https://rubygems.org"

gemspec

rails_version = ENV["RAILS_VERSION"]
rails_version = "6.1.0" if rails_version.nil?

if rails_version.to_f < 6
  gem "sqlite3", "~> 1.3.0"
else
  gem "sqlite3"
end

gem "activerecord", "~> #{rails_version}"

gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "simplecov", "~> 0.17.1"
gem "database_cleaner", "~> 2.0.0"
gem "pry"
