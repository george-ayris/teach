module Views.QuestionOutput exposing (renderQuestionOutput, toStringQuestionNumber)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Resources as R
import String
import Utils
import Models exposing (..)
import Messages exposing (..)


renderQuestionOutput : QuestionId -> Question -> Html Msg
renderQuestionOutput parentIds ({ questionType, title, questionNumber, image } as question) =
    let
        title_ =
            if String.isEmpty title then
                R.expandedQuestionPlaceholder
            else
                title

        questionId =
            parentIds ++ [ questionNumber ]

        renderImage =
            case image of
                Just { data } ->
                    img [ src data {- , style questionImage -} ] []

                Nothing ->
                    text ""
    in
        div []
            [ div [{- style questionStyle -}] [ text <| (toStringQuestionNumber questionId) ++ ". " ++ title_ ]
            , renderImage
            , div [] [ questionSpecificContent questionId question ]
            ]


toStringQuestionNumber : QuestionId -> String
toStringQuestionNumber id =
    case id of
        a :: b :: c :: [] ->
            String.toLower <| Utils.numberToRoman c

        a :: b :: [] ->
            String.toLower <| Utils.numberToLetter b

        a :: [] ->
            toString a

        _ ->
            ""


questionSpecificContent : QuestionId -> Question -> Html Msg
questionSpecificContent id { questionType } =
    case questionType of
        LongAnswer numRows ->
            div []
                [ if numRows > 0 then
                    textarea [ {- style writtenQuestionInput, -} rows numRows, placeholder "Written text response expected" ] []
                  else
                    div [] []
                ]

        TrueFalse ->
            Html.form [] (List.map (renderMultipleChoiceOutput id) [ { value = "True" }, { value = "False" } ])

        MultipleChoice { options } ->
            Html.form [] (List.map (renderMultipleChoiceOutput id) options)

        FillBlanks { options } ->
            if List.length options > 0 then
                div []
                    [ text ("Word Bank: ")
                    , text (String.append (String.join ", " <| List.map (\a -> a.value) options) ".")
                    ]
            else
                div [] []

        SubQuestionContainer questions ->
            div [{- style subQuestionContainer -}] (List.map (renderQuestionOutput id) questions)


renderMultipleChoiceOutput : QuestionId -> { a | value : String } -> Html Msg
renderMultipleChoiceOutput id option =
    div []
        [ input [ type_ "radio", name <| "Question " ++ (toString id), value option.value ] []
        , text
            (if String.isEmpty option.value then
                R.optionPlaceholder
             else
                option.value
            )
        ]
