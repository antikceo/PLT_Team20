tree grammar ChronosTree;

options {
	language = Java;
	tokenVocab = Chronos;
	ASTLabelType = CommonTree;
}

@header {
  import java.util.Map;
  import java.util.TreeMap;
  import java.lang.reflect.*;
}

@members {
	// TreeMap for storing our variables
 	private Map<String, CVal> varMap = new TreeMap<String, CVal>();
 	private Scheduler sch;

	/* function for evaluating functions!
	private Object evalFunction(String funcName, ArrayList<String> params) {
		
	}*/
	
	private void makeMasterList(String file) {
		out("tryina make the master");
		sch = new Scheduler(file);
	}
	
	private void put(String name, CVal obj) {
		varMap.put(name, obj);
		out("Put " + name + " in the map with value " + obj);
	}
	
	// shortcut for System.out.println
	private void out(Object obj) {
		System.out.println(obj);
	}
	
	// shortcut for System.err.println
	private void err(String str) {
		System.err.println(str);
	}
	
	// shortcut for getting the string of info about an object
	private String info(String str, CVal obj) {
		String s = str + " = " + obj;
		return s;
	}

	// prints Strings
	// gets rid of the surrounding quotes
	private void printString(String str) {
		String noQuotes = str.substring(1,str.length()-1);
		System.out.print(noQuotes);
	}
	
	// shortuct for System.out.print
	private void print(Object obj) {
		System.out.print(obj);
	}
}

program
@init { int num = 0; }
	:	line+ //{ out("This line said " + $line.text);}
	;
line:	declarator //{ out("This declarator said " + $declarator.text);}
	|	instantiator //{ out("This instantiator said " + $instantiator.text);}
	|	stmt
	;
declarator
	:	^(DECL type_specifier ID) {
			if (varMap.containsKey($ID.text)) {
				// if it exists, can't declare again!
				throw new RuntimeException("you've already declared " + $ID.text);
			}
			else {
				if ($type_specifier.text.equals("schedule")) {
					put($ID.text, new CVal(new Schedule($ID.text)));
				}
				else {
					put($ID.text, null);
				}
			}
		}
	;
instantiator
	:	^(INST ^('=' ID expr)) {
			if (varMap.containsKey($ID.text)) {
				// if it exists, can't instantiate (or declare) again!
				throw new RuntimeException("you've already declared " + $ID.text);
			}
			else {
				put($ID.text, $expr.result);
			}
		}
	;
stmt:	expr
	|	^('=' e1=expr e2=expr) {
			// if e1 has a dot function:		
			if ($e1.result instanceof CVal) {
				CVal val1 = $e1.result; // e1.result is a CVal already
				CVal val2 = $e2.result;
				// *****check if typenames of e1 and e2 are the same?
				if (varMap.containsKey($e1.text)) { // look for it in varMap
					put($e1.text, $e2.result); // put in its value
				}
			}
			else {
				throw new RuntimeException("illegal expression: not declared");
			}
		}
	|	selection_stmt
	|	iteration_stmt { out($iteration_stmt.text); }
	|	jump_stmt
	;
selection_stmt // TO DO! LEARN ABOUT SCOPE?
	:	^(COND ^(IF_T expr a=line*) ^(ELSE_T b=line*)) {
			/*if ($expr.text) {$a.text*} else {$b.text*};*/
		}
	;
iteration_stmt returns [String result] // only works on Courses
@init {
}
/*@after {
	len++;
	ArrayList<Course> ourList = varMap.get($list.text);
	if (len < ourList.size()) {
		input.Rewind(mark);
	}
}*/
	:	^(FOREACH_T ^(IN_T element=ID list=ID) ^(BLOCK lines=line*)) {
			$result = "for ( Course " + $element.text + " : " + $list +
			" ) {\n" + lines + "}";
		}
	;
jump_stmt // TO DO!
	:	BREAK_T //{ break; } // this is my break
	;
