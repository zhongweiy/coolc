#ifndef SEMANT_H_
#define SEMANT_H_

#include <assert.h>
#include <iostream>
#include <string>
#include "cool-tree.h"
#include "stringtab.h"
#include "symtab.h"
#include "list.h"

#define TRUE 1
#define FALSE 0

class ClassTable;
typedef ClassTable *ClassTableP;

// This is a structure that may be used to contain the semantic
// information such as the inheritance graph.  You may use it or not as
// you like: it is only here to provide a container for the supplied
// methods.

class ClassTable {
private:
  int semant_errors;
  SymbolTable<Symbol, Class__class> *install_basic_classes();
  ostream& error_stream;

  bool inheritance_is_acyclic(SymbolTable<Symbol, Class__class>*, Classes);
  void addto_class_graph(SymbolTable<Symbol, Class__class> *, Classes);
  bool check_parents_is_defined(SymbolTable<Symbol, Class__class> *, Classes);
  bool inherit_from_restricted_baseclass(Classes);

public:
  ClassTable(Classes);
  int errors() { return semant_errors; }
  ostream& semant_error();
  ostream& semant_error(Class_ c);
  ostream& semant_error(Symbol filename, tree_node *t);
  ostream& semant_error(Class_ c, const std::string& msg);
};


#endif

