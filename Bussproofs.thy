theory Bussproofs
  imports Main
begin

section\<open>Proof Tree Printing\<close>

text\<open>
  We set up an antiquotation to allow for printing datatypes as proof trees in text.
  For printing the proof trees in LaTeX we use the \texttt{bussproofs} package.

  We first define a datatype to represent the tree with information needed to print it.
  Finally we define the antiquotation that takes a prooftree term displays it.
\<close>

datatype 'lab label = NoLabel | LeftLabel 'lab | RightLabel 'lab

(* TODO could also allow line customisation *)
datatype ('prop, 'lab) prooftree =
    Axiom 'prop
  | Unary "'lab label" 'prop "('prop, 'lab) prooftree"
  | Binary "'lab label" 'prop "('prop, 'lab) prooftree" "('prop, 'lab) prooftree"
  | Trinary "'lab label" 'prop "('prop, 'lab) prooftree" "('prop, 'lab) prooftree" "('prop, 'lab) prooftree"

(* TODO add a constant that could be overloaded by clients to implicitly translate into prooftree *)

(* TODO could handle inline on top of block display *)
ML\<open>
fun latex_label (ctxt: Proof.context) (t: term): Latex.text =
  let
    fun latex_of (Const(@{const_name NoLabel}, _)) = ""
      | latex_of (Const(@{const_name LeftLabel}, _) $ x) = enclose "\\LeftLabel{" "}%\n" (HOLogic.dest_literal x)
      | latex_of (Const(@{const_name RightLabel}, _) $ x) = enclose "\\RightLabel{" "}%\n" (HOLogic.dest_literal x)
      | latex_of t = error (String.concat ["Term not supported in latex_label: ", Syntax.string_of_term ctxt t])
  in
  if type_of t = @{typ "String.literal label"}
    then Latex.string (latex_of t)
    else error ("String literal label expected: " ^ Syntax.string_of_typ ctxt (type_of t))
  end

fun latex_proof_tree (ctxt: Proof.context) (t: term): Latex.text =
  let
    fun latex_of (Const(@{const_name Axiom}, _) $ prop) =
          XML.enclose "\\AxiomC{" "}%\n" (Document_Output.pretty ctxt (Document_Output.pretty_term ctxt prop))
      | latex_of (Const(@{const_name Unary}, _) $ lab $ prop $ x) =
          latex_of x @ latex_label ctxt lab @ XML.enclose "\\UnaryInfC{" "}%\n" (Document_Output.pretty ctxt (Document_Output.pretty_term ctxt prop))
      | latex_of (Const(@{const_name Binary}, _) $ lab $ prop $ x $ y) =
          latex_of x @ latex_of y @ latex_label ctxt lab @ XML.enclose "\\BinaryInfC{" "}%\n" (Document_Output.pretty ctxt (Document_Output.pretty_term ctxt prop))
      | latex_of (Const(@{const_name Trinary}, _) $ lab $ prop $ x $ y $ z) =
          latex_of x @ latex_of y @ latex_of z @ latex_label ctxt lab @ XML.enclose "\\TrinaryInfC{" "}%\n" (Document_Output.pretty ctxt (Document_Output.pretty_term ctxt prop))
      | latex_of t = error (String.concat ["Term not supported in latex_proof_tree: ", Syntax.string_of_term ctxt t])
  in
  if type_of t = @{typ "('a, String.literal) prooftree"}
    then latex_of t
    else error ("Proof tree with string literal labels expected: " ^ Syntax.string_of_typ ctxt (type_of t))
  end

fun print_proof_tree {context: Proof.context, argument: term, ...} =
  let
    val t = Value_Command.value context argument
  in
    Latex.environment "prooftree" (latex_proof_tree context t)
  end

val _ = Theory.setup (Document_Antiquotation.setup \<^binding>\<open>prooftree\<close> (Args.term) print_proof_tree)
\<close>

end