require "rolistic/version"
require "rolistic/class_methods"
require "rolistic/everything"

module Rolistic
  def self.included(klass)
    klass.class_exec do
      attr_reader :name, :abilities
      extend ClassMethods
    end
  end

  def initialize(name = self.class.default)
    @name = name.to_sym if name
    @abilities = self.class.abilities_for(@name)
  end

  def to_s
    name.to_s
  end

  def can?(ability)
    abilities.member?(ability)
  end

  def default?
    name == self.class.default
  end

  def inspect
    "#<#{self.class} :#{to_s}>"
  end
end
