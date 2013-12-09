theory utp_rank
imports 
  utp_value
  "../alpha/utp_alpha_pred"
begin

class VALUE_RANK = VALUE +
  fixes rank      :: "'a \<Rightarrow> nat"
  and   max_rank  :: "'a itself \<Rightarrow> nat"
  assumes rank_type_inj: 
  "\<lbrakk> x1 : t; x2 : t \<rbrakk> \<Longrightarrow> rank x1 = rank x2"
  and rank_sound: "\<forall>n\<le>max_rank TYPE('a). \<exists> x. rank x = n"
begin

definition type_rank :: "'a UTYPE \<Rightarrow> nat" where
"type_rank t = rank (SOME x. x : t)"

definition TRANK :: "nat \<Rightarrow> 'a UTYPE set" where
"TRANK n = {x. type_rank x = n}"

lemma value_rank_type_rank: 
  "x : t \<Longrightarrow> rank x = type_rank t"
  apply (auto simp add: type_rank_def)
  apply (rule someI2, simp)
  apply (metis rank_type_inj)
done

definition RANK :: "nat \<Rightarrow> 'a set" where
"RANK n = {x. rank x = n}"

definition pred_rank :: "'a WF_ALPHA_PREDICATE \<Rightarrow> nat" where
"pred_rank P = FMax (type_rank `\<^sub>f vtype `\<^sub>f (\<alpha> P))"

definition PRANK :: "nat \<Rightarrow> 'a WF_ALPHA_PREDICATE set" where
"PRANK n = {x. pred_rank x = n}"

end

syntax
  "_MAXRANK"      :: "type => logic"  ("(1MAXRANK/(1'(_')))")

translations
  "MAXRANK('a)" == "CONST max_rank TYPE('a)"

class VALUE_HO = VALUE_RANK +
  assumes rank_inj_func: "\<forall>n<MAXRANK('a). (\<exists> f. dom f = PRANK n \<and> ran f = RANK (n + 1) \<and> inj_on f (dom f))"

end