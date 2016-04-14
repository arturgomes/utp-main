section {* UTP variables *}

theory utp_var
imports 
  "../contrib/Kleene_Algebra/Quantales"
  "../utils/cardinals"
  "../utils/Continuum"
  "../utils/finite_bijection"
  "../utils/Lenses"
  "../utils/Library_extra/Pfun"
  "../utils/Library_extra/Ffun"
  "../utils/Library_extra/Derivative_extra"
  "~~/src/HOL/Library/Prefix_Order"
  "~~/src/HOL/Library/Adhoc_Overloading"
  "~~/src/HOL/Library/Monad_Syntax"
  "~~/src/HOL/Library/Countable"
  "~~/src/HOL/Eisbach/Eisbach"
  utp_parser_utils
begin

no_notation inner (infix "\<bullet>" 70)

text {* This theory describes the foundational structure of UTP variables, upon which the rest
        of our model rests. We start by defining alphabets, which is this shallow model are
        simple represented as types, though by convention usually a record type where each
        field corresponds to a variable. *}

type_synonym '\<alpha> "alphabet"  = "'\<alpha>"

text {* UTP variables carry two type parameters, $'a$ that corresponds to the variable's type
        and $'\alpha$ that corresponds to alphabet of which the variable is a type. There
        is a thus a strong link between alphabets and variables in this model. Variable are characterized 
        by two functions, \emph{var-lookup} and \emph{var-update}, that respectively lookup and update 
        the variable's value in some alphabetised state space. These functions can readily be extracted
        from an Isabelle record type.
*}

type_synonym ('a, '\<alpha>) uvar = "('a, '\<alpha>) lens"

text {* The $VAR$ function is a syntactic translations that allows to retrieve a variable given its 
        name, assuming the variable is a field in a record. *}

syntax "_VAR" :: "id \<Rightarrow> ('a, 'r) uvar"  ("VAR _")
translations "VAR x" => "FLDLENS x"

abbreviation var_lookup :: "('a, '\<alpha>) uvar \<Rightarrow> '\<alpha> \<Rightarrow> 'a" where
"var_lookup \<equiv> lens_get"

abbreviation var_assign :: "('a, '\<alpha>) uvar \<Rightarrow> 'a \<Rightarrow> ('\<alpha> \<Rightarrow> '\<alpha>)" where
"var_assign x v \<sigma> \<equiv> lens_put x \<sigma> v"

abbreviation var_update :: "('a, '\<alpha>) uvar \<Rightarrow> ('a \<Rightarrow> 'a) \<Rightarrow> ('\<alpha> \<Rightarrow> '\<alpha>)" where
"var_update \<equiv> weak_lens.update"

abbreviation "semi_uvar \<equiv> mwb_lens"

abbreviation "uvar \<equiv> vwb_lens"

 text {* We also define some lifting functions for variables to create input and output variables.
        These simply lift the alphabet to a tuple type since relations will ultimately be defined
        to a tuple alphabet. *}

definition in_var :: "('a, '\<alpha>) uvar \<Rightarrow> ('a, '\<alpha> \<times> '\<beta>) uvar" where
[lens_defs]: "in_var x = x ;\<^sub>L fst\<^sub>L"

definition out_var :: "('a, '\<beta>) uvar \<Rightarrow> ('a, '\<alpha> \<times> '\<beta>) uvar" where
[lens_defs]: "out_var x = x ;\<^sub>L snd\<^sub>L"

definition pr_var :: "('a, '\<beta>) uvar \<Rightarrow> ('a, '\<beta>) uvar" where
[simp]: "pr_var x = x"

lemma in_var_semi_uvar [simp]:
  "semi_uvar x \<Longrightarrow> semi_uvar (in_var x)"
  by (simp add: comp_mwb_lens fst_vwb_lens in_var_def)

lemma in_var_uvar [simp]:
  "uvar x \<Longrightarrow> uvar (in_var x)"
  by (simp add: comp_vwb_lens fst_vwb_lens in_var_def)

