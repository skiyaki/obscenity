module Obscenity
  class Base
    class << self

      def blacklist
        @blacklist ||= set_list_content(Obscenity.config.blacklist)
      end

      def blacklist=(value)
        @blacklist = value == :default ? set_list_content(Obscenity::Config.new.blacklist) : value
      end

      def whitelist
        @whitelist ||= set_list_content(Obscenity.config.whitelist)
      end

      def whitelist=(value)
        @whitelist = value == :default ? set_list_content(Obscenity::Config.new.whitelist) : value
      end

      def word_size
        @word_size = Obscenity.config.word_size
      end

      def word_size=(value)
        Obscenity.config.word_size = value
        word_size
      end

      def blacklist_by_site(site_code)
        list = blacklist["default"] || []
        list += blacklist["#{site_code}"] if blacklist["#{site_code}"].present?
        list
      end

      def whitelist_by_site(site_code)
        list = []
        list += whitelist["#{site_code}"] if whitelist["#{site_code}"].present?
        list
      end

      def allow_all?(site_code)
        whitelist["#{site_code}"].present? && whitelist["#{site_code}"]["all"] == true
      end

      def profane?(text, site_code = nil)
        return(false) unless text.to_s.size >= word_size
        return(false) if allow_all?(site_code)
        blacklist_by_site(site_code).each do |foul|
          return(true) if text =~ /#{foul}/i && !whitelist_by_site.include?(foul)
        end
        false
      end

      def sanitize(text, site_code = nil)
        return(text) unless text.to_s.size >= word_size
        return(text) if allow_all?(site_code)
        blacklist_by_site(site_code).each do |foul|
          text.gsub!(/#{foul}/i, replace(foul)) unless whitelist_by_site(site_code).include?(foul)
        end
        @scoped_replacement = nil
        text
      end

      def replacement(chars)
        @scoped_replacement = chars
        self
      end

      def offensive(text, site_code = nil)
        words = []
        return(words) unless text.to_s.size >= word_size
        return(words) if allow_all?(site_code)
        blacklist_by_site(site_code).each do |foul|
          words << foul if text =~ /#{foul}/i && !whitelist_by_site(site_code).include?(foul)
        end
        words.uniq
      end

      def replace(word)
        content = @scoped_replacement || Obscenity.config.replacement
        case content
        when :vowels then word.gsub(/[aeiou]/i, '*')
        when :stars  then '*' * word.size
        when :nonconsonants then word.gsub(/[^bcdfghjklmnpqrstvwxyz]/i, '*')
        when :default, :garbled then '$@!#%'
        else content
        end
      end

      private
      def set_list_content(list)
        case list
        when Array then list
        when String, Pathname then YAML.load_file( list.to_s )
        else []
        end
      end

    end
  end
end
