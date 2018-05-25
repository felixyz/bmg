module Bmg
  module Relation
    class Spied
      include Operator::Unary

      def initialize(operand, spy)
        @operand = operand
        @spy = spy
      end

    protected

      attr_reader :spy

    public

      def type
        operand.type
      end

      def each(&bl)
        spy.call(self)
        operand.each(&bl)
      end

      def to_ast
        [ :spied, operand.to_ast, spy ]
      end

    public ### algebra

      Algebra.public_instance_methods(false).each do |m|
        next if [:spied, :unspied].include?(m)

        define_method(m) do |*args, &bl|
          args = args.map{|a| a.respond_to?(:unspied) ? a.unspied : a }
          operand.send(m, *args, &bl).spied(spy)
        end
      end

      def unspied
        operand
      end

    public ### update

      def insert(*args, &bl)
        operand.insert(*args, &bl)
      end

      def delete(*args, &bl)
        operand.delete(*args, &bl)
      end

      def update(*args, &bl)
        operand.update(*args, &bl)
      end

    protected ### inspect

      def args
        [ spy ]
      end

    end # class Spied
  end # module Relation
end # module Bmg
