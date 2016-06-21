module Models exposing (..)

type alias Model =
  { questions : List Question
  , uid : Int
  }

type alias Question =
  { id : Int
  , questionType : QuestionType
  , title : String
  }

type QuestionType
  = ShortAnswer
  | MultipleChoice

questionTypeToString : QuestionType -> String
questionTypeToString questionType =
  case questionType of
    ShortAnswer -> "ShortAnswer"
    MultipleChoice -> "MultipleChoice"

stringToQuestionType : String -> QuestionType
stringToQuestionType string =
  if string == "ShortAnswer"
  then ShortAnswer
  else MultipleChoice
