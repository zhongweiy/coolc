%{
 /* declaration */
#define LANGLE 1 // '<'
#define LANGLESLASH 2 // '</'
#define RANGLE 3 // '>'
#define SLASHANGLE 4 // '/>'
#define EQUAL 5 // '='
#define STRING 6 // "1ab"
#define WORD 7 // "hello" in "hello my html"
#define JAVASCRIPT // embeded Javascript fragment
char *word;

%}
 /* definitions */


%%
 /* rules */
\<\/ {
   return LANGLESLASH;
   }
\< {
   return LANGLE;
  }
\> {
  return RANGLE;
  }

\/\> {
   return SLASHANGLE;
   }

= {
   return EQUAL;
   }

[^ \t\v\r\n<>=]+ {
   word = yytext;
   return WORD;
   }

 /* whitespace */
[\n ] {}

. {
  printf("Unrecognized character: %s\n", yytext);
  }

%%
/* user code */

const char *token2string(int token) {
     switch(token) {
     case LANGLE: return "LANGLE"; break;
     case LANGLESLASH: return "LANGLESLASH"; break;
     case RANGLE: return "RANGLE"; break;
     case SLASHANGLE: return "SLASHANGLE"; break;
     case EQUAL: return "EQUAL"; break;
     default: return "UNKNOWN token";
     }
}

int main(int argc, char **argv)
{
   ++argv, --argc; /* skip program name */
   if (argc > 0)
      yyin = fopen(argv[0], "r");
   else
      yyin = stdin;

   int type = yylex();
   while (type) {
         if (type == WORD) {
            printf(":WORD %s ", word);
         } else {
            printf(":%s ", token2string(type));
         }
         type = yylex();
   }
   printf("\tEOF\n");
}
