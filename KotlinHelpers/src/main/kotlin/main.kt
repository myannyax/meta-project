import kotlin.math.pow

const val CONS = "CONS"
const val ONE = "_ONE"
const val ONE_2 = "(ATOM \"1\")"
const val ZERO = "_ZERO"
const val ZERO_2 = "(ATOM \"0\")"
const val EMPTY = "_EMPTY"
val CONS_REG = "\\(CONS (\\(ATOM \"0\"\\)|\\(ATOM \"1\"\\)) (.*)\\)".toRegex()


@OptIn(ExperimentalUnsignedTypes::class)
fun UInt.toConsRepresentation(pow: Boolean = false): String {
  if (pow) {
    var result = EMPTY
    for (kek in 1..this.toInt()) {
      result = "($CONS $ONE $result)"
    }
    return result
  }
  val str = Integer.toBinaryString(this.toInt())
  var result = EMPTY
  for (kek in str) {
    result = "($CONS ${if (kek == '0') ZERO else ONE} $result)"
  }
  return result
}

@OptIn(ExperimentalUnsignedTypes::class)
fun String.toIntAsCons(): UInt {
  val result = mutableListOf<Char>()
  var matchResult = CONS_REG.matchEntire(this)?.destructured
  while (matchResult != null) {
    val digit = when (matchResult.component1()) {
      ZERO_2 -> '0'
      ONE_2 -> '1'
      else -> throw Error("Unreachable")
    }
    matchResult = CONS_REG.matchEntire(matchResult.component2())?.destructured
    result.add(digit)
  }
  return result.reversed().joinToString("").toUInt(2)
}

@OptIn(ExperimentalUnsignedTypes::class)
fun main() {
  println("Enter op and operands like this: (+/*/^) number number")
  val line = readLine() ?: return
  val args = line.split(" ")
  assert(args.size == 3)
  val left = args[1].toUInt()
  val right = args[2].toUInt()
  println("Operands in Cons representation:\n${left.toConsRepresentation()}\n${right.toConsRepresentation(args[0] == "^")}")
  println("Enter result:")
  val resultLine = readLine() ?: return
  val result = "($resultLine)".toIntAsCons()
  val trueResult = when (args[0]) {
    "+" -> left + right
    "*" -> left * right
    "^" -> left.toDouble().pow(right.toDouble()).toUInt()
    else -> throw Error()
  }
  println("Your result: $result\nTrue result: $trueResult")
  if (result == trueResult) {
    println("They matched!")
  } else {
    println("There's a mistake!")
  }
}

