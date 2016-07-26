import Html.App as App
import Utils
import Models exposing (Model, Question, QuestionType(..), MultipleChoiceInfo, QuestionId(..))
import Messages exposing (Msg(..), UpdateType(..), QuestionOrderingInfo)
import Views exposing (view)
import String

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \m -> Sub.none
    }

init : (Model, Cmd Msg)
init =
  (Model "My Worksheet" [] 0, Cmd.none)

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg ({questions, uid} as model) =
  case msg of
    FormTitleUpdated newTitle ->
      ({ model | title = newTitle }, Cmd.none)

    QuestionAdded ->
      ({ model
        | questions = questions ++ [{ id = Id uid
                                    , questionType = ShortAnswer
                                    , title = ""
                                    , questionNumber = (List.length questions) + 1
                                    }]
        , uid = uid + 1 }
      , Cmd.none)

    QuestionRemoved id ->
      ({ model | questions = renumberQuestions <| List.filter (\q -> q.id /= id) questions }, Cmd.none)

    QuestionOrderChanged newOrderInfo ->
      ({ model | questions = moveQuestion newOrderInfo questions }, Cmd.none)

    SubQuestionAdded parentId ->
      ({ model | questions = List.map (addSubQuestion uid parentId) questions, uid = uid + 1 }, Cmd.none)

    QuestionUpdated id updateType ->
      case updateType of
        TitleUpdated newTitle ->
          ({ model | questions = List.map (updateQuestionTitle newTitle id) questions }, Cmd.none)

        TypeChanged newType ->
          let
            addOptionIfMultipleChoice questionType =
              case questionType of
                MultipleChoice _ ->
                  Utils.createCmd <| QuestionUpdated id MultipleChoiceOptionAdded
                _ -> Cmd.none
          in
            ({ model | questions = List.map (updateQuestionType newType id) questions }
            , addOptionIfMultipleChoice newType)

        MultipleChoiceOptionAdded ->
          ({ model | questions = List.map (addMultipleChoiceOption id) questions }, Cmd.none)

        MultipleChoiceOptionRemoved optionId ->
          ({ model | questions = List.map (removeMultipleChoiceOption id optionId) questions }, Cmd.none)

        MultipleChoiceOptionUpdated optionId newValue ->
          ({ model | questions = List.map (updateMultipleChoiceOption id optionId newValue) questions }, Cmd.none)

renumberQuestions : List Question -> List Question
renumberQuestions =
  let
    numberQuestion index question =
      { question | questionNumber = index + 1 }
  in
    List.indexedMap numberQuestion

moveQuestion : QuestionOrderingInfo -> List Question -> List Question
moveQuestion { oldQuestionNumber, newQuestionNumber } questions =
  let
    questionHasMovedUp = newQuestionNumber < oldQuestionNumber

    questionAffectedByMove questionNumber =
      if questionHasMovedUp
      then (oldQuestionNumber > questionNumber) && (questionNumber >= newQuestionNumber)
      else (newQuestionNumber >= questionNumber) && (questionNumber > oldQuestionNumber)

    reorderQuestion ({ questionNumber } as question) =
      if questionNumber == oldQuestionNumber
      then { question | questionNumber = newQuestionNumber }
      else if questionAffectedByMove questionNumber
      then if questionHasMovedUp
           then { question | questionNumber = questionNumber + 1 }
           else { question | questionNumber = questionNumber - 1 }
      else question
    in
      questions
      |> List.map reorderQuestion
      |> List.sortBy (\x -> x.questionNumber)

addSubQuestion : Int -> QuestionId -> Question -> Question
addSubQuestion uid parentId =
  let
    subQuestionId uid parentId =
      case parentId of
        Id id ->
          ParentId id (Id uid)

        ParentId int id ->
          ParentId int (subQuestionId uid id)

    addSubQuestionToContainer : QuestionType -> QuestionType
    addSubQuestionToContainer question =
      case question of
        SubQuestionContainer subQuestions ->
          SubQuestionContainer <| subQuestions ++ [{ id = subQuestionId uid parentId
                                                   , questionType = ShortAnswer
                                                   , title = ""
                                                   , questionNumber = (List.length subQuestions) + 1
                                                   }]

        _ -> question
  in
    updateListItemQuestionId (\q -> { q | questionType = addSubQuestionToContainer q.questionType }) parentId

updateQuestionTitle : String -> QuestionId -> Question -> Question
updateQuestionTitle newTitle id =
  updateListItemQuestionId (\q -> { q | title = newTitle }) id

updateQuestionType : QuestionType -> QuestionId -> Question -> Question
updateQuestionType newType id =
  updateListItemQuestionId (\q -> { q | questionType = newType }) id

addMultipleChoiceOption : QuestionId -> Question -> Question
addMultipleChoiceOption id =
   updateMultipleChoiceInfo (\{ options, uid } -> { options = options ++ [{ id = uid, value = "" }], uid = uid + 1 }) id

removeMultipleChoiceOption : QuestionId -> Int -> Question -> Question
removeMultipleChoiceOption questionId optionId =
  let
    removeOption info = { info | options = List.filter (\o -> o.id /= optionId) info.options }
  in
    updateMultipleChoiceInfo removeOption questionId

updateMultipleChoiceOption : QuestionId -> Int -> String -> Question -> Question
updateMultipleChoiceOption questionId optionId newValue =
  let
    updateOption option = { option | value = newValue }
    updateOptions options = List.map (updateListItemIntId updateOption optionId) options
  in
    updateMultipleChoiceInfo (\x -> { x | options = updateOptions x.options }) questionId

updateMultipleChoiceInfo : (MultipleChoiceInfo -> MultipleChoiceInfo) -> QuestionId -> Question -> Question
updateMultipleChoiceInfo updateFunction questionId =
  let
    updateChoiceInfo question =
      case question of
        MultipleChoice choiceInfo ->
          MultipleChoice <| updateFunction choiceInfo

        _ -> question
  in
    updateListItemQuestionId (\q -> { q | questionType = updateChoiceInfo q.questionType }) questionId

updateListItemIntId : ({ b | id : Int } -> { b | id : Int }) -> Int -> { b | id : Int } -> { b | id : Int }
updateListItemIntId updateFunction id item =
  if item.id == id
  then updateFunction item
  else item

updateListItemQuestionId : (Question -> Question) -> QuestionId -> Question -> Question
updateListItemQuestionId updateFunction id question =
  case id of
    Id int ->
      if question.id == id
      then updateFunction question
      else question

    ParentId parentId childId ->
      case question.questionType of
        SubQuestionContainer subQuestions ->
          if question.id == Id parentId
          then { question
               | questionType = SubQuestionContainer <| List.map (updateListItemQuestionId updateFunction childId) subQuestions }
          else question

        _ -> question
