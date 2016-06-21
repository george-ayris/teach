module Models exposing (..)

type alias Model =
  { questions : List Question
  , uid : Int
  }

type alias Question =
  { id : Int
  , type' : QuestionType
  , title : String
  }

type QuestionType
  = ShortAnswer
