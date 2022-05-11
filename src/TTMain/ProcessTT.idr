module TTMain.ProcessTT

import Core.Context
import Core.Env
import Core.Error
import Core.Evaluate
import Core.Syntax.Decls
import Core.Syntax.Raw
import Core.Typecheck.Check

parameters {auto c : Ref Ctxt Defs}
  processEval : RawI -> Core ()
  processEval rawtm
      = do coreLift $ putStrLn $ "Input " ++ show rawtm
           (tm, ty) <- infer top [] rawtm
           tmval <- nf [] tm
           tmnf <- quoteNF [] tmval
           tynf <- normalise [] ty

           coreLift $ putStrLn $ show tmnf ++ " : " ++ show tynf

  export
  processCommand : Command -> Core ()
  processCommand (Decl d) = processDecl d
  processCommand (Eval tm) = processEval tm