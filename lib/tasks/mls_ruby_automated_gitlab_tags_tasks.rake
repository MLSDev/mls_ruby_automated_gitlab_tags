namespace :mls_ruby_automated_gitlab_tags do
  desc 'Tag the deployed revision'

  #
  # GITLAB__HOST
  # GITLAB__PROJECT_ID
  # GITLAB__PRJ_URL
  #
  task :tag_revision do
    next unless ENV['GITLAB__HOST']
    next unless ENV['GITLAB__PROJECT_ID']
    next unless ENV['GITLAB__PRJ_URL']
    next unless ENV['CI_JOB_TOKEN']

    require 'net/https'
    require 'uri'
    require 'json'

    begin
      tags_uri = URI.parse(
        "https://#{ ENV['GITLAB__HOST'] }/api/v4/projects/#{ ENV['GITLAB__PROJECT_ID'] }/repository/tags"
      )

      headers = {
        'Accept':       'application/json',
        'Content-Type': 'application/json',
        'PRIVATE-TOKEN': ENV['CI_JOB_TOKEN']
      }

      http = Net::HTTP.new(tags_uri.host, tags_uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(tags_uri.request_uri, headers)
      response = http.request(request)

      puts response

      parsed_response = JSON.parse(response.body)

      last_tag = parsed_response.first.try(:[], 'name')
      last_tag ||= 'next_release' # in case if there was no tags created yet

      branch_for_deploy = 'production'

      compare_uri = URI.parse(
        "https://#{ ENV['GITLAB__HOST'] }/api/v4/projects/#{ ENV['GITLAB__PROJECT_ID'] }/repository/compare?from=#{ last_tag }&to=#{ branch_for_deploy }"
      )

      http = Net::HTTP.new(compare_uri.host, compare_uri.port).tap { |http| http.use_ssl = true }

      request = Net::HTTP::Get.new(compare_uri.request_uri, headers)
      response = http.request(request)

      puts response

      parsed_response = JSON.parse(response.body)

      # commits key - should be array of hashes
      messages =  parsed_response.fetch('commits', []).map do |commit|
        "1. [[VIEW]](#{ ENV['GITLAB__PRJ_URL'] }/commit/#{ commit['id'] }) #{ commit['title'] } (#{ commit['author_name'] })\n"
      end

      release_description = messages.join

      puts release_description

      body = {
        tag_name:            Time.now.strftime("%Y__%m__%d__%H_%M"),
        ref:                 branch_for_deploy,
        message:             'RELEASE 🎉🎉🎉',
        release_description: release_description
      }

      http = Net::HTTP.new(tags_uri.host, tags_uri.port).tap { |http| http.use_ssl = true }
      request = Net::HTTP::Post.new(tags_uri.request_uri, headers)
      request.body = body.to_json
      response = http.request(request)
      puts response
    rescue => e
      puts "An error happen while tagging. Plz double check if there was any misconfigurations."
      puts e.message
    end
  end
end
