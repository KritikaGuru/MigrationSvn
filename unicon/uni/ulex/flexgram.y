/*#
# flexgram.y - iyacc grammar for uflex
#
# Katie Ray, Project: ulex, March 15, 2003
# derived from lexgram.y, which contains a C YACC grammar for ulex
#*/

%{
# C version includes tree and automata
global rulenumber
%}

%token OR
%token BACKSLASH
%token SQUAREBRACKETS  
%token DOT             
%token CSET            
%token QUOTES          
%token LINEBEGIN       
%token LINEEND         
%token OPTIONAL        
%token ZEROORMORE      
%token ONEORMORE
%token PARENTHESES     
%token FORWARDSLASH    
%token CURLBRACKETS    
%token OCCURRENCES     
%token CLOSEPARENTHESES     
%token PERCENTS
%token CHARACTER
%token COMMENT
%token ACTION
%token BEGINNING
%token ENDING
%token QUESTION
%token STAR
%token PLUS
%token OREXPR
%token PARENTHETIC
%token FORSLASH
%token EXPRESSION
%token EXPRTREE
%token NEWLINE
%token CONCATEXPR
%token CONCAT

%%

Goal: Start { labelaut($1); createicon($1) } ;

Start:    Newlines Percentexp Newlines { $$ := convert($2) }
        | Newlines Percentexp          { $$ := convert($2) }
        | Percentexp Newlines          { $$ := convert($1) }
        | Percentexp                   { $$ := convert($1) }
	;

Percentexp: Regexps ;

Regexps : Exprs Newlines { $$ := $1 } 
	| Exprs		 { $$ := $1 }
	;

Newlines:  NEWLINE Newlines
	| NEWLINE;

Exprs:    Exprs Newlines OneExpr { $$ := alcnode(EXPRTREE, $1, $3) }
	| OneExpr
	;

OneExpr : Expr ACTION { $$ := alcnode(EXPRESSION, $1, alcleaf(ACTION, yylval.s))}

	| Expr { $$ := alcnode(EXPRESSION, $1, alcleaf(ACTION, "# fail")) }
	;

Expr    : QUOTES       { $$ := alcleaf(QUOTES, yylval.s) }
	| BACKSLASH    { $$ := alcleaf(BACKSLASH, yylval.s) }
	| CSET         { $$ := alcleaf(CSET, yylval.s) }
	| CHARACTER    { $$ := alcleaf(CHARACTER, yylval.s) }
	| DOT          { $$ := alcleaf(DOT) }
	| BeginLine
	| EndLine
	| Question
	| Star
	| Plus
	| Expr OR Expr { $$ := alcnode(OREXPR, $1, alcleaf(OR), $3) }
	| Expr Expr    { $$ := alcnode(CONCATEXPR, $1, alcleaf(CONCAT), $2) }
	| Parenthetic
	| ForSlash
	| Occurrence
	;

BeginLine: LINEBEGIN Expr { $$ := alcnode(BEGINNING, alcleaf(LINEBEGIN), $2) }
	;

EndLine: Expr LINEEND { $$ := alcnode(ENDING, $1, alcleaf(LINEEND)) }
	;

Question: Expr OPTIONAL { $$ := alcnode(QUESTION, $1, alcleaf(OPTIONAL)) }
	;

Star: Expr ZEROORMORE { $$ := alcnode(STAR, $1, alcleaf(ZEROORMORE)) }
	;

Plus: Expr ONEORMORE { $$ := alcnode(PLUS, $1, alcleaf(ONEORMORE)) }
	;

Parenthetic: PARENTHESES Expr CLOSEPARENTHESES {
	    $$ := alcnode(PARENTHETIC, alcleaf(PARENTHESES),
			  $2, alcleaf(CLOSEPARENTHESES))
	   }
	;

ForSlash: Expr FORWARDSLASH Expr {
	   $$ := alcnode(FORSLASH, $1, alcleaf(FORWARDSLASH), $3)
	   }
	;

