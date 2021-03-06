Set Automatic Introduction.

Require
  JMrelation.
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

Record Arrow (x y: Object): Type := arrow
  { map_obj:> obj x → obj y
  ; Fmap_inst: Fmap map_obj
  ; Functor_inst: Functor map_obj _ }.

Implicit Arguments arrow [[x] [y]].
Existing Instance Fmap_inst.
Existing Instance Functor_inst.

Hint Extern 4 (Arrows Object) => exact Arrow: typeclass_instances.

Section contents.

  Implicit Arguments map_obj [[x] [y]].

  Section more_arrows. Context (x y: Object).

    Global Instance e: Equiv (x ⟶ y) := λ a b =>
      (Π v, a v ≡ b v) ∧
      (Π `(f: v ⟶ w), JMrelation.R equiv (fmap a f) _ equiv (fmap b f)).

    Let e_refl: Reflexive e.
    Proof.
     intro a. unfold e. intuition.
     apply JMrelation.reflexive, _.
    Qed.

    Let e_sym: Symmetric e.
    Proof with intuition.
     unfold e. intros ?? [P Q]...
     apply JMrelation.symmetric...
    Qed.

    Let e_trans: Transitive e.
    Proof with intuition.
     unfold e. intros a b c [P Q] [R S]...
      transitivity (b v)...
     apply JMrelation.transitive with _ equiv (fmap b f)...
     apply _.
    Qed.

    Instance: Equivalence e.
    Global Instance: Setoid (x ⟶ y).

  End more_arrows.

  Global Instance: CatId Object := λ _ => arrow id _ _.

  Global Program Instance: CatComp Object := λ _ _ _ x y => arrow (x ∘ y) _ _.

  Global Instance: Π x y z: Object, Proper (equiv ==> equiv ==> equiv) ((◎): (y ⟶ z) → (x ⟶ y) → (x ⟶ z)).
  Proof with intuition; try apply _.
   unfold equiv, e.
   intros x y z a b [P Q] c d [R S].
   split; intros.
    change (a (c v) ≡ b (d v)). congruence.
   change (JMrelation.R equiv (fmap a (fmap c f)) _ equiv (fmap b (fmap d f))).
   apply JMrelation.transitive with _ equiv (fmap a (fmap d f))...
   specialize (S _ _ f). revert S.
   generalize (fmap c f) (fmap d f).
   repeat rewrite R.
   intros. apply JMrelation.relate.
   rewrite (JMrelation.unJM _ _ _ _ _ S)... (* <- uses K *)
  Qed.

  Global Instance: Category Object.
  Proof with reflexivity.
   constructor; try apply _; split; intuition; apply JMrelation.relate.
     change (fmap (c ∘ (b ∘ a)) f = fmap ((c ∘ b) ∘ a) f)...
    change (fmap a f = fmap a f)...
   change (fmap a f = fmap a f)...
  Qed.

End contents.
