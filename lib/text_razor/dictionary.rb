require 'httpclient'

module TextRazor

  class Dictionary < TextRazorObject

    API_KEY = "77fca4096416300804cda561a4b8cdda762724039743feaa0373f98a"

    SECURE_TEXTRAZOR_ENDPOINT = "https://api.textrazor.com/"
    ENTITIES_ENDPOINT = "entities/"

    self.client = HTTPClient.new


    def self.get_all

      self._get(uri: SECURE_TEXTRAZOR_ENDPOINT + ENTITIES_ENDPOINT)

    end

    def self.get(id:)

    end

    def add_entries(entries: {})

    end

    def delete_dictionary

    end

    def get_entry(entry_id:)

    end

    def delete_entry(entry_id:)

    end

    def self._build_request_headers
      request_headers = {}
      request_headers['Accept-encoding'] = 'gzip' if do_compression
      request_headers['Content-Type'] = 'application/json'
      request_headers['x-textrazor-key'] = API_KEY
      request_headers
    end

    def self._get(uri:)
      client = HTTPClient.new

      http_response = client.get(uri, header: self._build_request_headers)
    end

  end

end