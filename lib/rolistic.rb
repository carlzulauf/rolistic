require "rolistic/version"

require "active_support/concern"
require "active_support/core_ext/module/delegation"

module Rolistic
  extend ActiveSupport::Concern

  included do
    attr_reader :name, :abilities
    delegate :to_s, to: :name
  end

  def initialize(name = self.class.default)
    @name = name.to_sym if name
    @abilities = self.class.abilities_for(@name)
  end

  def can?(ability)
    abilities.member?(ability)
  end

  def default?
    name == self.class.default
  end

  def inspect
    to_s
  end

  class_methods do
    def load(raw)
      case raw
      when self then raw
      when String, Symbol
        new(raw) unless raw.blank?
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
      traits_map.fetch(trait) { [] }
    end

    def add_trait(trait, abilities)
      traits_map[trait] = abilities
    end

    def add_role(name, *traits_and_abilities, **options)
      abilities = traits_and_abilities.reduce([]) do |m, t_or_a|
        case t_or_a
        when Symbol then m + abilities_for_trait(t_or_a)
        when Array then m + t_or_a
        else t_or_a
        end
      end
      abilities_map[name] = abilities
      @default = name if options[:default]
    end

    def default
      @default if defined?(@default)
    end

    def available
      abilities_map.keys
    end
  end

  module Everything
    def self.member?(*)
      true
    end
  end
end
