module TextRazor

  # * Represents a single sentence extracted by TextRazor.
  class Sentence < TextRazorObject

    attr_accessor :_words
    attr_accessor :_root_word
    self.descr = %w(words)


    def initialize(sentence_json, link_index)
      self._words = []
      sentence_json.fetch("words", []).each do |word_json|
        _words << Word.new(word_json, link_index)
      end

      _add_links(link_index)
    end

    def _add_links(link_index)
      return if _words.nil?

      self._root_word = nil

      # Add links between the parent/children of the dependency tree in this sentence.
      word_positions = {}
      _words.each do |word|
        word_positions[word.position] = word
      end

      _words.each do |word|
        parent_position = word.parent_position
        if !parent_position.nil? && parent_position >= 0
          word._set_parent(word_positions[parent_position])
        else
          # Punctuation does not get attached to any parent, any non punctuation part of speech
          # must be the root word.
          if !word.part_of_speech.in?(["$", "``", "''", "(", ")", ",", "--", ".", ":"])
            self._root_word = word
          end
        end
      end
    end

    # Returns the root word of this sentence if "dependency-trees" extractor was requested.
    def root_word
      _root_word
    end

    # Returns a list of all the :class:`Word` in this sentence.
    def words
      _words
    end

  end
end
