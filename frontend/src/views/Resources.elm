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
  fontIconContainer msg <| FontAwesome.close Color.red 18

upButton : Msg -> Html Msg
upButton msg =
  fontIconContainer msg <| FontAwesome.arrow_up Color.black 18

downButton : Msg -> Html Msg
downButton msg =
  fontIconContainer msg <| FontAwesome.arrow_down Color.black 18

addImageButton : Msg -> Html Msg
addImageButton msg =
  fontIconContainer msg <| FontAwesome.picture_o Color.black 18

fontIconContainer : Msg -> Html Msg -> Html Msg
fontIconContainer msg icon =
  span [ style svgContainer, onClick <| msg ] [ icon ]
