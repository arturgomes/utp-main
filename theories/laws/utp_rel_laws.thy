(******************************************************************************)
(* Project: Unifying Theories of Programming in HOL                           *)
(* File: utp_rel_laws.thy                                                     *)
(* Author: Simon Foster and Frank Zeyda, University of York (UK)              *)
(******************************************************************************)

header {* Relation Laws *}

theory utp_rel_laws
imports 
  "../core/utp_pred" 
  "../core/utp_rename"
  "../core/utp_expr"
  "../core/utp_rel"
  "../tactics/utp_pred_tac"
  "../tactics/utp_expr_tac"
  "../tactics/utp_rel_tac"
  "../tactics/utp_xrel_tac"
  "../parser/utp_pred_parser"
  utp_pred_laws
  utp_rename_laws
  utp_subst_laws
begin

subsection {* Sequential Composition Laws *}

theorem SemiR_OrP_distl :
"`p1 ; (p2 \<or> p3)` = `(p1 ; p2) \<or> (p1 ; p3)`"
  by (utp_rel_auto_tac)

theorem SemiR_OrP_distr :
"`(p1 \<or> p2) ; p3` = `(p1 ; p3) \<or> (p2 ; p3)`"
  by (utp_rel_auto_tac)

theorem SemiR_SkipR_left [simp]:
"II ; p = p"
  by (utp_rel_auto_tac)

theorem SemiR_SkipR_right [simp]:
"p ; II = p"
  by (utp_rel_auto_tac)

theorem SemiR_FalseP_left [simp]:
"false ; p = false"
  by (utp_rel_auto_tac)

theorem SemiR_FalseP_right [simp]:
"p ; false = false"
  by (utp_rel_auto_tac)

theorem SemiR_assoc :
"p1 ; (p2 ; p3) = (p1 ; p2) ; p3"
  by (utp_rel_auto_tac)

text {* A sequential composition which doesn't mention undashed or dashed variables
        is the same as a conjunction *}

theorem SemiR_equiv_AndP_NON_REL_VAR:
  "\<lbrakk> UNREST REL_VAR p ; UNREST REL_VAR q \<rbrakk> \<Longrightarrow> p ; q = p \<and>p q"
  apply (auto simp add:SemiR_def AndP.rep_eq COMPOSABLE_BINDINGS_def)
  apply (rule UNREST_binding_override, simp, simp add:unrest UNREST_subset)
  apply (subgoal_tac "b1 \<oplus>\<^sub>b b2 on NON_REL_VAR = b1")
  apply (rule UNREST_binding_override)
  apply (metis UNDASHED_DASHED_NON_REL_VAR UNREST_binding_override binding_override_minus)
  apply (metis UNREST_subset Un_commute inf_sup_ord(3))
  apply (metis binding_override_equiv)
  apply (rule_tac x="RenameB SS x \<oplus>\<^sub>b x on UNDASHED" in exI)
  apply (rule_tac x="x" in exI)
  apply (auto simp add:urename closure)
  apply (simp add:UNREST_def)
  apply (drule_tac x="x" in bspec, simp)
  apply (drule_tac x="x \<oplus>\<^sub>b RenameB SS x on DASHED" in spec)
  apply (subgoal_tac "x \<oplus>\<^sub>b (x \<oplus>\<^sub>b RenameB SS x on DASHED) on REL_VAR = RenameB SS x \<oplus>\<^sub>b x on UNDASHED")
  apply (simp)
  apply (rule, rule, simp)
  apply (case_tac "xa \<in> UNDASHED")
  apply (simp_all add:urename)
  apply (case_tac "xa \<in> DASHED")
  apply (simp)
  apply (simp add:urename)
  apply (auto simp add:binding_equiv_def urename NON_REL_VAR_def)
done

text {* A condition has true as right identity *}

theorem SemiR_TrueP_precond : 
  "p \<in> WF_CONDITION \<Longrightarrow> p ; true = p"
  apply (auto simp add:SemiR_def COMPOSABLE_BINDINGS_def TrueP_def UNREST_def WF_CONDITION_def)
  apply (rule_tac x="x" in exI)
  apply (rule_tac x="(RenameB SS x) \<oplus>\<^sub>b x on DASHED" in exI)
  apply (auto simp add:RenameB_rep_eq urename binding_equiv_def)
  apply (smt Compl_eq_Diff_UNIV Diff_iff NON_REL_VAR_def SS_ident_app UnCI o_apply override_on_def)
done

text {* A postcondition has true as left identity *}

theorem SemiR_TrueP_postcond :
  "p \<in> WF_POSTCOND \<Longrightarrow> true ; p = p"
  apply (auto simp add:SemiR_def COMPOSABLE_BINDINGS_def TrueP_def UNREST_def WF_POSTCOND_def)
  apply (drule_tac x="b2" in bspec)
  apply (simp)
  apply (drule_tac x="b1" in spec)
  apply (subgoal_tac "b2 \<oplus>\<^sub>b b1 on UNDASHED = b1 \<oplus>\<^sub>b b2 on DASHED")
  apply (simp)
  apply (rule)
  apply (simp add:binding_equiv_def)
  apply (rule ext)
  apply (case_tac "x \<in> UNDASHED")
  apply (simp_all)
  apply (case_tac "x \<in> DASHED")
  apply (simp)
  apply (subgoal_tac "x \<in> NON_REL_VAR")
  apply (simp)
  apply (auto simp add:NON_REL_VAR_def)[1]
  apply (rule_tac x="(RenameB SS x) \<oplus>\<^sub>b x on UNDASHED" in exI)
  apply (rule_tac x="x" in exI)
  apply (auto)
  apply (rule)
  apply (rule)
  apply (simp add:RenameB_rep_eq urename)
  apply (case_tac "xa \<in> REL_VAR")
  apply (auto simp add:binding_equiv_def urename NON_REL_VAR_def RenameB_rep_eq)
done

theorem SemiR_AndP_right_precond: 
  "\<lbrakk> p \<in> WF_RELATION; q \<in> WF_RELATION; c \<in> WF_CONDITION \<rbrakk>
     \<Longrightarrow> `p ; (c \<and> q)` = `(p \<and> c\<acute>) ; q`"
  by (frule SemiR_TrueP_precond, utp_xrel_auto_tac)

theorem SemiR_AndP_right_postcond: 
  "\<lbrakk> p \<in> WF_RELATION; q \<in> WF_RELATION; c \<in> WF_POSTCOND \<rbrakk>
     \<Longrightarrow> p ; (q \<and>p c) = (p ; q) \<and>p c"
  by (frule SemiR_TrueP_postcond, utp_xrel_auto_tac)

