module TextRazor

  # * Represents a single "entailment" derived from the source text.
  # Requires the "entailments" extractor to be added to the TextRazor request.
  class Entailment < TextRazorObject

    attr_accessor :entailment_json
    attr_accessor :_matched_words
    self.descr = %w(id entailed_word score prior_score context_score
                    matched_positions matched_words)


    def initialize(entailment_json, link_index)
      self.entailment_json = entailment_json
      self._matched_words = []

      link_index.fetch(["entailment", id], []).each do |callback, arg|
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
      word._add_entailment(self)
    end

    # Returns the token positions in the current sentence that generated this entailment.
    def matched_positions
      entailment_json.fetch("wordPositions", [])
    end

    # Returns links the :class:`Word` in the current sentence that generated this entailment.
    def matched_words
      self._matched_words
    end

    # The unique id of this annotation within its annotation set.
    def id
      entailment_json.fetch("id", nil)
    end

    # Returns the score of this entailment independent of the context it is used in this sentence.
    def prior_score
      entailment_json.fetch("priorScore", nil)
    end

    # Returns the score of agreement between the source word's usage in this sentence and the
    # entailed words usage in our knowledgebase.
    def context_score
      entailment_json.fetch("contextScore", nil)
    end

    # Returns the overall confidence that TextRazor is correct that this is a valid entailment,
    # a combination of the prior and context score.
    def score
      entailment_json.fetch("score", nil)
    end

    # Returns the word string that is entailed by the source words.
    def entailed_word
      entailed_tree = entailment_json.fetch("entailedTree", nil)
      entailed_tree.fetch("word", nil) if entailed_tree
    end

    def to_s
      super + ": '%s' at positions %s" % [entailed_word, matched_positions.map(&:to_s).join(", ")]
    end

  end
end
