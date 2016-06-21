module Messages exposing (..)

import Models exposing (..)

type Msg
  = QuestionAdded
  | QuestionRemoved Int
  | QuestionUpdated Int UpdateType

type UpdateType
  = TypeChanged QuestionType
  | TitleUpdated String
  | MultipleChoiceOptionAdded
  | MultipleChoiceOptionRemoved Int
  | MultipleChoiceOptionUpdated Int String
