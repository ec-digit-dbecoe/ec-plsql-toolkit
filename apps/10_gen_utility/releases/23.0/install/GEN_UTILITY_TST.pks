CREATE OR REPLACE PACKAGE gen_utility_tst AS
--#pragma reversible
/*--#delete

   --%suite(PL/SQL code generator)

   --%context(evaluation of expressions)

#include PACKAGE BODY gen_utility_tst eval-for-loop

#if "tst.exception" != "0"
   --%test(case #tst.seq - tst.name: tst.expression vs tst.result)
   --%throws(tst.exception)
#else
   --%test(case #tst.seq - tst.name: tst.expression vs tst.result)
#endif
   PROCEDURE test_eval_tst.seq;
#endfor

   --%endcontext

   --%context(generator directives)

#include PACKAGE BODY gen_utility_tst dir-for-loop

#if "tst.exception" != "0"
   --%test(case #tst.seq - tst.name)
   --%throws(tst.exception)
#else
   --%test(case #tst.seq - tst.name)
#endif
   PROCEDURE test_dir_tst.seq;
#endfor

   --%endcontext

*/--#delete

END;
/
