Set Automatic Introduction.

Require
  theory.rings categories.variety.
Require Import
  Program Morphisms
  abstract_algebra universal_algebra ua_homomorphisms.

Definition op := False.

Definition sig: Signature := Build_Signature unit op (False_rect _).

Definition Laws: EqEntailment sig → Prop := λ _ => False.

Definition theory: EquationalTheory := Build_EquationalTheory sig Laws.

(* Constructing an object in the variety from an instance of the class: *)

Section from_instance.

  Context A `{Setoid A}.

  Notation carriers := (λ _ => A).

  Instance: AlgebraOps sig carriers := λ o => False_rect _ o.

  Instance: Algebra sig carriers.
  Proof. constructor; intuition. Qed.

  Instance: InVariety theory carriers.
  Proof. constructor; intuition. Qed.

  Definition object: variety.Object theory := variety.object theory (λ _ => A).

End from_instance.

(* Constructing an instance of the class from an object in the variety: *)

Section from_variety.

  Context `{InVariety theory A}.

  Instance: Setoid (A tt).

End from_variety.

Lemma mor_from_sr_to_alg `{InVariety theory A} `{InVariety theory B}
  (f: Π u, A u → B u) `{!Setoid_Morphism (f tt)}: HomoMorphism sig A B f.
Proof with try apply _.
 constructor.
    intros []...
   intros [].
  change (Algebra theory A)...
 change (Algebra theory B)...
Qed.

Instance struct_from_var_to_class `{InVariety theory A}: Setoid (A tt).