theorem SemiR_AndP_left_postcond: 
  "\<lbrakk> p \<in> WF_RELATION; q \<in> WF_RELATION; c \<in> WF_POSTCOND \<rbrakk>
     \<Longrightarrow> (p \<and>p c) ; q = p ; (c\<^sup>\<smile> \<and>p q)"
  by (frule SemiR_TrueP_postcond, utp_xrel_auto_tac)

theorem SemiR_AndP_left_precond: 
  "\<lbrakk> p \<in> WF_RELATION; q \<in> WF_RELATION; c \<in> WF_CONDITION \<rbrakk>
     \<Longrightarrow> (c \<and>p p) ; q = c \<and>p (p ; q)"
  by (frule SemiR_TrueP_precond, utp_xrel_auto_tac)

text {* A single variable can be extracted from a sequential composition and captured
        in an existential *}

lemma [simp] :"x \<in> DASHED_TWICE \<Longrightarrow> x \<in> NON_REL_VAR"
  by (simp add:var_defs)

lemma [simp] : "x \<in> NON_REL_VAR \<Longrightarrow> x\<acute> \<in> NON_REL_VAR" 
  by (simp add:var_defs)

lemma [elim]: "\<lbrakk> x\<acute> \<in> DASHED_TWICE; x \<in> DASHED \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (simp add:var_defs)

lemma SemiR_extract_variable:
  assumes "P \<in> WF_RELATION" "Q \<in> WF_RELATION" "x \<in> UNDASHED"
  shows "P ; Q = (\<exists>p {x\<acute>\<acute>\<acute>}. P[VarE x\<acute>\<acute>\<acute>|x\<acute>] ; Q[VarE x\<acute>\<acute>\<acute>|x])"
proof -
  have "P ; Q = (\<exists>p DASHED_TWICE . P[SS1] \<and>p Q[SS2])"
    by (simp add:assms SemiR_algebraic_rel)

  also have "... = (\<exists>p {x\<acute>\<acute>}. \<exists>p (DASHED_TWICE - {x\<acute>\<acute>}) . P[SS1] \<and>p Q[SS2])"
    by (metis DASHED_dash_DASHED_TWICE ExistsP_insert UNDASHED_dash_DASHED assms(3) insert_Diff)

  (* FIXME: This step really should go through much easier.... *)
  also from assms have "... = (\<exists>p {x\<acute>\<acute>\<acute>}. (\<exists>p DASHED_TWICE - {x\<acute>\<acute>} . (P[SS1] \<and>p Q[SS2]))[VarE x\<acute>\<acute>\<acute>|x\<acute>\<acute>])"
    apply (rule_tac trans)
    apply (rule ExistsP_SubstP[of "x\<acute>\<acute>\<acute>"])
    apply (simp_all)
    apply (rule unrest)
    apply (rule unrest)
    apply (auto intro: unrest closure simp add:urename)
  done

  also from assms have "... = (\<exists>p {x\<acute>\<acute>\<acute>}. (\<exists>p (DASHED_TWICE - {x\<acute>\<acute>}) . ((SubstP (P[SS1]) (VarE x\<acute>\<acute>\<acute>) (x\<acute>\<acute>)) \<and>p (SubstP (Q[SS2]) (VarE x\<acute>\<acute>\<acute>) (x\<acute>\<acute>)))))"
    apply (subgoal_tac "UNREST_EXPR (DASHED_TWICE - {x\<acute>\<acute>}) (VarE x\<acute>\<acute>\<acute>)")
    apply (simp add:usubst closure typing)
    apply (blast intro:unrest)
  done

  also from assms have "... = (\<exists>p {x\<acute>\<acute>\<acute>}. (\<exists>p DASHED_TWICE . ((SubstP (P[SS1]) (VarE x\<acute>\<acute>\<acute>) (x\<acute>\<acute>)) \<and>p (SubstP (Q[SS2]) (VarE x\<acute>\<acute>\<acute>) (x\<acute>\<acute>)))))"
    apply (subgoal_tac "UNREST {x\<acute>\<acute>} ((SubstP (P[SS1]) (VarE x\<acute>\<acute>\<acute>) (x\<acute>\<acute>)) \<and>p (SubstP (Q[SS2]) (VarE x\<acute>\<acute>\<acute>) (x\<acute>\<acute>)))")
    apply (subgoal_tac "(DASHED_TWICE - {x\<acute>\<acute>}) \<union> {x\<acute>\<acute>} = DASHED_TWICE")
    apply (smt ExistsP_union ExistsP_ident)
    apply (auto intro!:unrest typing simp add:usubst)
  done

  ultimately show ?thesis using assms
    apply (subgoal_tac "UNREST DASHED_TWICE (SubstP P (VarE (x\<acute>\<acute>\<acute>)) (x\<acute>))")
    apply (subgoal_tac "UNREST DASHED_TWICE (SubstP Q (VarE (x\<acute>\<acute>\<acute>)) (x))")
    apply (subgoal_tac "\<langle>SS1\<rangle>\<^sub>s (x\<acute>\<acute>\<acute>) = x\<acute>\<acute>\<acute>")
    apply (subgoal_tac "\<langle>SS2\<rangle>\<^sub>s (x\<acute>\<acute>\<acute>) = x\<acute>\<acute>\<acute>")
    apply (simp add:SemiR_algebraic urename closure typing defined)
    apply (simp add:urename closure)
    apply (metis SS1_DASHED_TWICE_app SS2_ident_app in_out_UNDASHED_DASHED(1) undash_dash utp_var.not_dash_member_in)
    apply (metis SS1_ident_app UNDASHED_dash_DASHED in_out_UNDASHED_DASHED(4) not_dash_dash_member_out undash_dash undash_eq_dash_contra2)
    apply (rule unrest)
    apply (simp add:typing)
    apply (rule closure, simp)
    apply (rule UNREST_EXPR_VarE[of _ DASHED_TWICE])
    apply (auto)
    apply (rule unrest)
    apply (simp add:typing)
    apply (rule closure, simp)
    apply (rule UNREST_EXPR_VarE[of _ DASHED_TWICE])
    apply (auto)
  done
qed

subsubsection {* Existential Lifting *}

text {* Lifting of exists around sequential composition requires that p1 and p2 are 
        relations and that p1 does use any of the inputs hidden by vs as inputs *}

