module TTImp.ProcessTransform

import Core.Context
import Core.Context.Log
import Core.Core
import Core.Env
import Core.Metadata
import Core.Evaluate
import Core.Unify.State

import TTImp.Elab
import TTImp.Elab.Check
import TTImp.ProcessDef -- for checking LHS
import TTImp.TTImp

%default covering

export
processTransform : {vars : _} ->
                   {auto c : Ref Ctxt Defs} ->
                   {auto m : Ref MD Metadata} ->
                   {auto u : Ref UST UState} ->
                   List ElabOpt -> NestedNames vars -> Env Term vars -> FC ->
                   Name -> RawImp -> RawImp -> Core ()
processTransform eopts nest env fc tn_in lhs rhs
    = do tn <- inCurrentNS tn_in
         tidx <- resolveName tn
         (_, (vars'  ** (sub', env', nest', lhstm, lhsty))) <-
             checkLHS True top tidx eopts nest env fc lhs
         logTerm "transform.lhs" 3 "Transform LHS" lhstm
         rhstm <- wrapError (InRHS fc tn_in) $
                       checkTermSub tidx InExpr (InTrans :: eopts) nest' env' env sub' rhs
                       !(nf env' lhsty)
         clearHoleLHS
         logTerm "transform.rhs" 3 "Transform RHS" rhstm
         addTransform fc (MkTransform tn env' lhstm rhstm)