module Utils exposing (createCmd)

import Task

createCmd : a -> Cmd a
createCmd msg =
  Task.perform identity identity (Task.succeed msg)
