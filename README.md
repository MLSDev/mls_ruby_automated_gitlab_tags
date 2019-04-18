# MlsRubyAutomatedGitlabTags
Tool that allows quickly prepare tag message that is based on commit messages.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'mls_ruby_automated_gitlab_tags', tag: 'vX.X.X', github: 'MLSDev/mls_ruby_automated_gitlab_tags'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install mls_ruby_automated_gitlab_tags
```

## Usage

It's supposed that your project has `.gitlab-ci.yml` configuration file.

We prefer to use separate `git_jobs` state. See an example below:

```yml
stages:
  - test
  - deploy
  - git_jobs
```

The task example:

```yml
git_work__create_tag:
  type: git_jobs
  tags:
    - shell-ruby
  script:
    - bundle exec rake mls_ruby_automated_gitlab_tags:tag_revision PRIVATE_TOKEN=$GITLAB__PRIVATE_TOKEN
  only:
    refs:
      - production
  allow_failure: true
  when: always # or manual
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
