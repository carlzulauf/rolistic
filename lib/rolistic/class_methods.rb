module Rolistic
  module ClassMethods
    def load(raw)
      case raw
      when self then raw
      when String, Symbol
        raw.to_s.match?(/\A[[:space:]]*\z/) ? new : new(raw)
      else
        new
      end
    end

    def dump(role)
      case role
      when String, Symbol then role.to_s
      when self
        role.to_s unless role.default?
      end
    end

    def abilities_map
      return @abilities_map if defined?(@abilities_map)
      @abilities_map = {}
    end

    def traits_map
      return @traits_map if defined?(@traits_map)
      @traits_map = {}
    end

    def abilities_for(name)
      abilities_map.fetch(name) { [] }
    end

    def abilities_for_trait(trait)
      traits_map.fetch(trait) { abilities_for(trait) }
    end

    def trait(trait, abilities)
      traits_map[trait] = abilities
    end
    alias_method :add_trait, :trait

    def role(name, *traits_and_abilities, **options)
      if traits_and_abilities.include?(:everything) && traits_and_abilities.size > 1
        raise DefinitionError, "role #{name.inspect} has access to everything " \
          "and cannot be combined with other traits or abilities"
      end
      abilities = traits_and_abilities.reduce([]) do |m, t_or_a|
        case t_or_a
        when :everything then Everything
        when Symbol
          trait_abilities = abilities_for_trait(t_or_a)
          if trait_abilities == Everything
            raise DefinitionError, "role #{name.inspect} cannot inherit from " \
              "#{t_or_a.inspect}, which has access to everything; " \
              "use :everything instead"
          end
          m + trait_abilities
        when Array then m + t_or_a
        else m
        end
      end
      abilities_map[name] = abilities == Everything ? Everything : abilities.dup.freeze
      @default = name if options[:default]
    end
    alias_method :add_role, :role

    def default
      @default if defined?(@default)
    end

    def available
      abilities_map.keys
    end
  end
end