theorem ExistsP_SemiR_expand1:
  assumes unrests: "UNREST DASHED_TWICE p1" "UNREST DASHED_TWICE p2"
  and     noconn:"UNREST (dash ` in vs) p1"
  and     "vs \<subseteq> UNDASHED \<union> DASHED"
  shows "p1 ; (\<exists>p vs. p2) = (\<exists>p out vs. (p1 ; p2))"
proof -

  from unrests have "UNREST DASHED_TWICE (\<exists>p vs . p2)"
    by (blast intro:unrest)

  with unrests
  have "p1 ; (\<exists>p vs. p2) = (\<exists>p DASHED_TWICE . p1[SS1] \<and>p (\<exists>p vs . p2)[SS2])"
    by (simp add:SemiR_algebraic)

  also have "... = (\<exists>p DASHED_TWICE . p1[SS1] \<and>p (\<exists>p (SS2 `\<^sub>s vs) . p2[SS2]))"
    by (simp add: RenameP_ExistsP_distr1)

  also have "... = (\<exists>p DASHED_TWICE . \<exists>p (SS2 `\<^sub>s vs) . (p1[SS1] \<and>p p2[SS2]))"
  proof -
    from unrests have "UNREST (SS2 `\<^sub>s vs) p1[SS1]"
    proof -

      have "dash ` (in vs) \<subseteq> UNDASHED \<union> DASHED"
        by (force simp add:var_defs)

      moreover have "dash ` out vs \<subseteq> DASHED_TWICE"
        by (force simp add:var_defs)

      moreover from assms have "UNREST (dash ` dash ` in vs) p1[SS1]"
        by (smt SS1_UNDASHED_DASHED_image UNREST_RenameP_alt Un_empty_left calculation(1) in_dash in_in le_iff_sup out_dash rename_image_def sup.idem)

      moreover from assms have "UNREST (out vs) p1[SS1]"
        apply (rule_tac ?vs1.0="dash ` out vs" in UNREST_RenameP_alt)
        apply (force intro:  UNREST_subset simp add:var_defs)
        apply (auto simp add:image_def SS1_simps closure out_vars_def)
      done

      ultimately show ?thesis using assms
        by (metis (lifting) SS2_UNDASHED_DASHED_image UNREST_union)
    qed

    thus ?thesis
      by (metis (lifting) ExistsP_AndP_expand2)
  qed

  also from assms have "... = (\<exists>p out vs. \<exists>p DASHED_TWICE . p1[SS1] \<and>p p2[SS2])"
  proof -
    have "DASHED_TWICE \<union> dash ` dash ` (in vs) = DASHED_TWICE"
      by (force simp add:var_defs)

    thus ?thesis using assms
      apply (simp add:SS2_simps)
      apply (smt ExistsP_union SS2_UNDASHED_DASHED_image rename_image_def sup_commute)
    done
  qed

  also from assms have "... = (\<exists>p out vs. (p1 ; p2))"
    by (simp add:SemiR_algebraic closure)

  ultimately show ?thesis
    by simp
qed

theorem ExistsP_SemiR_expand2:
  assumes unrests: "UNREST DASHED_TWICE p1" "UNREST DASHED_TWICE p2"
  and     "vs \<subseteq> UNDASHED \<union> DASHED"
  and     noconn:"UNREST (undash ` out vs) p2"
  shows "(\<exists>p vs. p1) ; p2 = (\<exists>p in vs. (p1 ; p2))"
proof -

  from unrests have "UNREST DASHED_TWICE (\<exists>p vs . p1)"
    by (blast intro:unrest)

  with unrests
  have "(\<exists>p vs. p1) ; p2 = (\<exists>p DASHED_TWICE . (\<exists>p vs . p1)[SS1] \<and>p p2[SS2])"
    by (simp add:SemiR_algebraic closure)

  also have "... = (\<exists>p DASHED_TWICE . (\<exists>p (SS1 `\<^sub>s vs) . p1[SS1]) \<and>p p2[SS2])"
    by (metis (lifting) RenameP_ExistsP_distr1)

  also have "... = (\<exists>p DASHED_TWICE . \<exists>p (SS1 `\<^sub>s vs) . (p1[SS1] \<and>p p2[SS2]))"
  proof -
    from unrests have "UNREST (SS1 `\<^sub>s vs) p2[SS2]"
    proof -

      have "undash ` (out vs) \<subseteq> UNDASHED \<union> DASHED"
        by (force simp add:var_defs)

      moreover have "dash ` out vs \<subseteq> DASHED_TWICE"
        by (force simp add:var_defs)

      moreover from assms have "UNREST (dash ` out vs) p2[SS2]"
        apply (rule_tac ?vs1.0="undash ` out vs" in UNREST_RenameP_alt)
        apply (auto simp add:var_member closure calculation var_simps SS2_simps)
        apply (metis (no_types) DASHED_undash_UNDASHED SS2_UNDASHED_app dash_undash_DASHED rev_image_eqI set_rev_mp utp_var.out_DASHED)
      done

      moreover from assms have "UNREST (in vs) p2[SS2]"
        apply (rule_tac ?vs1.0="dash ` dash ` in vs" in UNREST_RenameP_alt)
        apply (force intro:  UNREST_subset simp add:var_defs)
        apply (auto simp add:closure image_def)
        apply (rule_tac x="dash (dash x)" in exI)
        apply (auto simp add:SS2_simps)
        apply (metis (lifting) DASHED_dash_DASHED_TWICE SS2_DASHED_TWICE_app UNDASHED_dash_DASHED UnCI le_iff_sup undash_dash utp_var.in_UNDASHED)
      done

      ultimately show ?thesis using assms
        by (metis (lifting) SS1_UNDASHED_DASHED_image UNREST_union)
    qed

    thus ?thesis
      by (metis (lifting) ExistsP_AndP_expand1)
  qed

  also from assms have "... = (\<exists>p in vs. \<exists>p DASHED_TWICE . p1[SS1] \<and>p p2[SS2])"
  proof -
    have "dash ` (out vs) \<union> DASHED_TWICE = DASHED_TWICE"
      by (force simp add:var_defs)

    thus ?thesis using assms
      apply (simp add:SS1_simps)
      apply (smt ExistsP_union SS1_UNDASHED_DASHED_image Un_commute rename_image_def)
    done
  qed

  also from assms have "... = (\<exists>p in vs. (p1 ; p2))"
    by (simp add:SemiR_algebraic closure)

  ultimately show ?thesis
    by simp
qed

