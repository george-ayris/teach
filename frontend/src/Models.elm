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

type alias QuestionId = List Int

type QuestionType
  = ShortAnswer
  | MediumAnswer
  | LongAnswer
  | TrueFalse
  | MultipleChoice MultipleChoiceInfo
  | FillBlanks MultipleChoiceInfo
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
    FillBlanks _ -> "FillBlanks"

stringToQuestionType : String -> QuestionType
stringToQuestionType string =
  if string == "ShortAnswer" then ShortAnswer
  else if string == "MediumAnswer" then MediumAnswer
  else if string == "LongAnswer" then LongAnswer
  else if string == "TrueFalse" then TrueFalse
      else if string == "FillBlanks" then FillBlanks { options = [], uid = 0 }
  else if string == "MultipleChoice" then MultipleChoice { options = [], uid = 0 }
  else SubQuestionContainer []
