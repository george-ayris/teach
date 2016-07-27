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
                ({ title = "", questions = [ shortAnswerQuestion ] }, Cmd.none)
                (update QuestionAdded emptyModel)

        , test "QuestionMoved - down one position"
            <| assertEqual
                ({ modelWithThreeQuestions | questions = [ { longAnswerQuestion | questionNumber = 1 }
                                                         , { shortAnswerQuestion | questionNumber = 2 }
                                                         ]}
                , Cmd.none)
                (update (QuestionOrderChanged { oldQuestionId = [1], questionIdToMoveAfter = [2] }) modelWithTwoQuestions)

        , test "QuestionMoved - up two positions"
            <| assertEqual
                ({ modelWithThreeQuestions | questions = [ { multipleChoiceQuestion | questionNumber = 1 }
                                                         , { shortAnswerQuestion | questionNumber = 2 }
                                                         , { longAnswerQuestion | questionNumber = 3 }
                                                         ]}
                , Cmd.none)
                (update (QuestionOrderChanged { oldQuestionId = [3], questionIdToMoveAfter = [0] }) modelWithThreeQuestions)

        , test "QuestionMoved - sub-question down two positions"
            <| assertEqual
                ({ modelWithSubQuestion
                 | questions = [ shortAnswerQuestion
                               , { subQuestionContainer
                                 | questionType = SubQuestionContainer [ { longAnswerQuestion | questionNumber = 1 }
                                                                       , { multipleChoiceQuestion | questionNumber = 2 }
                                                                       , { shortAnswerQuestion | questionNumber = 3 }
                                                                       ]
                                 }
                               , multipleChoiceQuestion ]
                 }
                , Cmd.none)
                (update (QuestionOrderChanged { oldQuestionId = [2,1], questionIdToMoveAfter = [2,3] }) modelWithSubQuestion)
        , test "QuestionMoved - sub-question up one positions"
            <| assertEqual
                ({ modelWithSubQuestion
                 | questions = [ shortAnswerQuestion
                               , { subQuestionContainer
                                 | questionType = SubQuestionContainer [ { shortAnswerQuestion | questionNumber = 1 }
                                                                       , { multipleChoiceQuestion | questionNumber = 2 }
                                                                       , { longAnswerQuestion | questionNumber = 3 }
                                                                       ]
                                 }
                               , multipleChoiceQuestion ]
                 }
                , Cmd.none)
                (update (QuestionOrderChanged { oldQuestionId = [2,3], questionIdToMoveAfter = [2,1] }) modelWithSubQuestion)
        ]

emptyModel : Model
emptyModel = { title = "", questions = [] }

modelWithTwoQuestions : Model
modelWithTwoQuestions = { title = "", questions = [ shortAnswerQuestion, longAnswerQuestion ] }

modelWithThreeQuestions : Model
modelWithThreeQuestions = { title = "", questions = [ shortAnswerQuestion, longAnswerQuestion, multipleChoiceQuestion ] }

modelWithSubQuestion : Model
modelWithSubQuestion = { title = "", questions = [ shortAnswerQuestion, subQuestionContainer, multipleChoiceQuestion ] }

subQuestionContainer : Question
subQuestionContainer = { questionNumber = 2
                       , questionType = SubQuestionContainer [ shortAnswerQuestion, longAnswerQuestion, multipleChoiceQuestion ]
                       , title = "Ask and ask"
                       }

shortAnswerQuestion : Question
shortAnswerQuestion = { questionNumber = 1, questionType = ShortAnswer, title = "" }

longAnswerQuestion : Question
longAnswerQuestion = { questionNumber = 2, questionType = LongAnswer, title = "Write me an essay" }

multipleChoiceQuestion : Question
multipleChoiceQuestion = { questionNumber = 3, questionType = MultipleChoice { options = [], uid = 0 }, title = "Pick me, pick me!" }