lemma ExistsP_UNDASHED_expand_SemiR:
  "\<lbrakk> p \<in> WF_RELATION; q \<in> WF_RELATION; vs \<subseteq> UNDASHED \<rbrakk> \<Longrightarrow> 
  (\<exists>p vs. p) ; q = (\<exists>p vs. (p ; q))"
  apply (simp add: SemiR_algebraic_rel closure urename)
  apply (subgoal_tac "UNREST vs (q[SS2])")
  apply (simp add:ExistsP_AndP_expand1)
  apply (smt ExistsP_union Un_commute)
  apply (rule unrest) 
  apply (auto intro:closure simp add:urename)
done

lemma ExistsP_DASHED_expand_SemiR:
  "\<lbrakk> p \<in> WF_RELATION; q \<in> WF_RELATION; vs \<subseteq> DASHED \<rbrakk> \<Longrightarrow> 
  p ; (\<exists>p vs. q) = (\<exists>p vs. (p ; q))"
  apply (simp add: SemiR_algebraic_rel closure urename)
  apply (subgoal_tac "UNREST vs (p[SS1])")
  apply (simp add:ExistsP_AndP_expand2)
  apply (smt ExistsP_union Un_commute)
  apply (rule unrest) 
  apply (auto intro:closure simp add:urename)
done

text {* The following theorems show that an existential may be inserted or
        dropped from within a sequential composition when the opposing
        relation does not restrict the variables in the quantification *}

(* Note that assumption assumption 2 is automatic under a homogeneous alphabet.
   The following proof is performed by application of existential lifting.

   FIXME: The new tactics probably make these proofs much easier and cleaner...
 *)


theorem SemiR_ExistsP_left:
  assumes
  "UNREST DASHED_TWICE p" "UNREST DASHED_TWICE q"
  "UNREST (DASHED - vs1) p" "UNREST (UNDASHED - vs2) q"
  "vs1 \<subseteq> DASHED" "vs2 \<subseteq> UNDASHED"
  "dash ` vs2 \<subseteq> vs1"
  shows "(\<exists>p (vs1 - dash ` vs2). p) ; q = p ; q"
proof -

  let ?A = "dash ` out vs1 - dash ` dash ` in vs2"

  from assms have UNREST: "UNREST DASHED_TWICE (\<exists>p vs1 - dash ` vs2 . p)"
    by (auto intro:unrest)

  hence "(\<exists>p (vs1 - dash ` vs2). p) ; q = 
        (\<exists>p DASHED_TWICE .
         (\<exists>p ?A . p[SS1]) \<and>p q[SS2])"
  proof -

    from assms have "vs1 \<subseteq> UNDASHED \<union> DASHED"
      by (auto)

    with UNREST show ?thesis using assms
      apply (simp add: SemiR_algebraic closure urename var_simps)
      apply (simp add: SS1_UNDASHED_DASHED_image[simplified] var_simps var_dist closure)
    done
  qed

  also from assms(4) have "... = (\<exists>p DASHED_TWICE . (\<exists>p ?A . p[SS1] \<and>p q[SS2]))"
  proof -
    from assms(4) have "UNREST ?A q[SS2]"
      apply (rule unrest)
      apply (subgoal_tac "UNDASHED - vs2 \<subseteq> UNDASHED \<union> DASHED")
      apply (simp add: SS2_UNDASHED_DASHED_image[simplified] var_simps var_dist closure)
      apply (auto intro: unrest)
      apply (metis (lifting) DASHED_dash_DASHED_TWICE set_rev_mp utp_var.out_DASHED)
    done

    thus ?thesis
      by (metis ExistsP_AndP_expand1)
  qed

  also have "... = (\<exists>p DASHED_TWICE . p[SS1] \<and>p q[SS2])"
  proof -
    have "?A \<subseteq> DASHED_TWICE"
      by (auto simp add:var_defs)

    thus ?thesis
      by (metis ExistsP_union sup_absorb1)
  qed

  ultimately show ?thesis using assms UNREST
    by (simp add:SemiR_algebraic)
qed

theorem SemiR_ExistsP_right:
  assumes
  "UNREST DASHED_TWICE p" "UNREST DASHED_TWICE q"
  "UNREST (DASHED - vs1) p" "UNREST (UNDASHED - vs2) q"
  "vs1 \<subseteq> DASHED" "vs2 \<subseteq> UNDASHED"
  "vs1 \<subseteq> dash ` vs2"
  shows "p ; (\<exists>p (vs2 - undash ` vs1). q) = p ; q"
proof -

  let ?A = "dash ` dash ` in vs2 - (dash ` dash ` in (undash ` vs1) \<union> out (undash ` vs1))"

  from assms have UNREST: "UNREST DASHED_TWICE (\<exists>p vs2 - undash ` vs1 . q)"
    by (auto intro:unrest)

  hence "p ; (\<exists>p (vs2 - undash ` vs1). q) = 
        (\<exists>p DASHED_TWICE .
         p[SS1] \<and>p (\<exists>p ?A . q[SS2]))"
  proof -

    from assms have "vs1 \<subseteq> UNDASHED \<union> DASHED"
      by (auto)

    with UNREST show ?thesis using assms
      apply (simp add: SemiR_algebraic closure urename var_simps)
      apply (subgoal_tac "undash ` vs1 \<subseteq> UNDASHED \<union> DASHED")
      apply (subgoal_tac "vs2 \<subseteq> UNDASHED \<union> DASHED")
      apply (simp add: SS2_UNDASHED_DASHED_image[simplified] var_simps var_dist closure)
      apply (auto)
    done
  qed

  also have "... = (\<exists>p DASHED_TWICE . (\<exists>p ?A . p[SS1] \<and>p q[SS2]))"
  proof -
    from assms(3) have "UNREST ?A p[SS1]"
      apply (rule unrest)
      apply (subgoal_tac "DASHED - vs1 \<subseteq> UNDASHED \<union> DASHED")
      apply (simp add: SS1_UNDASHED_DASHED_image[simplified] var_simps var_dist closure)
      apply (auto intro: unrest)
      apply (metis DASHED_dash_DASHED_TWICE Int_iff UNDASHED_dash_DASHED in_vars_def)
      apply (metis (lifting) assms(5) dash_undash_image image_eqI out_dash)
    done

    thus ?thesis
      by (smt ExistsP_AndP_expand2)
  qed

  also have "... = (\<exists>p DASHED_TWICE . p[SS1] \<and>p q[SS2])"
  proof -
    have "?A \<subseteq> DASHED_TWICE"
      by (auto simp add:var_defs)

    thus ?thesis
      by (smt ExistsP_union sup_absorb1)
  qed

  ultimately show ?thesis using assms UNREST
    by (simp add:SemiR_algebraic)
