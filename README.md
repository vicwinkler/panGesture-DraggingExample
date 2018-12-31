# panGesture-DraggingExample
# Created by Vic W. on 12/20/18.

# This is a demonstration of panGestureRecognizer to "drag" a UIView.
# When the user touches a source color swatch (at the bottom) and starts
# the panGesture, the "dragView" becomes visible and is set to the source
# color. Once the dragView is within a "destination view", the destination
# is set to the dragView color. Then:
#   --If the user ends the drag within that destination, the color stays set.
#   --If the user moves the dragView back out of the destination, the
#     destination is "reset" to it's previous color.
