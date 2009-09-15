require File.join(File.dirname(__FILE__), '..', 'rackable')

class HelloWorld
  include Rackable

  def get()
		redirect "http://www.dn.se"
  end

	def post()

	end

end

run HelloWorld.new

=begin
An alternative version:

  class HelloWorld
    extend Rackable

    def self.get()
      "Hello, world!"
    end
  end

  run HelloWorld
=end
