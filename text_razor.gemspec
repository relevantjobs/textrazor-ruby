lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text_razor/version'

Gem::Specification.new do |s|
  s.name        = 'text_razor'
  s.version     = TextRazor::VERSION
  s.add_runtime_dependency "httpclient"
  s.date        = '2016-03-29'
  s.summary     = "TextRazor Ruby client"
  s.description = <<-DESC
TextRazor
=========

Ruby SDK for the TextRazor Text Analytics API (https://textrazor.com).

TextRazor offers a comprehensive suite of state-of-the-art natural language processing functionality, with easy integration into your applications in minutes. TextRazor helps hundreds of applications understand unstructured content across a range of verticals, with use cases including social media monitoring, enterprise search, recommendation systems and ad targetting.

Read more about the TextRazor API at https://www.textrazor.com.
  DESC
  s.authors     = ["George Lamprianidis"]
  s.email       = 'giorgos.lamprianidis@gmail.com'
  s.files       = ["lib/text_razor.rb"]
  s.homepage    = 'http://rubygems.org/gems/textrazor_client'
  s.license     = 'MIT'
end
