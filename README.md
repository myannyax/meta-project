# *meta-project*
Реализация сложения, умножения и возведения в степень на TSG
Для упрощения реализации код на TSG работает с бинарными числами в определенной форме, 
чтобы перевести нормальные числа из десятичной системы счисления в нее следует использовать 
Котлин код который находится в `KotlinHelpers/src/main/kotlin/main.kt`. 
С помощью нее можно получить нужную форму операндов и проверить ответ от интерпретатора.

## Как запускать:
```
ghci Arithm.hs Int.hs
Int.int prog [_ADD, x, y]
```
где `x, y` - операнды в форме, которую выдал котлин скрипт

`_ADD, _POW, _MULT` - операторы

## Проверка алгоритмом ura:
### Вычитание через сложение
```
*Arithm> str = (CONS _ZERO (CONS _ZERO (CONS _ONE _EMPTY)))
*Arithm> kek2 = (CONS _ZERO (CONS _ZERO (CONS _ONE (CONS _ONE _EMPTY))))
*Arithm> x = ([_ADD, str, (CVE 1)], RESTR [])
*Arithm> Int.ura prog x kek2
[([CVE 1 :-> CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "0") (CONS (CVE 11) (ATOM "Empty"))))],RESTR [CVE 11 :=/=: ATOM "0"])
```
Алгоритм очевидно не завершился, но если учесть что str = 4, kek2 = 12 и мы получили в результате класс который соответствует 8, то вычитание мы получили!
### Деление через умножение
```
*Arithm> str = (CONS _ZERO (CONS _ZERO (CONS _ONE _EMPTY)))
*Arithm> kek2 = CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "1") (CONS (ATOM "1") (ATOM "Empty"))))
*Arithm> x = ([_MULT, str, (CVE 1)], RESTR [])
*Arithm> Int.ura prog x kek2

с^CInterrupted.
*Arithm> x = ([_MULT, (CVE 1), str], RESTR [])
*Arithm> Int.ura prog x kek2
[([CVE 1 :-> CONS (CVE 2) (CONS (CVE 5) (ATOM "Empty"))],RESTR [CVE 2 :=/=: ATOM "0",CVE 5 :=/=: ATOM "0"])
```
Алгоритм снова очевидно не завершился.
Тут у меня str = 4, kek2 = 12 и в ответе 3, значит деление тоже работает! Правда даже на таких небольших числах алгоритм выдал этот класс уже за несколько минут.

### Log (ну почти) через возведение в степень
```
*Arithm> Int.int prog [_POW, (CONS _ZERO (CONS _ONE _EMPTY)), (CONS _ONE (CONS _ONE (CONS _ONE (CONS _ONE _EMPTY))))]
CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "1") (ATOM "Empty")))))
*Arithm> kek2 = CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "0") (CONS (ATOM "1") (ATOM "Empty")))))
*Arithm> str = (CONS _ZERO (CONS _ONE _EMPTY))
*Arithm> x = ([_POW, str, (CVE 1)], RESTR [])
*Arithm> Int.ura prog x kek2
[([CVE 1 :-> CONS (ATOM "1") (CONS (ATOM "1") (CONS (ATOM "1") (CONS (ATOM "1") (ATOM "Empty"))))],RESTR [])
```
тут интепретатором посчитан ответ для 2^4 потом он использован чтобы найти степень 2 которая равна ему


