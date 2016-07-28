module Update exposing (update)

import Utils
import Models exposing (Model, Question, QuestionType(..), MultipleChoiceInfo, QuestionId)
import Messages exposing (Msg(..), UpdateType(..), QuestionOrderingInfo)

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({questions} as model) =
  case msg of
    FormTitleUpdated newTitle ->
      ({ model | title = newTitle }, Cmd.none)

    QuestionAdded ->
      ({ model
       | questions = questions ++ [{ questionType = ShortAnswer
                                    , title = ""
                                    , questionNumber = (List.length questions) + 1
                                    }]
       }
      , Cmd.none)

    QuestionRemoved id ->
      ({ model | questions = removeQuestionWithId id questions }, Cmd.none)

    QuestionOrderChanged { oldQuestionId, questionIdToMoveAfter } ->
      ({ model | questions = moveQuestion oldQuestionId questionIdToMoveAfter questions }, Cmd.none)

    SubQuestionAdded parentId ->
      ({ model | questions = updateQuestionWithId addSubQuestion parentId questions }, Cmd.none)

    QuestionUpdated id updateType ->
      case updateType of
        TitleUpdated newTitle ->
          ({ model | questions = updateQuestionWithId (updateQuestionTitle newTitle) id questions }, Cmd.none)

        TypeChanged newType ->
          let
            addOptionIfMultipleChoice questionType =
              case questionType of
                MultipleChoice _ ->
                  Utils.createCmd <| QuestionUpdated id MultipleChoiceOptionAdded
                _ -> Cmd.none
          in
            ({ model | questions = updateQuestionWithId (updateQuestionType newType) id questions }
            , addOptionIfMultipleChoice newType)

        MultipleChoiceOptionAdded ->
          ({ model | questions = updateQuestionWithId (addMultipleChoiceOption) id questions }, Cmd.none)

        MultipleChoiceOptionRemoved optionId ->
          ({ model | questions = updateQuestionWithId (removeMultipleChoiceOption optionId) id questions }, Cmd.none)

        MultipleChoiceOptionUpdated optionId newValue ->
          ({ model | questions = updateQuestionWithId (updateMultipleChoiceOption optionId newValue) id questions }, Cmd.none)

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


addSubQuestion : Question -> Question
addSubQuestion =
  let
    addSubQuestion' subQuestions =
      subQuestions ++ [{ questionType = ShortAnswer
                       , title = ""
                       , questionNumber = (List.length subQuestions) + 1
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
