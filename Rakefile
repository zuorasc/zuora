require 'bundler'
Bundler.setup
require 'appraisal'
require 'rspec/core/rake_task'

desc 'Default: run library specs.'
task :default => :spec

desc "Run library specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = ["./spec/zuora/**/*_spec.rb"]
end

namespace :spec do
  desc "Run LIVE integration specs"
  RSpec::Core::RakeTask.new do |t|
    t.name = 'integrations'
    t.pattern = "./spec/integration/*_spec.rb"
  end
end

desc "Generate documentation"
task :doc => ['doc:generate']

namespace :doc do
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_destination = File.join(project_root, 'doc')

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                   [ File.join(project_root, 'README.md') ]
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.md']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_destination if File.exists?(doc_destination)
  end

end

task = ARGV.first
if task && ENV['FORCE'] != 'true' 
  if task == 'spec:integrations'
    puts <<-END.gsub(/^[ ]+/, '')
      ****************************************************************************
      * WARNING! This task runs agsinst the remote service. The credentials
      * you provided as environment variables for ZUORA_USER and ZUORA_PASS will
      * be used to connect to the remote service and make changes to the system.
      *
      * This may DESTROY your PRODUCTION data! Please verify that you are using
      * a sandbox account before continuing.
      *
      * If you know what you are doing you can run this task with FORCE=true to
      * prevent this message from appearing.
      ****************************************************************************
      
      Are you sure you want to continue? (Yes|No) [No]
    END
    confirmation = STDIN.gets.chomp.downcase
    puts('Quitting.') || exit unless ['yes','y'].include?(confirmation.downcase)
  end
end