qed

text {* This property allows conversion of an alphabetised identity into an existential *} 

lemma SemiR_right_ExistsP:
  "\<lbrakk> p \<in> WF_RELATION; x \<in> UNDASHED \<rbrakk> \<Longrightarrow> 
    p ; II (REL_VAR - {x,x\<acute>}) = (\<exists>p {x\<acute>}. p)"
  apply (subgoal_tac "REL_VAR - (REL_VAR - {x, x\<acute>}) = {x,x\<acute>}")
  apply (auto simp add:SkipRA_def closure unrest ExistsP_SemiR_expand1 var_dist SkipR_ExistsP_out)
done

lemma UNREST_unionE [elim]: 
  "\<lbrakk> UNREST (xs \<union> ys) p; \<lbrakk> UNREST xs p; UNREST ys p \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (metis UNREST_subset sup_ge1 sup_ge2)

lemma UNREST_EXPR_unionE [elim]: 
  "\<lbrakk> UNREST_EXPR (xs \<union> ys) p; \<lbrakk> UNREST_EXPR xs p; UNREST_EXPR ys p \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
by (metis UNREST_EXPR_subset inf_sup_ord(4) sup_ge1)

lemma SubstP_rel_closure [closure]:
  "\<lbrakk> p \<in> WF_RELATION; UNREST_EXPR NON_REL_VAR v; x \<in> REL_VAR; v \<rhd>\<^sub>e x \<rbrakk> 
  \<Longrightarrow> p[v|x] \<in> WF_RELATION"
  by (auto intro:unrest simp add:WF_RELATION_def unrest typing)

lemma SemiR_left_one_point:
  assumes "x \<in> UNDASHED" "P \<in> WF_RELATION" "Q \<in> WF_RELATION" "v \<rhd>\<^sub>e x"
          "UNREST_EXPR (DASHED \<union> NON_REL_VAR) v" "UNREST_EXPR {x} v"
  shows "`P ; ($x = v \<and> Q)` = `P[v\<acute>/x\<acute>] ; Q[v/x]`"
proof -

  let ?vs = DASHED_TWICE

  from assms 
  have "`P ; (($x = v) \<and> Q)` = (\<exists>p DASHED_TWICE. P[SS1] \<and>p `(($x = v) \<and> Q)`[SS2])"
    apply (rule_tac SemiR_algebraic_rel)
    apply (auto intro: closure unrest UNREST_EXPR_subset)
  done

  also from assms 
  have "... = (\<exists>p ?vs . P[SS1] \<and>p ((VarE x\<acute>\<acute>) ==p v[SS2]\<epsilon>) \<and>p Q[SS2])"
    by (simp add:urename)

  also
  have "... = (\<exists>p ?vs - {x\<acute>\<acute>} . \<exists>p {x\<acute>\<acute>} . P[SS1] \<and>p ((VarE x\<acute>\<acute>) ==p v[SS2]\<epsilon>) \<and>p Q[SS2])"
    by (smt DASHED_dash_DASHED_TWICE ExistsP_union UNDASHED_dash_DASHED assms(1) insert_Diff_single insert_absorb insert_is_Un sup_commute)

  also
  have "... = (\<exists>p ?vs - {x\<acute>\<acute>} . (\<exists>p {x\<acute>\<acute>} . (P[SS1] \<and>p Q[SS2]) \<and>p ((VarE x\<acute>\<acute>) ==p v[SS2]\<epsilon>)))"
    by (smt AndP_assoc AndP_comm)

  also from assms
  have "... = (\<exists>p ?vs - {x\<acute>\<acute>} . (P[SS1] \<and>p Q[SS2])[v[SS2]\<epsilon>|x\<acute>\<acute>])"
    apply (subgoal_tac "v[SS2]\<epsilon> \<rhd>\<^sub>e x")
    apply (subgoal_tac "UNREST_EXPR {x\<acute>\<acute>} (v[SS2]\<epsilon>)")
    apply (simp add: ExistsP_one_point typing defined)
    apply (rule UNREST_EXPR_subset)
    apply (rule unrest)
    apply (simp) back
    apply (simp add:urename)
    apply (simp add:typing)
  done

  also from assms
  have "... = (\<exists>p DASHED_TWICE - {x\<acute>\<acute>} . ((P[v[SS]\<epsilon>|x\<acute>])[SS1]) \<and>p ((Q[v|x])[SS2]))"
  proof -

    from assms have "(P[v[SS]\<epsilon>|x\<acute>])[SS1] = P[SS1][v[SS2]\<epsilon>|x\<acute>\<acute>]"
      apply (simp add:urename typing closure unrest defined)
      apply (subgoal_tac "UNREST_EXPR (VAR - UNDASHED) v")
      apply (drule RenameE_equiv[of UNDASHED v])
      apply (rule SS1_SS_eq_SS2)
      apply (simp)
      apply (auto intro:unrest UNREST_EXPR_subset)
    done

    moreover 
    from assms have "((Q[v|x])[SS2]) = (Q[SS2])[v[SS2]\<epsilon>|x\<acute>\<acute>]"
      by (simp add:urename typing closure unrest defined)

    ultimately show ?thesis by (simp add:usubst)

  qed

  also
  have "... = (\<exists>p DASHED_TWICE - {x\<acute>\<acute>}. \<exists>p {x\<acute>\<acute>} . (`P[v\<acute>/x\<acute>]`[SS1]) \<and>p (`Q[v/x]`[SS2]))"
  proof -
    from assms have "UNREST {x\<acute>\<acute>} (`P[v\<acute>/x\<acute>]`[SS1])"
      apply (rule_tac unrest)
      apply (rule_tac unrest)
      apply (simp add:typing)
      apply (rule UNREST_EXPR_subset)
      apply (rule unrest)
      apply (simp) back
      apply (simp_all add:urename)
    done

    moreover from assms have "UNREST {x\<acute>\<acute>} (`Q[v/x]`[SS2])"
      apply (rule_tac unrest)
      apply (rule_tac unrest)
      apply (simp add:typing)
      apply (simp_all add:urename)
    done

    ultimately show ?thesis
      by (metis (hide_lams, no_types) ExistsP_ident UNREST_AndP)
  qed

  also from assms 
  have "... = (\<exists>p DASHED_TWICE. (`P[v\<acute>/x\<acute>]`[SS1]) \<and>p (`Q[v/x]`[SS2]))"
    by (smt DASHED_dash_DASHED_TWICE ExistsP_union UNDASHED_dash_DASHED Un_commute Un_empty_left Un_insert_right insert_Diff_single insert_absorb)

  also from assms
  have "... = `P[v\<acute>/x\<acute>] ; Q[v/x]`"
    apply (rule_tac SemiR_algebraic_rel[THEN sym])
    apply (auto intro: closure unrest UNREST_EXPR_subset simp add:typing defined urename)
    apply (rule closure)
    apply (simp_all add:typing)
    apply (rule UNREST_EXPR_subset)
    apply (rule unrest)
    apply (simp)
    apply (simp add:urename)
  done

  ultimately show ?thesis by simp
