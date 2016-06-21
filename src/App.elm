import Html.App as App
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Utils
import Models exposing (Model)
import Messages exposing (Msg)

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
        | questions = questions ++ [{ id = uid, type' = ShortAnswer, title = "" }]
        , uid = uid + 1 }
      , Cmd.none)

    QuestionTitleUpdated id newTitle ->
      ({ model | questions = List.map (updateQuestionTitle id newTitle) questions }, Cmd.none)

updateQuestionTitle : Int -> String -> Question -> Question
updateQuestionTitle id newTitle question =
  if question.id == id
  then { question | title = newTitle }
  else question

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text "Form Builder" ]
    , div [] (List.map renderQuestion model.questions)
    , button [ onClick QuestionAdded ] [ text "Add Question" ]
    ]

renderQuestion : Question -> Html Msg
renderQuestion q =
  div []
    [ input [ type' "text", placeholder "What do you want to ask?", onInput (QuestionTitleUpdated q.id) ] [ text q.title ]
    , span [] [ text (questionType q.type') ]
    ]

questionType : QuestionType -> String
questionType type' =
  case type' of
    ShortAnswer ->
      "A short answer question"
