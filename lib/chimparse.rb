require "chimparse/version"
require "cgi"

module Chimparse
  extend self

  def fill(string, text_vars, html_vars)
    vars_as_list = merge_vars_as_list(text_vars, html_vars)
    content = vars_as_list.reduce(string) do |content, var|
      content.gsub(regexp_for(var["name"]), var["content"])
    end
    conditionals(content, vars_as_list)
  end

  def merge_vars_as_list(text_vars, html_vars)
    text_vars_as_list = text_vars.map do |k, v|
      { "name" => k, "content" => CGI::escapeHTML(v.to_s) }
    end
    html_vars_as_list = html_vars.map do |k, v|
      { "name" => k, "content" => v.to_s }
    end
    text_vars_as_list + html_vars_as_list
  end

  def conditionals(content, vars_as_list)
    regexp = /\*\|IF:(\w+)\|\*(.*?)\*\|END:IF\|\*/mi
    matches = regexp.match(content)
    return content unless matches
    array = else_if_branches(matches[0])
    other_value = else_branch(matches[0]) if has_else?(matches[0])
    new_content = content.sub(regexp, first_true(Hash[*array], vars_as_list) || other_value.to_s)
    conditionals(new_content, vars_as_list)
  end

  def has_else?(string)
    string.match(/\*\|ELSE:\|\*/mi)
  end

  def else_if_branches(string)
    end_array = has_else?(string) ? -3 : -1
    string.split(/\*\|IF:(.*?)\|\*|\*\|ELSEIF:(.*?)\|\*|\*\|(ELSE:|END:IF)\|\*/mi)[1...end_array]
  end

  def else_branch(string)
    string.split(/\*\|ELSE:\|\*(.*?)\*\|END:IF\|\*/mi)[1]
  end

  def first_true(hash, vars_as_list)
    pair = hash.find { |k, _| content_for(k, vars_as_list) }
    pair && pair[1]
  end

  def regexp_for(key)
    /\*\|(?:HTML:)?(#{key})\|\*/i
  end

  def content_for(key, vars_as_list)
    vars_as_list.find { |v| v["name"].match(/\b#{key}\b/i) }&.dig("content")
  end
end
