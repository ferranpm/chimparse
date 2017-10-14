require "attr_extras"
require "chimparse/version"
require "cgi"

module Chimparse
  class Filler
    static_facade :run, :string, :text_vars, :html_vars

    def run
      @content = string.dup
      text_vars.each do |key, value|
        @content.gsub!(regexp_for(key), value.to_s)
      end
      html_vars.each do |key, value|
        @content.gsub!(regexp_for_html(key), value.to_s)
      end
      conditionals
    end

    def conditionals
      regexp = /\*\|IF:(\w+)\|\*(.*?)\*\|END:IF\|\*/m
      matches = regexp.match(content)
      return content unless matches
      array = else_if_branches(matches[0])
      other_value = else_branch(matches[0]) if has_else?(matches[0])
      @content = content.sub(regexp, first_true(Hash[*array]) || other_value.to_s)
      conditionals
    end

    def has_else?(string)
      string.match(/\*\|ELSE:\|\*/m)
    end

    def else_if_branches(string)
      end_array = has_else?(string) ? -3 : -1
      string.split(/\*\|IF:(.*?)\|\*|\*\|ELSEIF:(.*?)\|\*|\*\|(ELSE:|END:IF)\|\*/m)[1...end_array]
    end

    def else_branch(string)
      string.split(/\*\|ELSE:\|\*(.*?)\*\|END:IF\|\*/m)[1]
    end

    def first_true(hash)
      pair = hash.find { |k, _| value_for(k) }
      pair && pair[1]
    end

    def value_for(k)
      text_vars[k] || text_vars[k.to_sym] || html_vars[k] || html_vars[k.to_sym]
    end

    def regexp_for(key)
      /\*\|#{key}\|\*/
    end

    def regexp_for_html(key)
      /\*\|HTML:#{key}\|\*/
    end
  end
end
