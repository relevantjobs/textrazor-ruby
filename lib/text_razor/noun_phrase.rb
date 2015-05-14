module TextRazor

  # * Represents a multi-word phrase extracted from a sentence.
  # Requires the "relations" extractor to be added to the TextRazor request.
  class NounPhrase < TextRazorObject

    attr_accessor :_noun_phrase_json
    attr_accessor :_words
    self.descr = %w(id word_positions words)


    def initialize(noun_phrase_json, link_index)
      self._noun_phrase_json = noun_phrase_json
      self._words = []

      link_index.fetch(["nounPhrase", id], []).each do |callback, arg|
        args = arg + Array(self)
        callback.call(*args)
      end

      word_positions.each do |position|
        link_index[["word", position]] ||= []
        link_index[["word", position]] << [-> (word) { _register_link(word) }, []]
      end
    end

    def _register_link(word)
      self._words << word
      word._add_noun_phrase(self)
    end

    # The unique id of this annotation within its annotation set.
    def id
      _noun_phrase_json.fetch("id", nil)
    end

    # Returns a list of the positions of the words in this phrase.
    def word_positions
      _noun_phrase_json.fetch("wordPositions", [])
    end

    # Returns a list of :class:`Word` that make up this phrase.
    def words
      _words
    end

    def to_s
      super + "at positions %s" % [words.map(&:to_s).join(", ")]
    end

  end
end
