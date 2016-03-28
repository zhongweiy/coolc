class B {
a : Int <- 4;
a : Int;

foo (x : Int) : Int {
     {
      x <- 3;
      y <- 1;
      4;
      (* dynamic dispatch *)
      bar(3);
      3.foo(1);
      (* static dispatch *)
      10@Int.foo();

      if 3
        then 4
        else 5
      fi;

      while 3 loop 3 pool;

      (* let expression *)
      let x : Int <- 3 in 3;
      let x : Int in 3;
      let x : Int <- 3, y : Int <- 4 in 5;
      let x : Int <- 3, y : Int in 5;
      let x : Int, y : Int <- 4 in 5;
      ( * why following syntax not work? * )
      ( * , y : Int <- 4 in 5; *)

      (* case expression *)
      case 3 of x : Int => 3; esac;
      
      case 3 of
           x : Int => 3;
           y : Int => 4;
      esac;

      new Int;
      isvoid 3;

      }

};
};