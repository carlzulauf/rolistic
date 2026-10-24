require "rolistic/version"
require "rolistic/errors"
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
    ability = ability.to_sym if ability.is_a?(String)
    abilities.member?(ability)
  end

  def default?
    name == self.class.default
  end

  # roles are value objects: abilities are derived from the class and name, so
  # two roles of the same class and name are equal. This lets ActiveRecord see
  # assigning an equivalent role as no change.
  def ==(other)
    other.class == self.class && other.name == name
  end
  alias_method :eql?, :==

  def hash
    [self.class, name].hash
  end

  # name.inspect quotes names that need it and shows a missing name as nil.
  # roles without a definition have no abilities, so they are marked as such.
  def inspect
    undefined = " (undefined)" unless self.class.find_role(name)
    "#<#{self.class} #{name.inspect}#{undefined}>"
  end
end
