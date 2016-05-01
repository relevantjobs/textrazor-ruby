require 'httpclient'

module TextRazor

  # * The main TextRazor client.  To process your text, create a :class:`TextRazor`
  # instance with your API key and set the extractors you need to process the text.
  # Calls to :meth:`analyze` and :meth:`analyze_url` will then process raw text or URLs,
  # returning a :class:`TextRazorResponse` on success.
  #
  # This class is threadsafe once initialized with the request options.
  # You should create a new instance for each request if you are likely to be changing
  # the request options in a multithreaded environment.
  #
  # Below is an entity extraction example from the tutorial, you can find more examples at
  # http://www.textrazor.com/tutorials.
  #
  # >>> client = TextRazor("DEMO", ["entities"])
  # >>> client.set_do_cleanup_HTML(true)
  # >>>
  # >>> response = client.analyze_url("http://www.bbc.co.uk/news/uk-politics-18640916")
  # >>>
  # >>> entities = list(response.entities)
  # >>> entities.sort { |e1, e2| e1.relevance_score <=> e2.relevance_score } .reverse
  # >>>
  # >>> seen = Set.new
  # >>> entities.each do |entity|
  # >>>   if entity.id not in seen:
  # >>>     print entity.id, entity.relevance_score, entity.confidence_score, entity.freebase_types
  # >>>     seen.add(entity.id)
  # >>> end

  class Client < TextRazorObject

    SECURE_TEXTRAZOR_ENDPOINT = "https://api.textrazor.com/"
    TEXTRAZOR_ENDPOINT = "http://api.textrazor.com/"

    attr_accessor :api_key
    attr_accessor :extractors
    attr_accessor :do_compression
    attr_accessor :do_encryption
    attr_accessor :cleanup_html
    attr_accessor :cleanup_mode
    attr_accessor :cleanup_return_cleaned
    attr_accessor :cleanup_return_raw
    attr_accessor :cleanup_use_metadata
    attr_accessor :download_user_agent
    attr_accessor :rules
    attr_accessor :language_override
    attr_accessor :enrichment_queries
    attr_accessor :dbpedia_type_filters
    attr_accessor :freebase_type_filters
    attr_accessor :allow_overlap
    attr_accessor :clnt


    def initialize(api_key, extractors, do_compression = true, do_encryption = false)
      self.api_key = api_key
      self.extractors = extractors
      self.do_compression = do_compression
      self.do_encryption = do_encryption
      self.cleanup_html = false
      self.cleanup_mode = nil
      self.cleanup_return_cleaned = nil
      self.cleanup_return_raw = nil
      self.cleanup_use_metadata = nil
      self.download_user_agent = nil
      self.rules = ""
      self.language_override = nil
      self.enrichment_queries = []
      self.dbpedia_type_filters = []
      self.freebase_type_filters = []
      self.allow_overlap = nil
      self.clnt = HTTPClient.new
      clnt.transparent_gzip_decompression = true
    end

    # Sets the TextRazor API key, required for all requests.
    def set_api_key(api_key)
      self.api_key = api_key
    end

    # Sets a list of "Extractors" which extract various information from your text.
    # Only select the extractors that are explicitly required by your application for
    # optimal performance. Any extractor that doesn't match one of the predefined list
    # below will be assumed to be a custom Prolog extractor.
    #
    # Valid options are: words, phrases, entities, dependency-trees, relations, entailments.
    def set_extractors(extractors)
      self.extractors = extractors
    end

    # Sets a string containing Prolog logic.  All rules matching an extractor name listed
    # in the request will be evaluated and all matching param combinations linked in the response.
    def set_rules(rules)
      self.rules = rules
    end

    # When true, request gzipped responses from TextRazor.
    # When expecting a large response this can significantly reduce bandwidth.
    # Defaults to true.
    def set_do_compression(do_compression)
      self.do_compression = do_compression
    end

    # When True, all communication to TextRazor will be sent over SSL,
    # when handling sensitive or private information this should be set to true.
    # Defaults to false.
    def set_do_encryption(do_encryption)
      self.do_encryption = do_encryption
    end

    # Set a list of "Enrichment Queries", used to enrich the entity response with
    # structured linked data. The syntax for these queries is documented at
    # https://www.textrazor.com/enrichment
    def set_enrichment_queries(enrichment_queries)
      self.enrichment_queries = enrichment_queries
    end

    # When set to a ISO-639-2 language code, force TextRazor to analyze content with this language.
    # If not set TextRazor will use the automatically identified language.
    def set_language_override(language_override)
      self.language_override = language_override
    end

    # <b>DEPRECATED:</b> See <tt>set_cleanup_mode</tt>
    # When true, input text is treated as raw HTML and will be cleaned of tags, comments, scripts,
    # and boilerplate content removed.  When this option is enabled, the cleaned_text property is
    # returned with the text content, providing access to the raw filtered text.  When enabled,
    # position offsets returned in individual words apply to the clean text, not the provided HTML.
    def set_do_cleanup_HTML(cleanup_html)
      warn ":set_do_cleanup_HTML has been deprecated." <<
           "Please see :set_cleanup_mode for a more flexible cleanup option."
      self.cleanup_html = cleanup_html
    end

    # Controls the preprocessing cleanup mode that TextRazor will apply to your content before
    # analysis. For all options aside from "raw" any position offsets returned will apply to the
    # final cleaned text, not the raw HTML. If the cleaned text is required please see the
    # :meth:`set_cleanup_return_cleaned' option.
    #
    # ==== Valid options are:
    # * +:raw+ - Content is analyzed "as-is", with no preprocessing.
    # * +:cleanHTML+ - Boilerplate HTML is removed prior to analysis, including tags, comments, menus, leaving only the body of the article.
    # * +:stripTags+ - All Tags are removed from the document prior to analysis. This will remove all HTML, XML tags, but the content of headings, menus will remain. This is a good option for analysis of HTML pages that aren't long form documents.
    #
    # Defaults to "raw" for analyze requests, and "cleanHTML" for analyze_url requests.
    def set_cleanup_mode(cleanup_mode)
      self.cleanup_mode = cleanup_mode
    end

    # When return_cleaned is true, the TextRazor response will contain the cleaned_text property.
    # To save bandwidth, only set this to true if you need it in your application.
    # Defaults to false.
    def set_cleanup_return_cleaned(return_cleaned)
      cleanup_return_cleaned = return_cleaned
    end

    # When return_raw is true, the TextRazor response will contain the raw_text property, the
    # original text TextRazor received or downloaded before cleaning. To save bandwidth, only set
    # this to true if you need it in your application. Defaults to false.
    def set_cleanup_return_raw(return_raw)
      self.cleanup_return_raw = return_raw
    end

    # When use_metadata is true, TextRazor will use metadata extracted from your document
    # to help in the disambiguation/extraction process. This include HTML titles and metadata,
    # and can significantly improve results for shorter documents without much other content.
    #
    # This option has no effect when cleanup_mode is 'raw'.
    def set_cleanup_use_metadata(use_metadata)
      self.cleanup_use_metadata = use_metadata
    end

    # Sets the User-Agent header to be used when downloading URLs through analyze_url.
    # This should be a descriptive string identifying your application, or an end user's
    # browser user agent if you are performing live requests from a given user.
    #
    # Defaults to "TextRazor Downloader (https://www.textrazor.com)"
    def set_download_user_agent(user_agent)
      self.download_user_agent = user_agent
    end

    # When allow_overlap is true, entities in the response may overlap.
    # When False, the "best" entity is found such that nil overlap. Defaults to true.
    def set_entity_allow_overlap(allow_overlap)
      self.allow_overlap = allow_overlap
    end

    # Set a list of DBPedia types to filter entity extraction on.
    # All returned entities must match at least one of these types.
    def set_entity_dbpedia_type_filters(filters)
      self.dbpedia_type_filters = filters
    end

    # Set a list of Freebase types to filter entity extraction on.
    # All returned entities must match at least one of these types.
    def set_entity_freebase_type_filters(filters)
      self.freebase_type_filters = filters
    end

    def _add_optional_param(post_data, param, value)
      post_data << [param, value] if !value.nil?
    end

    def _build_post_data
      post_data = [
        ["apiKey"     , api_key             ],
        ["rules"      , rules               ],
        ["extractors" , extractors.join(",")],
        ["cleanupHTML", cleanup_html        ]
      ]

      dbpedia_type_filters.each do |filter|
        post_data << ["entities.filterDbpediaTypes", filter]
      end

      freebase_type_filters.each do |filter|
        post_data << ["entities.filterFreebaseTypes", filter]
      end

      enrichment_queries.each do |filter|
        post_data << ["entities.enrichmentQueries", filter]
      end

      _add_optional_param(post_data, "entities.allowOverlap", allow_overlap)
      _add_optional_param(post_data, "languageOverride", language_override)
      _add_optional_param(post_data, "cleanup.mode", cleanup_mode)
      _add_optional_param(post_data, "cleanup.returnCleaned", cleanup_return_cleaned)
      _add_optional_param(post_data, "cleanup.returnRaw", cleanup_return_raw)
      _add_optional_param(post_data, "cleanup.useMetadata", cleanup_use_metadata)
      _add_optional_param(post_data, "download.userAgent", download_user_agent)

      post_data
    end

    def _do_request(post_data, request_headers)
      uri = do_encryption ? SECURE_TEXTRAZOR_ENDPOINT : TEXTRAZOR_ENDPOINT

      response = nil
      http_response = clnt.post(uri, body: post_data, header: request_headers)
      response_json = JSON.parse(http_response.body) rescue response_json = nil
      if response_json.nil?
        raise "Response is not valid JSON: #{http_response.body}"
      elsif response_json["ok"] == false
        raise TextRazor::Error::AnalysisException.new(response_json["error"])
      else
        response = Response.new(response_json)
      end
      response
    end

    def _build_request_headers
      request_headers = {}
      request_headers['Accept-encoding'] = 'gzip' if do_compression
      request_headers
    end

    # Calls the TextRazor API with the provided url.
    #
    # TextRazor will first download the contents of this URL, and then process the resulting text.
    #
    # TextRazor will only attempt to analyze text documents. Any invalid UTF-8 characters will be
    # replaced with a space character and ignored.
    # TextRazor limits the total download size to approximately 1M. Any larger documents will be
    # truncated to that size, and a warning will be returned in the response.
    #
    # By default, TextRazor will clean all HTML prior to processing.
    # For more control of the cleanup process, see the :meth:`set_cleanup_mode' option.
    #
    # Returns a :class:`TextRazorResponse` with the parsed data on success.
    # Raises a :class:`TextRazorAnalysisException` on failure.
    def analyze_url(url)
      return nil if url.to_s.strip.empty?
      post_data = self._build_post_data()
      post_data << ["url", url]
      _do_request(post_data, _build_request_headers)
    end

    # Calls the TextRazor API with the provided unicode text.
    #
    # Returns a :class:`TextRazorResponse` with the parsed data on success.
    # Raises a :class:`TextRazorAnalysisException` on failure.
    def analyze(text)
      return nil if text.to_s.strip.empty?
      post_data = self._build_post_data()
      post_data << ["text", text]
      _do_request(post_data, self._build_request_headers)
    end

  end
end
