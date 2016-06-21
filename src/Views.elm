module Views exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Messages exposing (Msg(..))
import Views.Styling exposing (..)
import String
import Color
import FontAwesome

questionPlaceholder : String
questionPlaceholder = "What do you want to ask?"

view : Model -> Html Msg
view model =
  div [ style mainContainer ]
    [ div [ style mainPanel ]
        [ h1 [ style panelHeading ] [ text "Form Builder" ]
        , div []
            [ div [] (List.map renderControl model.questions)
            , button [ onClick QuestionAdded ] [ text "Add Question" ]
            ]
        ]
    , div [ style mainPanel ]
        [ h1 [ style panelHeading ] [ text "Form Renderer" ]
        , div [] (List.map renderOutput model.questions)
        ]
    ]

renderControl : Question -> Html Msg
renderControl { id, questionType, title } =
  div []
    [ input [ type' "text", placeholder questionPlaceholder, onInput (QuestionTitleUpdated id) ] [ text title ]
    , select [ onInput <| questionTypeChanged id ] renderQuestionTypes
    , span [ style svgContainer, onClick <| QuestionRemoved id ] [ FontAwesome.close Color.red 18 ]
    ]

questionTypeChanged : Int -> String -> Msg
questionTypeChanged id string =
  QuestionTypeChanged id (stringToQuestionType string)

renderQuestionTypes : List (Html Msg)
renderQuestionTypes =
  [ ShortAnswer, MultipleChoice ] |> List.map renderQuestionType

renderQuestionType : QuestionType -> Html Msg
renderQuestionType questionType =
  option [ value <| questionTypeToString questionType ] [ text <| prettyPrint questionType ]

prettyPrint : QuestionType -> String
prettyPrint questionType =
  case questionType of
    ShortAnswer -> "Short answer"
    MultipleChoice -> "Multiple choice"

renderOutput : Question -> Html Msg
renderOutput { id, questionType, title } =
  let
    title' = if String.isEmpty title then questionPlaceholder else title
  in
    case questionType of
      ShortAnswer ->
        div []
          [ div [] [ text title' ]
          , textarea [] []
          ]
      MultipleChoice ->
        text "Hello"
