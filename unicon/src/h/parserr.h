/*
 * parserr.h -- table of parser error messages.
 *
 * Each entry maps a syntax error from a particular Yacc state into a
 * descriptive message.  This file needs to be updated whenever the
 * grammar is changed.
 */

static struct errmsg {
   int	e_state;		/* parser state number */
   char *e_mesg;		/* message text */
   } errtab[] = {

     0, "invalid declaration",
     1, "end of file expected",
     2, "invalid declaration",
    12, "missing semicolon",
    14, "link list expected",
    15, "invocable list expected",
    17, "invalid declaration",
    18, "missing record name",
    21, "invalid global declaration",
    30, "missing procedure name",
    32, "missing field list in record declaration",
    34, "missing end",
    35, "missing semicolon or operator",
    50, "invalid argument for unary operator",
    51, "invalid argument for unary operator",
    52, "invalid argument for unary operator",
    53, "invalid argument for unary operator",
    54, "invalid argument for unary operator",
    55, "invalid argument for unary operator",
    56, "invalid argument for unary operator",
    57, "invalid argument for unary operator",
    58, "invalid argument for unary operator",
    59, "invalid argument for unary operator",
    60, "invalid argument for unary operator",
    61, "invalid argument for unary operator",
    62, "invalid argument for unary operator",
    63, "invalid argument for unary operator",
    64, "invalid argument for unary operator",
    65, "invalid argument for unary operator",
    66, "invalid argument for unary operator",
    67, "invalid argument for unary operator",
    68, "invalid argument for unary operator",
    69, "invalid argument for unary operator",
    70, "invalid argument for unary operator",
    71, "invalid argument for unary operator",
    72, "invalid argument for unary operator",
    73, "invalid argument for unary operator",
    83, "invalid create expression",
    86, "invalid break expression",
    87, "invalid expression list",
    88, "invalid compound expression",
    89, "invalid expression list",
    90, "invalid keyword construction",
    96, "invalid return expression",
    97, "invalid suspend expression",
    98, "invalid if control expression",
    99, "invalid case control expression",
   100, "invalid while control expression",
   101, "invalid until control expression",
   102, "invalid every control expression",
   103, "invalid repeat expression",
   106, "missing link file name",
   107, "missing operation name",
   108, "missing number of arguments",
   109, "missing parameter list in procedure declaration",
   111, "invalid procedure body",
   112, "invalid local declaration",
   113, "invalid initial expression",
   117, "invalid expression",
   118, "invalid argument",
   119, "invalid argument",
   120, "invalid argument in assignment",
   121, "invalid argument in assignment",
   122, "invalid argument in assignment",
   123, "invalid argument in assignment",
   124, "invalid argument in augmented assignment",
   125, "invalid argument in augmented assignment",
   126, "invalid argument in augmented assignment",
   127, "invalid argument in augmented assignment",
   128, "invalid argument in augmented assignment",
   129, "invalid argument in augmented assignment",
   130, "invalid argument in augmented assignment",
   131, "invalid argument in augmented assignment",
   132, "invalid argument in augmented assignment",
   133, "invalid argument in augmented assignment",
   134, "invalid argument in augmented assignment",
   135, "invalid argument in augmented assignment",
   136, "invalid argument in augmented assignment",
   137, "invalid argument in augmented assignment",
   138, "invalid argument in augmented assignment",
   139, "invalid argument in augmented assignment",
   140, "invalid argument in augmented assignment",
   141, "invalid argument in augmented assignment",
   142, "invalid argument in augmented assignment",
   143, "invalid argument in augmented assignment",
   144, "invalid argument in augmented assignment",
   145, "invalid argument in augmented assignment",
   146, "invalid argument in augmented assignment",
   147, "invalid argument in augmented assignment",
   148, "invalid argument in augmented assignment",
   149, "invalid argument in augmented assignment",
   150, "invalid argument in augmented assignment",
   151, "invalid argument in augmented assignment",
   152, "invalid to clause",
   153, "invalid argument in alternation",
   154, "invalid argument",
   155, "invalid argument",
   156, "invalid argument",
   157, "invalid argument",
   158, "invalid argument",
   159, "invalid argument",
   160, "invalid argument",
   161, "invalid argument",
   162, "invalid argument",
   163, "invalid argument",
   164, "invalid argument",
   165, "invalid argument",
   166, "invalid argument",
   167, "invalid argument",
   168, "invalid argument",
   169, "invalid argument",
   170, "invalid argument",
   171, "invalid argument",
   172, "invalid argument",
   173, "invalid argument",
   174, "invalid argument",
   175, "invalid argument",
   176, "invalid argument",
   177, "invalid argument",
   178, "invalid argument",
   179, "invalid argument",
   180, "invalid argument",
   181, "invalid argument",
   182, "invalid subscript",
   183, "invalid pdco list",
   184, "invalid expression list",
   185, "invalid field name",
   212, "missing right parenthesis",
   214, "missing right brace",
   216, "missing right bracket",
   222, "missing then",
   223, "missing of",
   228, "missing identifier",
   233, "missing right parenthesis",
   235, "missing end",
   236, "invalid declaration",
   237, "missing semicolon or operator",
   303, "missing right bracket",
   306, "missing right brace",
   308, "missing right parenthesis",
   311, "invalid expression list",
   313, "invalid expression",
   315, "invalid do clause",
   316, "invalid then clause",
   317, "missing left brace",
   318, "invalid do clause",
   319, "invalid do clause",
   320, "invalid do clause",
   322, "invalid parameter list",
   328, "invalid by clause",
   330, "invalid section",
   335, "invalid pdco list",
   341, "invalid case clause",
   346, "missing right bracket",
   348, "missing right bracket or ampersand",
   350, "invalid else clause",
   351, "missing right brace or semicolon",
   353, "missing colon",
   354, "missing colon or ampersand",
   359, "invalid case clause",
   360, "invalid default clause",
   361, "invalid case clause",
    -1,  "syntax error"
   };