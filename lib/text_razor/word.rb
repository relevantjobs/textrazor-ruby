module TextRazor

  # * Represents a single Word (token) extracted by TextRazor.
  # Requires the "words" extractor to be added to the TextRazor request.
  class Word < TextRazorObject

    attr_accessor :_response_word
    attr_accessor :_parent
    attr_accessor :_children
    attr_accessor :_entities
    attr_accessor :_entailments
    attr_accessor :_relations
    attr_accessor :_relation_params
    attr_accessor :_property_predicates
    attr_accessor :_property_properties
    attr_accessor :_noun_phrases
    self.descr = %w(token stem lemma part_of_speech position input_start_offset input_end_offset
                    senses)


    def initialize(response_word, link_index)
      self._response_word = response_word

      self._parent = nil
      self._children = []

      self._entities = []
      self._entailments = []
      self._relations = []
      self._relation_params = []
      self._property_predicates = []
      self._property_properties = []
      self._noun_phrases = []

      link_index.fetch(["word", position], []).each do |callback, arg|
        args = arg + Array(self)
        callback.call(*args)
      end
    end

    def _add_child(child)
      _children << child
    end

    def _set_parent(parent)
      self._parent = parent
      parent._add_child(self)
    end

    def _add_entity(entity)
      self._entities << entity
    end

    def _add_entailment(entailment)
      _entailments << entailment
    end

    def _add_relation(relation)
      _relations << relation
    end

    def _add_relation_param(relation_param)
      _relation_params << relation_param
    end

    def _add_property_predicate(property)
      _property_predicates << property
    end

    def _add_property_properties(property)
      _property_properties << property
    end

    def _add_noun_phrase(noun_phrase)
      _noun_phrases << noun_phrase
    end

    # Returns the position of the grammatical parent of this word, or nil if this word
    # is either at the root of the sentence or the "dependency-trees" extractor was not requested.
    def parent_position
      _response_word.fetch("parentPosition", nil)
    end

    # Returns a link to the TextRazor word that is parent of this word, or nil if this word is
    # either at the root of the sentence or the "dependency-trees" extractor was not requested.
    def parent
      _parent
    end

    # Returns the Grammatical relation between this word and it's parent, or nil if this word is
    # either at the root of the sentence or the "dependency-trees" extractor was not requested.
    # TextRazor parses into the Stanford uncollapsed dependencies, as detailed at:
    # http://nlp.stanford.edu/software/dependencies_manual.pdf
    def relation_to_parent
      _response_word.fetch("relationToParent", nil)
    end

    # Returns a list of TextRazor words that make up the children of this word.
    # Returns an empty list for leaf words, or if the "dependency-trees" extractor was not
    # requested.
    def children
      _children
    end

    # Returns the position of this word in its sentence.
    def position
      _response_word.fetch("position", nil)
    end

    # Returns the stem of this word.
    def stem
      _response_word.fetch("stem", nil)
    end

    # Returns the morphological root of this word, see
    # http://en.wikipedia.org/wiki/Lemma_(morphology)
    # for details.
    def lemma
      _response_word.fetch("lemma", nil)
    end

    # Returns the raw token string that matched this word in the source text.
    def token
      _response_word.fetch("token", nil)
    end

    # Returns the Part of Speech that applies to this word.
    # We use the Penn treebank tagset, as detailed here:
    # http://www.comp.leeds.ac.uk/ccalas/tagsets/upenn.html
    def part_of_speech
      _response_word.fetch("partOfSpeech", nil)
    end

    # Returns the start offset in the input text for this token.
    # Note that this offset applies to the original Unicode string passed
    # in to the api, TextRazor treats multi byte utf8 charaters as a single position.
    def input_start_offset
      _response_word.fetch("startingPos", nil)
    end

    # Returns the end offset in the input text for this token.
    # Note that this offset applies to the original Unicode string passed
    # in to the api, TextRazor treats multi byte utf8 charaters as a single position.
    def input_end_offset
      _response_word.fetch("endingPos", nil)
    end

    # Returns a list of :class:`Entailment` that this word entails.
    def entailments
      _entailments
    end

    # Returns a list of :class:`Entity` that this word is a part of.
    def entities
      _entities
    end

    # Returns a list of :class:`Relation` that this word is a predicate of.
    def relations
      _relations
    end

    # Returns a list of :class:`RelationParam` that this word is a member of.
    def relation_params
      _relation_params
    end

    # Returns a list of :class:`Property` that this word is a property member of.
    def property_properties
      _property_properties
    end

    # Returns a list of :class:`Property` that this word is a predicate (or focus) member of.
    def property_predicates
      _property_predicates
    end

    # Returns a list of :class:`NounPhrase` that this word is a member of.
    def noun_phrases
      _noun_phrases
    end

    # Returns a list of (sense, score) tuples representing scores of each Wordnet sense this this word may be a part of.
    def senses
      _response_word.fetch("senses", [])
    end

    def to_s
      super + ": '%s' at position %s" % [token, position]
    end

  end
end
