module Views.WorksheetControls exposing (renderWorksheetControls)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R
import Views.QuestionSpecificControl exposing (renderQuestionSpecificControl)

renderWorksheetControls : Model -> Html Msg
renderWorksheetControls model =
  div []
    [ h1 [ style panelHeading
         , contenteditable True
         , on "blur" (Json.map FormTitleUpdated targetTextContent)
         , value model.title
         ] [ text model.title ]
    , div []
        [ div [] (List.map renderControl model.questions)
        , button [ onClick QuestionAdded ] [ text "Add question" ]
        ]
    ]

targetTextContent : Json.Decoder String
targetTextContent =
  Json.at ["target", "textContent"] Json.string

renderControl : Question -> Html Msg
renderControl ({ id, questionType, title } as question) =
  div []
    [ input [ type' "text", placeholder R.questionPlaceholder, onInput (QuestionUpdated id << TitleUpdated) ] [ text title ]
    , select [ onInput <| questionTypeChanged id ] renderQuestionTypes
    , R.removeButton <| QuestionRemoved id
    , renderQuestionSpecificControl question
    ]

questionTypeChanged : Int -> String -> Msg
questionTypeChanged id string =
  QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : List (Html Msg)
renderQuestionTypes =
  [ ShortAnswer, MediumAnswer, LongAnswer, MultipleChoice { options = [], uid = 0 } ]|> List.map renderQuestionType

renderQuestionType : QuestionType -> Html Msg
renderQuestionType questionType =
  option [ value <| questionTypeToString questionType ] [ text <| prettyPrint questionType ]

prettyPrint : QuestionType -> String
prettyPrint questionType =
  case questionType of
    ShortAnswer -> "Short answer"
    MediumAnswer -> "Medium answer"
    LongAnswer -> "Long answer"
    MultipleChoice _ -> "Multiple choice"
