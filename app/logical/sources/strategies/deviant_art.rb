module Sources
  module Strategies
    class DeviantArt < Base
      def self.url_match?(url)
        url =~ /^https?:\/\/(?:.+?\.)?deviantart\.(?:com|net)/
      end

      def site_name
        "Deviant Art"
      end

      def unique_id
        profile_url =~ /https?:\/\/(.+?)\.deviantart\.com/
        "deviantart" + $1
      end

      def get
        agent.get(URI.parse(normalized_url)) do |page|
          @artist_name, @profile_url = get_profile_from_page(page)
          @image_url = get_image_url_from_page(page)
          @tags = []
        end
      end

    protected

      def get_profile_from_page(page)
        links = page.search("div.dev-title-container a.username")

        if links.any?
          profile_url = links[0]["href"]
          artist_name = links[0].text
        else
          profile_url = nil
          artist_name = nil
        end

        return [artist_name, profile_url].compact
      end

      def get_image_url_from_page(page)
        image = page.search("div.dev-view-deviation img.dev-content-normal")

        if image.any?
          image[0]["src"]
        else
          nil
        end
      end

      def normalized_url
        @normalized_url ||= begin
          if url =~ %r{\Ahttp://(?:fc|th)\d{2}\.deviantart\.net/.+/[a-z0-9_]*_by_[a-z0-9_]+-d([a-z0-9]+)\.}i
            "http://fav.me/d#{$1}"
          elsif url =~ %r{\Ahttp://(?:fc|th)\d{2}\.deviantart\.net/.+/[a-f0-9]+-d([a-z0-9]+)\.}i
            "http://fav.me/d#{$1}"
          elsif url =~ %r{deviantart\.com/art/}
            url
          else
            nil
          end
        end
      end

      def agent
        @agent ||= Mechanize.new
      end
    end
  end
end
