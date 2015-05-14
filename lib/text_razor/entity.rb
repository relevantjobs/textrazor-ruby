module TextRazor

  # * Represents a single "Named Entity" extracted from the input text.
  # Requires the "entities" extractor to be added to the TextRazor request.
  class Entity < TextRazorObject

    attr_accessor :_response_entity
    attr_accessor :_matched_words
    self.descr = %w(id document_id freebase_id freebase_types wikipedia_link dbpedia_types
                    data relevance_score confidence_score matched_text
                    starting_position ending_position matched_positions)


    def initialize(entity_json, link_index)
      self._response_entity = entity_json
      self._matched_words = []

      link_index.fetch(["entity", document_id], []).each do |callback, arg|
        args = arg + Array(self)
        callback.call(*args)
      end

      matched_positions.each do |position|
        link_index[["word", position]] ||= []
        link_index[["word", position]] << [-> (word) { _register_link(word) }, []]
      end
    end

    def _register_link(word)
      _matched_words << word
      word._add_entity(self)
    end

    def document_id
      return _response_entity.fetch("id", nil)
    end

    # The disambiguated ID for this entity, or None if this entity could not be disambiguated.
    # This ID is from the localized Wikipedia for this document's language.
    def id
      _response_entity.fetch("entityId", nil)
    end
    alias_method :localized_id, :id

    # The disambiguated entityId in the English Wikipedia, where a link between localized and
    # English ID could be found. None if either the entity could not be linked, or where a
    # language link did not exist.
    def unique_id
      _response_entity.fetch("entityEnglishId", nil)
    end
    alias_method :english_id, :unique_id

    # Returns the disambiguated Freebase ID for this entity, or None if either
    # this entity could not be disambiguated, or a Freebase link doesn't exist.
    def freebase_id
      _response_entity.fetch("freebaseId", nil)
    end

    # Returns a link to Wikipedia for this entity, or None if either this entity
    # could not be disambiguated or a Wikipedia link doesn't exist.
    def wikipedia_link
      _response_entity.fetch("wikiLink", nil)
    end

    # Returns the source text string that matched this entity.
    def matched_text
      _response_entity.fetch("matchedText", nil)
    end

    def starting_position
      _response_entity.fetch("startingPos", nil)
    end

    def ending_position
      _response_entity.fetch("endingPos", nil)
    end

    # Returns a list of the token positions in the current sentence that make up this entity.
    def matched_positions
      _response_entity.fetch("matchingTokens", [])
    end

    # Returns a list of :class:`Word` that make up this entity.
    def matched_words
      _matched_words
    end

    # Returns a list of Freebase types for this entity, or an empty list if there are none.
    def freebase_types
      _response_entity.fetch("freebaseTypes", [])
    end

    # Returns the relevance this entity has to the source text. This is a float on a scale of
    # 0 to 1, with 1 being the most relevant.  Relevance is determined by the contextual
    # similarity between the entities context and facts in the TextRazor knowledgebase.
    def relevance_score
      _response_entity.fetch("relevanceScore", nil)
    end

    # Returns the confidence that TextRazor is correct that this is a valid entity.
    # TextRazor uses an ever increasing number of signals to help spot valid entities,
    # all of which contribute to this score.  These include the contextual
    # agreement between the words in the source text and our knowledgebase, agreement
    # between other entities in the text, agreement between the expected entity type
    # and context, prior probabilities of having seen this entity across wikipedia
    # and other web datasets.  The score ranges from 0.5 to 10, with 10 representing
    # the highest confidence that this is a valid entity.
    def confidence_score
      _response_entity.fetch("confidenceScore", nil)
    end

    # Returns a list of dbpedia types for this entity, or an empty list if there are none.
    def dbpedia_types
      _response_entity.fetch("type", [])
    end

    # Returns a dictionary containing enriched data found for this entity.
    def data
      _response_entity.fetch("data", {})
    end

    def to_s
      super + "at positions %s" % [matched_positions.map(&:to_s).join(", ")]
    end

  end
end
