module Messages exposing (..)

import Models exposing (..)

type Msg
  = QuestionAdded
  | QuestionRemoved Int
  | QuestionUpdated Int UpdateType
  | QuestionOrderChanged QuestionOrderingInfo
  | FormTitleUpdated String

type UpdateType
  = TypeChanged QuestionType
  | TitleUpdated String
  | MultipleChoiceOptionAdded
  | MultipleChoiceOptionRemoved Int
  | MultipleChoiceOptionUpdated Int String

type alias QuestionOrderingInfo =
  { oldQuestionNumber : Int
  , newQuestionNumber : Int
  }
