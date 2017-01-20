module Models exposing (..)

import Material


type alias Model =
    { title : String
    , questions : List Question
    , mdl : Material.Model
    }


type alias Question =
    { questionNumber : Int
    , questionType : QuestionType
    , title : String
    , image : Maybe Image
    , isExpanded : Bool
    }


type alias Image =
    { data : String
    , name : String
    }


type alias QuestionId =
    List Int


type QuestionType
    = LongAnswer NumLines
    | TrueFalse
    | MultipleChoice MultipleChoiceInfo
    | FillBlanks MultipleChoiceInfo
    | SubQuestionContainer (List Question)


type TemplateType
    = TrueFalseT
    | CustomMultChoiceT
    | FillBlanksT
    | TextT


type alias MultipleChoiceInfo =
    { options : List Option
    , uid : Int
    }


type alias Option =
    { id : Int
    , value : String
    }


type alias NumLines =
    Int



-- number of lines


questionTypeToString : QuestionType -> String
questionTypeToString questionType =
    case questionType of
        LongAnswer _ ->
            "LongAnswer"

        TrueFalse ->
            "TrueFalse"

        MultipleChoice _ ->
            "MultipleChoice"

        SubQuestionContainer _ ->
            "SubQuestionContainer"

        FillBlanks _ ->
            "FillBlanks"


stringToQuestionType : String -> QuestionType
stringToQuestionType string =
    if string == "LongAnswer" then
        LongAnswer 5
    else if string == "TrueFalse" then
        TrueFalse
    else if string == "FillBlanks" then
        FillBlanks { options = [], uid = 0 }
    else if string == "MultipleChoice" then
        MultipleChoice { options = [], uid = 0 }
    else
        SubQuestionContainer []
