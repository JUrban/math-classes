Set Automatic Introduction.

Require
  Unicode.Utf8.
Require Import
  Morphisms Setoid Program
  canonical_names abstract_algebra
  universal_algebra.

Section contents. Variable σ: Signature.

  Notation OpType := (OpType (sorts σ)).

  Section homo.

  Context
    (A B: sorts σ → Type)
    `{ea: Π a, Equiv (A a)} `{eb: Π a, Equiv (B a)}
    `{ai: AlgebraOps σ A} `{bi: AlgebraOps σ B}.

  Section with_f. Context (f: Π a, A a → B a).

    Implicit Arguments f [[a]].

    Fixpoint Preservation {n: OpType}: op_type A n → op_type B n → Prop :=
      match n with
      | ne_list.one d => λ o o' => f o = o'
      | ne_list.cons x y => λ o o' => Π x, Preservation (o x) (o' (f x))
      end.

    Class HomoMorphism: Prop :=
      { homo_proper:> Π a, Setoid_Morphism (@f a)
      ; preserves: Π (o: σ), Preservation (ai o) (bi o)
      ; homo_source_algebra: Algebra σ A
      ; homo_target_algebra: Algebra σ B }.

    Context `{Π i, Equivalence (ea i)} `{Π i, Equivalence (eb i)} `{Π a, Setoid_Morphism (@f a)}.

    Global Instance Preservation_proper n:
      Proper (op_type_equiv _ _ _ ==> op_type_equiv _ B n ==> iff) (@Preservation n).
        (* todo: use equiv in the signature and see why things break *)
    Proof with auto.
     induction n; simpl; intros x y E x' y' E'.
      split; intro F. rewrite <- E, <- E'... rewrite E, E'...
     split; simpl; intros; apply (IHn _ _ (E _ _ (reflexivity _)) _ _ (E' _ _ (reflexivity _)))...
    Qed.

    Global Instance Preservation_proper'' n:
      Proper (eq ==> equiv ==> iff) (@Preservation n).
    Proof with auto.
     induction n; simpl; intros x y E x' y' E'.
      split; intro F. rewrite <- E, <- E'... rewrite E, E'...
     split; simpl; intros.
      subst.
      apply (IHn (y x0) (y x0) eq_refl (y' (f x0)) (x' (f x0)) ).
       symmetry.
       apply E'.
       reflexivity.
      apply H2.
     subst.
     apply (IHn (y x0) (y x0) eq_refl (y' (f x0)) (x' (f x0)) ).
      symmetry.
      apply E'.
      reflexivity.
     apply H2.
    Qed. (* todo: evil, get rid of *)

  End with_f.

  Lemma Preservation_proper' (f g: Π a, A a → B a)
   `{Π i, Equivalence (ea i)} `{Π i, Equivalence (eb i)} `{Π a, Setoid_Morphism (@f a)}:
    (Π a (x: A a), f a x = g a x) → (Π (n: OpType) x y, Proper equiv x → Proper equiv y →
      @Preservation f n x y →
      @Preservation g n x y).
  Proof.
     induction n.
      simpl.
      intros.
      rewrite <- H5.
      symmetry.
      intuition.
     simpl.
     intros.
     apply IHn.
       apply H3. reflexivity.
      apply H4. reflexivity.
     assert (y (g _ x0) = y (f _ x0)).
      apply H4.
      symmetry.
      apply H2.
     apply (Preservation_proper'' f n (x x0) (x x0) eq_refl _ _ H6).
     apply H5.
    Qed.

    Lemma HomoMorphism_Proper: Proper ((λ f g => Π a x, f a x = g a x) ==> iff) HomoMorphism.
      (* todo: use pointwise_thingy *)
    Proof with try apply _; intuition.
     constructor; intros [? ? ? ?]; simpl in *.
      repeat constructor...
       repeat intro.
       do 2 rewrite <- H.
       rewrite H0...
      apply (Preservation_proper' x y H (σ o) (ai o) (bi o))...
     repeat constructor...
      repeat intro.
      do 2 rewrite H.
      rewrite H0...
     assert (Π (a : sorts σ) (x0 : A a), y a x0 = x a x0). symmetry. apply H.
     apply (Preservation_proper' y x H0 (σ o) (ai o) (bi o))...
    Qed.

End homo.

  Global Instance id_homomorphism A
    `{Π a, Equiv (A a)} {ao: AlgebraOps σ A} `{!Algebra σ A}: HomoMorphism _ _ (λ _ => id).
  Proof with try apply _; intuition.
   constructor; intros...
   generalize (ao o).
   induction (σ o); simpl...
   reflexivity.
  Qed.

  Global Instance compose_homomorphisms A B C f g
    `{Π a, Equiv (A a)} `{Π a, Equiv (B a)} `{Π a, Equiv (C a)}
    {ao: AlgebraOps σ A} {bo: AlgebraOps σ B} {co: AlgebraOps σ C}
    {gh: HomoMorphism A B g} {fh: HomoMorphism B C f}: HomoMorphism A C (λ a => f a ∘ g a).
  Proof with try apply _; auto.
   pose proof (homo_source_algebra _ _ g).
   pose proof (homo_target_algebra _ _ g).
   pose proof (homo_target_algebra _ _ f).
   constructor; intros...
   generalize (ao o) (bo o) (co o) (preserves _ _ g o) (preserves _ _ f o).
   induction (σ o); simpl; intros; unfold compose.
    rewrite H5...
   apply (IHo0 _ (o2 (g _ x)))...
  Qed.

Implicit Arguments inverse [[A] [B] [Inverse]].

  Lemma invert_homomorphism A B f
    `{Π a, Equiv (A a)} `{Π a, Equiv (B a)}
    {ao: AlgebraOps σ A} {bo: AlgebraOps σ B}
    {fh: HomoMorphism A B f}
    `{inv: Π a, Inverse (f a)}:
    (Π a, Bijective (f a)) →
    HomoMorphism A B f → HomoMorphism B A inv.
  Proof with try assumption; try apply _.
   intros.
   destruct H2.
   constructor...
    intro. fold (inverse (f a)). apply _.
   intro.
   generalize (ao o) (bo o) (preserves _ _ f o)
     (algebra_propers o: Proper equiv (ao o)) (algebra_propers o: Proper equiv (bo o)).
   induction (σ o); simpl.
    intros.
    apply (injective (f t)).
    pose proof (surjective (f t) o1).
    transitivity o1...
    symmetry...
   intros P Q R S T x.
   apply IHo0.
     specialize (R (inv t x)).
     pose proof (surjective (f t) x) as E.
     rewrite E in R.
     assumption.
    apply S. reflexivity.
   apply T. reflexivity.
  Qed.


(*
    Instance eval_morphism `{Algebra σ}  A {V} (v: Vars σ A V):
      HomoMorphism (Term0 σ V) A (λ _ => eval σ v).
    Proof.
     constructor; repeat intro; try apply _.
     unfold AlgebraOps_instance_0.
     generalize (algebra_propers o: eval v (Op V o) = H o).
     generalize (Op V o) (H o).
     induction (operation_type σ o); simpl; repeat intro.
      assumption.
     apply IHo0. simpl.
     apply H1.
     destruct H0. reflexivity.
    Qed.
*)

End contents.
