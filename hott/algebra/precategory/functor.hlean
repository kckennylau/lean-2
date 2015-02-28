/-
Copyright (c) 2014 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Module: algebra.precategory.functor
Authors: Floris van Doorn, Jakob von Raumer
-/

import .basic types.pi

open function category eq prod equiv is_equiv sigma sigma.ops is_trunc funext
open pi

structure functor (C D : Precategory) : Type :=
  (to_fun_ob : C → D)
  (to_fun_hom : Π ⦃a b : C⦄, hom a b → hom (to_fun_ob a) (to_fun_ob b))
  (respect_id : Π (a : C), to_fun_hom (ID a) = ID (to_fun_ob a))
  (respect_comp : Π {a b c : C} (g : hom b c) (f : hom a b),
    to_fun_hom (g ∘ f) = to_fun_hom g ∘ to_fun_hom f)

namespace functor

  infixl `⇒`:25 := functor
  variables {C D E : Precategory}

  attribute to_fun_ob [coercion]
  attribute to_fun_hom [coercion]

  -- The following lemmas will later be used to prove that the type of
  -- precategories forms a precategory itself
  protected definition compose [reducible] (G : functor D E) (F : functor C D) : functor C E :=
  functor.mk
    (λ x, G (F x))
    (λ a b f, G (F f))
    (λ a, calc
      G (F (ID a)) = G (ID (F a)) : {respect_id F a}
               ... = ID (G (F a)) : respect_id G (F a))
    (λ a b c g f, calc
      G (F (g ∘ f)) = G (F g ∘ F f)     : respect_comp F g f
                ... = G (F g) ∘ G (F f) : respect_comp G (F g) (F f))

  infixr `∘f`:60 := compose

  protected definition id [reducible] {C : Precategory} : functor C C :=
  mk (λa, a) (λ a b f, f) (λ a, idp) (λ a b c f g, idp)

  protected definition ID [reducible] (C : Precategory) : functor C C := id

  definition functor_eq_mk'' {F₁ F₂ : C → D} {H₁ : Π(a b : C), hom a b → hom (F₁ a) (F₁ b)}
    {H₂ : Π(a b : C), hom a b → hom (F₂ a) (F₂ b)} (id₁ id₂ comp₁ comp₂)
    (pF : F₁ = F₂) (pH : pF ▹ H₁ = H₂)
      : functor.mk F₁ H₁ id₁ comp₁ = functor.mk F₂ H₂ id₂ comp₂ :=
  apD01111 functor.mk pF pH !is_hprop.elim !is_hprop.elim

  definition functor_eq_mk' {F₁ F₂ : C → D} {H₁ : Π(a b : C), hom a b → hom (F₁ a) (F₁ b)}
    {H₂ : Π(a b : C), hom a b → hom (F₂ a) (F₂ b)} (id₁ id₂ comp₁ comp₂)
    (pF : F₁ ∼ F₂) (pH : Π(a b : C) (f : hom a b), eq_of_homotopy pF ▹ (H₁ a b f) = H₂ a b f)
      : functor.mk F₁ H₁ id₁ comp₁ = functor.mk F₂ H₂ id₂ comp₂ :=
  functor_eq_mk'' id₁ id₂ comp₁ comp₂ (eq_of_homotopy pF)
    (eq_of_homotopy (λc, eq_of_homotopy (λc', eq_of_homotopy (λf,
      begin
       apply concat, rotate_left 1, exact (pH c c' f),
       apply concat, rotate_left 1,
       exact (pi_transport_constant (eq_of_homotopy pF) (H₁ c c') f),
       apply (apD10' f),
       apply concat, rotate_left 1,
       exact (pi_transport_constant (eq_of_homotopy pF) (H₁ c) c'),
       apply (apD10' c'),
       apply concat, rotate_left 1,
       exact (pi_transport_constant (eq_of_homotopy pF) H₁ c),
       apply idp
      end))))

  definition functor_eq_mk_constant {F : C → D} {H₁ : Π(a b : C), hom a b → hom (F a) (F b)}
    {H₂ : Π(a b : C), hom a b → hom (F a) (F b)} (id₁ id₂ comp₁ comp₂)
    (pH : Π(a b : C) (f : hom a b), H₁ a b f = H₂ a b f)
      : functor.mk F H₁ id₁ comp₁ = functor.mk F H₂ id₂ comp₂ :=
  functor_eq_mk'' id₁ id₂ comp₁ comp₂ idp
                  (eq_of_homotopy (λc, eq_of_homotopy (λc', eq_of_homotopy (pH c c'))))

  definition functor_eq_mk {F₁ F₂ : C ⇒ D} : Π(p : to_fun_ob F₁ ∼ to_fun_ob F₂),
    (Π(a b : C) (f : hom a b), transport (λF, hom (F a) (F b)) (eq_of_homotopy p) (F₁ f) = F₂ f)
      → F₁ = F₂ :=
  functor.rec_on F₁ (λO₁ H₁ id₁ comp₁, functor.rec_on F₂ (λO₂ H₂ id₂ comp₂ p, !functor_eq_mk'))

  protected definition assoc {A B C D : Precategory} (H : functor C D) (G : functor B C) (F : functor A B) :
      H ∘f (G ∘f F) = (H ∘f G) ∘f F :=
  !functor_eq_mk_constant (λa b f, idp)

  protected definition id_left  (F : functor C D) : id ∘f F = F :=
  functor.rec_on F (λF1 F2 F3 F4, !functor_eq_mk_constant (λa b f, idp))

  protected definition id_right (F : functor C D) : F ∘f id = F :=
  functor.rec_on F (λF1 F2 F3 F4, !functor_eq_mk_constant (λa b f, idp))

  set_option apply.class_instance false
  -- "functor C D" is equivalent to a certain sigma type
  set_option unifier.max_steps 38500
  protected definition sigma_char :
    (Σ (to_fun_ob : C → D)
    (to_fun_hom : Π ⦃a b : C⦄, hom a b → hom (to_fun_ob a) (to_fun_ob b)),
    (Π (a : C), to_fun_hom (ID a) = ID (to_fun_ob a)) ×
    (Π {a b c : C} (g : hom b c) (f : hom a b),
      to_fun_hom (g ∘ f) = to_fun_hom g ∘ to_fun_hom f)) ≃ (functor C D) :=
  begin
    fapply equiv.MK,
      {intro S, fapply functor.mk,
        exact (S.1), exact (S.2.1),
        exact (pr₁ S.2.2), exact (pr₂ S.2.2)},
      {intro F,
        cases F with (d1, d2, d3, d4),
        exact (sigma.mk d1 (sigma.mk d2 (pair d3 (@d4))))},
      {intro F,
        cases F,
        apply idp},
      {intro S,
        cases S with (d1, S2),
        cases S2 with (d2, P1),
        cases P1,
        apply idp},
  end

  protected definition is_hset_functor
    [HD : is_hset D] : is_hset (functor C D) :=
  begin
    apply is_trunc_is_equiv_closed, apply equiv.to_is_equiv,
      apply sigma_char,
    apply is_trunc_sigma, apply is_trunc_pi, intros, exact HD, intro F,
    apply is_trunc_sigma, apply is_trunc_pi, intro a,
      {apply is_trunc_pi, intro b,
       apply is_trunc_pi, intro c, apply !homH},
    intro H, apply is_trunc_prod,
      {apply is_trunc_pi, intro a,
       apply is_trunc_eq, apply is_trunc_succ, apply !homH},
      {repeat (apply is_trunc_pi; intros),
       apply is_trunc_eq, apply is_trunc_succ, apply !homH},
  end

end functor


namespace category
  open functor

  --TODO: make this a structure
  definition precat_strict_precat : precategory (Σ (C : Precategory), is_hset C) :=
  precategory.mk (λ a b, functor a.1 b.1)
     (λ a b, @functor.is_hset_functor a.1 b.1 b.2)
     (λ a b c g f, functor.compose g f)
     (λ a, functor.id)
     (λ a b c d h g f, !functor.assoc)
     (λ a b f, !functor.id_left)
     (λ a b f, !functor.id_right)

  definition Precat_of_strict_cats := precategory.Mk precat_strict_precat

  namespace ops

    abbreviation SPreCat := Precat_of_strict_cats
    --attribute precat_strict_precat [instance]

  end ops

end category
