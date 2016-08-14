module Update exposing (update)

import Utils
import Models exposing (Model, Question, QuestionType(..), MultipleChoiceInfo, QuestionId)
import Messages exposing (Msg(..), UpdateType(..), QuestionOrderingInfo, ImageUploadedResult)
import Update.Extra exposing (andThen)
import Ports exposing (..)
import Material
import Json

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({questions} as model) =
  case msg of
    Mdl msg' ->
      Material.update msg' model

    RenderPdf ->
      model ! [ renderPdf <| Json.encodeModel model ]

    ImageUploaded info ->
      model ! [ imageUploaded info ]

    ImageUploadResultReceived ({questionId} as info) ->
      { model | questions = updateQuestionWithId (addImage info) questionId questions } ! []
      --|> andThen update CloseImageUploadDialog

    FormTitleUpdated newTitle ->
      { model | title = newTitle } ! []

    QuestionAdded ->
      { model
      | questions = questions ++ [{ questionType = ShortAnswer
                                  , title = ""
                                  , questionNumber = (List.length questions) + 1
                                  , image = Nothing
                                  , isExpanded = True
                                  }]
      } ! []

    QuestionRemoved id ->
      { model | questions = removeQuestionWithId id questions } ! []

    QuestionOrderChanged { oldQuestionId, questionIdToMoveAfter } ->
      { model | questions = moveQuestion oldQuestionId questionIdToMoveAfter questions } ! []

    SubQuestionAdded parentId ->
      { model | questions = updateQuestionWithId addSubQuestion parentId questions } ! []

    QuestionUpdated id updateType ->
      case updateType of
        TitleUpdated newTitle ->
          { model | questions = updateQuestionWithId (updateQuestionTitle newTitle) id questions } ! []

        TypeChanged newType ->
          let
            chainUpdates model =
              case newType of
                MultipleChoice { options } ->
                  if List.length options == 0
                  then model |> andThen update (QuestionUpdated id MultipleChoiceOptionAdded)
                  else model

                SubQuestionContainer _ ->
                  let
                    oldQuestion = retrieveQuestion id questions
                  in
                    case oldQuestion of
                      Just q ->
                        model
                        |> andThen update (QuestionUpdated id <| TitleUpdated "")
                        |> andThen update (SubQuestionAdded id)
                        |> andThen update (QuestionUpdated (id ++ [1]) <| TitleUpdated q.title)
                        |> andThen update (QuestionUpdated (id ++ [1]) <| TypeChanged q.questionType)

                      Nothing -> model

                _ -> model
          in
            { model | questions = updateQuestionWithId (updateQuestionType newType) id questions } ! []
             |> chainUpdates

        MultipleChoiceOptionAdded ->
          { model | questions = updateQuestionWithId (addMultipleChoiceOption) id questions } ! []

        MultipleChoiceOptionRemoved optionId ->
          { model | questions = updateQuestionWithId (removeMultipleChoiceOption optionId) id questions } ! []

        MultipleChoiceOptionUpdated optionId newValue ->
          { model | questions = updateQuestionWithId (updateMultipleChoiceOption optionId newValue) id questions } ! []

        Collapse ->
          { model | questions = updateQuestionWithId collapse id questions } ! []

        Expand ->
          { model | questions = updateQuestionWithId expand id questions } ! []

moveQuestion : QuestionId -> QuestionId -> List Question -> List Question
moveQuestion oldQuestionId questionIdToMoveAfter questions =
  let
    question = retrieveQuestion oldQuestionId questions
  in
    case question of
      Just q ->
        questions
        |> removeQuestion oldQuestionId
        |> addQuestion q questionIdToMoveAfter
        |> renumberQuestions oldQuestionId
        |> renumberQuestions questionIdToMoveAfter

      Nothing -> questions

retrieveQuestion : QuestionId -> List Question -> Maybe Question
retrieveQuestion questionId questions =
    case questionId of
      (a::[]) ->
        findQuestionInList a questions

      (a::b) ->
        case findQuestionInList a questions of
          Just question ->
            case question.questionType of
              SubQuestionContainer subQuestions ->
                retrieveQuestion b subQuestions

              _ -> Nothing

          Nothing -> Nothing

      [] -> Nothing

findQuestionInList : Int -> List Question -> Maybe Question
findQuestionInList a list =
  let
    question = List.filter (\q -> q.questionNumber == a) list
  in
    case question of
      (q::[]) -> Just q
      _       -> Nothing

