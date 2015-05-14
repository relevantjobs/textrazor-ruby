module TextRazor

  # * Represents a single Word (token) extracted by TextRazor.
  # Requires the "words" extractor to be added to the TextRazor request.
  class Response < TextRazorObject

    attr_accessor :response_json
    attr_accessor :custom_annotations
    attr_accessor :_topics
    attr_accessor :_coarse_topics
    attr_accessor :_entities
    attr_accessor :_entailments
    attr_accessor :_relations
    attr_accessor :_properties
    attr_accessor :_noun_phrases
    attr_accessor :sentences
    attr_accessor :_saved_values
    self.descr = %w(response_json)


    def initialize(response_json)
      self.response_json = response_json
      self.sentences = []
      self.custom_annotations = []

      link_index = {}

      if response_json["response"]
        # There's a bit of magic here. Each annotation registers a callback
        # with the ids and types of annotation that it is linked to.
        # When the linked annotation is later parsed it adds the link via the callback.
        # This means that annotations must be added in order of the dependency between them.

        self.custom_annotations =
            response_json["response"].fetch("customAnnotations", []).map do |json|
              CustomAnnotation.new(json, link_index)
            end

        self._topics =
            response_json["response"].fetch("topics", []).map do |topic_json|
              Topic.new(topic_json, link_index)
            end

        self._coarse_topics =
            response_json["response"].fetch("coarseTopics", []).map do |topic_json|
              Topic.new(topic_json, link_index)
            end

        self._entities =
            response_json["response"].fetch("entities", []).map do |entity_json|
              Entity.new(entity_json, link_index)
            end

        self._entailments =
            response_json["response"].fetch("entailments", []).map do |entailment_json|
              Entailment.new(entailment_json, link_index)
            end

        self._relations =
            response_json["response"].fetch("relations", []).map do |relation_json|
              Relation.new(relation_json, link_index)
            end

        self._properties =
            response_json["response"].fetch("properties", []).map do |property_json|
              Property.new(property_json, link_index)
            end

        self._noun_phrases =
            response_json["response"].fetch("nounPhrases", []).map do |phrase_json|
              NounPhrase.new(phrase_json, link_index)
            end

        self.sentences =
            response_json["response"].fetch("sentences", []).map do |sentence_json|
              Sentence.new(sentence_json, link_index)
            end
      end
    end

    def raw_text
      response_json["response"].fetch("rawText", "")
    end

    def cleaned_text
      response_json["response"].fetch("cleanedText", "")
    end

    def summary
      "Request processed in: %s seconds.  Num Sentences:%s" % \
          [response_json["time"], response_json["response"].fetch("sentences", []).length]
    end

    # Returns any output generated while running the embedded prolog engine on your rules.
    def custom_annotation_output
      response_json["response"].fetch("customAnnotationOutput", "")
    end

    # Returns a list of all the coarse :class:`Topic` in the response.
    def coarse_topics
      _coarse_topics
    end

    # Returns a list of all the :class:`Topic` in the response.
    def topics
      _topics
    end

    # Returns a list of all the :class:`Entity` across all sentences in the response.
    def entities
      _entities
    end

    # Returns an enumerator of all :class:`Word` across all sentences in the response.
    def words
      sentences.map { |sentence| sentence.words.map { |word| word } } .flatten.each
    end

    # Returns a list of all :class:`Entailment` across all sentences in the response.
    def entailments
      _entailments
    end

    # Returns a list of all :class:`Relation` across all sentences in the response.
    def relations
      _relations
    end

    # Returns a list of all :class:`Property` across all sentences in the response.
    def properties
      _properties
    end

    # Returns a list of all the :class:`NounPhrase` across all sentences in the response.
    def noun_phrases
      _noun_phrases
    end

    def matching_rules
      custom_annotations.map(&:name)
    end

    # Returns true if TextRazor successfully analyzed your document, false if there was some error.
    # More detailed information about the error is available in the :meth:`error` property.
    def ok
      response_json.fetch("ok", false)
    end
    alias_method :ok?, :ok

    # Returns a descriptive error message of any problems that may have occurred during analysis,
    # or an empty string if there was no error.
    def error
      response_json.fetch("error", "")
    end

    # Returns any warning or informational messages returned from the server.
    def message
      response_json.fetch("message", "")
    end

    def [](attribute)
      _saved_values[attribute] ||= begin
        yielded_values = []
        custom_annotations.each do |custom_annotation|
          if custom_annotation.name == attribute
            yielded_values << custom_annotation
          end
        end
        yielded_values
      end
    end

  end
end
