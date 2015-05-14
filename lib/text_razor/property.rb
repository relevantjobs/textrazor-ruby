module TextRazor

  # * Represents a property relation extracted from raw text.  A property implies an "is-a" or
  # "has-a" relationship between the predicate (or focus) and its property.
  # Requires the "relations" extractor to be added to the TextRazor request.
  class Property < TextRazorObject

    attr_accessor :_property_json
    attr_accessor :_predicate_words
    attr_accessor :_property_words
    self.descr = %w(id predicate_positions predicate_words property_positions property_words)


    def initialize(property_json, link_index)
      self._property_json = property_json
      self._predicate_words = []
      self._property_words = []

      link_index.fetch(["property", id], []).each do |callback, arg|
        args = arg + Array(self)
        callback.call(*args)
      end

      predicate_positions.each do |position|
        link_index[["word", position]] ||= []
        link_index[["word", position]] <<
            [-> (is_predicate, word) { _register_link(is_predicate, word) }, [true]]
      end

      property_positions.each do |position|
        link_index[["word", position]] ||= []
        link_index[["word", position]] <<
            [-> (is_predicate, word) { _register_link(is_predicate, word) }, [false]]
      end
    end

    def _register_link(is_predicate, word)
      if is_predicate
        _predicate_words << word
        word._add_property_predicate(self)
      else
        _property_words << word
        word._add_property_properties(self)
      end
    end

    # The unique id of this annotation within its annotation set.
    def id
      _property_json.fetch("id", nil)
    end

    # Returns a list of the positions of the words in the predicate (or focus) of this property.
    def predicate_positions
      _property_json.fetch("wordPositions", [])
    end

    # Returns a list of TextRazor words that make up the predicate (or focus) of this property.
    def predicate_words
      _predicate_words
    end

    # Returns a list of word positions that make up the modifier of the predicate of this property.
    def property_positions
      _property_json.fetch("propertyPositions", [])
    end

    # Returns a list of :class:`Word` that make up the property that targets the focus words.
    def property_words
      _property_words
    end

    def to_s
      super + "at positions %s" % [predicate_positions.map(&:to_s).join(", ")]
    end

  end
end