expr returns [CVal result]
	// goes to assignment_expr rule
	//	assignment_expr
	// logical; returns 1 or 0
	:	^(OR e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			/* if e1 and e2 are boolean expressions, 
			then this operation is legal */
			if (val1.isBool() && val2.isBool()) {
				$result = (val1.getBool() || val2.getBool())? new CVal(new Integer(1))
															: new CVal(new Integer(0));
			}
			else {
				throw new RuntimeException("Cannot perform OR operation on non-boolean expressions");
			}
		}
	|	^(AND e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if (val1.isBool() && val2.isBool()) {
				$result = (val1.getBool() && val2.getBool())? new CVal(new Integer(1))
															: new CVal(new Integer(0));
			}
			else {
				throw new RuntimeException("Cannot perform AND operation on non-boolean expressions");
			}
		}
	|	^(NOT e=expr) {
			CVal val = $e.result;
			if (val.isBool()) {
				$result = (!val.getBool())? new CVal(new Integer(1))
										  : new CVal(new Integer(0));
			}
			else {
				throw new RuntimeException("Cannot perform NOT operation on non-boolean expressions");
			}
		}
	// relative; returns 1 or 0
	|	^(EQ e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if ( val1.compareTo(val2) == 0 )
				$result = new CVal(new Integer(1));
			else $result = new CVal(new Integer(0));
		}
	|	^(NEQ e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
		if ( val1.compareTo(val2) == 0 )
				$result = new CVal(new Integer(1));
			else $result = new CVal(new Integer(0));
		}
	|	^(GEQ e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
		if ( val1.compareTo(val2) == 0 || val1.compareTo(val2) == 1 )
				$result = new CVal(new Integer(1));
			else $result = new CVal(new Integer(0));
		}
	|	^(LEQ e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if ( val1.compareTo(val2) == 0 || val1.compareTo(val2) == -1 )
				$result = new CVal(new Integer(1));
			else $result = new CVal(new Integer(0));
		}
	|	^('<' e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if ( val1.compareTo(val2) < 0 )
				$result = new CVal(new Integer(1));
			else $result = new CVal(new Integer(0));
		}
	|	^('>' e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if ( val1.compareTo(val2) > 0 )
				$result = new CVal(new Integer(1));
			else $result = new CVal(new Integer(0));
		}
	// math; returns int or double
	// for '+' concatenation, also returns String
	|	^('+' e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			out( "ADDING: " + info($e1.text, val1) + " ; " + info($e2.text, val2) );
			if (val1.isInt() && val2.isInt()) {
				Integer temp = val1.asInt() + val2.asInt();
				$result = new CVal(temp);
			}
			if (val1.isDouble() && val2.isDouble()) {
				Double temp = val1.asDouble() + val2.asDouble();
				$result = new CVal(temp);
			}
			if (val1.isString() && val2.isString()) {
				String temp = val1.asString() + val2.asString();
				$result = new CVal(temp);
			}
			// convert other object to string if one term is already a string
			if (val1.isString()) {
				String temp = val1.asString() + val2.toString();
				$result = new CVal(temp);
			}
			if (val2.isString()) {
				String temp = val1.toString() + val2.asString();
				$result = new CVal(temp);
			}
		}
	|	^('-' e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if (val1.isInt() && val2.isInt()) {
				Integer temp = val1.asInt() - val2.asInt();
				$result = new CVal(temp);
			}
			if (val1.isDouble() && val2.isDouble()) {
				Double temp = val1.asDouble() - val2.asDouble();
				$result = new CVal(temp);
			}
		}
	|	^('*' e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if (val1.isInt() && val2.isInt()) {
				Integer temp = val1.asInt() * val2.asInt();
				$result = new CVal(temp);
			}
			if (val1.isDouble() && val2.isDouble()) {
				Double temp = val1.asDouble() * val2.asDouble();
				$result = new CVal(temp);
			}
		}
	|	^('/' e1=expr e2=expr) {
			CVal val1 = $e1.result;
			CVal val2 = $e2.result;
			if (val1.isInt() && val2.isInt()) {
				Integer temp = val1.asInt() / val2.asInt();
				$result = new CVal(temp);
			}
			if (val1.isDouble() && val2.isDouble()) {
				Double temp = val1.asDouble() / val2.asDouble();
				$result = new CVal(temp);
			}
		}
	
	// dot operator - car.color
	|	^('.' e1=expr e2=expr) {
			// CHECK e1 (LEFT of dot)
			// Is e1 a CVal?
			CVal left = null; // left is the CVal equivalent of e1,
			if ($e1.result instanceof CVal) {
				out("ITS AN INSTANCE OF CVAL");
				left = $e1.result;
			}
			// or a function call? NEVER HAPPENS!
			// or an ID?
			else if ( varMap.containsKey($e1.text) ) {
				out("DEARIES< WE FOUND IT");
				left = varMap.get($e1.text);
			}
			
			// CHECK e2 (RIGHT of dot)
			// Is e2 a function?
			if ($e2.result.isFunction()) {
				out("I SEE A FUNCTION ON THE RIGHT SIDE FO THE DOT");
				out("It looks like this: " + $e2.text);
				// get methods of left
				Function rightf = $e2.result.asFunction();
				//out("FUNCITON IS: " + rightf);
				try {
					// Get typename of left
					Class cls = Class.forName(left.typename());
					out("THE TYPE ISWSSSS " + cls);
					Method[] rightfMethods = cls.getMethods();
					for (Method m : rightfMethods) {
						if (m.getName().equals(rightf.name)) {
							m.invoke(left, rightf.params);
						}
					}
				} catch (Exception excep) { excep.printStackTrace(); }
				// evalFunction()
			}
			// If not, then e2 must be a field
			else {
				// get fields of left
			}
		}
	
	// derived types
	|	datetime { $result = new CVal($datetime.result); }
	|	timeblock { $result = new CVal($timeblock.result); }
	|	dayblock { $result = new CVal($dayblock.result); }
	|	function {
			Function func = $function.result;
			if (func.name.equals("print")) {
				for (int i=0; i<func.params.size(); i++) {
					CVal c = func.params.get(i);
					if (c.isString()) {
						printString(c.asString());
					}
					else print(c);
					if (i==func.params.size()-1) {
						out("");
					} else {
						print(" ");
					}
				}
			}
			if (func.name.contains("generateCourses")) {
				// call read to input file
				try {
					CVal filename = func.params.get(0);
					makeMasterList(filename.asString());
				} catch (NullPointerException exception) {
					throw new RuntimeException("No filename specified!");
				}
			}
			$result = new CVal(func);
		}
		
	// primary types
	|	INT { $result = new CVal( Integer.parseInt($INT.text) ); }
	|	DOUBLE { $result = new CVal( Double.parseDouble($DOUBLE.text) ); }
	|	ID { $result = varMap.get($ID.text); }
	|	STRING { $result = new CVal( $STRING.text ); }
	|	TIME { $result = new CVal( new Time($TIME.text) ); }
	;
