module Views.Resources exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Color
import Messages exposing (..)
import Models exposing (..)
import Material
import Material.Button as Button
import Material.Options as Options
import Material.Icon as Icon
import Material.Dialog as Dialog
import Material.Options exposing (Property)


type alias Mdl =
    Material.Model


titlePlaceholder =
    "Your Worksheet Title"


questionPlaceholder =
    "Expand to edit..."


expandedQuestionPlaceholder =
    "What do you want to ask?"


optionPlaceholder =
    "Option X"


removeButton : QuestionId -> Mdl -> Msg -> Html Msg
removeButton id mdl msg =
    iconButton (id ++ [ 0 ]) mdl (Options.onClick msg) "close"


upButton : QuestionId -> Mdl -> Msg -> Html Msg
upButton id mdl msg =
    iconButton (id ++ [ 1 ]) mdl (Options.onClick msg) "arrow_upward"


downButton : QuestionId -> Mdl -> Msg -> Html Msg
downButton id mdl msg =
    iconButton (id ++ [ 2 ]) mdl (Options.onClick msg) "arrow_downward"


addImageButton : QuestionId -> Mdl -> Html Msg
addImageButton id mdl =
    iconButton (id ++ [ 3 ]) mdl (Dialog.openOn "click") "insert_photo"


closeDialogButton : QuestionId -> Mdl -> Html Msg
closeDialogButton id mdl =
    iconButton (id ++ [ 4 ]) mdl (Dialog.closeOn "click") "close"


questionIsCollapsed : QuestionId -> Mdl -> Msg -> Html Msg
questionIsCollapsed id mdl msg =
    iconButton (id ++ [ 5 ]) mdl (Options.onClick msg) "expand_more"


questionIsExpanded : QuestionId -> Mdl -> Msg -> Html Msg
questionIsExpanded id mdl msg =
    iconButton (id ++ [ 6 ]) mdl (Options.onClick msg) "expand_less"


iconButton : QuestionId -> Mdl -> Button.Property Msg -> String -> Html Msg
iconButton id mdl prop icon =
    Button.render Mdl
        id
        mdl
        [ Button.icon
        , Button.ripple
        , prop
        ]
        [ Icon.i icon ]
