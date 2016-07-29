module Messages exposing (..)

import Models exposing (..)

type Msg
  = QuestionAdded
  | QuestionRemoved QuestionId
  | QuestionUpdated QuestionId UpdateType
  | QuestionOrderChanged QuestionOrderingInfo
  | FormTitleUpdated String
  | SubQuestionAdded QuestionId
  | RenderPdf

type UpdateType
  = TypeChanged QuestionType
  | TitleUpdated String
  | MultipleChoiceOptionAdded
  | MultipleChoiceOptionRemoved Int
  | MultipleChoiceOptionUpdated Int String

type alias QuestionOrderingInfo =
  { oldQuestionId : QuestionId
  , questionIdToMoveAfter : QuestionId
  }