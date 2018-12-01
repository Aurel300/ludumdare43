package common;

enum InfInt {
  Num(n:Int);
  Inf;
}

class InfIntTools {
  public static inline function max(a:InfInt, b:InfInt):InfInt return switch [a, b] {
      case [Inf, Inf]: Inf;
      case [Num(a), Inf] | [Inf, Num(a)]: Inf;
      case [Num(a), Num(b)]: Num(a > b ? a : b);
    };
  
  public static inline function min(a:InfInt, b:InfInt):InfInt return switch [a, b] {
      case [Inf, Inf]: Inf;
      case [Num(a), Inf] | [Inf, Num(a)]: Num(a);
      case [Num(a), Num(b)]: Num(a < b ? a : b);
    };
}
