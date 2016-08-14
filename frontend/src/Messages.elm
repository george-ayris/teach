module Messages exposing (..)

import Models exposing (..)
import Material

type Msg
  = QuestionAdded
  | QuestionRemoved QuestionId
  | QuestionUpdated QuestionId UpdateType
  | QuestionOrderChanged QuestionOrderingInfo
  | FormTitleUpdated String
  | SubQuestionAdded QuestionId
  | RenderPdf
  | ImageUploaded ImageUploadedInfo
  | ImageUploadResultReceived ImageUploadedResult
  | Mdl (Material.Msg Msg)

type UpdateType
  = TypeChanged QuestionType
  | TitleUpdated String
  | MultipleChoiceOptionAdded
  | MultipleChoiceOptionRemoved Int
  | MultipleChoiceOptionUpdated Int String
  | Collapse
  | Expand

type alias QuestionOrderingInfo =
  { oldQuestionId : QuestionId
  , questionIdToMoveAfter : QuestionId
  }

type alias ElementId = String

type alias ImageUploadedInfo =
  { questionId : QuestionId
  , elementId : String
  }

type alias ImageUploadedResult =
  { questionId : QuestionId
  , result : String
  , name : String
  }
