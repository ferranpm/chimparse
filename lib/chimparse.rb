require "chimparse/version"
require "strscan"

module Chimparse
  class << self
    def run(string, variables)
      ast = Parser.run(string)
      Filler.run(ast, variables)
    end
  end

  module Filler
    class << self
      def run(ast, variables)
        return "" unless ast
        if ast.class == Chimparse::Parser::Value
          ast.value + run(ast.next, variables)
        elsif ast.class == Chimparse::Parser::Variable
          variables[ast.name] + run(ast.next, variables)
        elsif ast.class == Chimparse::Parser::Conditional
          if variables[ast.variable]
            run(ast.left, variables)
          else
            run(ast.right, variables)
          end
        end
      end
    end
  end

  module Parser
    class Value < Struct.new(:value, :next)
    end
    class Variable < Struct.new(:name, :next)
    end
    class Conditional < Struct.new(:variable, :left, :right)
    end

    class << self
      def run(string)
        scanner = StringScanner.new(string)
        parse(scanner)
      end

      def parse(scanner)
        if scanner.scan(/\*\|(\w+)\|\*/)
          Variable.new(scanner[1].to_sym, parse(scanner))
        elsif scanner.scan(/\*\|(\w+):(\w+)?\|\*/)
          case scanner[1].downcase.to_sym
          when :if, :elseif
            Conditional.new(scanner[2].to_sym, run(scanner.scan_until(/(?=\*\|(elseif:\w+|else:|end:if)\|\*)/i)), parse(scanner))
          when :else
            parse(scanner)
          end
        elsif value = scanner.scan(/[^\*]+/)
          Value.new(value, parse(scanner)) if value
        end
      end
    end
  end
end
