import Html.App as App
import Utils
import Models exposing (Model, Question, QuestionType(..), MultipleChoiceInfo)
import Messages exposing (Msg(..), UpdateType(..))
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
  (Model "My First Worksheet" [] 0, Cmd.none)

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg ({questions, uid} as model) =
  case msg of
    FormTitleUpdated newTitle ->
      ({ model | title = newTitle }, Cmd.none)

    QuestionAdded ->
      ({ model
        | questions = questions ++ [{ id = uid
                                    , questionType = ShortAnswer
                                    , title = ""
                                    , questionNumber = (List.length questions) + 1
                                    }]
        , uid = uid + 1 }
      , Cmd.none)

    QuestionRemoved id ->
      ({ model | questions = renumberQuestions <| List.filter (\q -> q.id /= id) questions }, Cmd.none)

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

updateQuestionTitle : String -> Int -> Question -> Question
updateQuestionTitle newTitle id =
  updateListItem (\q -> { q | title = newTitle }) id

updateQuestionType : QuestionType -> Int -> Question -> Question
updateQuestionType newType id =
  updateListItem (\q -> { q | questionType = newType }) id

addMultipleChoiceOption : Int -> Question -> Question
addMultipleChoiceOption id =
   updateMultipleChoiceInfo (\{ options, uid } -> { options = options ++ [{ id = uid, value = "" }], uid = uid + 1 }) id

removeMultipleChoiceOption : Int -> Int -> Question -> Question
removeMultipleChoiceOption questionId optionId =
  let
    removeOption info = { info | options = List.filter (\o -> o.id /= optionId) info.options }
  in
    updateMultipleChoiceInfo removeOption questionId

updateMultipleChoiceOption : Int -> Int -> String -> Question -> Question
updateMultipleChoiceOption questionId optionId newValue =
  let
    updateOption option = { option | value = newValue }
    updateOptions options = List.map (updateListItem updateOption optionId) options
  in
    updateMultipleChoiceInfo (\x -> { x | options = updateOptions x.options }) questionId

updateMultipleChoiceInfo : (MultipleChoiceInfo -> MultipleChoiceInfo) -> Int -> Question -> Question
updateMultipleChoiceInfo updateFunction questionId =
  let
    updateChoiceInfo question =
      case question of
        MultipleChoice choiceInfo ->
          MultipleChoice <| updateFunction choiceInfo

        _ -> question
  in
    updateListItem (\q -> { q | questionType = updateChoiceInfo q.questionType }) questionId

updateListItem : ({ b | id : Int } -> { b | id : Int }) -> Int -> { b | id : Int } -> { b | id : Int }
updateListItem updateFunction id item =
  if item.id == id
  then updateFunction item
  else item
