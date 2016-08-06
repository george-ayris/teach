module Views.Resources exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Color
import Messages exposing (..)
import Models exposing (..)
import Views.Styling exposing (..)
import Material
import Material.Button as Button
import Material.Icon as Icon

type alias Mdl =
  Material.Model

questionPlaceholder = "What do you want to ask?"
optionPlaceholder = "Option X"

removeButton : QuestionId -> Mdl -> Msg -> Html Msg
removeButton id mdl msg =
  iconButton (id ++ [0]) mdl msg "close"

upButton : QuestionId -> Mdl -> Msg -> Html Msg
upButton id mdl msg =
  iconButton (id ++ [1]) mdl msg "arrow_upward"

downButton : QuestionId -> Mdl -> Msg -> Html Msg
downButton id mdl msg =
  iconButton (id ++ [2]) mdl msg "arrow_downward"

addImageButton : QuestionId -> Mdl -> Msg -> Html Msg
addImageButton id mdl msg =
  iconButton (id ++ [3]) mdl msg "insert_photo"

iconButton : QuestionId -> Mdl -> Msg -> String -> Html Msg
iconButton id mdl msg icon =
  Button.render Mdl id mdl
    [ Button.icon
    , Button.ripple
    , Button.onClick msg
    ]
    [ Icon.i icon ]