function returns [Function result]
// i.e. print()
	:	/*^(PRINT_T print_target*) { out("printttt"); }
	|*/	^(ID ^(PARAMS argument_expr_list?)) {
			$result = new Function($ID.text, $argument_expr_list.result);
		}
	;
/*print_target
	:	INT { out($INT); }
	|	DOUBLE { out($DOUBLE); }
	|	STRING { out($STRING); }
	|	ID { if (varMap.containsKey($ID.text)) { out("Found it!");out( (varMap.get($ID.text)).value() );} }
	|	function { out($function.result); }
	;*/
datetime returns [Datetime result]
// i.e. [M,W] 10:00~11:00
	:	^(DATETIME dayblock timeblock) {
		$result = new Datetime($dayblock.result, $timeblock.result);
		}
	;
timeblock returns [Timeblock result]
// i.e. 13:00~14:00
	:	^(TIMES a=TIME b=TIME) {
			$result = new Timeblock(new Time($a.text), new Time($b.text));
		}
	;
dayblock returns [Dayblock result]
// i.e. [M,W,F]
@init { $result = new Dayblock(); }
	:	^( DAYBLOCK_T (DAY {
			char daychar = ($DAY.text).charAt(0);
			try{$result.add(daychar);}
			catch (Exception e1) {out("Can't add this day");}
		})+ )
	;
argument_expr_list returns [ArrayList<CVal> result]
@init { $result = new ArrayList<CVal>(); }
	:	(expr {$result.add($expr.result);})+
	;
type_specifier
	:	INT_T
	|	DOUBLE_T
	|	DAYBLOCK_T
	|	TIME_T
	|	STRING_T
	|	SCHEDULE_T
	|	COURSE_T
	|	COURSELIST_T
	|	TIMEBLOCK_T
	|	DATETIME_T
	;
