module Yardbird
  class Writer

    def initialize(stream, options = {})
      @stream = stream
      @section_level = options[:section_level] || 0
      @indent_level = 0
    end

    def flush
      @stream.flush
    end

    def line(*args)
      if @need_blank
        @stream.write("\n")
        @need_blank = false
      end
      @stream.write(args.join)
      @stream.write("\n")
    end

    def section(title = nil, &block)
      heading(title) if title

      @section_level += 1
      yield
      @section_level -= 1
    end

    def blank
      @need_blank = true
    end

    def heading(s, options = {})
      if (anchor = options[:anchor])
        s = "<a name='#{anchor}'>#{s}</a>"
      end

      blank
      line(('#' * (@section_level + 1)) + " #{s}")
      blank
    end

    def bullet(s)
      line((' ' * (@indent_level * 2)) + "* #{s}")
    end

    def code_block(&block)
      indent(2) do
        yield
      end
    end

    def indent(count = 1, &block)
      @indent_level += count
      yield
      @indent_level -= count
    end

  end
end
