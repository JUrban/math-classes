Set Automatic Introduction.

Require Import
  Relation_Definitions Morphisms Setoid Program
  abstract_algebra interfaces.functors theory.categories.

Record Object := object
  { obj:> Type
  ; Arrows_inst: Arrows obj
  ; Equiv_inst: Π x y: obj, Equiv (x ⟶ y)
  ; CatId_inst: CatId obj
  ; CatComp_inst: CatComp obj
  ; Category_inst: Category obj }.

Implicit Arguments object [[Arrows_inst] [Equiv_inst] [CatId_inst] [CatComp_inst] [Category_inst]].
Existing Instance Arrows_inst.
Existing Instance Equiv_inst.
Existing Instance CatId_inst.
Existing Instance CatComp_inst.
Existing Instance Category_inst.
    (* Todo: Ask mattam for [Existing Instance foo bar bas.] *)

(* The above would be much more elegantly written as

  Inductive Object := object (obj: Type) `{Category obj}.

Unfortunately, that doesn't register the coercion and class instances. *)

Record Arrow (x y: Object): Type := arrow
  { map_obj:> obj x → obj y
  ; Fmap_inst: Fmap map_obj
  ; Functor_inst: Functor map_obj _ }.

Implicit Arguments arrow [[x] [y]].
Existing Instance Fmap_inst.
Existing Instance Functor_inst.

Hint Extern 4 (Arrows Object) => exact Arrow: typeclass_instances.
  (* Matthieu is adding [Existing Instance (c: T).], which is nicer. *)

Section contents.

  Implicit Arguments map_obj [[x] [y]].

  Section more_arrows. Context (x y: Object).

    Global Program Instance e: Equiv (x ⟶ y) := λ a b =>
      exists X: Π _, isoT _ _, Π (p q: x) (r: p ⟶ q),
       fmap a r ◎ snd (X p) = snd (X q) ◎ fmap b r.

    Let e_refl: Reflexive e.
    Proof.
     intro a.
     exists (λ v => refl_arrows (a v)).
     intros ???. simpl.
     rewrite id_l, id_r. reflexivity.
    Qed.

    Program Let sym_arrows (a b: x → y) (v: x) (p: isoT (a v) (b v)): isoT (b v) (a v)
        := (snd p, fst p).

    Next Obligation. destruct p. simpl in *. firstorder. Qed.

    Let e_sym: Symmetric e.
    Proof.
     intros ?? [x1 H].
     exists (λ v => sym_arrows _ _ _ (x1 v)). simpl.
     intros ???.
     pose proof (H p q r).
     destruct (x1 p), (x1 q). simpl in *.
     apply (arrows_between_isomorphic_objects _  _ _ _ _ _ _ _ _ _ u u0).
     assumption.
    Qed. (* todo: clean up *)

    Program Let trans_arrows (x0 y0 z: x → y) (v: x)
     (x1: sig (λ (p: (x0 v ⟶ y0 v) * _) => uncurry iso_arrows p))
     (x2: sig (λ (p: (y0 v ⟶ z v) * _) => uncurry iso_arrows p)): (* todo: use isoT *)
      isoT (x0 v) (z v) := (fst x2 ◎ fst x1, snd x1 ◎ snd x2).

    Next Obligation. Proof with assumption.
     destruct H as [? H1], H0 as [? H2]. unfold uncurry. simpl in *.
     split. rewrite <- comp_assoc, (comp_assoc a0 a2 a1), H0, id_l...
     rewrite <- comp_assoc, (comp_assoc a1 a a0), H1, id_l...
    Qed.

    Let e_trans: Transitive e.
    Proof.
     intros a b c [f H] [g H0].
     exists (λ v => trans_arrows _ _ _ _ (f v) (g v)).
     simpl. intros ? ? ?.
     generalize (H p q r), (H0 p q r).
     clear H H0. intros E E'.
     rewrite comp_assoc, E, <- comp_assoc, E', comp_assoc.
     reflexivity.
    Qed.

    Instance: Equivalence e.
    Global Instance: Setoid (x ⟶ y).

  End more_arrows.

  Let obj_iso (x: Object): Equiv x := @iso x _ _ _ _.

  Global Instance: Π (x y: Object) (a: x ⟶ y), Setoid_Morphism (map_obj a).
  Proof with try apply _.
   constructor...
   intros v w [[f g] [E F]].
   exists (fmap a f, fmap a g).
   unfold uncurry. destruct a. simpl in *.
   split; rewrite <- preserves_comp...
    rewrite E. apply preserves_id...
   rewrite F. apply preserves_id...
  Qed. (* Putting this in the "arrows" section above (where it belongs) triggers a Coq bug. *)

  Global Instance: CatId Object := λ _ => arrow id _ _.

  Global Program Instance: CatComp Object := λ _ _ _ x y => arrow (x ∘ y) _ _.

  Program Let proper_arrows (x y z: Object) (x0 y0: y ⟶ z) (x1 y1: x ⟶ y)
    (f: Π v, @isoT _ _ _ _ _ (map_obj x0 v) (map_obj y0 v))
    (g: Π v, @isoT _ _ _ _ _ (map_obj x1 v) (map_obj y1 v)) (v: x):
      @isoT _ _ _ _ _ (map_obj x0 (map_obj x1 v)) (map_obj y0 (map_obj y1 v))
   := (fst (f (y1 v)) ◎ fmap x0 (fst (g v)), fmap x0 (snd (g v)) ◎ snd (f (y1 v))).
     (* Todo: Investigate why things go wrong without the underscores. *)

  Next Obligation. Proof with try apply _; intuition.
   destruct (f (y1 v)) as [? [e0 e1]].
   destruct (g v) as [? [e2 e3]].
   split; simpl in *.
    rewrite <- comp_assoc.
    rewrite (comp_assoc _ (fmap x0 _) (fmap x0 _)).
    rewrite <- preserves_comp, e2, preserves_id, id_l...
   rewrite <- comp_assoc.
   rewrite (comp_assoc (fmap x0 _) _ _).
   rewrite e1, id_l, <- preserves_comp, e3, preserves_id...
  Defined.

  Global Instance: Π x y z: Object, Proper (equiv ==> equiv ==> equiv) ((◎): (y ⟶ z) → (x ⟶ y) → (x ⟶ z)).
  Proof with try apply _.
   repeat intro.
   unfold e.
   destruct H.
   destruct H0.
   simpl in *.
   exists (proper_arrows x y z x0 y0 x1 y1 x2 x3).
   intros.
   simpl.
   pose proof (H0 p q r). clear H0.
   destruct (x3 p) as [[a a0] [e0 e1]], (x3 q) as [[a1 a2] [e2 e3]]. clear x3.
   simpl in *.
   change (
     fmap x0 (fmap x1 r) ◎ (fmap x0 a0 ◎ snd (` (x2 (y1 p)))) =
     fmap x0 a2 ◎ snd (` (x2 (y1 q))) ◎ fmap y0 (fmap y1 r)).
   pose proof (H (y1 p) (y1 q) (fmap y1 r)). clear H.
   destruct (x2 (y1 p)) as [[a3 a4] [e4 e5]], (x2 (y1 q)) as [[a5 a6] [e6 e7]]. clear x2.
   simpl in *.
   rewrite <- comp_assoc, <- H0. clear H0.
   apply transitivity with ((fmap x0 (fmap x1 r) ◎ fmap x0 a0) ◎ a4).
    repeat rewrite comp_assoc. reflexivity.
   rewrite <- preserves_comp...
   rewrite H1.
   rewrite comp_assoc.
   rewrite <- preserves_comp...
   reflexivity.
  Qed. (* todo: clean up! *)
 
  Program Let id_lr_arrows (x y: Object) (a: y ⟶ x) v: isoT (map_obj a v) (map_obj a v)
    := (cat_id, cat_id).
    (* We can't remove the map_obj here and elsewhere even though it's a coercion,
     because unification isn't smart enough to resolve and use that coercion. This is
     likely due to Coq bug #2229. *)

  Next Obligation. split; apply id_l. Qed.

  Let id_l' (x y: Object) (a: x ⟶ y): cat_id ◎ a = a.
  Proof.
   exists (id_lr_arrows _ _ a).
   intros ? ? ?. simpl. unfold compose, id.
   rewrite id_r, id_l. reflexivity.
  Qed.

  Let id_r' (x y: Object) (a: x ⟶ y): a ◎ cat_id = a.
  Proof.
   exists (id_lr_arrows _ _ a).
   intros ? ? ?. simpl. unfold compose, id.
   rewrite id_r, id_l. reflexivity.
  Qed.

  Section comp_assoc.

    Variables (w x y z: Object) (a: w ⟶ x) (b: x ⟶ y) (c: y ⟶ z).

    Program Let comp_assoc_arrows (v: w): isoT (c (b (a v))) (c (b (a v))) :=
      (fmap c (fmap b (fmap a cat_id)), fmap c (fmap b (fmap a cat_id))).
    Next Obligation. unfold uncurry. simpl. split; repeat rewrite preserves_id; try apply _; apply id_l. Qed.

    Lemma comp_assoc': c ◎ (b ◎ a) = (c ◎ b) ◎ a.
    Proof.
     exists comp_assoc_arrows.
     simpl. intros ? ? ?. unfold compose.
     repeat rewrite preserves_id; try apply _. (* todo: remove need for [try apply _] *)
     rewrite id_l, id_r. reflexivity.
    Qed.

  End comp_assoc.

  Global Instance: Category Object := { comp_assoc := comp_assoc'; id_l := id_l'; id_r := id_r' } .

End contents.
