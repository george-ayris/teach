module Models exposing (..)

type alias Model =
  { title : String
  , questions : List Question
  , uid : Int
  }

type alias Question =
  { id : Int
  , questionNumber : Int
  , questionType : QuestionType
  , title : String
  }

type QuestionType
  = ShortAnswer
  | MediumAnswer
  | LongAnswer
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
    MediumAnswer -> "MediumAnswer"
    LongAnswer -> "LongAnswer"
    MultipleChoice _ -> "MultipleChoice"

stringToQuestionType : String -> QuestionType
stringToQuestionType string =
  if string == "ShortAnswer" then ShortAnswer
  else if string == "MediumAnswer" then MediumAnswer
  else if string == "LongAnswer" then LongAnswer
  else MultipleChoice { options = [], uid = 0 }
