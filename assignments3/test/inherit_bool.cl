(* cool-manual section 8.5: it is an error to inherit from Bool *)
class B inherits Bool {
};

Class Main {
	main():B {
          new B
	};
};