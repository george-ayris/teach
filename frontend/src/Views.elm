module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (..)
import Messages exposing (Msg(..), UpdateType(..))
import Views.Styling exposing (..)
import Views.WorksheetOutput exposing (renderWorksheetOutput)
import Views.WorksheetControls exposing (renderWorksheetControls)

view : Model -> Html Msg
view model =
  div [ style mainContainer ]
    [ div [ style columnSpacer ] []
    , div [ style mainPanel ] [ renderWorksheetControls model ]
    , div [ style columnSpacer ] []
    , div [ style mainPanel ] [ renderWorksheetOutput model ]
    , div [ style columnSpacer ] []
    ]