qed

(*
lemma SemiR_left_one_point:
  assumes "x \<in> UNDASHED" "P \<in> WF_RELATION" "v \<rhd>\<^sub>e x" 
          "UNREST_EXPR (DASHED \<union> NON_REL_VAR) v" "UNREST_EXPR {x} v"
  shows "P ; (VarE x ==p v \<and>p II (REL_VAR - {x,x\<acute>})) = P[v[SS]\<epsilon>|x\<acute>]"
proof -
  
  from assms 
  have "P ; (VarE x ==p v \<and>p II (REL_VAR - {x,x\<acute>})) 
       = P \<and>p (VarE x\<acute> ==p v[SS]\<epsilon>) ; II (REL_VAR - {x,x\<acute>})"
    apply (subgoal_tac "REL_VAR - (REL_VAR - {x, x\<acute>}) = {x,x\<acute>}")
    apply (rule_tac trans)
    apply (rule SemiR_AndP_right_precond)
    apply (simp add:closure unrest)
    apply (force intro:closure)
    apply (rule closure)
    apply (rule unrest)
    apply (force)
    apply (subgoal_tac "(- UNDASHED :: 'a VAR set) = DASHED \<union> NON_REL_VAR")
    apply (simp)
    apply (auto)[1]
    apply (simp add:ConvR_def urename)
    apply (force)
  done

  also from assms
  have "... = (\<exists>p {x\<acute>}. P \<and>p (VarE x\<acute> ==p v[SS]\<epsilon>))"
    apply (rule_tac SemiR_right_ExistsP)
    apply (rule closure)
    apply (simp)
    apply (rule closure)
    apply (rule unrest)
    apply (auto intro:unrest simp add:urename)
    apply (rule UNREST_EXPR_subset)
    apply (rule unrest)
    apply (auto simp add:urename)
  done

  also from assms have "... = P[v[SS]\<epsilon>|x\<acute>]"
    apply (rule_tac ExistsP_one_point)
    apply (simp add:typing)
    apply (rule UNREST_EXPR_subset)
    apply (rule unrest)
    apply (simp) back
    apply (simp add:urename)
  done

  ultimately show ?thesis by simp
qed
*)

subsubsection {* Alphabetised Skip laws *}

theorem SemiR_SkipRA_right :
  assumes 
  "UNREST (DASHED - out vs) p"
  "UNREST (dash ` (UNDASHED - in vs)) p"
  "UNREST DASHED_TWICE p" 
  "vs \<subseteq> UNDASHED \<union> DASHED"
  shows 
  "p ; II vs = p"
proof -
  have "UNREST DASHED_TWICE II"
    by (auto simp add:SkipR_def closure UNREST_def)

  moreover from assms have "UNDASHED - in vs =  in (UNDASHED \<union> DASHED - vs)"
    by (auto simp add:var_simps var_defs)

  moreover from assms have "out (UNDASHED \<union> DASHED - vs) = DASHED - out vs "
    by (auto simp add:var_simps var_defs)

  moreover have "(UNDASHED \<union> DASHED) - vs \<subseteq> (UNDASHED \<union> DASHED)"
    by force

  moreover from assms have "p ; II = p"
    by (utp_rel_auto_tac)

  ultimately show ?thesis using assms
    by (metis (lifting) ExistsP_SemiR_expand1 ExistsP_ident SkipRA.rep_eq)
qed

theorem SemiR_SkipRA_left :
  assumes 
  "UNREST (UNDASHED - in vs) p"
  "UNREST (undash ` (DASHED - out vs)) p"
  "UNREST DASHED_TWICE p" 
  "vs \<subseteq> UNDASHED \<union> DASHED"
  shows 
  "II vs ; p = p"
proof -
  have "UNREST DASHED_TWICE II"
    by (auto simp add:SkipR_def closure UNREST_def)

  moreover have "(UNDASHED \<union> DASHED) - vs \<subseteq> (UNDASHED \<union> DASHED)"
    by force

  moreover from assms have "DASHED - out vs = out (UNDASHED \<union> DASHED - vs)"
    by (auto simp add:var_simps var_defs)

  moreover from assms have "in (UNDASHED \<union> DASHED - vs) = UNDASHED - in vs "
    by (auto simp add:var_simps var_defs)

  moreover from assms have "II ; p = p"
    by (utp_rel_auto_tac)

  ultimately show ?thesis using assms
    by (metis (lifting) ExistsP_SemiR_expand2 ExistsP_ident SkipRA.rep_eq)
qed

lemma SkipRA_left_unit:
  assumes "P \<in> WF_RELATION" "vs \<subseteq> REL_VAR" "UNREST (UNDASHED - in vs) P"
          "HOMOGENEOUS vs"
  shows "II vs ; P = P"
  apply (rule_tac SemiR_SkipRA_left)
  apply (simp_all add:assms unrest closure var_dist)
done

lemma SkipRA_right_unit:
  assumes "P \<in> WF_RELATION" "vs \<subseteq> REL_VAR" "UNREST (DASHED - out vs) P"
          "HOMOGENEOUS vs"
  shows "P ; II vs = P"
  apply (rule_tac SemiR_SkipRA_right)
  apply (simp_all add:assms unrest closure var_dist)
done

theorem SkipRA_empty :
  shows "II {} = true"
  apply (simp add:SkipRA_def)
  apply (utp_pred_tac)
  apply (rule_tac x="\<B>" in exI)
  apply (simp add:default_binding.rep_eq)
done

theorem SkipRA_unfold :
  assumes "x \<in> vs" "dash x \<in> vs" "x \<in> UNDASHED" "HOMOGENEOUS vs"
  shows "II vs = VarE (dash x) ==p VarE x \<and>p II (vs - {x,dash x})"
