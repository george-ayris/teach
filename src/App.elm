import Html.App as App
import Utils
import Models exposing (Model, Question, QuestionType(..), MultipleChoiceInfo, QuestionId)
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
  (Model "My Worksheet" [], Cmd.none)

-- UPDATE
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

    QuestionOrderChanged newOrderInfo ->
      ({ model | questions = moveQuestion newOrderInfo questions }, Cmd.none)

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

renumberQuestions : List Question -> List Question
renumberQuestions =
  let
    numberQuestion index question =
      { question | questionNumber = index + 1 }
  in
    List.indexedMap numberQuestion

moveQuestion : QuestionOrderingInfo -> List Question -> List Question
moveQuestion ({ oldQuestionId, newQuestionId } as orderingInfo) questions =
{-  let
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
      if listContainsQuestion id questions
      then
        questions
        |> List.map reorderQuestion
        |> List.sortBy (\x -> x.questionNumber)
      else
        case id of
          ParentId parentId _ ->
            List.map (updateListItem (moveQuestionInSubQuestion orderingInfo) (Id parentId)) questions

          _ -> questions -}
    questions

moveQuestionInSubQuestion : QuestionOrderingInfo -> Question -> Question
moveQuestionInSubQuestion orderingInfo question =
  case question.questionType of
    SubQuestionContainer subQuestions ->
      { question
      | questionType = SubQuestionContainer <| moveQuestion orderingInfo subQuestions
      }

    _ -> question

addSubQuestion : Question -> Question
addSubQuestion q =
  let
    addSubQuestionToContainer : QuestionType -> QuestionType
    addSubQuestionToContainer question =
      case question of
        SubQuestionContainer subQuestions ->
          SubQuestionContainer <| subQuestions ++ [{ questionType = ShortAnswer
                                                   , title = ""
                                                   , questionNumber = (List.length subQuestions) + 1
                                                   }]

        _ -> question
  in
    { q | questionType = addSubQuestionToContainer q.questionType }

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

updateQuestionWithNumber : (Question -> Question) -> Int -> Question -> Question
updateQuestionWithNumber updateFunction questionNumber question =
  if question.questionNumber == questionNumber
  then updateFunction question
  else question

updateQuestionWithId : (Question -> Question) -> QuestionId -> List Question -> List Question
updateQuestionWithId updateFunction questionId questions =
  case questionId of
    (a::[]) ->
      List.map (updateQuestionWithNumber updateFunction a) questions

    (a::b) ->
      List.map (updateQuestionWithNumber (updateQuestionInSubQuestion updateFunction b) a) questions

    [] ->
      questions

updateQuestionInSubQuestion : (Question -> Question) -> QuestionId -> Question -> Question
updateQuestionInSubQuestion updateFunction questionId question =
  case question.questionType of
    SubQuestionContainer subQuestions ->
      { question
      | questionType = SubQuestionContainer <| updateQuestionWithId updateFunction questionId subQuestions
      }

    _ -> question

removeQuestionWithId : QuestionId -> List Question -> List Question
removeQuestionWithId questionId questions =
  case questionId of
    (a::[]) ->
      renumberQuestions <| List.filter (\q -> q.questionNumber /= a) questions

    (a::b) ->
      List.map (updateQuestionWithNumber (removeQuestionInSubQuestion b) a) questions

    [] ->
      questions

removeQuestionInSubQuestion : QuestionId -> Question -> Question
removeQuestionInSubQuestion questionId question =
  case question.questionType of
    SubQuestionContainer subQuestions ->
      { question
      | questionType = SubQuestionContainer <| removeQuestionWithId questionId subQuestions
      }

    _ -> question
