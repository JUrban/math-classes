Set Automatic Introduction.

Require Import
  Relation_Definitions Morphisms Ring
  abstract_algebra interfaces.naturals theory.categories.
Require
  varieties.ring.

Section initial_maps.

  Variable Int: Type.

  Class IntegersToRing :=
    integers_to_ring: Π R `{RingMult R} `{RingPlus R} `{RingOne R} `{RingZero R} `{GroupInv R}, Int → R.

  Context `{IntegersToRing} `{Ring Int} `{Π `{Ring B}, Ring_Morphism (integers_to_ring B)}.

  Global Instance integer_initial_arrow: InitialArrow (ring.object Int).
   intro.
   exists (λ u => match u return Int → y u with tt => integers_to_ring (y tt) end).
   abstract (apply ring.encode_morphism_only, _).
  Defined. (* for some reason [Program] isn't cooperating here. look into it *)

End initial_maps.

Instance: Params (@integers_to_ring) 8.

Class Integers A {e plus mult zero one opp} `{IntegersToRing A} :=
  { integers_ring:> @Ring A e plus mult zero one opp
  ; integers_to_ring_mor:> Π `{Ring B}, Ring_Morphism (integers_to_ring A B)
  ; integers_initial:> Initial (ring.object A) }.

Section specializable.

  Context (Int N: Type) `{Equiv Int} `{RingMult Int} `{RingPlus Int} `{RingOne Int} `{GroupInv Int} `{RingZero Int} `{NaturalsToSemiRing N}.

  Class IntAsNat := int_as_nat: Π i: Int, { n: N | i = naturals_to_semiring N Int n } + { n: N | i = - naturals_to_semiring N Int n }.

  Class IntAbs := int_abs: Π i: Int, { n: N | naturals_to_semiring N Int n = i ∨ - naturals_to_semiring N Int n = i }.
  Definition int_abs' `{IntAbs}: Int → N := λ x => proj1_sig (int_abs x).

End specializable.

Instance: Params (@int_abs') 10.

Instance integer_precedes `{Integers Int}: Order Int := sr_precedes.

Instance: Params (@integer_precedes) 9.
