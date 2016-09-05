module Views.QuestionControl exposing (renderControl)

import Views.QuestionOutput exposing (toStringQuestionNumber)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Views.Styling exposing (..)
import Views.Resources as R

import Material
--import Json.Decode as Json
import Material.Card as Card
--import Material.Color as Color
import Material.Elevation as Elevation
import Material.List as MList
import Material.Options as Options exposing (css, cs)
import Material.Textfield as Textfield
import Material.Slider as Slider
--import Material.Typography as Typo
import Material.Button as Button
import Material.Menu as Menu
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
        upButton =  if isFirstElement
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
            , Options.attribute <| Html.Events.onMouseDown Dragging
            ]
            [ Card.text
                [ css "width" "100%"
                , css "box-sizing" "border-box"
                , css "background-color" "#EEE"
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
                    , Options.div
                        [ css "flex-grow" "1"
                        , css "padding-left" "4px"
                        , css "padding-right" "4px"
                        ]
                        [ Textfield.render Mdl questionId mdl
                            [ Textfield.disabled
                            , Textfield.value <|   toStringQuestionNumber questionId  ++ ")"
                            , css "float" "left"
                            , css "width" "7%"
                            , cs "textfield__minimised"
                            ]
                        , Textfield.render Mdl questionId mdl
                            [ Textfield.onInput <| QuestionUpdated questionId << TitleUpdated
                            , Textfield.label R.questionPlaceholder
                            , Textfield.value <| if question.isExpanded then " " else title
                            , Textfield.disabled
                            , css "width" "80%"
                            , css "float" "left"
                            , cs "textfield__minimised"
                            ]
                        ]
                    , Options.div
                        [ css "float" "right"
                        , css "width" "200px"
                        , css "text-align" "right"
                        ]
                        [ R.addImageButton questionId mdl
                        , upButton
                        , downButton
                        , R.removeButton questionId mdl <| QuestionRemoved questionId
                        ]
                    ]
                ]
            , if question.isExpanded
                then
                    Card.text [] [
                        Options.div []
                            [ Options.div []
                                [ Textfield.render Mdl questionId mdl
                                    [ Textfield.onInput <| QuestionUpdated questionId << TitleUpdated
                                    , Textfield.label R.expandedQuestionPlaceholder
                                    , Textfield.textarea
                                    , Textfield.value title
                                    , Textfield.rows 3
                                    , css "width" "100%"
                                    ]
                                ]
                            -- , select
                            --    [ onInput <| questionTypeChanged questionId ]
                            --    (renderQuestionTypes questionId questionType)
                            , renderTypeButtons questionId mdl question
                            , renderQuestionSpecificControl questionId mdl question
                            ]
                        ]
                else Card.text [css "padding" "0px"] []
            ]
{-
questionTypeChanged : QuestionId -> String -> Msg
questionTypeChanged id string =
    QuestionUpdated id <| TypeChanged (stringToQuestionType string)

renderQuestionTypes : QuestionId -> QuestionType -> List (Html Msg)
renderQuestionTypes id selectedOption =
    let
        questionTypes =
            [ LongAnswer 0
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
-}

prettyPrint : QuestionType -> String
prettyPrint questionType =
    case questionType of
        LongAnswer _ -> "Text Response"
        TrueFalse -> "True/false"
        MultipleChoice _ -> "Multiple choice"
        FillBlanks _ -> "Fill in blanks"
        SubQuestionContainer _ -> "Add sub-question"

prettyTemplate : TemplateType -> String
prettyTemplate templateType =
    case templateType of
        TrueFalseT -> "True/False"
        CustomMultChoiceT -> "Custom"
        TextT -> "Basic Text"
        FillBlanksT -> "Fill in Blanks"

renderTypeButtons : QuestionId -> Mdl -> Question -> Html Msg
renderTypeButtons id mdl {questionType} =
    let
        questionButtonTypes : List ( QuestionType, Int, (List TemplateType) )
        questionButtonTypes =
            [ ( LongAnswer 5, 1, [TextT, FillBlanksT] )
            , ( MultipleChoice { options = [], uid = 0 }, 2, [CustomMultChoiceT, TrueFalseT] )
            , ( SubQuestionContainer [], 3 , [])
        ]
        renderButton : (QuestionType, Int, (List TemplateType)) -> List (Html Msg)
        renderButton (qType, typeId, menuOptions) =
            [ Button.render Mdl (id ++ [3+typeId]) mdl
                [ Button.raised
                , Button.colored
                , ( if questionTypeToString questionType /= questionTypeToString qType
                      then (css "" "" )
                      else Button.disabled
                    )
                , Button.onClick <| QuestionUpdated id <| TypeChanged qType
                , css "width" "25%"
                , css "font-size" "9pt"
                , css "padding" "0pt"
                ]
                [ text <| prettyPrint qType ]
            , if questionTypeToString qType /= questionTypeToString (SubQuestionContainer [])
                && questionTypeToString qType == questionTypeToString questionType
                then
                    let
                        menuType1 = Maybe.withDefault TextT <| List.head menuOptions
                        menuType2 = Maybe.withDefault TextT <| List.head
                            <| Maybe.withDefault [TextT] <| List.tail menuOptions
                    in
                        Options.div [ css "width" "10%" ] [
                            Menu.render Mdl (id ++ [typeId]) mdl
                            [ Menu.topRight]
                            [ Menu.item
                                [ Menu.onSelect <| QuestionUpdated id <| TemplateChosen menuType1 ]
                                [ text <| prettyTemplate <| menuType1 ]
                            , Menu.item
                                [ Menu.onSelect <| QuestionUpdated id <| TemplateChosen menuType2 ]
                                [ text <| prettyTemplate <| menuType2 ]
                            ]
                        ]
                else if questionTypeToString qType /= questionTypeToString (SubQuestionContainer [])
                    then Options.div [css "margin" "0px", css "padding" "0px", css "width" "10%"] []
                else Options.div [css "margin" "0px", css "padding" "0px", css "width" "0%"] []

            ]
    in
        Options.div [ css "justify-content" "space-between"
                    , css "display" "flex"
                    ]
                    <| List.concat <| List.map renderButton questionButtonTypes

renderQuestionSpecificControl : QuestionId -> Mdl -> Question -> Html Msg
renderQuestionSpecificControl id mdl ({ questionType, title } as question) =
    case questionType of
        LongAnswer numLines ->
            div [] [
                Slider.view
                    [ Slider.onChange <| (\val -> QuestionUpdated id (AnswerLengthUpdated (round val) ) )
                    , Slider.value <| toFloat numLines
                    , Slider.min 0
                    , Slider.max 30
                    , css "padding" "10px"
                    ]
                ]

        FillBlanks { options } ->
            div [] <| List.concat
                [ List.map (renderOption id mdl "Word for bank") options
                , [ div [] [ button
                            [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ]
                            [ text "Add word to bank" ]
                        ]
                    ]
                ]

        MultipleChoice { options } ->
            div [] <| List.concat
                [ List.map (renderOption id mdl R.optionPlaceholder) options
                , [ div [] [ button
                            [ onClick <| QuestionUpdated id MultipleChoiceOptionAdded ]
                            [ text "Add option" ]
                        ]
                    ]
                ]

        SubQuestionContainer questions ->
            let
                controls = List.indexedMap (renderControl id mdl <| List.length questions) questions
            in
                div [ style subQuestionContainer ]
                    [ MList.ul []
                        <| List.concat
                        [ (List.map (\x -> MList.li [] [ MList.content [] [x]]) controls)
                        , [ MList.li [] <|
                                [ MList.content []
                                    [ Button.render Mdl (id ++ [5]) mdl
                                        [ Button.raised
                                        , Button.ripple
                                        , Button.onClick <| SubQuestionAdded id
                                        , Button.colored
                                        ]
                                        [ text "Add sub-question" ]
                                    ]
                                ]
                            ]
                        ]
                    ]

        _ -> text ""

renderOption : QuestionId -> Mdl -> String -> Option -> Html Msg
renderOption questionId mdl placeholder option =
    div []
        [ Textfield.render Mdl (questionId ++ [option.id]) mdl
            [ Textfield.onInput <| QuestionUpdated questionId << MultipleChoiceOptionUpdated option.id
            , Textfield.label placeholder
            , Textfield.text'
            , Textfield.value option.value
            , cs "textfield__list-element"
            ]
        , R.removeButton questionId mdl <| QuestionUpdated questionId <| MultipleChoiceOptionRemoved option.id
        ]
