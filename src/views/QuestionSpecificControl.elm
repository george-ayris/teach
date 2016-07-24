module Views.QuestionSpecificControl exposing (renderQuestionSpecificControl)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R

renderQuestionSpecificControl : Question -> Html Msg
renderQuestionSpecificControl ({ id, questionType, title } as question) =
  case questionType of
    MultipleChoice { options } ->
      div [] <| List.concat
        [ List.map (renderOption id) options
        , [ div [] [ button [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ] [ text "Add option" ]]]
        ]

    _ -> text ""

renderOption : Int -> Option -> Html Msg
renderOption questionId option =
  div []
    [ input
        [ type' "text"
        , placeholder R.optionPlaceholder
        , onInput (QuestionUpdated questionId << MultipleChoiceOptionUpdated option.id)
        , value option.value
        ] [ text option.value ]
    , R.removeButton <| QuestionUpdated questionId <| MultipleChoiceOptionRemoved option.id
    ]
