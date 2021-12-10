module MlsRubyAutomatedGitlabTags
  class Railtie < Rails::Railtie
    railtie_name :mls_ruby_automated_gitlab_tags

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end