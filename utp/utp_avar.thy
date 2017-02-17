(******************************************************************************)
(* Project: The Isabelle/UTP Proof System                                     *)
(* File: utp_avar.thy                                                         *)
(* Author: Frank Zeyda (University of York, UK)                               *)
(* Email: frank.zeyda@york.ac.uk                                              *)
(******************************************************************************)
(* LAST REVIEWED: 13 Feb 2017 *)

section {* Axiomatic Variables *}

theory utp_avar
imports utp_var ulens
begin

default_sort type

text {*
  Note that theory @{theory ulens} already includes key definitions and laws
  for lenses of axiomatic variables. Our concern here is merely to integrate
  them smoothly into Isabelle/UTP.
*}

subsection {* Compatibility with Isabelle/UTP *}

subsubsection {* Mitigating Inclusion Side-effects *}

text {*
  A problem in Isabelle/HOL is that depending on the order in which imported
  theory are processed, the undeclaration of syntax and notations may be lost
  after the inclusion; in particular, if a theory is imported that does not
  depend on the theory that undeclares the respective notation or syntax. The
  below is a hack that replicates undeclarations from various theories in the
  utp folder. Apparently, this is an issue to do with theory merging; perhaps
  raise this with the Isabelle community and developers --- there must be a
  better solution.
*}

no_notation
  inner (infix "\<bullet>" 70) and
  le (infixl "\<sqsubseteq>\<index>" 50)

no_notation
  Set.member  ("op :") and
  Set.member  ("(_/ : _)" [51, 51] 50)

-- {* From @{text utp_pred}. *}

no_syntax
  "_INF1"     :: "pttrns \<Rightarrow> 'b \<Rightarrow> 'b"           ("(3\<Sqinter>_./ _)" [0, 10] 10)
  "_INF"      :: "pttrn \<Rightarrow> 'a set \<Rightarrow> 'b \<Rightarrow> 'b"  ("(3\<Sqinter>_\<in>_./ _)" [0, 0, 10] 10)
  "_SUP1"     :: "pttrns \<Rightarrow> 'b \<Rightarrow> 'b"           ("(3\<Squnion>_./ _)" [0, 10] 10)
  "_SUP"      :: "pttrn \<Rightarrow> 'a set \<Rightarrow> 'b \<Rightarrow> 'b"  ("(3\<Squnion>_\<in>_./ _)" [0, 0, 10] 10)

no_notation
  conj (infixr "\<and>" 35) and
  disj (infixr "\<or>" 30) and
  Not ("\<not> _" [40] 40)

no_notation
  inf (infixl "\<sqinter>" 70) and
  sup (infixl "\<squnion>" 65) and
  Inf ("\<Sqinter>_" [900] 900) and
  Sup ("\<Squnion>_" [900] 900) and
  bot ("\<bottom>") and
  top ("\<top>")

subsubsection {* Syntactic Adjustments *}

text {*
  We undeclare several notations here to avoid inherent ambiguities with those
  used in Isabelle/UTP. Note that it is sufficient to undeclare them as input
  notations, namely to be still able to take advantage of them being printed.
*}

no_notation (input)
  dash ("_\<acute>" [1000] 1000) and
  undash ("_\<inverse>" [1000] 1000) and
  subscr ("_\<^bsub>_\<^esub>" [1000, 0] 1000)

no_syntax (input)
  "_MkPVar1" :: "id \<Rightarrow>         'a var" ("$_" [1000] 1000)
  "_MkPVar2" :: "id \<Rightarrow> type \<Rightarrow> 'a var" ("$_:{_}"  [1000, 0] 1000)
  "_MkPVar3" :: "id \<Rightarrow> type \<Rightarrow> 'a var" ("$_:{_}-" [1000, 0] 1000)

no_syntax (input)
  "_MkAxVar1" :: "id \<Rightarrow>         ('a, 'b) lens" ("@_" [1000] 1000)
  "_MkAxVar2" :: "id \<Rightarrow> type \<Rightarrow> ('a, 'b) lens" ("@_:{_}"  [1000, 0] 1000)
  "_MkAxVar3" :: "id \<Rightarrow> type \<Rightarrow> ('a, 'b) lens" ("@_:{_}-" [1000, 0] 1000)

no_notation (input)
  ustate_app_mono ("_\<cdot>_" [1000, 1000] 1000) and
  ustate_app_poly ("_\<star>_" [1000, 1000] 1000)

subsubsection {* Hiding Constants and Types *}

hide_type (open) uvar.uvar

subsubsection {* Forgetting Liftings *}

text {* The liftings below can interfere with the automatic proof tactics. *}

lifting_forget Strings.literal.lifting
lifting_forget uvar.var.lifting
lifting_forget ustate.ustate.lifting

subsection {* Variable Constructors *}

definition in_avar :: "'a::injectable var \<Rightarrow> ('a \<Longrightarrow> '\<alpha>::ust \<times> '\<beta>)" where
[simp]: "in_avar x = in_var (avar\<^sub>L x)"

definition out_avar :: "'a::injectable var \<Rightarrow> ('a \<Longrightarrow> '\<alpha> \<times> '\<beta>::ust)" where
[simp]: "out_avar x = out_var (avar\<^sub>L x)"

adhoc_overloading
  ivar in_avar and
  ovar out_avar and
  svar avar_lens

subsection {* Variable Syntax *}

syntax "_MkAxVar1" :: "id \<Rightarrow>         svid" ("{_}" [1000] 1000)
syntax "_MkAxVar2" :: "id \<Rightarrow> type \<Rightarrow> svid" ("{_::_}"  [1000, 0] 1000)
syntax "_MkAxVar3" :: "id \<Rightarrow> type \<Rightarrow> svid" ("{_::_}-" [1000, 0] 1000)

syntax "_MkAxVar1_logic" :: "id \<Rightarrow>         logic" ("{_}\<^sub>x" [1000] 1000)
syntax "_MkAxVar2_logic" :: "id \<Rightarrow> type \<Rightarrow> logic" ("{_::_}\<^sub>x"  [1000, 0] 1000)
syntax "_MkAxVar3_logic" :: "id \<Rightarrow> type \<Rightarrow> logic" ("{_::_}\<^sub>x-" [1000, 0] 1000)

translations "_MkAxVar1 n"   \<rightleftharpoons> "_MkPVar1 n"
translations "_MkAxVar2 n a" \<rightleftharpoons> "_MkPVar2 n a"
translations "_MkAxVar3 n a" \<rightleftharpoons> "_MkPVar3 n a"

translations "_MkAxVar1_logic n"   \<rightharpoonup> "_MkPVar1 n"
translations "_MkAxVar2_logic n a" \<rightharpoonup> "_MkPVar2 n a"
translations "_MkAxVar3_logic n a" \<rightharpoonup> "_MkPVar3 n a"
end