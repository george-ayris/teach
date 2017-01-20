module Main exposing (..)

import ElmTest exposing (..)
import UpdateTest


tests : Test
tests =
    UpdateTest.tests


main : Program Never
main =
    runSuite tests
