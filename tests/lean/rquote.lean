--
namespace foo
 constant f : nat → nat
 constant g : nat → nat
end foo

namespace boo
 constant f : nat → nat
end boo

open foo boo

#check ``f

#check ``g

open int

#check ``has_add.add

#check ``nat_abs

#check `f
#check `foo.f

namespace bla
section
  parameter A : Type
  definition ID : A → A := λ x, x

  #check ``ID

end
end bla
