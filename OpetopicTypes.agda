{-# OPTIONS --without-K --rewriting #-}

open import HoTT
open import PolyMonads

module OpetopicTypes where

  record OpType {I : Type₀} (M : Mnd I) : Type₁ where
    coinductive
    field

      Ob : I → Type₀
      Hom : OpType (slc (pb M Ob))

  open OpType
  
  -- Now, the definition will be that the space of fillers for
  -- a given niche is contractible.
  
  Niche : {I : Type₀} {M : Mnd I} (X : OpType M) → I → Type₀
  Niche {M = M} X i = ⟦ M ⟧ (Ob X) i

  Fillers : {I : Type₀} {M : Mnd I} (X : OpType M) (i : I) (n : Niche X i) → Type₀
  Fillers X i n = Σ (Ob X i) (λ x → Ob (Hom X) ((i , x) , n))

  record is-coherent {I : Type₀} {M : Mnd I} (X : OpType M) : Type₀ where
    coinductive
    field

      has-unique-fillers : {i : I} (n : Niche X i) → is-contr (Fillers X i n)
      hom-is-coherent : is-coherent (Hom X)

  open is-coherent

  filler-of : {I : Type₀} {M : Mnd I} {X : OpType M} {i : I}
              (n : Niche X i) (is-coh : is-coherent X) → Ob X i
  filler-of n is-coh = fst (fst (has-level-apply (has-unique-fillers is-coh n)))              

  pth-to-id-cell : {I : Type₀} {M : Mnd I} (X : OpType M) (is-coh : is-coherent X)
                   {i : I} (x y : Ob X i) (p : x == y) → 
                   Ob (Hom X) ((i , x) , (η M i , λ p → transport (Ob X) (ap (τ M) (ηp-η M i p)) y))
  pth-to-id-cell {M = M} X is-coh {i} x .x idp = filler-of id-niche (hom-is-coherent is-coh)

    where id-niche : Niche (Hom X) (((i , x) , (η M i , λ p → transport (Ob X) (ap (τ M) (ηp-η M i p)) x)))
          id-niche = dot (i , x) , λ { () }

  record is-complete {I : Type₀} {M : Mnd I} (X : OpType M) (is-coh : is-coherent X) : Type₀ where
    coinductive
    field

      pth-to-id-equiv : {i : I} (x y : Ob X i) → is-equiv (pth-to-id-cell X is-coh x y)
      hom-is-complete : is-complete (Hom X) (hom-is-coherent is-coh)

  ∞Alg : {I : Type₀} (M : Mnd I) → Type₁
  ∞Alg M = Σ (OpType M) is-coherent

  A∞-Mnd : Mnd (⊤ × ⊤)
  A∞-Mnd = slc (id ⊤)

  module A∞Spaces (X : ∞Alg A∞-Mnd) where

    X₀ : Type₀
    X₀ = Ob (fst X) (unit , unit)
    
    mult : X₀ → X₀ → X₀
    mult x y = filler-of mult-niche (snd X)
    
      where mult-niche : Niche (fst X) (unit , unit)
            mult-niche = (box unit (λ _ → unit) (λ _ → box unit (λ _ → unit) (λ _ → dot unit))) ,
                         λ { (inl unit) → x ;
                             (inr (unit , inl unit)) → y ;
                             (inr (unit , inr (unit , ()))) }