module Messages exposing (..)

import Models exposing (..)

type Msg
  = QuestionAdded
  | QuestionRemoved Int
  | QuestionTitleUpdated Int String
  | QuestionTypeChanged Int QuestionType
