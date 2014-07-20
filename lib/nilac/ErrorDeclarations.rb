class NilaSyntaxError < RuntimeError

  def initialize(message)

    puts "SyntaxError: " + message

    abort

  end

end