proof -

  have "(UNDASHED \<union> DASHED - vs) \<inter> (UNDASHED \<union> DASHED - (vs - {x, dash x})) = UNDASHED \<union> DASHED - vs"
    by (force)


  (* The proof below proceeds by showing that any variable v is identified by both sides
     of the goal. The are three cases of v:
     1) v = x
     2) v \<noteq> x and v \<in> vs
     3) v \<noteq> x and v \<notin> vs
  *)

  with assms show ?thesis
    apply (simp add:SkipRA_def)
    apply (utp_pred_tac, utp_expr_tac)
    apply (safe)
    (* Subgoal 1 *)
    apply (force)
    (* Subgoal 2 *)
    apply (rule_tac x="b \<oplus>\<^sub>b b' on UNDASHED \<union> DASHED - vs" in exI)
    apply (simp_all add:closure)
    (* Subgoal 3 *)
    apply (rule_tac x="b'" in exI)
    apply (rule ballI)
    apply (case_tac "v=x")
    (* Subgoal 3.1 (Case 1) *)
    apply (simp_all)
    apply (case_tac "v \<in> vs")
    (* Subgoal 3.2 (Case 2) *)
    apply (simp_all)
    apply (erule_tac v="v" in hom_alphabet_undash)
    apply (simp_all)
    apply (drule_tac x="v" in bspec)
    apply (simp)
    apply (subgoal_tac "dash v \<noteq> dash x")
    apply (subgoal_tac "v \<in> vs - {x, dash x}")
    apply (subgoal_tac "dash v \<in> vs - {x, dash x}")
    apply (simp)
    apply (force)
    apply (force)
    apply (metis undash_dash)
    (* Subgoal 3.3 (Case 3) *)
    apply (subgoal_tac "dash v \<in> UNDASHED \<union> DASHED - vs")
    apply (force)
    apply (simp)
    apply (metis hom_alphabet_dash)
  done
qed

subsection {* Assignment Laws *}

theorem AssignR_SemiR_left:
  "\<lbrakk> x \<in> UNDASHED; e \<rhd>\<^sub>e x; UNREST_EXPR DASHED e \<rbrakk> \<Longrightarrow> `x := e ; p` = `p[e/x]`"
  apply (utp_rel_auto_tac)
  apply (subgoal_tac "xa(x :=\<^sub>b \<lbrakk>e\<rbrakk>\<epsilon>xa) \<in> WF_REL_BINDING")
  apply (simp add:WF_REL_BINDING_def)
  apply (auto)
  apply (rule_tac x="b(x :=\<^sub>b \<langle>xa\<rangle>\<^sub>b x)" in exI)
  apply (subgoal_tac "b(x :=\<^sub>b \<langle>xa\<rangle>\<^sub>b x) \<oplus>\<^sub>b bc on DASHED = (b \<oplus>\<^sub>b bc on DASHED)(x :=\<^sub>b \<langle>xa\<rangle>\<^sub>b x)")
  apply (drule sym)
  apply (simp_all add:typing)
done

lemma AssignRA_alt_def:
  assumes "x \<in> a" "x\<acute> \<in> a" "x \<in> UNDASHED" "UNREST_EXPR (UNDASHED \<union> DASHED - a) v" "v \<rhd>\<^sub>e x"
  shows "AssignRA x a v = VarE x\<acute> ==p v \<and>p II (a - {x,x\<acute>})"
using assms
proof (simp add:SkipRA_def AssignRA_def AssignR_alt_def)
  from assms have "UNDASHED \<union> DASHED - (a - {x, x\<acute>}) = (UNDASHED \<union> DASHED - a) \<union> {x, x\<acute>}"
    by (auto)

  hence "(\<exists>p UNDASHED \<union> DASHED - (a - {x, x\<acute>}) . II) = (\<exists>p UNDASHED \<union> DASHED - a. \<exists>p {x, x\<acute>} . II)"
    by (metis (lifting) ExistsP_union)

  moreover from assms have "UNREST ((UNDASHED \<union> DASHED) - a) (VarE x\<acute> ==p v)"
    by (rule_tac unrest, auto intro:unrest)

  ultimately show "(\<exists>p REL_VAR - a . VarE x\<acute> ==p v \<and>p (\<exists>p {x, x\<acute>} . II)) =
                    VarE x\<acute> ==p v \<and>p (\<exists>p insert x (insert x\<acute> (REL_VAR - a)) . II)"
    by (metis (hide_lams, no_types) ExistsP_AndP_expand2 ExistsP_union Un_insert_right sup_bot_right)
qed

theorem AssignRA_SemiR_left:
  assumes "x \<in> UNDASHED" "x \<in> vs" "e \<rhd>\<^sub>e x" "HOMOGENEOUS vs" "vs \<subseteq> UNDASHED \<union> DASHED"
   "UNREST (VAR - vs) p" "UNREST_EXPR (VAR - in vs) e"
  shows "(x :=p\<^bsub>vs\<^esub> e ; p) = p[e|x]"
proof -

  from assms have "UNREST DASHED_TWICE (x :=p e)" 
    apply (rule_tac UNREST_subset)
    apply (rule unrest)
    apply (auto)
    apply (rule UNREST_EXPR_subset)
    apply (auto)
  done

  moreover from assms have "UNREST DASHED_TWICE p" 
    by (rule_tac UNREST_subset, auto intro:unrest)

  moreover from assms have 
    "UNDASHED \<union> DASHED - vs \<subseteq> UNDASHED \<union> DASHED" and
    "UNREST (undash ` out (UNDASHED \<union> DASHED - vs)) p"
    "UNREST_EXPR DASHED e"
    apply (auto intro:unrest)
    apply (rule_tac UNREST_subset)
    apply (simp)
    apply (simp add:var_dist)
    apply (force)
    apply (rule UNREST_EXPR_subset)
    apply (simp)
    apply (force)
  done

  moreover from assms have "UNREST (in (UNDASHED \<union> DASHED - vs)) (p[e|x])"
    apply (rule_tac UNREST_subset[of "(VAR - vs) \<inter> (VAR - in vs)"])
    apply (rule_tac unrest)
    apply (simp_all add:var_dist)
    apply (force)
  done

  ultimately show ?thesis using assms
    apply (simp add:AssignRA_def)
    apply (rule trans)
    apply (rule ExistsP_SemiR_expand2)
    apply (simp_all)
    apply (simp add: AssignR_SemiR_left ExistsP_ident)
  done
qed

theorem SkipRA_assign :
  assumes "x \<in> vs" "x\<acute> \<in> vs" "x \<in> UNDASHED" "HOMOGENEOUS vs"
  shows "II vs = x :=p\<^bsub>vs\<^esub> VarE x"
  apply (subgoal_tac "UNREST_EXPR (UNDASHED \<union> DASHED - vs) (VarE x)")
  apply (subgoal_tac "VarE x \<rhd>\<^sub>e x")
  apply (simp add:assms SkipRA_unfold[of x vs] AssignRA_alt_def[of x vs "VarE x"])
  apply (simp add:typing)
  apply (rule UNREST_EXPR_VarE)
  apply (force simp add:assms)
