module Arithm where

import Int


_ONE = ATOM "1"
_ZERO = ATOM "0"
_ADD = ATOM "A"
_MULT = ATOM "M"
_POW = ATOM "P"
_EMPTY = ATOM "Empty"

-- x, y - in reversed binary representation with _EMPTY at the end
-- example: CONS _ZERO (CONS _ONE (CONS _ONE _EMPTY)) for 6 or (6 -> 110 -> 011[])
-- example2: (CONS _ZERO (CONS _ONE (CONS _ZERO (CONS _ONE (CONS _ZERO (CONS _ZERO (CONS _ZERO (CONS _ONE (CONS _ZERO (CONS _ONE (CONS _ONE _EMPTY))))))))))) for 1674
prog :: Prog
prog = [
          (DEFINE "Main" [_OP, _X, _Y]
            (ALT (EQA' _OP _ADD)
              (CALL "AdditionRoot" [(CONS _X (CONS _Y _EMPTY)), _EMPTY, _EMPTY])
              (ALT (EQA' _OP _MULT)
                -- for Multiplication the second argument can't be empty at the beginning
                (CALL "Multiplication" [(CONS _X _EMPTY), _Y])
                (ALT (EQA' _OP _POW)
                  -- for pow the second argument should be cons with n ones for the result to be x^n
                  (CALL "Pow" [_X, _Y])
                  (RETURN _INVALID_OP)
                )
              )
            )
          ),
          (DEFINE "AdditionRoot" [_LST_OP, _RES, _MULT_LST_OP]
            (ALT (CONS' _LST_OP _X_HEAD _X_TAIL _X_HEAD)
              (CALL "Addition" [_X_HEAD, _RES, _ZERO, _EMPTY, _X_TAIL, _MULT_LST_OP])
              (ALT (EQA' _X_HEAD _EMPTY)
                (ALT (CONS' _MULT_LST_OP _Y_HEAD _Y_TAIL _Y_HEAD)
                  (CALL "Multiplication" [_MULT_LST_OP, _RES])
                  (RETURN _RES)
                )
                (RETURN _FAILURE)
              )
            )
          ),
          (DEFINE "AdditionRootReverseHelper" [_LST_OP, _RES, _REM, _MULT_LST_OP]
            (ALT (CONS' _RES _X_HEAD _X_TAIL _X_HEAD)
              (CALL "AdditionRootReverseHelper" [_LST_OP, _X_TAIL, (CONS _X_HEAD _REM), _MULT_LST_OP])
              (ALT (EQA' _X_HEAD _EMPTY)
                (CALL "AdditionRoot" [_LST_OP, _REM, _MULT_LST_OP])
                (RETURN _FAILURE)
              )
            )
          ),
          (DEFINE "Addition" [_X, _Y, _REM, _RES, _LST_OP, _MULT_LST_OP]
            (ALT (CONS' _X _X_HEAD _X_TAIL _X_HEAD)
              (ALT (CONS' _Y _Y_HEAD _Y_TAIL _Y_HEAD)
                (CALL "AdditionH" [_X_HEAD, _Y_HEAD, _X_TAIL, _Y_TAIL, _REM, _RES, _LST_OP, _MULT_LST_OP])
                (ALT (EQA' _Y_HEAD _EMPTY)
                  (CALL "AdditionH" [_X_HEAD, _ZERO, _X_TAIL, _EMPTY, _REM, _RES, _LST_OP, _MULT_LST_OP])
                  (RETURN _FAILURE)
                )
              )
              (ALT (EQA' _X_HEAD _EMPTY)
                (ALT (CONS' _Y _Y_HEAD _Y_TAIL _Y_HEAD)
                  (CALL "AdditionH" [_ZERO, _Y_HEAD, _EMPTY, _Y_TAIL, _REM, _RES, _LST_OP, _MULT_LST_OP])
                  (ALT (EQA' _Y_HEAD _EMPTY)
                    (ALT (EQA' _REM _ONE)
                      (CALL "AdditionRootReverseHelper" [_LST_OP, (CONS _REM _RES), _EMPTY, _MULT_LST_OP])
                      (CALL "AdditionRootReverseHelper" [_LST_OP, _RES, _EMPTY, _MULT_LST_OP])
                    )
                    (RETURN _FAILURE)
                  )
                )
                (RETURN _FAILURE2)
              )
            )
          ),
          (DEFINE "Multiplication" [_MULT_LST_OP, _RES]
            (ALT (CONS' _MULT_LST_OP _X_HEAD _X_TAIL _X_HEAD)
              (CALL "MultiplicationKek" [_X_HEAD, _RES, _EMPTY, _X_TAIL])
              (ALT (EQA' _X_HEAD _EMPTY)
                (RETURN _RES)
                (RETURN _FAILURE)
              )
            )
          ),
          (DEFINE "Pow" [_X, _Y]
            (CALL "PowKek" [_X, _Y, _EMPTY])
          ),
          -- add _X_DIGIT to _Y_DIGIT and return reminder as _REM, res as _RES (it contains previous results, the current one us in the head),
          -- _X, _Y, _LST_OP are state helpers for recursion
          (DEFINE "AdditionH" [_X_DIGIT, _Y_DIGIT, _X, _Y, _REM, _RES, _LST_OP, _MULT_LST_OP]
            (ALT (EQA' _X_DIGIT _ZERO)
              (ALT (EQA' _Y_DIGIT _ONE)
                (ALT (EQA' _REM _ZERO)
                  (CALL "Addition" [_X, _Y, _ZERO, (CONS _ONE _RES), _LST_OP, _MULT_LST_OP]) -- 0 + 1 + 0
                  (CALL "Addition" [_X, _Y, _ONE, (CONS _ZERO _RES), _LST_OP, _MULT_LST_OP]) -- 0 + 1 + 1
                )
                (ALT (EQA' _REM _ZERO)
                  (CALL "Addition" [_X, _Y, _ZERO, (CONS _ZERO _RES), _LST_OP, _MULT_LST_OP]) -- 0 + 0 + 0
                  (CALL "Addition" [_X, _Y, _ZERO, (CONS _ONE _RES), _LST_OP, _MULT_LST_OP]) -- 0 + 0 + 1
                )
              )
              (ALT (EQA' _Y_DIGIT _ONE)
                (ALT (EQA' _REM _ZERO)
                  (CALL "Addition" [_X, _Y, _ONE, (CONS _ZERO _RES), _LST_OP, _MULT_LST_OP]) -- 1 + 1 + 0
                  (CALL "Addition" [_X, _Y, _ONE, (CONS _ONE _RES), _LST_OP, _MULT_LST_OP]) -- 1 + 1 + 1
                )
                (ALT (EQA' _REM _ZERO)
                  (CALL "Addition" [_X, _Y, _ZERO, (CONS _ONE _RES), _LST_OP, _MULT_LST_OP]) -- 1 + 0 + 0
                  (CALL "Addition" [_X, _Y, _ONE, (CONS _ZERO _RES), _LST_OP, _MULT_LST_OP]) -- 1 + 0 + 1
                )
              )
            )
          ),
          -- _RES for results from multiplication by 0 or 1 to be summurized later
          (DEFINE "MultiplicationKek" [_X, _Y, _RES, _MULT_LST_OP]
            (ALT (CONS' _Y _Y_HEAD _Y_TAIL _Y_HEAD)
              (CALL "MultiplicationH" [_Y_HEAD, _X, _Y_TAIL, _RES, _MULT_LST_OP])
              (ALT (EQA' _Y_HEAD _EMPTY)
                (CALL "AdditionRoot" [_RES, _EMPTY, _MULT_LST_OP])
                (RETURN _FAILURE)
              )
            )
          ),
          (DEFINE "PowKek" [_X, _Y, _RES]
            (ALT (CONS' _Y _Y_HEAD _Y_TAIL _Y_HEAD)
              (ALT (EQA' _Y_HEAD _ONE)
                (CALL "PowKek" [_X, _Y_TAIL, (CONS _X _RES)])
                (RETURN _FAILURE)
              )
              (ALT (EQA' _Y_HEAD _EMPTY)
                (ALT (CONS' _RES _X_HEAD _X_TAIL _X_HEAD)
                  (CALL "Multiplication" [_X_TAIL, _X_HEAD])
                  (RETURN _ONE)
                )
                (RETURN _FAILURE)
              )
            )
          ),
          (DEFINE "MultiplicationH" [_Y_DIGIT, _X, _Y, _RES, _MULT_LST_OP]
            (ALT (EQA' _Y_DIGIT _ZERO)
              -- return zero if x * 0
              (CALL "MultiplicationKek" [(CONS _ZERO _X), _Y, (CONS (CONS _ZERO _EMPTY) _RES), _MULT_LST_OP])
              -- shift x if x * 1
              (CALL "MultiplicationKek" [(CONS _ZERO _X), _Y, (CONS _X _RES), _MULT_LST_OP])
            )
          )
      ]  where
            _X = PVE "x"
            _Y = PVE "y"
            _X_HEAD = PVA "xHead"
            _X_TAIL = PVE "xTail"
            _Y_HEAD = PVA "yHead"
            _Y_TAIL = PVE "yTail"
            _OP = PVA "op"
            _X_DIGIT = PVA "xDigit"
            _Y_DIGIT = PVE "yDigit"
            _REM = PVA "rem"
            _RES = PVE "result"
            _MULT_RES = ATOM "MultRes"
            _L_RES = PVA "Lresult"
            _ONE = ATOM "1"
            _ZERO = ATOM "0"
            _LST_OP = PVE "lstOp"
            _MULT_LST_OP = PVE "MultLstOp"
            _INVALID_OP = ATOM "InvalidOp"
            _FAILURE = ATOM "InvalidArgument"
            _FAILURE2 = ATOM "InvalidArgumentKek"


-- examples:
b1674 = (CONS _ZERO (CONS _ONE (CONS _ZERO (CONS _ONE (CONS _ZERO (CONS _ZERO (CONS _ZERO (CONS _ONE (CONS _ZERO (CONS _ONE (CONS _ONE _EMPTY)))))))))))
b374 = (CONS _ZERO (CONS _ONE (CONS _ONE (CONS _ZERO (CONS _ONE (CONS _ONE (CONS _ONE (CONS _ZERO (CONS _ONE _EMPTY)))))))))
b2 = (CONS _ZERO (CONS _ONE _EMPTY))
b4forPow = CONS _ONE (CONS _ONE (CONS _ONE (CONS _ONE _EMPTY)))
