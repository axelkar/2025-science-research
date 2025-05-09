#set page(height: auto, width: 9cm, margin: 0.5cm)

#let colMath(x, color) = text(fill: color)[$#x$]
#let a = colMath("a", red)
#let b = colMath("b", blue)
#let c = colMath("c", green)
#let d = colMath("d", orange)

$
#a / #b &= #c / #d || : #c / #d \
#a / #b : #c / #d &= 1 \
#a / #b dot #d / #c &= 1 \
(#a #d) / (#b #c) &= 1 || dot #b #c \
#a #d &= #b #c || dot #b #c \
$
eli
$
#a / #b &= #c / #d \
#a #d &= #b #c
$
