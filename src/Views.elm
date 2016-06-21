module Views exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Messages exposing (Msg(..), UpdateType(..))
import Views.Styling exposing (..)
import String
import Color
import FontAwesome
import Json.Decode as Json

questionPlaceholder = "What do you want to ask?"
optionPlaceholder = "Option X"

view : Model -> Html Msg
view model =
  div [ style mainContainer ]
    [ div [ style columnSpacer ] []
    , div [ style mainPanel ]
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
    , div [ style columnSpacer ] []
    , div [ style mainPanel ]
        [ h1 [ style panelHeading ] [ text model.title ]
        , div [] (List.map renderOutput model.questions)
        ]
    , div [ style columnSpacer ] []
    ]

targetTextContent : Json.Decoder String
targetTextContent =
  Json.at ["target", "textContent"] Json.string

renderControl : Question -> Html Msg
renderControl ({ id, questionType, title } as question) =
  div []
    [ input [ type' "text", placeholder questionPlaceholder, onInput (QuestionUpdated id << TitleUpdated) ] [ text title ]
    , select [ onInput <| questionTypeChanged id ] renderQuestionTypes
    , removeButton <| QuestionRemoved id
    , renderSpecificQuestionControl question
    ]

removeButton : Msg -> Html Msg
removeButton msg =
  span [ style svgContainer, onClick <| msg ] [ FontAwesome.close Color.red 18 ]

renderSpecificQuestionControl : Question -> Html Msg
renderSpecificQuestionControl ({ id, questionType, title } as question) =
  case questionType of
    ShortAnswer ->
      span [] []

    MultipleChoice { options } ->
      div [] <| List.concat
        [ List.map (renderOption id) options
        , [ div [] [ button [ onClick <| QuestionUpdated id <| MultipleChoiceOptionAdded ] [ text "Add option" ]]]
        ]

renderOption : Int -> Option -> Html Msg
renderOption questionId option =
  div []
    [ input
        [ type' "text"
        , placeholder optionPlaceholder
        , onInput (QuestionUpdated questionId << MultipleChoiceOptionUpdated option.id)
        , value option.value
        ] [ text option.value ]
    , removeButton <| QuestionUpdated questionId <| MultipleChoiceOptionRemoved option.id
    ]

questionTypeChanged : Int -> String -> Msg
questionTypeChanged id string =
  QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : List (Html Msg)
renderQuestionTypes =
  [ ShortAnswer, MultipleChoice { options = [], uid = 0 } ]|> List.map renderQuestionType

renderQuestionType : QuestionType -> Html Msg
renderQuestionType questionType =
  option [ value <| questionTypeToString questionType ] [ text <| prettyPrint questionType ]

prettyPrint : QuestionType -> String
prettyPrint questionType =
  case questionType of
    ShortAnswer -> "Short answer"
    MultipleChoice _ -> "Multiple choice"

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

      MultipleChoice { options, uid } ->
        div []
          [ div [] [ text title' ]
          , Html.form [] (List.map (renderMultipleChoiceOutput id) options)
          ]

renderMultipleChoiceOutput : Int -> Option -> Html Msg
renderMultipleChoiceOutput id option =
  div []
   [ input [ type' "radio", name <| "Question " ++ (toString id), value option.value ] []
   , text (if String.isEmpty option.value then optionPlaceholder else option.value)
   ]
