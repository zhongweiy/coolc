(* cool-manual section 8.4: it is an error to inherit from String *)
class B inherits String {
};

Class Main {
	main():B {
          new B
	};
};