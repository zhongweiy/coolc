(* cool-manual section 8.3: it is an error to inherit from Int *)
class B inherits Int {
};

Class Main {
	main():B {
          new B
	};
};