/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
        if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
                YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;
int excess_string_size(void);
int excess_string_size(void) {
        size_t strsize = (string_buf_ptr - string_buf) / sizeof(char);
        /* printf("strsize: %d\n", strsize); */
        return strsize >= MAX_STR_CONST;
        }
int add_char_to_string_buf(char c);
/* TODO add_char_to_string_buf does not work. sometimes, we need no return. */
int add_char_to_string_buf(char c) {
     if (!excess_string_size()) {
        *string_buf_ptr++ = c;
        return 0;
     } else {
        cool_yylval.error_msg = "String constant too long";
        return ERROR;
     }
     }


extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>

%x COMMENTS1 COMMENTS2 STRING
%option stack

%%


 /*
  *  Nested comments
  */
\(\*    {
         yy_push_state(INITIAL); /* handle nested comments. */
         BEGIN(COMMENTS1);
         }
<COMMENTS1>\\. {}
<COMMENTS1><<EOF>> {
                   BEGIN(INITIAL);
                   cool_yylval.error_msg = "EOF in comment";
                   return ERROR;
                   }
<COMMENTS1>\(\* {
                yy_push_state(COMMENTS1);
                BEGIN(COMMENTS1);
                }
<COMMENTS1>\*\) {
                yy_pop_state();
                }
<COMMENTS1>. {}

--      BEGIN(COMMENTS2);
<COMMENTS2>\n {
                      BEGIN(INITIAL);
                      curr_lineno++;
              }
<COMMENTS2><<EOF>> BEGIN(INITIAL);
<COMMENTS2>. {}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }

\<\- return ASSIGN;
\<\= return LE;

 /* single character */
[@.{}:;()+\-*/~<=,] return *yytext;

 /* white space */
[ \f\r\t\v] {}

<COMMENTS1,INITIAL>\n curr_lineno++;

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
t(?i:rue) {
     cool_yylval.boolean = true;
     return BOOL_CONST;
     }

f(?i:alse) {
     cool_yylval.boolean = false;
     return BOOL_CONST;
     }

(?i:class) return CLASS;
(?i:else) return ELSE;
(?i:if) return IF;
(?i:fi) return FI;
(?i:in) return IN;
(?i:inherits) return INHERITS;
(?i:let) return LET;
(?i:loop) return LOOP;
(?i:pool) return POOL;
(?i:then) return THEN;
(?i:while) return WHILE;
(?i:case) return CASE;
(?i:esac) return ESAC;
(?i:of) return OF;
(?i:new) return NEW;
(?i:isvoid) return ISVOID;
(?i:not) return NOT;

[0-9]+ {
         cool_yylval.symbol = inttable.add_string(yytext);
         return INT_CONST;
         }
[A-Z][a-zA-Z0-9_]* {
         cool_yylval.symbol = idtable.add_string(yytext);
         return TYPEID;
         }
[a-z][a-zA-Z0-9_]* {
         cool_yylval.symbol = idtable.add_string(yytext);
         return OBJECTID;
         }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for
  *  \n \t \b \f, the result is c.
  *
  */

\" {
   string_buf_ptr = string_buf;
   BEGIN(STRING);
   }

<STRING>\" {
           BEGIN(INITIAL);
           if (!excess_string_size()) {
               *string_buf_ptr = '\0';
               cool_yylval.symbol = stringtable.add_string(string_buf);
               return STR_CONST;
           } else {
               cool_yylval.error_msg = "String constant too long";
               return ERROR;
           }
           }

<STRING>\0 {
           BEGIN(INITIAL);
           cool_yylval.error_msg = "String contains null character";
           return ERROR;
           }
           
<STRING>{
        "\\n"   { int rc = add_char_to_string_buf('\n');
                  if (rc) return rc;
                  }
        "\\t"   { int rc = add_char_to_string_buf('\t');
                  if (rc) return rc;
                  }
        "\\f"   add_char_to_string_buf('\f');
        "\\b"   add_char_to_string_buf('\b');
        }

<STRING>\\\n {
             curr_lineno++;
             int rc = add_char_to_string_buf('\n');
             if (rc) return rc;
             }

<STRING><<EOF>> {
                BEGIN(INITIAL);
                cool_yylval.error_msg = "EOF in string constant";
                return ERROR;
                }

<STRING>\\. {
              int rc = add_char_to_string_buf(yytext[1]);
              if (rc) return rc;
            }

<STRING>[^\\\n\"]+ {
                   char *yptr = yytext;
                   while (*yptr) {
                         /* TODO checking still not work. */
                         int rc = add_char_to_string_buf(*yptr++);
                         if (rc) return rc;
                   }
                   }

<STRING>\n {
           cool_yylval.error_msg = "Unterminated string constant";
           curr_lineno++;
           BEGIN(INITIAL);
           return ERROR;
           }
           
  /* illegal character.
   * TODO \001\002\003\004 is hard coded here. Any other invisible character?
   */
[!#$%^&?`|_>\\'\[\]\001\002\003\004] {
         cool_yylval.error_msg = yytext;
         return ERROR;
         }

\*\) {
     cool_yylval.error_msg = "Unmatched *)";
     return ERROR;
     }

%%
