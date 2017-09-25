# Copyright (c) 2014 TextRazor, http://textrazor.com/
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module TextRazor

  class TextRazorObject

    class_attribute :descr

    def id
    end

    def to_s
      "#{self.class.name} " + (id.to_s.blank? ? "" : "@id=#{id} ")
    end

    def to_h
      Hash[self.class.descr.to_a.map { |m| [m, send(m)] }]
    end

    def to_nil(x)
      if (x.respond_to?(:empty?) && x.empty?) || (x.respond_to?(:blank?) && x.blank?)
        nil
      else
        x
      end
    end

    def inspect
      "#<#{self.class.name} #{to_h.inspect}>"
    end

  end

end

require 'text_razor/version'
require 'text_razor/error'
require 'text_razor/error/analysis_exception'
require 'text_razor/topic'
require 'text_razor/property'
require 'text_razor/entity'
require 'text_razor/entailment'
require 'text_razor/relation'
require 'text_razor/relation_param'
require 'text_razor/custom_annotation'
require 'text_razor/dictionary'
require 'text_razor/noun_phrase'
require 'text_razor/word'
require 'text_razor/sentence'
require 'text_razor/response'
require 'text_razor/client'

