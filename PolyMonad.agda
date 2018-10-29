{-# OPTIONS --without-K --rewriting #-}

open import HoTT
open import Util
open import Polynomial
open import Substitution

module PolyMonad where

  --
  --  We define the (partial) magma for the slice..
  --
  
  module _ {ℓ} {I : Type ℓ} (P : Poly I) (M : PolyMagma P) where
    
    slc-flatn : {i : I} {f : Op P i} → W (P // M) (i , f) → W P i
    slc-flatn-frm : {i : I} {f : Op P i} (w : W (P // M) (i , f)) → Frame P (slc-flatn w) f

    slc-flatn (lf (i , f)) = corolla P f
    slc-flatn (nd ((w , e) , κ)) = subst P w (λ g n → slc-flatn (κ g n) , slc-flatn-frm (κ g n))

    slc-flatn-frm (lf (i , f)) = corolla-frm P f
    slc-flatn-frm (nd ((w , idp) , κ)) j = μ-frm M w j ∘e
      subst-lf-eqv P w (λ g n → slc-flatn (κ g n) , slc-flatn-frm (κ g n)) j
    
    slc-bd-frame-to : {f : Ops P} (pd : W (P // M) f)
      → (g : Ops P) → Leaf (P // M) pd g → Node P (slc-flatn pd) g
    slc-bd-frame-to (lf i) ._ idp = inl idp
    slc-bd-frame-to (nd ((w , e) , κ)) g (h , n , l) = 
      subst-nd-from P w (λ g n → slc-flatn (κ g n) , slc-flatn-frm (κ g n)) g
        (h , n , slc-bd-frame-to (κ h n) g l)

    slc-bd-frame-from : {f : Ops P} (pd : W (P // M) f)
      → (g : Ops P) → Node P (slc-flatn pd) g → Leaf (P // M) pd g 
    slc-bd-frame-from (lf i) .i (inl idp) = idp
    slc-bd-frame-from (lf i) g (inr (j , p , ())) 
    slc-bd-frame-from (nd ((w , e) , κ)) g n = 
      let (h , n₀ , n₁) = subst-nd-to P w (λ g n → slc-flatn (κ g n) , slc-flatn-frm (κ g n)) g n
      in h , n₀ , slc-bd-frame-from (κ h n₀) g n₁

    postulate

      slc-bd-frame-to-from : {f : Ops P} (pd : W (P // M) f)
        → (g : Ops P) (n : Node P (slc-flatn pd) g)
        → slc-bd-frame-to pd g (slc-bd-frame-from pd g n) == n

      slc-bd-frame-from-to : {f : Ops P} (pd : W (P // M) f)
        → (g : Ops P) (l : Leaf (P // M) pd g)
        → slc-bd-frame-from pd g (slc-bd-frame-to pd g l) == l

    slc-bd-frm : {f : Ops P} (pd : W (P // M) f) 
      → (g : Ops P) → Leaf (P // M) pd g ≃ Node P (slc-flatn pd) g
    slc-bd-frm pd g = equiv (slc-bd-frame-to pd g) (slc-bd-frame-from pd g)
      (slc-bd-frame-to-from pd g) (slc-bd-frame-from-to pd g)

    CohWit : Type ℓ
    CohWit = {i : I} {f : Op P i} (pd : W (P // M) (i , f))
      → μ M (slc-flatn pd) == f
    
    -- We only need a multiplication on the equality now to finish the magma
    slc-mgm : CohWit → PolyMagma (P // M)
    μ (slc-mgm Ψ) pd = slc-flatn pd , Ψ pd 
    μ-frm (slc-mgm Ψ) = slc-bd-frm
  
  record CohStruct {ℓ} {I : Type ℓ} (P : Poly I) (M : PolyMagma P) : Type ℓ where
    coinductive
    field
    
      Ψ : CohWit P M
      H : CohStruct (P // M) (slc-mgm P M Ψ)

  open CohStruct

  -- A polynomial monad is a pair of a magma and
  -- a coherence structure on that magma.
  record PolyMonad {ℓ} {I : Type ℓ} (P : Poly I) : Type ℓ where
    field
      Mgm : PolyMagma P
      Coh : CohStruct P Mgm
