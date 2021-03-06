# queries reportbooru to find missed post searches
class MissedSearchService
  def each_search(&block)
    fetch_data.scan(/(.+?) (\d+)\.0\n/).each(&block)
  end

  def fetch_data
    Cache.get("ms", 1.minute) do
      url = URI.parse("#{Danbooru.config.report_server}/missed_searches")
      response = ""
      Net::HTTP.start(url.host, url.port, :use_ssl => url.is_a?(URI::HTTPS)) do |http|
        http.read_timeout = 1
        http.request_get(url.request_uri) do |res|
          if res.is_a?(Net::HTTPSuccess)
            puts res.inspect
            response = res.body
          end
        end
      end
      response.force_encoding("utf-8")
    end
  end
end
