require "pp"

class CFVM
  def initialize()
    @prog = []
    @stack = []
    @sstack = []
    @quotedepth = 0
    @quote = []
    @env = {}
  end

  def append(prog, name)
    @prog.concat prog.split(/\s+/)
  end

  def exec_one token
    #p [@quotedepth, @stack, token]
    if @quotedepth > 0
      case token
      when "["
	@quote << token
	@quotedepth += 1
      when "]"
	@quotedepth -= 1
	@quote << token if @quotedepth != 0
      else
	@quote << token
      end

      if @quotedepth == 0
	@stack << @quote
	@quote = []
      end

      return
    end

    case token
    when "", /^#/ # NOP
    when /^[0-9]/
      @stack << token.to_i
    when /^:/
      @stack << token[1..-1].to_sym
    when "("
      @sstack << @stack
      @stack = []
    when ")"
      @sstack.last << @stack
      @stack = @sstack.pop
    when "["
      @quotedepth += 1
    when "]"
      raise AlreadyOnTop
    else
      exec_proc token.to_sym
    end
  end

  def exec p=@prog
    p.each &method(:exec_one)
  end

  def exec_proc name
    return if name == :""
    if @env[name]
      if @env[name].respond_to? :call
        @env[name].()
      elsif @env[name].respond_to? :each
        exec @env[name]
      else
        @stack << @env[name]
      end
    else
      raise NameNotFound.new(name)
    end
  end

  def basic_lib
    @env[:def] = -> do
      name=@stack.pop
      value=@stack.pop
      @env[name] = value
    end

    @env[:dup] = -> do
      @stack << @stack.last
    end
    @env[:pop] = -> do
      @stack.pop
    end
    @env[:swap] = -> do
      a,b = @stack.pop,@stack.pop
      @stack << a << b
    end
    @env[:swapn] = -> do
      index = @stack.pop + 1
      @stack[-index],@stack[-1] = @stack[-1],@stack[-index]
    end
    @env[:popup] = -> do
      @sstack.last << @stack.pop
    end
    @env[:popdown] = -> do
      @stack << @sstack.last.pop
    end

    @env[:~] = -> do
      @stack << ~@stack.pop
    end
    @env[:!] = -> do
      @stack << ((@stack.pop == 0) ? 1 : 0)
    end

    [:+, :*, :==, :!=, :|, :&, :^].each do |i|
      @env[i] = -> do
	r = @stack.pop.send(i, @stack.pop)
        r = 1 if r == true
	r = 0 if r == false or r == nil
        @stack << r
      end
    end
    [:-, :/, :%, :<, :>, :<=, :>=, :>>, :<<].each do |i|
      @env[i] = -> do
        d = @stack.pop
	r = @stack.pop.send(i, d)
        r = 1 if r == true
	r = 0 if r == false or r == nil
        @stack << r
      end
    end

    @env[:if] = -> do
      code = @stack.pop
      cond = @stack.pop
      exec code if cond != 0
    end

    @env[:exec] = -> do
      exec @stack.pop
    end

    @env[:p] = -> do
      print @stack.last.to_s
    end

    @env[:enter] = -> do
      @sstack << @stack
      @stack = @sstack.last.pop
    end

    @env[:nl] = "\n"
    @env[:sp] = " "

    @env[:dump] = -> do
      pp self
    end
  end

  class AlreadyOnTop < Exception
  end
  class NameNotFound < Exception
  end
end
