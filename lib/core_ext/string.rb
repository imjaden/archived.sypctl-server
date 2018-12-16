# encoding: utf-8
class String
  
  # Strips indentation in heredocs.
  #
  # For example in
  #
  #   if options[:usage]
  #     puts <<-USAGE.strip_heredoc
  #       This command does such and such.
  #
  #       Supported options are:
  #         -h         This message
  #         ...
  #     USAGE
  #   end
  #
  # the user would see the usage message aligned against the left margin.
  #
  # Technically, it looks for the least indented non-empty line
  # in the whole string, and removes that amount of leading whitespace.
  def strip_heredoc
    gsub(/^#{scan(/^[ \t]*(?=\S)/).min}/, "".freeze).tap do |stripped|
      stripped.freeze if frozen?
    end
  end

  # 'h e  l l   0, w  or  ld' => 'h e l l 0 w or ld'
  # 'i love   you 520 💋'     => 'i love you 520'
  # '我 爱  你💋 yeath'        => '我 爱 你 yeath'
  def escape_emoji
    a = self.dup.scan(/\p{Han}+|\w|\s|-|_/u)
    b = self.dup.chars
    return self if a == b

    (b - a.flatten.join.chars).each do |emoji|
      self.gsub!(emoji, '<:' + emoji.bytes.to_a.join(',') + ':>')
    end
    self
  end
end