done

subsubsection {* Variable Laws *}

lemma VarOpenP_commute:
  "\<lbrakk> x \<in> UNDASHED; y \<in> UNDASHED \<rbrakk> \<Longrightarrow> `var x; var y` = `var y; var x`"
    apply (simp add:VarOpenP_def)
    apply (simp add:assms ExistsP_UNDASHED_expand_SemiR closure)
    apply (metis (hide_lams, no_types) ExistsP_insert insert_commute)
done

lemma VarCloseP_commute:
  "\<lbrakk> x \<in> UNDASHED; y \<in> UNDASHED \<rbrakk> \<Longrightarrow> `end x; end y` = `end y; end x`"
    apply (simp add:VarCloseP_def)
    apply (simp add:assms ExistsP_DASHED_expand_SemiR closure)
    apply (metis (hide_lams, no_types) ExistsP_insert insert_commute)
done

lemma [simp]: "REL_VAR - VAR = {}"
  by (simp add:var_simps)

lemma VarOpenP_VarCloseP:
  "x \<in> UNDASHED \<Longrightarrow> `var x; end x` = II (VAR - {x,x\<acute>})"
  apply (simp add:VarOpenP_def VarCloseP_def)
  apply (simp add:ExistsP_UNDASHED_expand_SemiR ExistsP_DASHED_expand_SemiR closure)
  apply (simp add: SkipRA_def)
  apply (metis ExistsP_deatomise doubleton_eq_iff)
done

lemma AssignR_VarCloseP:
  "\<lbrakk> x \<in> UNDASHED; v \<rhd>\<^sub>e x; UNREST_EXPR DASHED v \<rbrakk> \<Longrightarrow> `x := v; end x` = `end x`"
  apply (simp add:AssignR_SemiR_left VarCloseP_def SkipR_as_SkipRA)
  apply (subgoal_tac "UNREST_EXPR {x\<acute>} v")
  apply (simp add: SkipRA_unfold[of x REL_VAR, simplified] usubst closure unrest typing defined)
  apply (subgoal_tac "UNREST {x\<acute>} (II (REL_VAR - {x, x\<acute>}))")
  apply (simp add: ExistsP_AndP_expand1[THEN sym])
  apply (simp add:ExistsP_has_value typing defined unrest)
  apply (auto intro:unrest UNREST_subset UNREST_EXPR_subset)
done

subsubsection {* Conditional Laws *}

theorem CondR_true:
  "`P \<lhd> true \<rhd> Q` = P"
  by (utp_pred_tac)

theorem CondR_false:
  "`P \<lhd> true \<rhd> Q` = P"
  by (utp_pred_tac)

theorem CondR_idem:
  "`P \<lhd> b \<rhd> P` = P"
  by (utp_pred_auto_tac)

theorem CondR_sym:
  "`P \<lhd> b \<rhd> Q` = `Q \<lhd> \<not>b \<rhd> P`"
  by (utp_pred_auto_tac)

theorem CondR_assoc:
  "`(P \<lhd> b \<rhd> Q) \<lhd> c \<rhd> R` = `P \<lhd> (b \<and> c) \<rhd> (Q \<lhd> c \<rhd> R)`"
  by (utp_pred_auto_tac)

theorem CondR_distrib:
  "`P \<lhd> b \<rhd> (Q \<lhd> c \<rhd> R)` = `(P \<lhd> b \<rhd> Q) \<lhd> c \<rhd> (P \<lhd> b \<rhd> R)`"
  by (utp_pred_auto_tac)

theorem CondR_unreachable_branch:
  "`P \<lhd> b \<rhd> (Q \<lhd> b \<rhd> R)` = `P \<lhd> b \<rhd> R`"
  by (utp_pred_auto_tac)

theorem CondR_disj:
  "`P \<lhd> b \<rhd> (P \<lhd> c \<rhd> Q)` = `P \<lhd> b \<or> c \<rhd> Q`"
  by (utp_pred_auto_tac)

theorem CondR_SemiR_distr: 
  assumes "p \<in> WF_RELATION" "q \<in> WF_RELATION" "r \<in> WF_RELATION" "b \<in> WF_CONDITION"
  shows "(p \<triangleleft> b \<triangleright> q) ; r = (p ; r) \<triangleleft> b \<triangleright> (q ; r)"
  using assms
proof -

  from assms have "b ; true = b"
    by (simp add: SemiR_TrueP_precond)

  with assms show ?thesis
    by utp_xrel_auto_tac
qed


subsubsection {* Converse Laws *}

lemma ConvR_invol [simp]: "(p\<^sup>\<smile>)\<^sup>\<smile> = p"
  by (utp_rel_tac)

lemma ConvR_TrueP [simp]: "true\<^sup>\<smile> = true"
  by (simp add:ConvR_def urename)

lemma ConvR_FalseP [simp]: "false\<^sup>\<smile> = false"
  by (simp add:ConvR_def urename)

lemma ConvR_SkipR [simp]: "II\<^sup>\<smile> = II"
  by (utp_rel_tac)

lemma ConvR_SemiR [urename]: "(p;q)\<^sup>\<smile> = q\<^sup>\<smile> ; p\<^sup>\<smile>"
  by (utp_rel_auto_tac)

lemma ConvR_OrP [urename]: "(p \<or>p q)\<^sup>\<smile> = p\<^sup>\<smile> \<or>p q\<^sup>\<smile>"
  by (utp_rel_auto_tac)

lemma ConvR_AndP [urename]: "(p \<and>p q)\<^sup>\<smile> = p\<^sup>\<smile> \<and>p q\<^sup>\<smile>"
  by (utp_rel_auto_tac)

lemma ConvR_NotP [urename]: "(\<not>p p)\<^sup>\<smile> = \<not>p(p\<^sup>\<smile>)"
  by (simp add:ConvR_def urename)

lemma ConvR_VarP_1 [urename]: 
  "x \<in> UNDASHED \<Longrightarrow> (VarP x)\<^sup>\<smile> = VarP x\<acute>"
  by (simp add:ConvR_def urename)

lemma ConvR_VarP_2 [urename]: 
  "x \<in> UNDASHED \<Longrightarrow> (VarP x\<acute>)\<^sup>\<smile> = VarP x"
  by (simp add:ConvR_def urename)


end