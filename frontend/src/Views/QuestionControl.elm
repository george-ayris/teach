module Views.QuestionControl exposing (renderControl)

import Views.QuestionOutput exposing (toStringQuestionNumber)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R
--import Json.Decode as Json
import Material.Card as Card
--import Material.Color as Color
import Material.Elevation as Elevation
import Material.List as MList
import Material.Options as Options exposing (css, cs)
import Material
import Material.Textfield as Textfield
--import Material.Typography as Typo
import Material.Button as Button
--import Material.Dialog as Dialog

type alias Mdl =
  Material.Model

renderControl : QuestionId -> Mdl -> Int -> Int -> Question -> Html Msg
renderControl parentIds mdl listLength index ({ questionType, title, questionNumber, image} as question) =
  let
    questionId = parentIds ++ [ questionNumber ]
    isFirstElement = index == 0
    questionMovedUp = QuestionOrderChanged { oldQuestionId = questionId
                                          , questionIdToMoveAfter = parentIds ++ [ questionNumber - 2 ]
                                          }
    upButton = if isFirstElement
            then text ""
              else R.upButton questionId mdl questionMovedUp
    isLastElement = index == listLength - 1
    questionMovedDown = QuestionOrderChanged { oldQuestionId = questionId
                                             , questionIdToMoveAfter = parentIds ++ [ questionNumber + 1 ]
                                             }
    downButton = if isLastElement
                 then text ""
                 else R.downButton questionId mdl questionMovedDown
  in
    Card.view
      [ Elevation.e4
      , css "width" "100%"
      ]
      [ Card.text
        [ css "width" "100%"
        , css "box-sizing" "border-box"
        ]
        [ Options.div
            [ css "display" "flex"
            , css "justify-content" "space-between"
            ]
            [ Options.div
                []
                [ if question.isExpanded
                  then R.questionIsExpanded questionId mdl <| QuestionUpdated questionId Collapse
                  else R.questionIsCollapsed questionId mdl <| QuestionUpdated questionId Expand
                ]
            , if question.isExpanded
              then
                Options.div
                  [ css "flex-grow" "1"
                  , css "padding-left" "4px"
                  , css "padding-right" "4px"
                  ]
                  [
                    Button.render Mdl questionId mdl
                      [ Button.disabled
                      , Button.raised
                      , css "float" "left"
                      , css "width" "5%"
                      ]
                      [ text <| toStringQuestionNumber questionId  ]
                  ]
              else
                Options.div
                  [ css "flex-grow" "1"
                  , css "padding-left" "4px"
                  , css "padding-right" "4px"
                  ]
                  [ Textfield.render Mdl questionId mdl
                      [ Textfield.onInput <| QuestionUpdated questionId << TitleUpdated
                      , Textfield.label R.questionPlaceholder
                      , Textfield.value title
                      , css "width" "75%"
                      , css "float" "right"
                      , cs "textfield__minimised"
                      ]
                  , Button.render Mdl questionId mdl
                      [ Button.disabled
                      , Button.raised
                      , css "float" "left"
                      ]
                      [ text <| toStringQuestionNumber questionId  ]
                  ]
            , Options.div
                []
                [ R.addImageButton questionId mdl
                , upButton
                , downButton
                , R.removeButton questionId mdl <| QuestionRemoved questionId
                ]
            ]
        , if question.isExpanded
          then
            div []
              [ div []
                    [ Textfield.render Mdl questionId mdl
                      [ Textfield.onInput <| QuestionUpdated questionId << TitleUpdated
                      , Textfield.label R.questionPlaceholder
                      , Textfield.textarea
                      , Textfield.value title
                      , Textfield.rows 3
                      , css "width" "100%"
                      , css "float" "right"
                      ]
                    ]
                , select
                    [ onInput <| questionTypeChanged questionId ]
                    (renderQuestionTypes questionId questionType)
                , renderQuestionSpecificControl questionId mdl question
              ]
          else text ""
        ]
      ]

questionTypeChanged : QuestionId -> String -> Msg
questionTypeChanged id string =
  QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : QuestionId -> QuestionType -> List (Html Msg)
renderQuestionTypes id selectedOption =
  let
    questionTypes =
      [ ShortAnswer
      , MediumAnswer
      , LongAnswer
      , TrueFalse
      , MultipleChoice { options = [], uid = 0 }
      , FillBlanks { options = [], uid = 0 }
      ]
  in
    if List.length id > 2
    then List.map (renderQuestionType selectedOption) questionTypes
    else List.map (renderQuestionType selectedOption) <| questionTypes ++ [ SubQuestionContainer [] ]

renderQuestionType : QuestionType -> QuestionType -> Html Msg
renderQuestionType selectedOption questionType =
  let
    optionSelected =
      questionTypeToString selectedOption == questionTypeToString questionType
  in
    option [ value <| questionTypeToString questionType, selected optionSelected ] [ text <| prettyPrint questionType ]

prettyPrint : QuestionType -> String
prettyPrint questionType =
  case questionType of
    ShortAnswer -> "Short answer"
    MediumAnswer -> "Medium answer"
    LongAnswer -> "Long answer"
    TrueFalse -> "True/false"
    MultipleChoice _ -> "Multiple choice"
    FillBlanks _ -> "Fill the blanks"
    SubQuestionContainer _ -> "Or add a sub-question"

renderQuestionSpecificControl : QuestionId -> Mdl -> Question -> Html Msg
renderQuestionSpecificControl id mdl ({ questionType, title } as question) =
  case questionType of
    FillBlanks { options } ->
      div [] <| List.concat
        [ List.map (renderWord id mdl) options
        , [ div [] [ button [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ] [ text "Add word to bank" ]]]
        ]

    MultipleChoice { options } ->
      div [] <| List.concat
        [ List.map (renderOption id mdl) options
        , [ div [] [ button [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ] [ text "Add option" ]]]
        ]

    SubQuestionContainer questions ->
      let
        controls = List.indexedMap (renderControl id mdl <| List.length questions) questions
      in
        div [ style subQuestionContainer ]
          [ MList.ul [] <| List.concat
              [ (List.map (\x -> MList.li [] [ MList.content [] [x]]) controls)
              , [ MList.li [] <| [ MList.content []
                  [ Button.render Mdl (id ++ [5]) mdl
                      [ Button.raised
                      , Button.ripple
                      , Button.onClick <| SubQuestionAdded id
                      , Button.colored
                      ]
                      [ text "Add sub-question" ]
                  ]]
                ]
              ]
          ]

    _ -> text ""

renderOption : QuestionId -> Mdl -> Option -> Html Msg
renderOption questionId mdl option =
  div []
    [ Textfield.render Mdl (questionId ++ [option.id]) mdl
        [ Textfield.onInput <| QuestionUpdated questionId << MultipleChoiceOptionUpdated option.id
        , Textfield.label R.optionPlaceholder
        , Textfield.text'
        , cs "textfield__list-element"
        ]
    , R.removeButton questionId mdl <| QuestionUpdated questionId <| MultipleChoiceOptionRemoved option.id
    ]

renderWord : QuestionId -> Mdl -> Option -> Html Msg
renderWord questionId mdl option =
  div []
    [ Textfield.render Mdl (questionId ++ [option.id]) mdl
        [ Textfield.onInput <| QuestionUpdated questionId << MultipleChoiceOptionUpdated option.id
        , Textfield.label "Word for bank"
        , Textfield.text'
        , cs "textfield__list-element"
        ]
    , R.removeButton questionId mdl <| QuestionUpdated questionId <| MultipleChoiceOptionRemoved option.id
    ]
