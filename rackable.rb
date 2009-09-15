module Rackable
  attr_reader :rack

  def call(env)
    allowed_methods = [:get, :put, :post, :delete]

    @rack = Struct.new(:env, :request, :response, :header, :query, :data).new
    rack.env = env

    rack.request  = Rack::Request.new(env)
    rack.response = Rack::Response.new
    rack.header   = rack.response.header

    rack.query = rack.request.GET.inject({})  {|h, (k,v)| h[k.to_sym] = v; h }
    rack.data  = rack.request.POST.inject({}) {|h, (k,v)| h[k.to_sym] = v; h }

    method = rack.env['REQUEST_METHOD'].downcase.to_sym

    args = rack.env['PATH_INFO'][1..-1].split('/').collect { |arg|
      Rack::Utils.unescape(arg)
    }

    method, was_head = :get, true if method == :head

    rack.response.status, body = catch(:halt) do
      begin
        raise NoMethodError unless allowed_methods.include? method
        body = send(method, *args)
        [rack.response.status, body]

      rescue NoMethodError
        rack.header['Allow'] = allowed_methods.delete_if { |meth|
          !respond_to?(meth)
        }.tap {|a|
          a.unshift 'HEAD' if respond_to? :get
        }.map { |meth|
          meth.to_s.upcase
        }.join(', ')

        http_error 405

      rescue ArgumentError
        http_error 400

      end
    end

    rack.response.write(body) unless was_head
    rack.response.finish
  end


  private

  def http_error(code, message=nil)
    throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
  end


	def redirect(url)
		rack.response.redirect(url, 302)
	end
	
	

end

