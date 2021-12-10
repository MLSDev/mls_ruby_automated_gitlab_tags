module MlsRubyAutomatedGitlabTags
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/mls_ruby_automated_gitlab_tags.rake'
    end
  end
end