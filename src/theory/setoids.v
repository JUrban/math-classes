(* To be imported qualified. *)

Set Automatic Introduction.

Require Import
  Morphisms Setoid abstract_algebra Program.

Instance: Equiv Prop := iff.
Instance: Setoid Prop.

Instance: Π A `{Setoid B}, Setoid (A → B).
Proof. constructor; repeat intro; firstorder. Qed.

Instance sig_Setoid `{Setoid A} (P: A → Prop): Setoid (sig P).
Instance sigT_Setoid `{Setoid A} (P: A → Type): Setoid (sigT P).

Section simple_product.

  Context `{Setoid A} `{Setoid B}.

  Global Instance: Equiv (A * B) := λ p q => fst p = fst q ∧ snd p = snd q.

  Global Instance: Setoid (A * B).
  Proof. firstorder. Qed.

  Global Instance: Setoid_Morphism (@fst A B).
  Proof. constructor; try apply _. firstorder. Qed.

  Global Instance: Setoid_Morphism (@snd A B).
  Proof. constructor; try apply _. firstorder. Qed.

End simple_product.

Section product.

  Context (I: Type) (c: I → Type) `{Π i, Equiv (c i)} `{Π i, Setoid (c i)}.

  Let product: Type := Π i, c i.

  Global Instance: Equiv product := `(Π i, x i = y i).

  Global Instance: Setoid product.
  Proof.
   constructor.
     repeat intro. reflexivity.
    intros ?? E ?. symmetry. apply E.
   intros ? y ??? i. transitivity (y i); firstorder.
  Qed.

  Global Instance projection_morphism i: Setoid_Morphism (λ c: product => c i).
  Proof. firstorder. Qed.

End product.

Instance id_morphism `{Setoid T}: Setoid_Morphism (@id T).

Instance compose_morphisms (A B C: Type)
  `{!Equiv A} `{!Equiv B} `{!Equiv C} (f: A → B) (g: B → C)
  {P: Setoid_Morphism f} {Q: Setoid_Morphism g}: Setoid_Morphism (g ∘ f).
Proof. destruct P, Q. constructor; apply _. Qed.

Instance: Π `{Setoid_Morphism A B f} `{!Inverse f}, Bijective f → Setoid_Morphism (inverse f).
Proof.
 intros.
 pose proof (setoidmor_a f).
 pose proof (setoidmor_b f).
 constructor; try apply _.
 repeat intro. apply (injective f).
 pose proof (surjective f) as E.
 rewrite (E x), (E y). assumption.
Qed.

Instance morphism_proper `{ea: Equiv A} `{eb: Equiv B}: Proper ((=) ==> (=)) (@Setoid_Morphism A B _ _).
Proof.
 cut (Π (x y: A → B), x = y → Setoid_Morphism x → Setoid_Morphism y).
  firstorder.
 intros x y E [AS BS P].
 constructor; try apply _. intros v w E'.
 rewrite <- (E v), <- (E w), E'. reflexivity.
Qed.

Lemma projected_equivalence `{Setoid B} `{f: A → B}: Equivalence (λ x y => f x = f y).
Proof with auto.
 constructor; repeat intro.
   reflexivity.
  symmetry...
 transitivity (f y)...
Qed.
