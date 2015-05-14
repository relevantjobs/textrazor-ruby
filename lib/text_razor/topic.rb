module TextRazor

  # * Represents a single abstract topic extracted from the input text.
  # Requires the "topics" extractor to be added to the TextRazor request.
  class Topic < TextRazorObject

    attr_accessor :_topic_json
    attr_accessor :link_index
    self.descr = %w(id label score wikipedia_link)


    def initialize(topic_json, link_index)
      self._topic_json = topic_json

      link_index.fetch(["topic", id], []).each do |callback, arg|
        args = arg + Array(self)
        callback.call(*args)
      end
    end

    # The unique id of this annotation within its annotation set.
    def id
      _topic_json.fetch("id", nil)
    end

    # Returns the label for this topic.
    def label
      _topic_json.fetch("label", "")
    end

    # Returns a link to Wikipedia for this topic, or None if this topic
    # couldn't be linked to a wikipedia page.
    def wikipedia_link
      _topic_json.fetch("wikiLink", nil)
    end

    # Returns the relevancy score of this topic to the query document.
    def score
      _topic_json.fetch("score", 0)
    end

    def to_s
      super + "with label '%s'" % [label]
    end

  end
end
