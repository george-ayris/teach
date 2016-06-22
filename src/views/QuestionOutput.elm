module Views.QuestionOutput exposing (renderQuestionOutput)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R
import String
import Models exposing (..)
import Messages exposing (..)

renderQuestionOutput : Question -> Html Msg
renderQuestionOutput ({ id, questionType, title, questionNumber } as question) =
    let
      title' = if String.isEmpty title then R.questionPlaceholder else title
    in
      div []
        [ div [ style questionStyle ] [ text <| (toString questionNumber) ++ ". " ++ title' ]
        , div [] [ questionSpecificContent question ]
        ]

questionSpecificContent : Question -> Html Msg
questionSpecificContent { id, questionType } =
  case questionType of
    ShortAnswer ->
      textarea [ style writtenQuestionInput, rows 1, placeholder "A few words expected" ] []

    MediumAnswer ->
      textarea [ style writtenQuestionInput, rows 4, placeholder "A couple of sentences expected" ] []

    LongAnswer ->
      textarea [ style writtenQuestionInput, rows 8, placeholder "A paragraph expected" ] []

    TrueFalse ->
      Html.form [] (List.map (renderMultipleChoiceOutput id) [{ value = "True" }, { value = "False" }])

    MultipleChoice { options } ->
      Html.form [] (List.map (renderMultipleChoiceOutput id) options)

renderMultipleChoiceOutput : Int -> { a | value : String } -> Html Msg
renderMultipleChoiceOutput id option =
  div []
   [ input [ type' "radio", name <| "Question " ++ (toString id), value option.value ] []
   , text (if String.isEmpty option.value then R.optionPlaceholder else option.value)
   ]