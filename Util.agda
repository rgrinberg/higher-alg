{-# OPTIONS --without-K --rewriting #-}

open import HoTT

module Util where

  -- Used for the "inspect idiom" in proofs below
  
  data Graph {ℓ : ULevel} {X : Type ℓ} {Y : X → Type ℓ} (f : ∀ x → Y x) (x : X) (y : Y x) : Type ℓ where
    ingraph : f x == y → Graph f x y

  inspect : ∀ {ℓ} {X : Type ℓ} {Y : X → Type ℓ} (f : ∀ x → Y x) (x : X) → Graph f x (f x)
  inspect f x = ingraph idp

  -- These 4 transp lemmas are used in Biased
  to-transp!-↓ : ∀ {i j} {A : Type i} (P : A → Type j) {a₁ a₂ : A}
    (p : a₁ == a₂) (y : P a₂) → y == transport! P p y [ P ↓ ! p ]
  to-transp!-↓ P idp y = idp

  to-transp!!-↓ : ∀ {i j} {A : Type i} (P : A → Type j) {a₁ a₂ : A}
    (p : a₁ == a₂) (y : P a₂) → transport! P p y == y [ P ↓ p ]
  to-transp!!-↓ P idp y = idp

  transp!-ap : ∀ {i j k} {A : Type i} {B : Type j} (C : B → Type k) (f : A → B)
    → {x y : A} (p : x == y) (c : C (f y))
    → transport! (C ∘ f) p c == transport! C (ap f p) c 
  transp!-ap C f idp c = idp

  transp!-∙ : ∀ {i j} {A : Type i} (B : A → Type j) 
    → {x y z : A} (p : x == y) (q : y == z) (c : B z)
    → transport! B (p ∙ q) c == transport! B p (transport! B q c)
  transp!-∙ B idp idp c = idp


  -- Needed for a lemma.

  apd↓-cst :  ∀ {i j} {A : Type i} {B C : A → Type j} (f : {a : A} → B a → C a)
    {x y : A} {p : x == y} {u : B x} {v : B y}
    → u == v [ B ↓ p ]
    → f u == f v [ C ↓ p ]
  apd↓-cst f {p = idp} idp = idp

  to-transp-↓ : ∀ {i j} {A : Type i} (P : A → Type j) {a₁ a₂ : A}
    (p : a₁ == a₂) (y : P a₁) → y == transport P p y [ P ↓ p ]
  to-transp-↓ _ idp _ = idp

  ↓-apd-lem : ∀ {i j k} {A : Type i} {B : A → Type j} (C : (a : A) → B a → Type k)
    (f : Π A B) {x y : A} (p : x == y)
    {u : C x (f x)} {v : C y (f y)}
    → u == v [ uncurry C ↓ pair= p (apd f p) ]
    → u == v [ (λ a → C a (f a)) ↓ p ]
  ↓-apd-lem C f idp idp = idp

  any-contr-eqv : ∀ {i j} {A : Type i} {B : Type j}
    → (a-ct : is-contr A)
    → (b-ct : is-contr B)
    → (f : A → B)
    → is-equiv f
  any-contr-eqv {A = A} {B = B} a-ct b-ct f =
    is-eq f (λ _ → contr-center a-ct)
      (λ b → contr-has-all-paths ⦃ b-ct ⦄ (f (contr-center a-ct)) b)
      (λ a → contr-path a-ct a)

  prop-transp : ∀ {i j} {A : Type i} {B : A → Type j}
    → {a₀ a₁ : A} (p : a₀ == a₁)
    → (isp : (a : A) → is-prop (B a))
    → (b₀ : B a₀) (b₁ : B a₁)
    → b₀ == b₁ [ B ↓ p ]
  prop-transp idp isp b₀ b₁ = prop-has-all-paths ⦃ isp _ ⦄ b₀ b₁

  equiv-== : ∀ {i j} {A : Type i} {B : Type j}
    → {f g : A ≃ B} (e : (a : A) → fst f a == fst g a) → f == g
  equiv-== {f = f , f-eq} {g = g , g-eq} e =
    pair= (λ= e) (prop-transp (λ= e)
          (λ ϕ → is-equiv-is-prop {f = ϕ}) f-eq g-eq)

  ↓-equiv-in : ∀ {i j k} {A : Type i}
    → {B : (a : A) → Type j} {C : (a : A) → Type k}
    → {a₀ a₁ : A} {p : a₀ == a₁}
    → {e : B a₀ ≃ C a₀} {f : B a₁ ≃ C a₁}
    → (r : (b₀ : B a₀) (b₁ : B a₁) (s : b₀ == b₁ [ B ↓ p ])
           → fst e b₀ == fst f b₁ [ C ↓ p ])
    → e == f [ (λ a → B a ≃ C a) ↓ p ]
  ↓-equiv-in {p = idp} r = equiv-== (λ b → r b b idp)

  contr-contr-eqv : ∀ {i j} {A : Type i} {B : Type j}
    → (a-ct : is-contr A)
    → (b-ct : is-contr B)
    → A ≃ B
  contr-contr-eqv {A = A} {B = B} a-ct b-ct =
    equiv to from to-from from-to

    where to : A → B
          to a = contr-center b-ct

          from : B → A
          from b = contr-center a-ct

          to-from : (b : B) → to (from b) == b
          to-from b = contr-has-all-paths ⦃ b-ct ⦄ (to (from b)) b

          from-to : (a : A) → from (to a) == a
          from-to a = contr-has-all-paths ⦃ a-ct ⦄ (from (to a)) a

  ⊔-emap : ∀ {i i' j j'} {A : Type i} {A' : Type i'}
    → {B : Type j} {B' : Type j'}
    → A ≃ B → A' ≃ B' → A ⊔ A' ≃ B ⊔ B'
  ⊔-emap {A = A} {A' = A'} {B = B} {B' = B'} e f =
    equiv to from to-from from-to

    where to : A ⊔ A' → B ⊔ B'
          to (inl a) = inl (–> e a)
          to (inr a') = inr (–> f a')

          from : B ⊔ B' → A ⊔ A'
          from (inl b) = inl (<– e b)
          from (inr b') = inr (<– f b')

          to-from : (b : B ⊔ B') → to (from b) == b
          to-from (inl b) = <– (inl=inl-equiv (–> e (<– e b)) b) (<–-inv-r e b)
          to-from (inr b') = <– (inr=inr-equiv (–> f (<– f b')) b') (<–-inv-r f b')

          from-to : (a : A ⊔ A') → from (to a) == a
          from-to (inl a) = <– (inl=inl-equiv (<– e (–> e a)) a) (<–-inv-l e a)
          from-to (inr a') = <– (inr=inr-equiv (<– f (–> f a')) a') (<–-inv-l f a')

  Σ-⊔-equiv : ∀ {i j k} {A : Type i} {B : Type j} (P : A ⊔ B → Type k)
    → Σ (A ⊔ B) P ≃ Σ A (P ∘ inl) ⊔ Σ B (P ∘ inr)
  Σ-⊔-equiv {A = A} {B = B} P = equiv to from to-from from-to

    where to : Σ (A ⊔ B) P → Σ A (P ∘ inl) ⊔ Σ B (P ∘ inr)
          to (inl a , p) = inl (a , p)
          to (inr b , p) = inr (b , p)

          from : Σ A (P ∘ inl) ⊔ Σ B (P ∘ inr) → Σ (A ⊔ B) P
          from (inl (a , p)) = inl a , p
          from (inr (b , p)) = inr b , p

          to-from : (x : Σ A (P ∘ inl) ⊔ Σ B (P ∘ inr)) → to (from x) == x
          to-from (inl (a , p)) = idp
          to-from (inr (b , p)) = idp

          from-to : (x : Σ (A ⊔ B) P) → from (to x) == x
          from-to (inl a , p) = idp
          from-to (inr b , p) = idp

  -- Probably there is a more explicit way, but since we only use
  -- this abstractly, equiv induction is enough for our purposes.
  transport-equiv-lemma : ∀ {i j} {A B : Type i} (α : A ≃ B)
    → (P : A → Type j) (σ : (b : B) → P (<– α b)) (b : B)
    → transport P (<–-inv-l α (<– α b)) (σ (–> α (<– α b))) == σ b
  transport-equiv-lemma {j = j} = equiv-induction
     (λ {A} {B} α → (P : A → Type j) (σ : (b : B) → P (<– α b)) (b : B) → transport P (<–-inv-l α (<– α b)) (σ (–> α (<– α b))) == σ b)
     (λ A B σ a → idp)

  -- So I'm pretty sure that I've proved this before,
  -- but is there a direct way to see it?
  postulate
  
    n-type-right-cancel : ∀ {i j n} {A : Type i} {B : A → Type j}
      → has-level n (Σ A B)
      → has-level (S n) A
      → (a : A) → has-level n (B a)

  -- Annoying to have to reprove this ...
  λ=-idp : ∀ {i j} {A : Type i} {P : A → Type j}
    (f : Π A P) → λ= (λ x → idp {a = f x}) == idp
  λ=-idp f = ! (λ=-η {f = f} {g = f} idp)

  -- Used for extracting action on nodes
  ⊔-po-inl : ∀ {i j k} {A : Type i} {P : A → Type j} {Q : A → Type k}
    → {x y : A} (e : x == y) (p : P x) (q : P y)
    → inl p == inl q [ (λ a → P a ⊔ Q a) ↓ e ]
    → p == q [ P ↓ e ]
  ⊔-po-inl idp p q d = –> (inl=inl-equiv p q) d

