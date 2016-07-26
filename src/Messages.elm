module Messages exposing (..)

import Models exposing (..)

type Msg
  = QuestionAdded
  | QuestionRemoved QuestionId
  | QuestionUpdated QuestionId UpdateType
  | QuestionOrderChanged QuestionOrderingInfo
  | FormTitleUpdated String
  | SubQuestionAdded QuestionId

type UpdateType
  = TypeChanged QuestionType
  | TitleUpdated String
  | MultipleChoiceOptionAdded
  | MultipleChoiceOptionRemoved Int
  | MultipleChoiceOptionUpdated Int String

type alias QuestionOrderingInfo =
  { oldQuestionNumber : Int
  , newQuestionNumber : Int
  , id : QuestionId
  }
