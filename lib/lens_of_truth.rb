require 'fiddle'

module LensOfTruth
  def find_nearby spec = Object, limit: Float::INFINITY
    spec = proc if block_given?
    found = nil
    swivel = Fiddle::SIZEOF_UINTPTR_T / 2

    [-swivel, swivel].map { |coef|
      Thread.new do |i = 0|
        until found || i > limit
          begin
            obj = ObjectSpace._id2ref __id__ + coef * i += 1
            break found = obj if spec === obj
          rescue RangeError
          end
        end
      end
    }.each &:join

    found
  end

  refine(Object) { include LensOfTruth }
end
