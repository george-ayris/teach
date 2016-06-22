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
        , div [] (List.indexedMap (renderOutput <| List.length model.questions) model.questions)
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
    MultipleChoice { options } ->
      div [] <| List.concat
        [ List.map (renderOption id) options
        , [ div [] [ button [ onClick <| QuestionUpdated id <| MultipleChoiceOptionAdded ] [ text "Add option" ]]]
        ]

    _ -> span [] []

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

renderOutput : Int -> Int -> Question -> Html Msg
renderOutput listLength currentIndex question =
  if (listLength - 1) == currentIndex
  then renderOutputWith (text "") question
  else renderOutputWith (hr [] []) question

renderOutputWith : Html Msg -> Question -> Html Msg
renderOutputWith htmlElem ({ id, questionType, title, questionNumber } as question) =
  let
    title' = if String.isEmpty title then questionPlaceholder else title
  in
    div []
      [ div [ style questionStyle ] [ text <| (toString questionNumber) ++ ". " ++ title' ]
      , div [] [ questionSpecificContent question ]
      , htmlElem
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

    MultipleChoice { options } ->
      Html.form [] (List.map (renderMultipleChoiceOutput id) options)

renderMultipleChoiceOutput : Int -> Option -> Html Msg
renderMultipleChoiceOutput id option =
  div []
   [ input [ type' "radio", name <| "Question " ++ (toString id), value option.value ] []
   , text (if String.isEmpty option.value then optionPlaceholder else option.value)
   ]
