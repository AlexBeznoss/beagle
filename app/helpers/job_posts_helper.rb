module JobPostsHelper
  def provider_url(provider)
    {
      "remoteok" => "https://remoteok.com/remote-ruby-jobs",
      "gorails" => "https://jobs.gorails.com/",
      "rubyjobboard" => "https://www.rubyjobboard.com/newest-ruby-on-rails-jobs",
      "rubyonremote" => "https://rubyonremote.com"
    }[provider]
  end

  def provider_badge(provider)
    url = provider_url(provider)
    name = {
      "remoteok" => "RemoteOK",
      "gorails" => "GoRails",
      "rubyjobboard" => "RubyJobBoard",
      "rubyonremote" => "RubyOnRemote"
    }[provider]

    link_to url, target: "_blank", class: "m-1.5", rel: "noopener" do
      content_tag(
        :span,
        name,
        class: "inline-flex items-center rounded-lg bg-pink-100 px-3 py-0.5 text-sm font-medium text-pink-800"
      )
    end
  end
end
