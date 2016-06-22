module Views.Resources exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Color
import FontAwesome
import Messages exposing (..)
import Views.Styling exposing (..)

questionPlaceholder = "What do you want to ask?"
optionPlaceholder = "Option X"

removeButton : Msg -> Html Msg
removeButton msg =
  span [ style svgContainer, onClick <| msg ] [ FontAwesome.close Color.red 18 ]
