require 'baby_squeel/nodes'
require 'baby_squeel/relation'
require 'baby_squeel/association'

module BabySqueel
  class DSL < Relation
    class << self
      def evaluate(scope, &block) # :nodoc:
        Nodes.unwrap new(scope).evaluate(&block)
      end

      def evaluate_sifter(scope, *args, &block) # :nodoc:
        evaluate scope do |root|
          root.instance_exec(*args, &block)
        end
      end
    end

    # Create a Grouping node. This allows you to set balanced
    # pairs of parentheses around your SQL.
    #
    # ==== Arguments
    #
    # * +expr+ - The expression to group.
    #
    # ==== Example
    #     Post.where.has{_([summary, description]).in(...)}
    #     #=> SELECT "posts".* FROM "posts" WHERE ("posts"."summary", "posts"."description") IN (...)"
    #     Post.select{[id, _(Comment.where.has{post_id == posts.id}.selecting{COUNT(id)})]}.as('comment_count')}
    #     #=> SELECT "posts"."id", (SELECT COUNT("comments"."id") FROM "comments" WHERE "comments.post_id" = "posts"."id") AS "comment_count" FROM "posts"
    #
    def _(expr)
      expr = Arel.sql(expr.to_sql) if expr.is_a? ::ActiveRecord::Relation
      Nodes.wrap Arel::Nodes::Grouping.new(expr)
    end

    # Create a SQL function. See Arel::Nodes::NamedFunction.
    #
    # ==== Arguments
    #
    # * +name+ - The name of a SQL function (ex. coalesce).
    # * +args+ - The arguments to be passed to the SQL function.
    #
    # ==== Example
    #     Post.selecting { func('coalesce', id, 1) }
    #     #=> SELECT COALESCE("posts"."id", 1) FROM "posts"
    #
    def func(name, *args)
      Nodes.wrap Arel::Nodes::NamedFunction.new(name.to_s, args)
    end

    # Generate an EXISTS subselect from an ActiveRecord::Relation
    #
    # ==== Arguments
    #
    # * +relation+ - An ActiveRecord::Relation
    #
    # ==== Example
    #     Post.where.has { exists Post.where(id: 1) }
    #
    def exists(relation)
      func 'EXISTS', sql(relation.to_sql)
    end

    # Generate a NOT EXISTS subselect from an ActiveRecord::Relation
    #
    # ==== Arguments
    #
    # * +relation+ - An ActiveRecord::Relation
    #
    # ==== Example
    #     Post.where.has { not_exists Post.where(id: 1) }
    #
    def not_exists(rel)
      func 'NOT EXISTS', sql(rel.to_sql)
    end

    # See Arel::sql
    def sql(value)
      Nodes.wrap ::Arel.sql(value)
    end

    # Quotes a string and marks it as SQL
    def quoted(value)
      sql _scope.connection.quote(value)
    end

    private

    def resolver
      @resolver ||= Resolver.new(self, [:function, :column, :association])
    end
  end
end
