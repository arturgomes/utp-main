theory Lens_Footprint
  imports Lens_Order
begin

definition lobs_equiv :: "('a \<Longrightarrow> 's) \<Rightarrow> 's \<Rightarrow> 's \<Rightarrow> bool" (infix "\<cong>\<index>" 50) where
"s \<cong>\<^bsub>X\<^esub> s' \<longleftrightarrow> get\<^bsub>X\<^esub> s = get\<^bsub>X\<^esub> s'"

lemma equiv_lobs:
  "equiv UNIV {(s, s'). s \<cong>\<^bsub>X\<^esub> s'}"
  by (simp add: equiv_def refl_on_def sym_def lobs_equiv_def trans_def)

definition footprint :: "('a \<Longrightarrow> 's) \<Rightarrow> 's set set" ("\<lbrakk>_\<rbrakk>\<^sub>L") where
"\<lbrakk>X\<rbrakk>\<^sub>L = UNIV // {(s, s'). s \<cong>\<^bsub>X\<^esub> s'}"

lemma footprint_id_lens: "\<lbrakk>1\<^sub>L\<rbrakk>\<^sub>L = {{x} | x. True}"
  by (auto simp add: footprint_def lobs_equiv_def id_lens_def quotient_def)

lemma footprint_unit_lens: "\<lbrakk>0\<^sub>L\<rbrakk>\<^sub>L = {UNIV}"
  by (simp add: footprint_def lobs_equiv_def quotient_def)

lemma footprint_lens_comp: "\<lbrakk>X ;\<^sub>L Y\<rbrakk>\<^sub>L = (\<Union>x. {{s'. get\<^bsub>X\<^esub> (get\<^bsub>Y\<^esub> x) = get\<^bsub>X\<^esub> (get\<^bsub>Y\<^esub> s')}})"
  by (simp add: footprint_def quotient_def lobs_equiv_def lens_comp_def)
    
lemma sublens_footprint_imp:
  "X \<subseteq>\<^sub>L Y \<Longrightarrow> (\<forall> A\<in>\<lbrakk>Y\<rbrakk>\<^sub>L. \<exists> B\<in>\<lbrakk>X\<rbrakk>\<^sub>L. A \<subseteq> B)"
  apply (auto)
  apply (auto simp add: sublens_def footprint_lens_comp)[1]
  apply (simp add: footprint_def quotient_def lobs_equiv_def)
  apply (metis (mono_tags, lifting) mem_Collect_eq subsetI) 
done

text {* How to show the implication in the other direction? *}
  
  
end