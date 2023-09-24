module BabySqueel
  class NotFoundError < StandardError # :nodoc:
    def initialize(model_name, name, strategies)
      super "There is no #{sentence(strategies)} " \
            "named '#{name}' for #{model_name}."
    end

    private

    def sentence(*words)
      if words.length < 3
        words.join ' or '
      else
        sentence words[0..-2].join(', '), words.last
      end
    end
  end

  class AssociationNotFoundError < StandardError  # :nodoc:
    def initialize(model_name, name)
      super "Association named '#{name}' was not found for #{model_name}."
    end
  end

  class AssociationAliasingError < StandardError  # :nodoc:
    MESSAGE =
      "Attempted to alias '%{association}' as '%{alias_name}', but the " \
      "association was implicitly joined. Either join the association " \
      "with `on` or remove the alias. For example:" \
      "\n\n  Post.joining { author }" \
      "\n  Post.joining { author.on(author_id == author.id) }\n\n"

    def initialize(association, alias_name)
      super format(MESSAGE, association: association, alias_name: alias_name)
    end
  end

  class PolymorphicSpecificationError < StandardError # :nodoc:
    MESSAGE =
      "'%{association}' is not a polymorphic association, therefore " \
      "the following expression is invalid:" \
      "\n\n  %{association}.of(%{klass})\n\n"

    def initialize(association, klass)
      super format(MESSAGE, association: association, klass: klass)
    end
  end

  class PolymorphicNotSpecifiedError < StandardError # :nodoc:
    MESSAGE =
      "'%{association}' is a polymorphic association, therefore " \
      "you must call #of when referencing the association. For example:" \
      "\n\n  %{association}.of(SomeModel)\n\n"

    def initialize(association)
      super format(MESSAGE, association: association)
    end
  end

  class AssociationComparisonError < StandardError # :nodoc:
    def initialize(name, other)
      super "You can't compare association '#{name}' to #{other}."
    end
  end
end
