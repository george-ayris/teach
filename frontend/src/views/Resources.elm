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
import Material.Dialog as Dialog
import Material.Options exposing (Property)

type alias Mdl =
  Material.Model

titlePlaceholder = "Your worksheet title"
questionPlaceholder = "What do you want to ask?"
optionPlaceholder = "Option X"

removeButton : QuestionId -> Mdl -> Msg -> Html Msg
removeButton id mdl msg =
  iconButton (id ++ [0]) mdl (Button.onClick msg) "close"

upButton : QuestionId -> Mdl -> Msg -> Html Msg
upButton id mdl msg =
  iconButton (id ++ [1]) mdl (Button.onClick msg) "arrow_upward"

downButton : QuestionId -> Mdl -> Msg -> Html Msg
downButton id mdl msg =
  iconButton (id ++ [2]) mdl (Button.onClick msg) "arrow_downward"

addImageButton : QuestionId -> Mdl -> Html Msg
addImageButton id mdl =
  iconButton (id ++ [3]) mdl (Dialog.openOn "click") "insert_photo"

closeDialogButton : QuestionId -> Mdl -> Html Msg
closeDialogButton id mdl =
  iconButton (id ++ [4]) mdl (Dialog.closeOn "click") "close"

iconButton : QuestionId -> Mdl -> Property { disabled : Bool, onClick : Maybe (Attribute Msg), ripple : Bool } Msg -> String -> Html Msg
iconButton id mdl prop icon =
  Button.render Mdl id mdl
    [ Button.icon
    , Button.ripple
    , prop
    ]
    [ Icon.i icon ]
