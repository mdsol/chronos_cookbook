require 'bundler/setup'

namespace :style do
  require 'rubocop/rake_task'
  desc 'Run Ruby style checks'
  Rubocop::RakeTask.new(:ruby)

  namespace :ruby do
    desc 'Run Ruby style checks with checkstyle output for Jenkins'
    Rubocop::RakeTask.new(:checkstyle) do |t|
      t.requires   = ['rubocop/formatter/checkstyle_formatter']
      t.formatters = ['Rubocop::Formatter::CheckstyleFormatter']
      t.options    = ['--out', 'tmp/checkstyle.xml']
    end
  end

  require 'foodcritic'
  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef)
end

desc 'Run all style checks'
task style: ['style:chef', 'style:ruby']

require 'kitchen'
desc 'Run Test Kitchen integration tests'
task :integration do
  Kitchen.logger = Kitchen.default_file_logger
  Kitchen::Config.new.instances.each do |instance|
    instance.test(:always)
  end
end

# We cannot run Test Kitchen on Travis CI yet...
namespace :travis do
  desc 'Run tests on Travis'
  task ci: ['style']
end

namespace :test do
  desc 'CI build task for Jenkins'
  task jenkins: ['style:ruby:checkstyle', 'integration']

  desc 'Run all tests'
  task local: ['style', 'integration']
end

# The default rake task should just run it all
task default: 'test:jenkins'
