import Html.App as App
import Utils
import Models exposing (Model, Question, QuestionType(..))
import Messages exposing (Msg(..))
import Views exposing (view)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \m -> Sub.none
    }

init : (Model, Cmd Msg)
init =
  (Model [] 0, Cmd.none)

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg ({questions, uid} as model) =
  case msg of
    QuestionAdded ->
      ({ model
        | questions = questions ++ [{ id = uid, questionType = ShortAnswer, title = "" }]
        , uid = uid + 1 }
      , Cmd.none)

    QuestionTitleUpdated id newTitle ->
      ({ model | questions = List.map (updateQuestionTitle newTitle id) questions }, Cmd.none)

    QuestionRemoved id ->
      ({ model | questions = List.filter (\q -> q.id /= id) questions }, Cmd.none)

    QuestionTypeChanged id newType ->
      ({ model | questions = List.map (updateQuestionType newType id) questions }, Cmd.none)

updateQuestionTitle : String -> Int -> Question -> Question
updateQuestionTitle newTitle id =
  updateQuestion (\q -> { q | title = newTitle }) id

updateQuestionType : QuestionType -> Int -> Question -> Question
updateQuestionType newType id =
  updateQuestion (\q -> { q | questionType = newType }) id

updateQuestion : (Question -> Question) -> Int -> Question -> Question
updateQuestion updateFunction id question =
  if question.id == id
  then updateFunction question
  else question
