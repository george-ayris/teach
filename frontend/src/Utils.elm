module Utils exposing (..)

import Task


createCmd : a -> Cmd a
createCmd msg =
    Task.perform identity (Task.succeed msg)


numberToLetter : Int -> String
numberToLetter num =
    case num of
        1 ->
            "a"

        2 ->
            "b"

        3 ->
            "c"

        4 ->
            "d"

        5 ->
            "e"

        6 ->
            "f"

        _ ->
            "g"


numberToRoman : Int -> String
numberToRoman num =
    case num of
        1 ->
            "i"

        2 ->
            "ii"

        3 ->
            "iii"

        4 ->
            "iv"

        _ ->
            "v"