Occurrence: Expr CURLBRACKETS {
	   $$ := alcnode(OCCURRENCES, $1, alcleaf(CURLBRACKETS, yylval.s))
	   }
	;

%%

# extern int yylineno

procedure yyerror(s)
   #
   # Eventually want to use merr for better error messaging.
   #

   fprintf(stderr, "%s on line %d\n", s, yylineno)
   return 0
end

global root

#
# convert() takes the tree as input and converts it into an automata.
#
procedure convert(tr)
   local returnvalue, aut1, aut2
   local newnode1, newnode2
   local listptr, listptr2
   local elistptr
   local tempstring, getsinglechar
   local t1, t2, i

   if /root := tr then {
      if \debugtree then {
      	 treeprint(tr)
	 exit(0)
         }
      }


   #
   # Conversion is accomplished by breaking it down into separate cases and
   # exploiting recursion wherever possible.
   #

   case tr.label of {
   EXPRTREE: {
	#
	# This case is handled by converting the two subtrees and then making
	# a new start node with epsilon transitions to the start nodes of the
	# two machines for each branch.
	#

	returnvalue := alcautomata()
	returnvalue.start := alcanode(0)

	aut1 := convert(tr.children[1])
	aut2 := convert(tr.children[2])

	returnvalue.start.epsilon := alcnodelist()
	returnvalue.start.epsilon.current := aut1.start
	returnvalue.start.epsilon._next := alcnodelist()
	returnvalue.start.epsilon._next.current := aut2.start

	returnvalue.states := alcnodelist()
	returnvalue.states.current := returnvalue.start

	returnvalue.states._next := aut1.states
	listptr := aut1.states

	while \ (listptr._next) do
	  listptr := listptr._next

	listptr._next := aut2.states
	
	returnvalue.accepting := aut1.accepting
	listptr := aut1.accepting

	while \ (listptr._next) do
	  listptr := listptr._next
	
	listptr._next := aut2.accepting

	return returnvalue
      }

    EXPRESSION: {
	#
	# This case is handled by converting the expression recursively and 
	# associating the accepting states with the semantic action if there
	# is one. This case is also the one that is used to set which rule
	# number is associated with which states. This is accomplished by 
	# using a global variable that is incremented each time that we 
	# convert an expression.
	#

#	write("children is ", image(tr.children))
	if not (returnvalue := convert(tr.children[1])) then
	   stop("convert failed for ", image(tr.children[1])|"nochild")

	if \ (tr.children[2]) then {
	    listptr := returnvalue.accepting
	    while \listptr do {
		listptr.current.semaction := tr.children[2].text
		listptr := listptr._next
	      }
	  }
	
	listptr := returnvalue.states
	
	while \listptr do {
	    listptr.current.rulenum := rulenumber
	    listptr := listptr._next
	  }
	
	rulenumber +:= 1
	
	return returnvalue
      }

    OREXPR: {
	#
	# This case is handled by converting the two expressions that are 
	# connected by the or and making a new start state with an epsilon
	# transition to the start state of each of the other two machines.
	#

	returnvalue := alcautomata()
	returnvalue.start := alcanode(0)
	
	aut1 := convert(tr.children[1])
	aut2 := convert(tr.children[3])

	returnvalue.start.epsilon := alcnodelist()
        returnvalue.start.epsilon.current := aut1.start
        returnvalue.start.epsilon._next := alcnodelist()
        returnvalue.start.epsilon._next.current := aut2.start

	returnvalue.states := alcnodelist()
	returnvalue.states.current := returnvalue.start

        returnvalue.states._next := aut1.states
        listptr := aut1.states

        while \ (listptr._next) do
          listptr := listptr._next

        listptr._next := aut2.states

        returnvalue.accepting := aut1.accepting
        listptr := aut1.accepting

        while \ (listptr._next) do
          listptr := listptr._next

        listptr._next := aut2.accepting

        return returnvalue
      }

    CONCATEXPR: {
	#
	# This case is handled by converting the two subexpressions and 
	# linking the accepting states of the first to the start state of the
	# second. The accepting states are those of the second machine.
	#

	aut1 := convert(tr.children[1])
	aut2 := convert(tr.children[3])

	listptr := aut1.accepting
	
	while \listptr do {
	    if /(listptr.current.epsilon) then {
		listptr.current.epsilon := alcnodelist()
		listptr.current.epsilon.current := aut2.start
	      }

	    else {
		listptr2 := listptr.current.epsilon

		while \ (listptr2._next) do
		  listptr2 := listptr2._next
		
		listptr2._next := alcnodelist()
		listptr2._next.current := aut2.start
	      }

	    listptr := listptr._next
	  }

	listptr := aut1.states

	while \ (listptr._next) do
	  listptr := listptr._next

	listptr._next := aut2.states

	aut1.accepting := aut2.accepting
	return aut1
      }

    QUOTES: {
	#
	# This case is handled by creating a chain of states with transitions
	# that correspond to each individual letter of the string in quotes.
	#

	returnvalue := alcautomata()

	newnode1 := alcanode(0)
	listptr := alcnodelist()
	listptr.current := newnode1

        returnvalue.start := newnode1
        returnvalue.states := listptr

	tempstring := tr.text[2:0]  # skip past initial doublequote

	while tempstring[1] ~== "\"" do {
	    getsinglechar := tempstring[1]
	    newnode2 := alcanode(0)
	    listptr._next := alcnodelist()
	    listptr._next.current := newnode2

	    newnode1.edges := alcedgelist()
	    newnode1.edges.current := alcedge(getsinglechar)
	    newnode1.edges.current.destinations := alcnodelist()
	    newnode1.edges.current.destinations.current := newnode2

	    newnode1 := newnode2
	    listptr := listptr._next
	    tempstring := tempstring[2:0]
	  }

	returnvalue.accepting := alcnodelist()
	returnvalue.accepting.current := newnode2
	return returnvalue
      }

    BACKSLASH: {
	#
	# This case is handled by creating a two state automata with the edge
	# labelled directly with the character that follows the backslash.
	#

	returnvalue := alcautomata()

	newnode1 := alcanode(0)
        newnode2 := alcanode(0)
	
	listptr := alcnodelist()
	listptr.current := newnode1
	listptr._next := alcnodelist()
	listptr._next.current := newnode2

	elistptr := alcedgelist()
	tr.text := tr.text[2:0] # skip over \

	if tr.text == 'n' then tr.text := "\n"
     
	else if tr.text == 't' then tr.text := "\t"

	elistptr.current := alcedge(tr.text)
	
	listptr2 := alcnodelist()
	listptr2.current := newnode2

	elistptr.current.destinations := listptr2

	newnode1.edges := elistptr

	returnvalue.start := newnode1
	returnvalue.states := listptr
	returnvalue.accepting := alcnodelist()
	returnvalue.accepting.current := newnode2

	return returnvalue
      }

    CSET: {
	#
	# This case is handled by creating an automata with a start state and
	# transitioning to a final state and the edge is labelled with the 
	# entire string representing the cset. This becomes a special case in
	# handling the simulation of the automata.
	#

	returnvalue := alcautomata()
	returnvalue.start := alcanode(0)
	returnvalue.states := alcnodelist()
	returnvalue.accepting := alcnodelist()

	returnvalue.accepting.current := alcanode(0)

	returnvalue.states.current := returnvalue.start
	returnvalue.states._next := alcnodelist()
	returnvalue.states._next.current := returnvalue.accepting.current

	returnvalue.start.edges := alcedgelist()
	returnvalue.start.edges.current := alcedge(tr.text)
	returnvalue.start.edges.current.destinations := alcnodelist()
	returnvalue.start.edges.current.destinations.current :=
	  returnvalue.accepting.current

	return returnvalue
      }

    CHARACTER: {
	#
	# The most striaghtforward case - create a two state automata that
	# transitions from the start to the final state on the specified 
	# character.
	#

	returnvalue := alcautomata()

	newnode1 := alcanode(0)
	newnode2 := alcanode(0)
	elistptr := newnode1.edges

	newnode1.edges := alcedgelist()
	newnode1.edges.current := alcedge(tr.text)
	newnode1.edges.current.destinations := alcnodelist()
	newnode1.edges.current.destinations.current := newnode2

	returnvalue.start := newnode1

	returnvalue.states := alcnodelist()
	returnvalue.states.current := newnode1
	returnvalue.states._next := alcnodelist()
	returnvalue.states._next.current := newnode2

	returnvalue.accepting := alcnodelist()
	returnvalue.accepting.current := newnode2

	return returnvalue
      }

    DOT: {
	#
	# This case uses a special feature of our automata that creates a 
	# transition that simply means consume any character. Each node has
	# an associated list of nodes called dot that it can reach on any 
	# single character.
	#

	returnvalue := alcautomata()
	returnvalue.start := alcanode(0)

	newnode1 := alcanode(0)
	listptr := alcnodelist()

	listptr.current := newnode1
	returnvalue.start.dot := listptr

	listptr := alcnodelist()
	listptr.current := returnvalue.start
	listptr._next := alcnodelist()
	listptr._next.current := newnode1
	returnvalue.states := listptr

	returnvalue.accepting := alcnodelist()
	returnvalue.accepting.current := newnode1

	return returnvalue
      }

    BEGINNING: {
	#
	# This is accomplished by converting the tree obtained from the 
	# regular expression into an automata, and then adding a transition
	# from all final states to themselves on any input.
	#

	aut1 := convert(tr.children[2])

	listptr := aut1.accepting

	while \listptr do {
	    listptr2 := listptr.current.dot

	    if /listptr2 then {
		listptr2 := alcnodelist()
		listptr2.current := listptr.current
		listptr.current.dot := listptr2
	      }

	    else {
		while \ (listptr2._next) do
		  listptr2 := listptr2._next
		
		listptr2._next := alcnodelist()
		listptr2._next.current := listptr.current
	      }

	    listptr := listptr._next
	  }

	return aut1
      }

    ENDING: {
	#
	# This case is handled by converting the regular expression and then
	# adding a new start state that transitions to itself on any input
	# and has an epsilon transition to the start state of the converted
	# machine.
	#

	aut1 := convert(tr.children[1])

	newnode1 := alcanode(0)

	newnode1.dot := alcnodelist()
	newnode1.dot.current := newnode1

	newnode1.epsilon := alcnodelist()
	newnode1.epsilon.current := aut1.start

	listptr := aut1.states
	aut1.states := alcnodelist()
	aut1.states.current := newnode1
	aut1.states._next := listptr

	aut1.start := newnode1
	return aut1
      }

    QUESTION: {
	#
	# This adds the start state to the list of accepting states for the
	# machine that is a conversion of the regular expression.
	#

	aut1 := convert(tr.children[1])

	listptr := aut1.accepting
	if /listptr then
	  return aut1

	while \ (listptr._next) do
	  listptr := listptr._next
	
	listptr._next := alcnodelist()
	listptr._next.current := aut1.start

	return aut1
      }

    STAR: {
	#
	# This case converts the regular expression and then adds an epsilon
	# transition from the final states to the start state and makes the
	# start state a final state.
	#

        aut1 := convert(tr.children[1])

        listptr := aut1.accepting

        while \ listptr do {
	    listptr2 := listptr.current.epsilon

	    if /listptr2 then {
		listptr2 := alcnodelist()
		listptr2.current := aut1.start
		listptr.current.epsilon := listptr2
	      }

	    else {
		while \ (listptr2._next) do
		  listptr2 := listptr2._next

		listptr2._next := alcnodelist()
		listptr2._next.current := aut1.start
	      }

	    listptr := listptr._next
	  }

	listptr := aut1.accepting
	aut1.accepting := alcnodelist()
        aut1.accepting.current := aut1.start
	aut1.accepting._next := listptr

        return aut1
      }

    PLUS: {
	#
	# Works similar to the case for star except that it doesn't make the
	# start state a final state.
	#

        aut1 := convert(tr.children[1])

        listptr := aut1.accepting
        if /listptr then
          return aut1

        while \listptr do {
            if / (listptr.current.epsilon) then {
                listptr.current.epsilon := alcnodelist()
                listptr.current.epsilon.current := aut1.start
              }

            else {
                listptr2 := listptr.current.epsilon

                while \ (listptr2._next) do
                  listptr2 := listptr2._next

		listptr2._next := alcnodelist()
                listptr2._next.current := aut1.start
              }

            listptr := listptr._next
          }

        return aut1
      }

    PARENTHETIC:
      return convert(tr.children[2])

    FORSLASH |

    OCCURRENCES: {
	tempstring := tr.text
	tempstring +:= 1
	t1 := *tempstring - 48                # convert from char to int
	tempstring +:= 2

	#
	# First we convert the regular expression that we are generating 
	# multiple occurrences for.
	#

	returnvalue := convert(tr.children[1])

	every i := 1 to t1-1 do {
	    #
	    # This loop will continue until the first number in the number
	    # of occurrences or theonly number as the case may be. It will 
	    # reconvert the regular expression to create a copy of the 
	    # automata and then it will link the previous final states to the
	    # start state of this machine turning off the previous final 
	    # states.
	    #

	    aut1 := convert(tr.children[1])
	    
	    listptr := returnvalue.accepting
	    while \listptr do {
		if / (listptr.current.epsilon) then {
		    listptr.current.epsilon := alcnodelist()
		    listptr.current.epsilon.current := aut1.start
		  }

		else {
		    listptr2 := listptr.current.epsilon

		    while \ (listptr2._next) do
		      listptr2 := listptr2._next

		    listptr2._next := alcnodelist()
		    listptr2._next.current := aut1.start
		  }

		listptr := listptr._next
	      }

	    returnvalue.accepting := aut1.accepting 

	    listptr := returnvalue.states
	    while \ (listptr._next) do
	      listptr := listptr._next

	    listptr._next := aut1.states
	  }

	if \tempstring then {
	    #
	    # If there were two numbers in the set of occurrences then we do 
	    # basically the same as the above up to the second number except
	    # that we do not turn off the final states of the previous machine
	    # during each iteration.
	    #

	    t2 := *tempstring - 48
	    every i := t1 to t2-1 do {
		aut1 := convert(tr.children[1])
		listptr := returnvalue.accepting

		while \listptr do {
		    if / (listptr.current.epsilon) then {
			listptr.current.epsilon := alcnodelist()
			listptr.current.epsilon.current := aut1.start
		      }

		    else {
			listptr2 := listptr.current.epsilon

			while \ (listptr2._next) do
			  listptr2 := listptr2._next

			listptr2._next := alcnodelist()
			listptr2._next.current := aut1.start
		      }

		    listptr := listptr._next
		  }

		listptr := returnvalue.accepting

		while \ (listptr._next) do
		  listptr := listptr._next

		listptr._next := aut1.accepting

		listptr := returnvalue.states
		while \ (listptr._next) do
		  listptr := listptr._next

		listptr._next := aut1.states
	      }
	  }
	return returnvalue
      }
    }
   stop("failing off the end of convert: ", image(tr),
        " label ", image(tr.label), " text ", image(tr.text),
	" kids ",image(tr.children))
end
