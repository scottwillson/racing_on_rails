module Categories
  module NameNormalization
    extend ActiveSupport::Concern

    RACING_ASSOCIATIONS = %{ ABA ATRA CBRA GBRA MBRA NABRA OBRA WSBA }

    included do
      def self.find_or_create_by_normalized_name(name)
        Category.find_or_create_by name: normalized_name(name)
      end

      def self.normalized_name(name)
        _name = strip_whitespace(name)
        _name = split_camelcase(_name)
        _name = normalize_punctuation(_name)
        _name = normalize_case(_name)
        _name = replace_roman_numeral_categories(_name)
        normalize_spelling _name
      end

      def self.strip_whitespace(name)
        if name
          name = name.to_s.strip
          name = name.gsub(/\s+/, " ")
          # E.g., 30 - 39
          name = name.gsub(/(\d+)\s?-\s?(\d+)/, '\1-\2')

          # 1 / 2 => 1/2
          name = name.gsub(/\s?\/\s?/, "/")

          # 6- race
          name = name.gsub(/\s+-\s?/, " - ")
          name = name.gsub(/\s?-\s+/, " - ")

          # 40 + => 40+
          name = name.gsub(/(\d+)\s+\+/, '\1+')

          # U 14, U-14
          name = name.gsub(/U[ -](\d\d)/, 'U\1')
        end
        name
      end

      def self.split_camelcase(name)
        if name && !(name.downcase == name || name.upcase == name)
          name = name.gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1 \2')
          name = name.gsub(/([a-z\d])([A-Z])/,'\1 \2')
        end

        # Men30+, W4
        name = name.gsub(/(masters|master|men|women|m|w)(\d)/i, '\1 \2')

        name
      end

      def self.normalize_punctuation(name)
        if name
          # trailing punctuation
          name = name.gsub(/[\/:.,"]\z/, "")

          # Men (Juniors)
          name = name.gsub(/\((masters|master|juniors|junior|men|women)\)/i, '\1')

          name = normalize_ability_punctuation(name)
          name = normalize_age_group_punctuation(name)

          name = name.gsub(%r{//+}, "/")
          name = name.gsub(%r{\+ -( ?)}, "+ ")
          name = name.gsub(%r{\+ -( ?)}, "+ ")
          name = name.gsub("*", "")

          # (200+)
          name = name.gsub(/\((\d\d+\+)\)/i, '\1')

          # split_camelcase may have alredy split this
          name = name.gsub(/\((\d ?k pursuit)\)/i, '\1')
          name = name.gsub(/\((\d ?k)\)/i, '\1')
          name = name.gsub(/six[ -]?day/i, "Six-day")

          name = name.gsub(/(\d+) day/i, '\1-Day')
          name = name.gsub(/(\d+) hour/i, '\1-Hour')
          name = name.gsub(/(\d+) mile/i, '\1-Mile')

          name = name.gsub(/(\d+) man/i, '\1-Man')
          name = name.gsub(/(\d+) person/i, '\1-Person')
          name = name.gsub(/(one|two|three|four|five|six)[ -]man/i, '\1-Man')
          name = name.gsub(/(one|two|three|four|five|six)[ -]person/i, '\1-Person')

          unless name[/laps/i]
            name = name.gsub(/(\d+) lap/i, '\1-Lap')
          end
        end
        name
      end

      # 1 2, 2 3, 3.4.5, 2-3-4 to 1/2/3
      def self.normalize_ability_punctuation(name)
        5.downto(2).each do |length|
          [ "P", 1, 2, 3, 4, 5 ].each_cons(length) do |cats|
            [ " ", ".", "-" ].each do |delimiter|
              # Don't combine 1/2/3 40+
              unless name[%r{/\d#{delimiter}\d\d}]
                name = name.gsub(%r{( ?)#{cats.join(delimiter)}( ?)}, "\\1#{cats.join("/")}\\2")
              end
            end
          end
        end
        name
      end

      def self.normalize_age_group_punctuation(name)
        (10..17).each do |age|
          name = name.gsub(%r{#{age}/#{age + 1}}, "#{age}-#{age + 1}")
        end

        (10..16).each do |age|
          name = name.gsub(%r{#{age}/#{age + 2}}, "#{age}-#{age + 2}")
        end

        (10..15).each do |age|
          name = name.gsub(%r{#{age}/#{age + 3}}, "#{age}-#{age + 3}")
        end

        (30..90).each do |age|
          name = name.gsub(%r{#{age}/#{age + 9}}, "#{age}-#{age + 5}")
          name = name.gsub(%r{#{age}/#{age + 4}}, "#{age}-#{age + 9}")
        end
        name
      end

      def self.normalize_case(name)
        if name
          name = name.split.map do |token|
            # Calling RacingAssociation.current triggers an infinite loop
            if token[/of/i]
              "of"
            elsif token[/\Ai+\z/i] || token[/\A\d[a-z]/i]
              token.upcase
            elsif token[/\Ac{1,2}x\z/i] || token[/\At{2,3}\z/i] || token[/\Abmx\z/i]
              token.upcase
            elsif token[/\Att-?\w*/i] || token[/\A-?tt\w*/i]
              token.gsub(/tt/i, "TT")
            elsif token[/\Attt-?\w*/i] || token[/\A-?ttt\w*/i]
              token.gsub(/ttt/i, "TTT")
            elsif token.in?(RACING_ASSOCIATIONS) || token.in?(%w{ MTB SS TT TTT }) || token[/\A[A-Z][a-z]/]
              token
            else
              token.downcase.gsub(/\A[a-z]/) { $&.upcase }.gsub(/[[:punct:]][a-z]/) { $&.upcase }
            end
          end.join(" ")
        end
        name
      end

      def self.replace_roman_numeral_categories(name)
        if name
          name = name.split.map do |token|
            if token == "I"
              "1"
            elsif token == "II"
              "2"
            elsif token == "III"
              "3"
            elsif token == "IV"
              "4"
            elsif token == "V"
              "5"
            else
              token
            end
          end.join(" ")
        end
        name
      end

      def self.normalize_spelling(name)
        if name
          name = name.split.map do |token|
            if token[/\A(cat|caat|categpry|categroy|cateogry|categegory|catgory|caegory|ct)\.?\z/i]
              "Category"
            elsif token[/\ds\z/i]
              token.gsub(/(\d)s\z/i, '\1')
            elsif token == "1/23" || token == "12/3" || token == "123"
              "1/2/3"
            elsif token[/\A(sr|sen)\.?\z/i] || token[/\Aseniors\z/i] || token[/\Asenoir\z/i]
              "Senior"
            elsif token[/\Ajr\.?\z/i] || token[/\Ajuniors\z/i] || token[/\Ajrs\.?\z/i] || token[/\Ajunior(s)?:\z/i] ||
               token[/\Ajnr\.?\z/i]
              "Junior"
            elsif token[/\Awjr\z/i]
              "Junior Women"
            elsif token[/\Amaster\z/i] || token[/\Amas\z/i] || token[/\Amstr?\z/i] || token[/\Amaster's\z/i] ||
              token[/\Amast.?\z/i] || token[/\Amaasters\z/i] || token[/\Amastes\z/i] || token[/\Amastres\z/i] ||
              token[/\Amater\z/i] || token[/\Amaser\z/i] || token[/\Amst\z/i]

              "Masters"
            elsif token[/\Amas\d\d\+\z/i]
              token.gsub(/\Amas(\d\d\+)\z/i, 'Masters \1')
            elsif token[/\Awmas\z/i]
              "Masters Women"
            elsif token[/\Aveteran'?s\z/i] || token[/\Aveteren\z/i] || token[/\A(vet|vt)\.?\z/i]
              "Veteran"
            elsif token[/\Avsty\z/i]
              "Varsity"
            elsif token[/\Aspt\z/i]
              "Sport"
            elsif token[/\Ajv\z/i]
              "Junior Varsity"
            elsif token[/\Aclydesdales\z/i] || token[/\Aclyde(s)?\z/i] || token[/\Aclydsdales\z/i]
              "Clydesdale"
            elsif token[/\Awomen'?s\z/i] || token[/\Awoman'?s\z/i]
              "Women"
            elsif token[/\Awmn?\.?\z/i] || token[/\Awom\.?\z/i] || token[/\Aw\z/i] || token[/\Awmen?\.?\z/i] || token[/\Awomenen\z/i]
              "Women"
            elsif token[/\Afemale\z/i] || token[/\Awommen:\z/i] || token[/\Aw\z/i]
              "Women"
            elsif token[/\Amen'?s\z/i] || token[/\Amale\Z/i] || token[/\Amen:\z/i] || token[/\Amed\z/i] || token[/\Amens's\z/i]
              "Men"
            elsif token[/\A\dmen\z/i]
              token.gsub(/\A(\d)men\z/i, '\1 Men')
            elsif token[/\Aco(-)?ed\z/i]
              "Co-ed"
            elsif token[/\Abeg?\.?\z/i] || token[/\Abg\.?\z/i] || token[/\Abegin?\.?\z/i] || token[/\Abeginners\z/i] || token[/\Abeg:\z/i] ||
              token[/\ABeginning\z/i]

              "Beginner"
            elsif token[/\A(exp|expt|ex|exeprt|exb|exper|exprert)\.?\z/i]
              "Expert"
            elsif token[/\Asprt\.?\z/i]
              "Sport"
            elsif token[/\Asinglespeeds?\z/i] || token[/\Ass\z/i]
              "Singlespeed"
            elsif token[/\Atand?\z/i] || token[/\Atandems\z/i]
              "Tandem"
            elsif token[/\Auni\z/i] || token[/\AUnicycles\z/i]
              "Unicycle"
            elsif token[/\A\d\dU\z/i]
              # 14U => U14
              token.gsub(/(\d\d)U/, 'U\1')
            elsif token[/\A\d\d>\z/i]
              # Example: Men 30> => Men 30+
              token.gsub(/(\d\d)>/, '\1+')
            elsif token[/\Apursuite\z/i]
              "Pursuit"
            elsif token == "Mdison"
              "Madison"
            elsif token == "Kilom"
              "Kilometer"
            elsif token == "Siixday"
              "Six-day"
            elsif token == "&"
              "and"
            else
              token
            end
          end.join(" ")

          name = normalize_category_spelling(name)
          name = normalize_junior_spelling(name)
          name = normalize_masters_spelling(name)
          name = normalize_ability_spelling(name)
          name = normalize_mtb_spelling(name)
          name = normalize_competition_spelling(name)
          name = normalize_time_spelling(name)
          name = normalize_weight_spelling(name)
          name = normalize_distance_spelling(name)
          name = normalize_order(name)

          name = name.gsub(/\bAnd\b/, "and")

          name = name.gsub(/\A\d+\) ?/, "")
        end
        name
      end

      def self.normalize_category_spelling(name)
        name.gsub(/cat ?(\d)/i, 'Category \1').
             gsub(/category(\d)/i, 'Category \1').
             gsub(/category (\d)\/ /i, 'Category \1 ')
      end

      # 14 and Under, 14U, 14 & U
      def self.normalize_junior_spelling(name)
        name.gsub(/junior m /i, 'Junior Men ').
             gsub(/Espior/i, 'Espoir ').
             gsub(/(\d+) (and|&) U\z/i, 'U\1').
             gsub(/(\d+)& U\z/i, 'U\1').
             gsub(/under (\d{2,3})/i, 'U\1').
             gsub(/(\d+) ?(and)? ?(under|younger|up to)/i, 'U\1').
             gsub(/(\d+) ?& ?under|younger|up to/i, 'U\1').
             gsub(/ 0-(\d+)/i, ' U\1').
             gsub(/ U (\d+)/i, ' U\1')
      end

      def self.normalize_masters_spelling(name)
        name = name.gsub(/mm (\d\d)\+/i, 'Masters Men \1+').
                    gsub(/\Am (\d\d)\+/i, 'Masters \1+').
                    gsub(/ m (\d\d)\+/i, ' Masters \1+')

        if name[/\bM [1-5]+\b/i]
          categories = name[/M ([1-5]+)/i, 1].split("")
          name = name.gsub(/M [1-5]+/i, "Men #{categories.join("/")}")
        end

        name.gsub(/masters (\d\d)\Z/i, 'Masters \1+').
             gsub(/masters (\d\d) /i, 'Masters \1+ ').
             gsub(/(\d+) ?and ?(over|older)/i, '\1+').
             gsub(/(\d+) ?& ?(over|older)/i, '\1+')
      end

      def self.normalize_ability_spelling(name)
        name.gsub(%r{M P/1/2}i, "Men Pro/1/2").
             gsub(%r{P/1/2}i, "Pro/1/2").
             gsub(/Pro.*1\/2/i, "Pro/1/2").
             gsub(/Pr([\/, ])/i, 'Pro\1')
      end

      def self.normalize_mtb_spelling(name)
        name.gsub(/semi( ?)pro/i, "Semi-Pro").
             gsub(/exp\/pro/i, "Pro/Expert").
             gsub(/varsity junior/i, "Junior Varsity").
             gsub(/jr. varsity/i, "Junior Varsity").

             gsub(/single speeds?/i, "Singlespeed").
             gsub(/sgl spd/i, "Singlespeed").
             gsub(/sgl speed/i, "Singlespeed").

             gsub(/hard tail/i, "Hardtail")
      end

      def self.normalize_time_spelling(name)
        name.gsub(/( ?)hr( ?)/i, '\1Hour\2').
             gsub(/(\d+) ?hour/i, '\1-Hour')
      end

      def self.normalize_weight_spelling(name)
        name.gsub(/(\d{3})\+ (lbs|lb)(\.)?/i, '\1+').
             gsub(/(\d{3})( )?(lbs|lb) \+/i, '\1+').
             gsub(/(\d{3})( )?(lbs|lb)(.)?\+/i, '\1+').
             gsub(/\((\d\d+\+)\)/i, '\1')
      end

      def self.normalize_distance_spelling(name)
        name = name.gsub(/\bmeter(s)?/i, "m").
                    gsub(/metre/i, "m").
                    gsub(/(\d) ?m\b/i, '\1m').
                    gsub(/(\d\d\d\d) ?m\b/i, '\1m')

        # Not masters Kilometer
        unless name[/\d\d-\d\d Kilometer/]
          name = name.gsub(/(\d+) ?(kilometer|kilometre|kilos|km|k)\b/i, '\1K')
        end
        name
      end

      def self.normalize_competition_spelling(name)
        name.gsub(/hot spot/i, "Hotspot").
             gsub(/iron man/i, "Ironman").
             gsub(/multi[ -]person/i, "Multiperson").
             gsub(/miss.*out/i, "Miss and Out").
             gsub(/win.*out/i, "Win and Out").
             gsub(/Eddie/, "Eddy")
      end

      # Men Masters => Masters Men
      def self.normalize_order(name)
        [ "Masters", "Juniors", "Beginner", "Novice", "Sport", "Expert", "Semi-Pro", "Elite", "Singlespeed" ].each do |cat|
          name = name.gsub("Men #{cat}", "#{cat} Men")
          name = name.gsub("Women #{cat}", "#{cat} Women")
        end
        name
      end
    end
  end
end
