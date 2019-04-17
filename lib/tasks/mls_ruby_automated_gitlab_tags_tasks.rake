namespace :mls_ruby_automated_gitlab_tags do
  desc 'Tag the deployed revision'

  task :tag_revision do
    next unless ENV['CI_PROJECT_ID']
    next unless ENV['CI_PROJECT_URL']
    # next unless ENV['CI_JOB_TOKEN']

    require 'net/https'
    require 'uri'
    require 'json'

    begin
      puts 'ⓂⓁⓈ [🛠] :: Getting last tag'

      tags_uri = URI.parse(
        "#{ ENV['CI_API_V4_URL'] }/projects/#{ ENV['CI_PROJECT_ID'] }/repository/tags"
      )

      headers = {
        'Accept':        'application/json',
        'Content-Type':  'application/json',
        'PRIVATE-TOKEN': ENV['PRIVATE_TOKEN']
      }

      http = Net::HTTP.new(tags_uri.host, tags_uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(tags_uri.request_uri, headers)
      response = http.request(request)

      case response
      when Net::HTTPSuccess
        puts 'ⓂⓁⓈ [🛠] :: Tags ✅'
      when Net::HTTPUnauthorized
        puts 'ⓂⓁⓈ [🛠] :: Net::HTTPUnauthorized 🚨 - have You missed PRIVATE_TOKEN configuration?'
        exit 1
      when Net::HTTPServerError
        puts 'ⓂⓁⓈ [🛠] :: Net::HTTPServerError'
        exit 1
      else
        puts "ⓂⓁⓈ [🛠] :: #{ response }"
        exit 1
      end

      parsed_response = JSON.parse(response.body)

      last_tag = parsed_response.first.try(:[], 'name')
      if last_tag
        branch_for_deploy = 'production'
        puts "ⓂⓁⓈ [🛠] :: We found that last tag is #{ last_tag }"
      else
        last_tag ||= 'production' # in case if there was no tags created yet
        branch_for_deploy = 'next_release'
        puts "ⓂⓁⓈ [🛠] :: We didnt found last tag in your git repository. So, its supposed that You have #{ last_tag } branch that will be used as last save point."
        puts "ⓂⓁⓈ [🛠] :: Also, we will use #{ branch_for_deploy } branch that supposed to be latest branch that is gonna be deployed"
      end

      compare_uri = URI.parse(
        "#{ ENV['CI_API_V4_URL'] }/projects/#{ ENV['CI_PROJECT_ID'] }/repository/compare?from=#{ last_tag }&to=#{ branch_for_deploy }"
      )

      http = Net::HTTP.new(compare_uri.host, compare_uri.port).tap { |http| http.use_ssl = true }

      request = Net::HTTP::Get.new(compare_uri.request_uri, headers)
      response = http.request(request)

      case response
      when Net::HTTPSuccess
        puts 'ⓂⓁⓈ [🛠] :: Compare ✅'
      when Net::HTTPUnauthorized
        puts 'ⓂⓁⓈ [🛠] :: Net::HTTPUnauthorized 🚨 - have You missed PRIVATE_TOKEN configuration?'
        exit 1
      when Net::HTTPServerError
        puts 'ⓂⓁⓈ [🛠] :: Net::HTTPServerError'
        exit 1
      else
        puts "ⓂⓁⓈ [🛠] :: #{ response }"
        exit 1
      end

      parsed_response = JSON.parse(response.body)

      # commits key - should be array of hashes
      messages =  parsed_response.fetch('commits', []).map do |commit|
        "1. [[VIEW]](#{ ENV['CI_PROJECT_URL'] }/commit/#{ commit['id'] }) #{ commit['title'] } (#{ commit['author_name'] })\n"
      end

      release_description = messages.join

      puts "ⓂⓁⓈ [🛠] :: Release notes has length #{ release_description.size }"

      uri = URI.parse(
        "#{ ENV['CI_API_V4_URL'] }/projects/#{ ENV['CI_PROJECT_ID'] }/repository/tags"
      )

      headers = {
        'Accept':       'application/json',
        'Content-Type': 'application/json',
        'PRIVATE-TOKEN': ENV['PRIVATE_TOKEN']
      }

      body = {
        tag_name:            Time.now.strftime("%Y__%m__%d__%H_%M"),
        ref:                 branch_for_deploy,
        message:             'RELEASE 🎉🎉🎉',
        release_description: release_description
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body.to_json
      response = http.request(request)

      case response
      when Net::HTTPSuccess
        puts 'ⓂⓁⓈ [🛠] :: Create tag ✅'
      when Net::HTTPUnauthorized
        puts 'ⓂⓁⓈ [🛠] :: Net::HTTPUnauthorized 🚨 - have You missed PRIVATE_TOKEN configuration?'
        exit 1
      when Net::HTTPServerError
        puts 'ⓂⓁⓈ [🛠] :: Net::HTTPServerError'
        exit 1
      else
        puts "ⓂⓁⓈ [🛠] :: #{ response }"
        exit 1
      end
    rescue => e
      puts "An error happen while tagging. Plz double check if there was any misconfigurations."
      puts e.message
    end
  end
end