removeQuestion : QuestionId -> List Question -> List Question
removeQuestion =
  let
    removeQuestionWithNumber n = List.filter (\q -> q.questionNumber /= n)
  in
    mapOntoQuestionsInHierachy removeQuestionWithNumber

addQuestion : Question -> QuestionId -> List Question -> List Question
addQuestion question questionIdToAddAfter =
  let
    addQuestionAfterNumber n questions =
      let
        (before, after) =
          List.partition (\q -> q.questionNumber <= n) questions
      in
        before ++ [question] ++ after
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
    (a::[]) ->
      processQuestions a questions

    (a::b) ->
      List.map
        (updateQuestionWithNumber
          (mapOntoSubQuestions (mapOntoQuestionsInHierachy processQuestions b))
          a)
        questions

    _ -> questions

expand : Question -> Question
expand question =
  { question | isExpanded = True }

collapse : Question -> Question
collapse question =
  { question | isExpanded = False }

addImage : ImageUploadedResult -> Question -> Question
addImage { name, result } question =
  { question | image = Just { data = result, name = name } }

addSubQuestion : Question -> Question
addSubQuestion =
  let
    addSubQuestion' subQuestions =
      subQuestions ++ [{ questionType = ShortAnswer
                       , title = ""
                       , questionNumber = (List.length subQuestions) + 1
                       , image = Nothing
                       , isExpanded = True
                       }]
  in
   mapOntoSubQuestions addSubQuestion'

updateQuestionTitle : String -> Question -> Question
updateQuestionTitle newTitle q = { q | title = newTitle }

updateQuestionType : QuestionType -> Question -> Question
updateQuestionType newType q = { q | questionType = newType }

addMultipleChoiceOption : Question -> Question
addMultipleChoiceOption =
   updateMultipleChoiceInfo (\{ options, uid } -> { options = options ++ [{ id = uid, value = "" }], uid = uid + 1 })

removeMultipleChoiceOption : Int -> Question -> Question
removeMultipleChoiceOption optionId =
  let
    removeOption info = { info | options = List.filter (\o -> o.id /= optionId) info.options }
  in
    updateMultipleChoiceInfo removeOption

updateMultipleChoiceOption : Int -> String -> Question -> Question
updateMultipleChoiceOption optionId newValue =
  let
    updateOption option = { option | value = newValue }
    updateOptions options = List.map (updateListItem updateOption optionId) options
  in
    updateMultipleChoiceInfo (\x -> { x | options = updateOptions x.options })

updateMultipleChoiceInfo : (MultipleChoiceInfo -> MultipleChoiceInfo) -> Question -> Question
updateMultipleChoiceInfo updateFunction q =
  let
    updateChoiceInfo question =
      case question of
        MultipleChoice choiceInfo ->
          MultipleChoice <| updateFunction choiceInfo

        _ -> question
  in
    { q | questionType = updateChoiceInfo q.questionType }

updateListItem : ({ b | id : a } -> { b | id : a }) -> a -> { b | id : a } -> { b | id : a }
updateListItem updateFunction id item =
  if item.id == id
  then updateFunction item
  else item

updateQuestionWithId : (Question -> Question) -> QuestionId -> List Question -> List Question
updateQuestionWithId updateFunction questionId questions =
  let
    updateQuestionInSubQuestion questionId question =
      mapOntoSubQuestions (updateQuestionWithId updateFunction questionId) question
  in
    case questionId of
      (a::[]) ->
        List.map (updateQuestionWithNumber updateFunction a) questions

      (a::b) ->
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
      (a::[]) ->
        renumberQuestionList <| List.filter (\q -> q.questionNumber /= a) questions

      (a::b) ->
        List.map (updateQuestionWithNumber (removeQuestionInSubQuestion b) a) questions

      [] ->
        questions

updateQuestionWithNumber : (Question -> Question) -> Int -> Question -> Question
updateQuestionWithNumber updateFunction questionNumber question =
  if question.questionNumber == questionNumber
  then updateFunction question
  else question

mapOntoSubQuestions : (List Question -> List Question) -> Question -> Question
mapOntoSubQuestions f question =
  case question.questionType of
    SubQuestionContainer subQuestions ->
      { question | questionType = SubQuestionContainer <| f subQuestions }

    _ -> question
