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
  | MultipleChoice MultipleChoiceInfo

type alias MultipleChoiceInfo =
  { options : List Option
  , uid : Int
  }

type alias Option =
  { id : Int
  , value : String
  }

questionTypeToString : QuestionType -> String
questionTypeToString questionType =
  case questionType of
    ShortAnswer -> "ShortAnswer"
    MultipleChoice _ -> "MultipleChoice"

stringToQuestionType : String -> QuestionType
stringToQuestionType string =
  if string == "ShortAnswer"
  then ShortAnswer
  else MultipleChoice { options = [], uid = 0 }
