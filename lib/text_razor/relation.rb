module TextRazor

  # * Represents a grammatical relation between words.  Typically owns a number of
  # :class:`RelationParam`, representing the SUBJECT and OBJECT of the relation.
  # Requires the "relations" extractor to be added to the TextRazor request.
  class Relation <TextRazorObject

    attr_accessor :_relation_json
    attr_accessor :_params
    attr_accessor :_predicate_words
    self.descr = %w(id predicate_positions predicate_words params)


    def initialize(relation_json, link_index)
      self._relation_json = relation_json
      self._params = relation_json["params"].map do |param|
        RelationParam.new(param, self, link_index)
      end
      self._predicate_words = []

      link_index.fetch(["relation", id], []).each do |callback, arg|
        args = arg + Array(self)
        callback.call(*args)
      end

      predicate_positions.each do |position|
        link_index[["word", position]] ||= []
        link_index[["word", position]] << [-> (word) { _register_link(word) }, []]
      end
    end

    def _register_link(word)
      self._predicate_words << word
      word._add_relation(self)
    end

    # The unique id of this annotation within its annotation set.
    def id
      _relation_json.fetch("id", nil)
    end

    # Returns a list of the positions of the predicate words in this relation within their sentence.
    def predicate_positions
      _relation_json.fetch("wordPositions", [])
    end

    # Returns a list of the TextRazor words in this relation.
    def predicate_words
      _predicate_words
    end

    # Returns a list of the TextRazor params of this relation.
    def params
      _params
    end

    def to_s
      super + "at positions %s" % [predicate_words.map(&:to_s).join(", ")]
    end

  end
end
