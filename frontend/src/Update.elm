module Update exposing (update)

--import Utils

import Models exposing (Model, Question, QuestionType(..), MultipleChoiceInfo, QuestionId, TemplateType(..))
import Messages exposing (Msg(..), UpdateType(..), QuestionOrderingInfo, ImageUploadedResult)
import Update.Extra exposing (andThen)
import Ports exposing (..)
import Material
import Json


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ questions } as model) =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        RenderPdf ->
            model ! [ renderPdf <| Json.encodeModel model ]

        ImageUploaded info ->
            model ! [ imageUploaded info ]

        ImageUploadResultReceived ({ questionId } as info) ->
            { model | questions = updateQuestionWithId (addImage info) questionId questions } ! []

        --|> andThen update CloseImageUploadDialog
        FormTitleUpdated newTitle ->
            { model | title = newTitle } ! []

        QuestionAdded ->
            { model
                | questions =
                    questions
                        ++ [ { questionType = LongAnswer 5
                             , title = ""
                             , questionNumber = (List.length questions) + 1
                             , image = Nothing
                             , isExpanded = False
                             }
                           ]
            }
                ! []

        QuestionRemoved id ->
            { model | questions = removeQuestionWithId id questions } ! []

        QuestionOrderChanged { oldQuestionId, questionIdToMoveAfter } ->
            { model | questions = moveQuestion oldQuestionId questionIdToMoveAfter questions } ! []

        Dragging ->
            model ! []

        SubQuestionAdded parentId ->
            { model | questions = updateQuestionWithId addSubQuestion parentId questions } ! []

        QuestionUpdated id updateType ->
            case updateType of
                TitleUpdated newTitle ->
                    { model | questions = updateQuestionWithId (updateQuestionTitle newTitle) id questions } ! []

                TypeChanged newType ->
                    let
                        --chainUpdates : (Model, Cmd Msg) -> (Model, Cmd Msg) -- type annotation if wanted
                        chainUpdates model =
                            case newType of
                                FillBlanks { options } ->
                                    model |> andThen update (QuestionUpdated id ChangedToFillBlank)

                                MultipleChoice { options } ->
                                    if List.length options == 0 then
                                        model |> andThen update (QuestionUpdated id MultipleChoiceOptionAdded)
                                    else
                                        model

                                SubQuestionContainer _ ->
                                    let
                                        oldQuestion =
                                            retrieveQuestion id questions
                                    in
                                        case oldQuestion of
                                            Just q ->
                                                model
                                                    |> andThen update (QuestionUpdated id <| TitleUpdated "")
                                                    |> andThen update (SubQuestionAdded id)
                                                    |> andThen update (QuestionUpdated (id ++ [ 1 ]) <| TitleUpdated q.title)
                                                    |> andThen update (QuestionUpdated (id ++ [ 1 ]) <| TypeChanged q.questionType)

                                            Nothing ->
                                                model

                                _ ->
                                    model
                    in
                        { model | questions = updateQuestionWithId (updateQuestionType newType) id questions }
                            ! []
                            |> chainUpdates

                TemplateChosen newTemplate ->
                    { model | questions = updateQuestionWithId (useTemplate newTemplate) id questions } ! []

                AnswerLengthUpdated newNumLines ->
                    { model | questions = updateQuestionWithId (updateAnswerLength newNumLines) id questions } ! []

                ChangedToFillBlank ->
                    { model | questions = updateQuestionWithId (\q -> { q | title = "Use ___ as blanks" }) id questions } ! []

                MultipleChoiceOptionAdded ->
                    { model | questions = updateQuestionWithId (addMultipleChoiceOption) id questions } ! []

                MultipleChoiceOptionRemoved optionId ->
                    { model | questions = updateQuestionWithId (removeMultipleChoiceOption optionId) id questions } ! []

                MultipleChoiceOptionUpdated optionId newValue ->
                    { model | questions = updateQuestionWithId (updateMultipleChoiceOption optionId newValue) id questions } ! []

                Collapse ->
                    { model | questions = updateQuestionWithId (\q -> { q | isExpanded = False }) id questions } ! []

                Expand ->
                    { model | questions = updateQuestionWithId (\q -> { q | isExpanded = True }) id questions } ! []


moveQuestion : QuestionId -> QuestionId -> List Question -> List Question
moveQuestion oldQuestionId questionIdToMoveAfter questions =
    let
        question =
            retrieveQuestion oldQuestionId questions
    in
        case question of
            Just q ->
                questions
                    |> removeQuestion oldQuestionId
                    |> addQuestion q questionIdToMoveAfter
                    |> renumberQuestions oldQuestionId
                    |> renumberQuestions questionIdToMoveAfter

            Nothing ->
                questions


retrieveQuestion : QuestionId -> List Question -> Maybe Question
retrieveQuestion questionId questions =
    case questionId of
        a :: [] ->
            findQuestionInList a questions

        a :: b ->
            case findQuestionInList a questions of
                Just question ->
                    case question.questionType of
                        SubQuestionContainer subQuestions ->
                            retrieveQuestion b subQuestions

                        _ ->
                            Nothing

                Nothing ->
                    Nothing

        [] ->
            Nothing


findQuestionInList : Int -> List Question -> Maybe Question
findQuestionInList a list =
    let
        question =
            List.filter (\q -> q.questionNumber == a) list
    in
        case question of
            q :: [] ->
                Just q

            _ ->
                Nothing


removeQuestion : QuestionId -> List Question -> List Question
removeQuestion =
    let
        removeQuestionWithNumber n =
            List.filter (\q -> q.questionNumber /= n)
    in
        mapOntoQuestionsInHierachy removeQuestionWithNumber


