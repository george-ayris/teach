module UpdateTest exposing (..)

import ElmTest exposing (..)
import Update exposing (update)
import Models exposing (..)
import Messages exposing (..)

tests : Test
tests =
    suite "Update tests"
        [ test "QuestionAdded"
            <| assertEqual
                (update QuestionAdded { title = "", questions = [] })
                ({ title = "", questions = [{ questionNumber = 1, questionType = ShortAnswer, title = "" }] }, Cmd.none)
        ]
