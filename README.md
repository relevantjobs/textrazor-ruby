TextRazor Ruby SDK
====================

Ruby SDK for the TextRazor Text Analytics API.

TextRazor offers state-of-the-art natural language processing tools through a simple API, allowing you to build semantic technology into your applications in minutes.  

Hundreds of applications rely on TextRazor to understand unstructured text across a range of verticals, with use cases including social media monitoring, enterprise search, recommendation systems and ad targetting.  

Getting Started
===============

- Get a free API key from [https://www.textrazor.com](https://www.textrazor.com).

- Install the TextRazor Ruby SDK

	Using Bundler add in your Gemfile

	```
	gem 'text_razor', github: 'glampr/textrazor-ruby'
	```

- Create an instance of the TextRazor object and start analyzing your text.

	```ruby
	require 'text_razor'

	client = TextRazor(YOUR_API_KEY_HERE, ["entities"])
	response = client.analyze("Barclays misled shareholders and the public about one of the biggest investments in the bank's history, a BBC Panorama investigation has found.")

	response.entities.each do |entity|
		puts entity
	end
	```

For full API documentation visit [https://www.textrazor.com/documentation_python](https://www.textrazor.com/documentation_python).
to check the Python documentation. The Ruby SDK is identical.
If you have any questions please get in touch at support@textrazor.com

This gem will try to follow the version number of the Python SDK.
