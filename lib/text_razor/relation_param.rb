module TextRazor

  # * Represents a Param to a specific :class:`Relation`.
  # Requires the "relations" extractor to be added to the TextRazor request.
  class RelationParam < TextRazorObject

    attr_accessor :_param_json
    attr_accessor :_relation_parent
    attr_accessor :_param_words
    self.descr = %w()


    def initialize(param_json, relation_parent, link_index)
      self._param_json = param_json
      self._relation_parent = relation_parent
      self._param_words = []

      param_positions.each do |position|
        link_index[["word", position]] ||= []
        link_index[["word", position]] << [-> (word) { _register_link(word) }, []]
      end
    end

    def _register_link(word)
      _param_words << word
      word._add_relation_param(self)
    end

    # Returns the :class:`Relation` that owns this param.
    def relation_parent
      _relation_parent
    end

    # Returns the relation of this param to the predicate:
    # Possible values: SUBJECT, OBJECT, OTHER
    def relation
      _param_json.fetch("relation", nil)
    end

    # Returns a list of the positions of the words in this param within their sentence.
    def param_positions
      _param_json.fetch("wordPositions", [])
    end

    # Returns a list of all the :class:`Word` that make up this param.
    def param_words
      _param_words
    end

    # Returns an enumerator of all :class:`Entity` mentioned in this param.
    def entities
      seen = Set.new
      param_words.each do |word|
        word.entities.each do |entity|
          seen.add(entity)
        end
      end
      seen.each
    end

    def to_s
      super + ": '%s' at positions %s" % [relation, param_words.map(&:to_s).join(", ")]
    end

  end
end
