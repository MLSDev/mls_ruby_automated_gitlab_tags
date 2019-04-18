# USAGE

It's supposed that your project has `.gitlab-ci.yml` configuration file.

We prefer to use separate `git_jobs` state. See an example below:

```yml
stages:
  - test
  - deploy
  - git_jobs
```

The task example:

Add to your `.gitlab-ci.yml` file the following lines:

```yml
include:
  - 'config/gitlabci/.gitlab-ci_git_jobs.yml'
```

Add `config/gitlabci/.gitlab-ci_git_jobs.yml` the following statements:


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

Or configure it as You even can imagine, just dont forget about `PRIVATE_TOKEN`.

How to retrieve `Access Key` via `profile/personal_access_tokens` page in `GitLab`

[personal_access_tokens]: ./personal_access_key_page.png "PersonalAccessKey"

Or visit [the GitLab Documentation Page][gitlab_access_tokens_help]

Also, You can find more details about [GitLab Environment Variables here][gitlab_env_variables_help]

![PersonalAccessKey][personal_access_tokens]

[gitlab_access_tokens_help]: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html "gitlab_access_tokens_help"

[gitlab_env_variables_help]: https://git.mlsdev.com/help/ci/variables/README#variables "gitlab_env_variables_help"