lemma out_var_semi_uvar [simp]:
  "semi_uvar x \<Longrightarrow> semi_uvar (out_var x)"
  by (simp add: comp_mwb_lens out_var_def snd_vwb_lens)

lemma out_var_uvar [simp]:
  "uvar x \<Longrightarrow> uvar (out_var x)"
  by (simp add: comp_vwb_lens out_var_def snd_vwb_lens)

lemma in_out_indep [simp]:
  "in_var x \<bowtie> out_var y"
  by (simp add: lens_indep_def in_var_def out_var_def fst_lens_def snd_lens_def lens_comp_def)

lemma out_in_indep [simp]:
  "out_var x \<bowtie> in_var y"
  by (simp add: lens_indep_def in_var_def out_var_def fst_lens_def snd_lens_def lens_comp_def)

lemma in_var_indep [simp]:
  "x \<bowtie> y \<Longrightarrow> in_var x \<bowtie> in_var y"
  by (simp add: in_var_def out_var_def fst_vwb_lens lens_indep_left_comp)

lemma out_var_indep [simp]:
  "x \<bowtie> y \<Longrightarrow> out_var x \<bowtie> out_var y"
  by (simp add: lens_indep_left_comp out_var_def snd_vwb_lens)

text {* We also define some lookup abstraction simplifications. *}

lemma var_lookup_in [simp]: "lens_get (in_var x) (A, A') = lens_get x A"
  by (simp add: in_var_def fst_lens_def lens_comp_def)

lemma var_lookup_out [simp]: "lens_get (out_var x) (A, A') = lens_get x A'"
  by (simp add: out_var_def snd_lens_def lens_comp_def)

lemma var_update_in [simp]: "lens_put (in_var x) (A, A') v = (lens_put x A v, A')"
  by (simp add: in_var_def fst_lens_def lens_comp_def)

lemma var_update_out [simp]: "lens_put (out_var x) (A, A') v = (A, lens_put x A' v)"
  by (simp add: out_var_def snd_lens_def lens_comp_def)

text {* Variables can also be used to effectively define sets of variables. Here we define the
        the universal alphabet ($\Sigma$) to be a variable with identity for both the lookup
        and update functions. Effectively this is just a function directly on the alphabet type. *}

abbreviation (input) univ_alpha :: "('\<alpha>, '\<alpha>) uvar" ("\<Sigma>") where
"univ_alpha \<equiv> 1\<^sub>L"

nonterminal svid and svar and salpha

syntax
  "_salphaid"    :: "id \<Rightarrow> salpha" ("_" [999] 999)
  "_salphavar"   :: "svar \<Rightarrow> salpha" ("_" [999] 999)
  "_salphacomp"  :: "salpha \<Rightarrow> salpha \<Rightarrow> salpha" (infixr "," 75)
  "_svid"        :: "id \<Rightarrow> svid" ("_" [999] 999)
  "_svid_alpha"  :: "svid" ("\<Sigma>")
  "_spvar"       :: "svid \<Rightarrow> svar" ("&_" [999] 999)
  "_sinvar"      :: "svid \<Rightarrow> svar" ("$_" [999] 999)
  "_soutvar"     :: "svid \<Rightarrow> svar" ("$_\<acute>" [999] 999)

consts
  svar :: "'v \<Rightarrow> 'e" 
  ivar :: "'v \<Rightarrow> 'e"
  ovar :: "'v \<Rightarrow> 'e"

adhoc_overloading
  svar pr_var and ivar in_var and ovar out_var

translations
  "_salphaid x" => "x"
  "_salphacomp x y" => "x +\<^sub>L y"
  "_salphavar x" => "x"
  "_svid_alpha" == "\<Sigma>"
  "_svid x" => "x"
  "_spvar x" == "CONST svar x"
  "_sinvar x" == "CONST ivar x"
  "_soutvar x" == "CONST ovar x"

end