addQuestion : Question -> QuestionId -> List Question -> List Question
addQuestion question questionIdToAddAfter =
    let
        addQuestionAfterNumber n questions =
            let
                ( before, after ) =
                    List.partition (\q -> q.questionNumber <= n) questions
            in
                before ++ [ question ] ++ after
    in
        mapOntoQuestionsInHierachy addQuestionAfterNumber questionIdToAddAfter


renumberQuestions : QuestionId -> List Question -> List Question
renumberQuestions =
    mapOntoQuestionsInHierachy (\_ -> renumberQuestionList)


renumberQuestionList : List Question -> List Question
renumberQuestionList =
    let
        numberQuestion index question =
            { question | questionNumber = index + 1 }
    in
        List.indexedMap numberQuestion


mapOntoQuestionsInHierachy : (Int -> List Question -> List Question) -> QuestionId -> List Question -> List Question
mapOntoQuestionsInHierachy processQuestions questionId questions =
    case questionId of
        a :: [] ->
            processQuestions a questions

        a :: b ->
            List.map
                (updateQuestionWithNumber
                    (mapOntoSubQuestions (mapOntoQuestionsInHierachy processQuestions b))
                    a
                )
                questions

        _ ->
            questions


addImage : ImageUploadedResult -> Question -> Question
addImage { name, result } question =
    { question | image = Just { data = result, name = name } }


addSubQuestion : Question -> Question
addSubQuestion =
    let
        addSubQuestion_ subQuestions =
            subQuestions
                ++ [ { questionType = LongAnswer 0
                     , title = ""
                     , questionNumber = (List.length subQuestions) + 1
                     , image = Nothing
                     , isExpanded = False
                     }
                   ]
    in
        mapOntoSubQuestions addSubQuestion_


updateQuestionTitle : String -> Question -> Question
updateQuestionTitle newTitle q =
    { q | title = newTitle }


updateQuestionType : QuestionType -> Question -> Question
updateQuestionType newType q =
    { q | questionType = newType, title = "" }


useTemplate : TemplateType -> Question -> Question
useTemplate template =
    case template of
        TrueFalseT ->
            updateMultipleChoiceInfo
                (\{ options, uid } ->
                    { options = [ { id = 0, value = "True" }, { id = 1, value = "False" } ], uid = 2 }
                )

        CustomMultChoiceT ->
            updateMultipleChoiceInfo
                (\{ options, uid } ->
                    { options = [ { id = 0, value = "" } ], uid = 1 }
                )

        _ ->
            (\q -> q)


addMultipleChoiceOption : Question -> Question
addMultipleChoiceOption =
    updateMultipleChoiceInfo (\{ options, uid } -> { options = options ++ [ { id = uid, value = "" } ], uid = uid + 1 })


removeMultipleChoiceOption : Int -> Question -> Question
removeMultipleChoiceOption optionId =
    let
        removeOption info =
            { info | options = List.filter (\o -> o.id /= optionId) info.options }
    in
        updateMultipleChoiceInfo removeOption


updateAnswerLength : Int -> Question -> Question
updateAnswerLength numNewLines q =
    { q | questionType = LongAnswer numNewLines }


updateMultipleChoiceOption : Int -> String -> Question -> Question
updateMultipleChoiceOption optionId newValue =
    let
        updateOption option =
            { option | value = newValue }

        updateOptions options =
            List.map
                ((\updateFunc id item ->
                    if item.id == id then
                        updateFunc item
                    else
                        item
                 )
                    updateOption
                    optionId
                )
                options
    in
        updateMultipleChoiceInfo (\x -> { x | options = updateOptions x.options })


updateMultipleChoiceInfo : (MultipleChoiceInfo -> MultipleChoiceInfo) -> Question -> Question
updateMultipleChoiceInfo updateFunction q =
    let
        updateChoiceInfo question =
            case question of
                MultipleChoice choiceInfo ->
                    MultipleChoice <| updateFunction choiceInfo

                FillBlanks choiceInfo ->
                    FillBlanks <| updateFunction choiceInfo

                _ ->
                    question
    in
        { q | questionType = updateChoiceInfo q.questionType }


updateQuestionWithId : (Question -> Question) -> QuestionId -> List Question -> List Question
updateQuestionWithId updateFunction questionId questions =
    let
        updateQuestionInSubQuestion questionId question =
            mapOntoSubQuestions (updateQuestionWithId updateFunction questionId) question
    in
        case questionId of
            a :: [] ->
                List.map (updateQuestionWithNumber updateFunction a) questions

            a :: b ->
                List.map (updateQuestionWithNumber (updateQuestionInSubQuestion b) a) questions

            [] ->
                questions


removeQuestionWithId : QuestionId -> List Question -> List Question
removeQuestionWithId questionId questions =
    let
        removeQuestionInSubQuestion questionId question =
            mapOntoSubQuestions (removeQuestionWithId questionId) question
    in
        case questionId of
            a :: [] ->
                renumberQuestionList <| List.filter (\q -> q.questionNumber /= a) questions

            a :: b ->
                List.map (updateQuestionWithNumber (removeQuestionInSubQuestion b) a) questions

            [] ->
                questions


updateQuestionWithNumber : (Question -> Question) -> Int -> Question -> Question
updateQuestionWithNumber updateFunction questionNumber question =
    if question.questionNumber == questionNumber then
        updateFunction question
    else
        question


mapOntoSubQuestions : (List Question -> List Question) -> Question -> Question
mapOntoSubQuestions f question =
    case question.questionType of
        SubQuestionContainer subQuestions ->
            { question | questionType = SubQuestionContainer <| f subQuestions }

        _ ->
            question
