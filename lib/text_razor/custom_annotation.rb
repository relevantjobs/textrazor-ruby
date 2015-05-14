module TextRazor

  class CustomAnnotation <TextRazorObject

    attr_accessor :_annotation_json
    attr_accessor :_saved_values
    self.descr = %w(id name _saved_values)


    def initialize(annotation_json, link_index)
      self._annotation_json = annotation_json
      self._saved_values = {}

      annotation_json.fetch("contents", []).each do |key_value|
        key_value.fetch("links", []).each do |link|
          link_index[[link["annotationName"], link["linkedId"]]] ||= []
          link_index[[link["annotationName"], link["linkedId"]]] <<
              [-> (link, annotation) { _register_link(link, annotation) }, [link]]
        end
      end
    end

    def _register_link(link, annotation)
      link["linked"] = annotation
      annotation[name] << self
    end

    def name
      _annotation_json["name"]
    end

    def [](attribute)
      _saved_values[attribute] ||= begin
        yielded_values = []
        _annotation_json["contents"].each do |key_value|
          if "key".in?(key_value) && key_value["key"] == attribute
            key_value.fetch("links", []).each do |link|
              yielded_values << link.has_key?("linked") ? link["linked"] : link
            end
            key_value.fetch("intValue", []).each do |int_value|
              yielded_values << int_value
            end
            key_value.fetch("floatValue", []).each do |floatValue|
              yielded_values << floatValue
            end
            key_value.fetch("intValue", []).each do |stringValue|
              yielded_values << stringValue
            end
            key_value.fetch("intValue", []).each do |bytesValue|
              yielded_values << bytesValue
            end
          end
        end
        yielded_values
      end
    end

    def to_s
      super + "with name '%s'" % [name]
    end

  end
end
