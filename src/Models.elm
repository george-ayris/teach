module Models exposing (..)

type alias Model =
  { title : String
  , questions : List Question
  , uid : Int
  }

type alias Question =
  { id : QuestionId
  , questionNumber : Int
  , questionType : QuestionType
  , title : String
  }

type QuestionId
  = Id Int
  | ParentId Int QuestionId

type QuestionType
  = ShortAnswer
  | MediumAnswer
  | LongAnswer
  | TrueFalse
  | MultipleChoice MultipleChoiceInfo
  | SubQuestionContainer (List Question)

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
    TrueFalse -> "TrueFalse"
    MultipleChoice _ -> "MultipleChoice"
    SubQuestionContainer _ -> "SubQuestionContainer"

stringToQuestionType : String -> QuestionType
stringToQuestionType string =
  if string == "ShortAnswer" then ShortAnswer
  else if string == "MediumAnswer" then MediumAnswer
  else if string == "LongAnswer" then LongAnswer
  else if string == "TrueFalse" then TrueFalse
  else if string == "MultipleChoice" then MultipleChoice { options = [], uid = 0 }
  else SubQuestionContainer []
