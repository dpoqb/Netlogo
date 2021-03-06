breed[people person]
;;risk-perception-bias-->RP (T): risk cognitive bias changes with time t, RP (T) belongs to [0,1],
;;[0,0.33] belongs to risk perception low
;;(0.33,0.67] belongs to non cognitive bias
;;(0.67,1] is risk perception high.
turtles-own[
  group
  fear-index
  risk-perception-bias
  person-information-authenticity
  person-public-influence
  temp-rpb
]

;;The credibility of the government belongs to the [0,1], and the greater the value of cr_g (T), the greater the influence of the government.
globals [
  last-patch-residual
  mouse-was-down?   ;;tracks the previous state of the mouse
  terror-event?     ;;tracks whether a terror event has occurred recently, true after a terror event until government intervention occur
  help-timer        ;;keeps track of time until government intervention occurs
<<<<<<< HEAD
  system-time
=======
>>>>>>> master
]

;;the patches can represent media ,the label of patches can describe terror event
patches-own [
  residual-fear               ;;residual fear from after terror events
  media-fear-index            ;;The media sends fear to other objects through information reporting
]

to setup
  clear-all
  set-default-shape people "circle"
  create-people people-population[
    set size 1
    setxy random-xcor random-ycor
    set fear-index random 100 + 1
    set risk-perception-bias precision (random-float 1.0) 2
    set person-information-authenticity precision (random-float 1.0) 2
    set person-public-influence precision (random-float 1.0) 2
    set group who mod groups
    update-color
  ]
  ask people [
    if people-network?
    [ let network n-of links-with-others other people with [group = [group] of myself]
      create-links-with network]
        display-labels
  ]
   ask patches [
    set residual-fear 0
    if show-residual-fear? = true
    [set plabel residual-fear]
  ]
  set mouse-was-down? false
  set terror-event? false
  set help-timer 0
  reset-ticks
end


to go
  terror-event
  ask people [
    ;;attention to risk-perception-bias
    if risk-perception-bias >= 0 and risk-perception-bias < 0.33 [
      set temp-rpb (precision (risk-perception-bias * 3) 2)
      ]
    if risk-perception-bias >= 0.33 and risk-perception-bias < 0.67 [
      set temp-rpb 1
      ]
    if risk-perception-bias >= 0.67 and risk-perception-bias <= 1 [
      set temp-rpb (precision (risk-perception-bias * 2) 2)
      ]
    let other-person-here one-of other people-here
    if other-person-here != nobody
    [ adjust-fear-index-between-people other-person-here ]
    if people-network? = true and ticks mod network-communication-frequency = 0 ;adjust fear-index based on every link neighboor
    [ foreach [self] of link-neighbors [ adjust-fear-index-between-people ? ] ]
    residual-fear-effect
    update-color
    move
    set last-patch-residual [residual-fear] of patch-here
    ]
  ask patches [
    ifelse show-residual-fear? = true
    [ set plabel residual-fear ]
    [ set plabel "" ]
       if residual-fear > 0
    [ set residual-fear (residual-fear - residual-decay-rate) ]
  ]
  if terror-event?[
    if media?[
    ;; a TV will appear once every MEDIA-FREQUENCY ticks
    if ticks mod (media-frequency / 2) = 0 [
      ask n-of media-numbers patches with [count turtles-here > 0] [
        media-trend
      ]
    ]
    ;; reset TV patches to black
    if ticks mod media-frequency = 0 [
      ask patches with [pcolor = yellow][
        set pcolor black
      ]
    ]
  ]
  ]
  ;;The government intervened at some time
  ifelse help-timer > 0
  [ set help-timer help-timer - 1 ]
  [
   if terror-event? = true
    [
<<<<<<< HEAD
      if ticks >= 20000 [ set terror-event? false ]
=======
      if ticks >= 1000 [ set terror-event? false ]
>>>>>>> master
      ;;The number of interventions is [0, people-population],
      ;; but the number of actual interventions is determined by resource utilization
      ask n-of round (numbers-of-intervation * resource-utilization-rate) people
      [
        let fear-change (fear-index - round((level-of-intervation * resource-utilization-rate * fear-index * government-credibility) / 10))
        ifelse fear-change < 0 [set fear-index 0]
        [set fear-index fear-change]
<<<<<<< HEAD
      ]
=======
        ]
>>>>>>> master
      ;;Indirectly intervene Internet users through media
      ask n-of round(guidance-effort * (4 * max-pxcor * max-pycor)) patches
      [
        let media-fear-change (media-fear-index - round((
            intervention-ability-to-media * guidance-effort * media-fear-index * government-credibility) / 10))
        ifelse media-fear-index < 0 [set media-fear-index 0]
        [set media-fear-index media-fear-change]
      ]
    ]
  ]
  tick
end

to terror-event
  if mouse-was-down? and not mouse-down?
  [
    set system-time ticks
    ask patch round mouse-xcor round mouse-ycor [
      ask people in-radius terror-range [
       let boundary fear-index + terror-severity < 100
       ifelse boundary
       [ set fear-index (fear-index + terror-severity) ]
       [ set fear-index 100 ]
       set last-patch-residual fear-index
      ]
      ask patches in-radius terror-range
      [ set residual-fear round (terror-severity * initial-residual-fear / 100) ]
    ]
    if terror-event? = false
    [set help-timer intervation-delay]
    set terror-event? true
    ask patches [
      ;;The seriousness of terrorist incidents and the authenticity of media information
      ;;can influence the fear index of media reports
          let medfin (media-information-authenticity * terror-severity) +
          ((-1)^(random 2) * (random 10))
          ifelse medfin > 0 [
           ifelse medfin > 100
           [ set media-fear-index 100 ]
           [ set media-fear-index medfin ]
          ]
          [ set media-fear-index 0 ]
      ]
  ]
  set mouse-was-down? mouse-down?
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Interaction between Internet users and Internet users;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to adjust-fear-index-between-people [other-turtle]
  if other-turtle != nobody
  [
    ;;fear-index of people interactive
    let difference-between-people round ([fear-index] of other-turtle - fear-index) * ([temp-rpb] of other-turtle *
      [person-information-authenticity] of other-turtle * [person-public-influence] of other-turtle) / 20
    let fear-change round (fear-index + difference-between-people)

    ;;risk-perception-bias of people interactive
    let difference-risk-perception-bias ((([temp-rpb] of other-turtle - temp-rpb) *
    [temp-rpb] of other-turtle * [person-information-authenticity] of other-turtle *
    [person-public-influence] of other-turtle) / 20)
    let rpb-change (precision (risk-perception-bias + difference-risk-perception-bias) 2)

    ;;person-information-authenticity interactive
    let difference-person-information-authenticity (([person-information-authenticity] of other-turtle -
      person-information-authenticity) * [temp-rpb] of other-turtle *
      [person-information-authenticity] of other-turtle * [person-public-influence] of other-turtle) / 20
    let pia-change (precision (person-information-authenticity + difference-person-information-authenticity) 2)

    ifelse terror-event? = false
    [
      ifelse fear-change < 0
      [ set fear-index 0 ]
      [
        ifelse fear-change > 100
        [ set fear-index 100 ]
        [ set fear-index fear-change ]
      ]
      ifelse rpb-change < 0
      [set risk-perception-bias 0]
      [
        ifelse rpb-change > 1
        [set risk-perception-bias 1]
        [set risk-perception-bias rpb-change]
        ]
      ifelse pia-change < 0
      [ set person-information-authenticity 0 ]
      [
        ifelse pia-change > 1
        [ set person-information-authenticity 1]
        [ set person-information-authenticity pia-change ]
        ]
    ]
    [
      if difference-between-people > 0
      [
        ifelse fear-change > 100
          [ set fear-index 100 ]
          [ set fear-index fear-change ]
      ]
      if difference-risk-perception-bias > 0
      [
        ifelse rpb-change > 1
        [ set risk-perception-bias 1 ]
        [ set risk-perception-bias rpb-change ]
      ]
      if difference-person-information-authenticity > 0
      [
        ifelse pia-change > 1
        [ set person-information-authenticity 1 ]
        [ set person-information-authenticity pia-change ]
      ]
    ]
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Internet users interact with the media;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to adjust-fear-index-between-media-people [watcher]
  if watcher != nobody
  [
<<<<<<< HEAD
    let difference-between-media-and-people round (media-fear-index - ([fear-index] of watcher) *
      media-information-authenticity * media-public-influence) / 20
    let difference-between-people-and-media round ([fear-index] of watcher - media-fear-index)
     * ([temp-rpb] of watcher * [person-information-authenticity] of watcher * [person-public-influence] of watcher) * 5
    let people-fear-change round ([fear-index] of watcher + difference-between-media-and-people)
    let media-fear-change  round (media-fear-index + difference-between-people-and-media)
    if terror-event? = true[
      ifelse people-fear-change < 0
      [ ask watcher [set fear-index 0 ]]
      [
        ifelse people-fear-change > 100
        [ ask watcher [set fear-index 100] ]
        [ ask watcher [set fear-index people-fear-change] ]
      ]
      ifelse media-fear-change < 0
      [set media-fear-index 0]
      [
        ifelse media-fear-change > 100
        [set media-fear-index 100]
        [set media-fear-index media-fear-change]
        ]
=======
    let difference-between-media-people round (media-fear-index - ([fear-index] of watcher) *
      media-information-authenticity * media-public-influence) / 20
    let fear-change (precision ([fear-index] of watcher + difference-between-media-people) 2)
    if terror-event? = true[
      ifelse fear-change < 0
      [ ask watcher [set fear-index 0 ]]
      [
        ifelse fear-change > 100
        [ ask watcher [set fear-index 100] ]
        [ ask watcher [set fear-index fear-change] ]
      ]
>>>>>>> master
      ]
  ]
end


;residual-fear-effect, a turtle procedure
;Increases the FEAR-INDEX by the current RESIDUAL-FEAR of the patch the turtle is on
to residual-fear-effect
  if [residual-fear] of patch-here != 0 and last-patch-residual = 0
  [
    let pdifference fear-index + [residual-fear] of patch-here
    ifelse pdifference > 100
    [ set fear-index 100 ]
    [ set fear-index pdifference ]
  ]
end

;move, a turtle procedure
;If there is a person ahead and a random number is less than the fear-index,
;then go towards them, otherwise turn randomly and then advance forward.
to move
  let person-ahead one-of people in-cone 2 120
  ifelse person-ahead != nobody and (random 100 + 1) < fear-index
  [ face person-ahead ]
  [ rt random 121 - 60 ]
  fd 1
end


;;Reflect the extent of people's fears by color
to update-color
  ifelse fear-index = 50
  [ set color white ]
  [
    ifelse fear-index > 50
    [ set color 18 - ((fear-index - 50) / 10) ]
    [ set color 108 - ((50 - fear-index) / 10) ]
  ]
  display-labels
end

to display-labels
  ask people[
  if show-fear-index? = true[
    set label fear-index
  ]
  ]
end

;; when media? is true, patches run this procedure, representing TV-watching.
;; assume that a turtle will accept a trend regardless of category with media exposure
to media-trend
<<<<<<< HEAD
  set pcolor yellow
  ;; the turtle watches TV
=======
  set pcolor yellow ;; the turtle watches TV
>>>>>>> master
  ;; the media will try to influence one of the turtles on the TV patch
  let watcher one-of turtles-here
  if watcher != nobody [
    ask watcher[
      adjust-fear-index-between-media-people watcher
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
361
25
795
480
20
20
10.3415
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
23
163
89
196
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
23
64
209
97
groups
groups
0
10
5
1
1
NIL
HORIZONTAL

SWITCH
212
65
357
98
people-network?
people-network?
0
1
-1000

SLIDER
212
26
358
59
links-with-others
links-with-others
0
10
2
1
1
NIL
HORIZONTAL

SLIDER
24
26
208
59
people-population
people-population
0
100
99
1
1
NIL
HORIZONTAL

TEXTBOX
148
10
298
42
network variables
12
0.0
1

SWITCH
24
228
189
261
show-residual-fear?
show-residual-fear?
0
1
-1000

SLIDER
24
267
169
300
terror-range
terror-range
0
10
<<<<<<< HEAD
5
=======
0
>>>>>>> master
1
1
NIL
HORIZONTAL

SLIDER
193
229
356
262
terror-severity
terror-severity
0
100
<<<<<<< HEAD
100
=======
0
>>>>>>> master
1
1
NIL
HORIZONTAL

SLIDER
172
267
356
300
initial-residual-fear
initial-residual-fear
0
100
100
1
1
%
HORIZONTAL

SLIDER
23
99
282
132
network-communication-frequency
network-communication-frequency
0
100
<<<<<<< HEAD
20
=======
50
>>>>>>> master
1
1
ticks
HORIZONTAL

BUTTON
90
163
153
196
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
24
339
206
372
residual-decay-rate
residual-decay-rate
0
100
<<<<<<< HEAD
2
=======
0
>>>>>>> master
1
1
/tick
HORIZONTAL

SWITCH
155
164
300
197
show-fear-index?
show-fear-index?
1
1
-1000

TEXTBOX
942
10
1092
28
people variables
12
0.0
1

PLOT
<<<<<<< HEAD
798
25
1185
201
=======
799
25
1184
200
>>>>>>> master
fear-index of people
people
fear-index
0.0
100.0
0.0
100.0
true
true
"set-plot-x-range 0 people-population\nset-plot-y-range 0 100\nset-histogram-num-bars people-population" "clear-plot\nlet the-data [(list who fear-index)] of turtles\nset-plot-pen-mode 1\nforeach the-data[\nplotxy first ? last ?\n]"
PENS
"default" 1.0 2 -16777216 false "" ""

PLOT
<<<<<<< HEAD
799
202
1186
374
=======
800
202
1185
372
>>>>>>> master
risk-perception-bias of people
people
risk-perception-bias
0.0
100.0
0.0
1.0
true
false
"set-plot-x-range 0 people-population\nset-plot-y-range 0 1.0\nset-histogram-num-bars people-population" "clear-plot\nlet the-data [(list who risk-perception-bias)] of turtles\nset-plot-pen-mode 1\nforeach the-data[\nplotxy first ? last ?\n]"
PENS
"default" 1.0 1 -16777216 true "" ""

TEXTBOX
130
208
280
226
terror-event variables
12
0.0
1

TEXTBOX
58
320
208
338
government variables
12
0.0
1

TEXTBOX
230
320
380
338
media variables\n
12
0.0
1

MONITOR
361
482
467
527
Slight fear(%)
count turtles with [fear-index >= 0 and fear-index < 20]
17
1
11

MONITOR
470
482
585
527
Moderate fear(%)
count turtles with [fear-index >= 20 and fear-index < 50]
17
1
11

MONITOR
588
482
690
527
Severe fear(%)
count turtles with [fear-index >= 50 and fear-index < 70]
17
1
11

MONITOR
693
482
794
527
Extreme fear(%)
count turtles with [fear-index >= 70 and fear-index <= 100]
17
1
11

PLOT
<<<<<<< HEAD
361
530
=======
362
529
>>>>>>> master
793
740
fear-sacle of people
ticks
different fear-scale numbers of people
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Slite fear" 1.0 0 -10899396 true "" "plot count turtles with [ fear-index >= 0 and fear-index < 20 ]"
"Moderate fear" 1.0 0 -13345367 true "" "plot count turtles with [ fear-index >= 20 and fear-index < 50 ]"
"Server fear" 1.0 0 -955883 true "" "plot count turtles with [ fear-index >= 50 and fear-index < 70 ]"
"Extreme fear" 1.0 0 -2674135 true "" "plot count turtles with [ fear-index >= 70 and fear-index <= 100 ]"

SWITCH
<<<<<<< HEAD
212
482
302
515
=======
211
483
301
516
>>>>>>> master
media?
media?
0
1
-1000

SLIDER
212
338
357
371
media-frequency
media-frequency
2
10
2
2
1
NIL
HORIZONTAL

SLIDER
24
374
206
407
government-credibility
government-credibility
0
1
<<<<<<< HEAD
1
=======
0
>>>>>>> master
0.01
1
NIL
HORIZONTAL

SLIDER
212
374
357
407
media-information-authenticity
media-information-authenticity
0
1.0
<<<<<<< HEAD
1
=======
0
>>>>>>> master
0.01
1
NIL
HORIZONTAL

SLIDER
212
411
356
444
media-public-influence
media-public-influence
0
1
<<<<<<< HEAD
1
=======
0
>>>>>>> master
0.01
1
NIL
HORIZONTAL

SLIDER
24
410
206
443
intervation-delay
intervation-delay
0
200
<<<<<<< HEAD
20
=======
0
>>>>>>> master
20
1
ticks
HORIZONTAL

SLIDER
24
446
207
479
numbers-of-intervation
numbers-of-intervation
0
people-population
<<<<<<< HEAD
10
=======
0
>>>>>>> master
1
1
people
HORIZONTAL

SLIDER
25
482
207
515
level-of-intervation
level-of-intervation
0
1.0
<<<<<<< HEAD
0.5
=======
0
>>>>>>> master
0.01
1
reduction
HORIZONTAL

SLIDER
25
553
208
586
guidance-effort
guidance-effort
0
1.00
0
0.01
1
NIL
HORIZONTAL

SLIDER
24
588
208
621
intervention-ability-to-media
intervention-ability-to-media
0
1.00
0
0.01
1
NIL
HORIZONTAL

SLIDER
25
518
207
551
resource-utilization-rate
resource-utilization-rate
0
1.00
<<<<<<< HEAD
0.1
0.01
=======
0
0.01
1
NIL
HORIZONTAL

PLOT
800
742
1187
926
average fear index
ticks
average fear index
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"media" 1.0 0 -16448764 true "" "plot mean [media-fear-index] of patches"
"people" 1.0 0 -2674135 true "" "plot mean [fear-index] of people"

SLIDER
211
446
356
479
media-numbers
media-numbers
0
10
0
1
>>>>>>> master
1
NIL
HORIZONTAL

PLOT
<<<<<<< HEAD
361
742
793
926
average fear index
ticks
average fear index
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"media" 1.0 0 -16448764 true "" "plot mean [media-fear-index] of patches"
"people" 1.0 0 -2674135 true "" "plot mean [fear-index] of people"

SLIDER
211
446
356
479
media-numbers
media-numbers
0
10
10
1
1
NIL
HORIZONTAL

PLOT
=======
>>>>>>> master
800
374
1186
556
person public influence
people
person-public-influence
0.0
100.0
0.0
1.0
true
false
"set-plot-x-range 0 people-population\nset-plot-y-range 0 1.00\nset-histogram-num-bars people-population" "clear-plot\nlet the-data [(list who person-public-influence)] of turtles\nset-plot-pen-mode 1\nforeach the-data[\nplotxy first ? last ?\n]"
PENS
<<<<<<< HEAD
"default" 1.0 1 -16777216 true "" ""

PLOT
801
744
1186
926
=======
"default" 1.0 0 -16777216 true "" ""

PLOT
800
558
1187
740
>>>>>>> master
different fear-index numbers of people
fear index
numbers of people
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [round fear-index] of turtles"

<<<<<<< HEAD
PLOT
800
559
1186
740
person-information-authenticity
people
person-information-authenticity
0.0
100.0
0.0
1.0
true
false
"set-plot-x-range 0 people-population\nset-plot-y-range 0 1.00\nset-histogram-num-bars people-population" "clear-plot\nlet the-data [(list who person-information-authenticity)] of turtles\nset-plot-pen-mode 1\nforeach the-data[\nplotxy first ? last ?\n]"
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
620
27
767
76
terror event start time
system-time
17
1
12

TEXTBOX
596
704
746
722
6220
12
0.0
1

=======
>>>>>>> master
@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [ fear-index &gt;= 0 and fear-index &lt; 20 ]</metric>
    <enumeratedValueSet variable="guidance-effort">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="resource-utilization-rate">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.5"/>
      <value value="0.6"/>
      <value value="0.7"/>
      <value value="0.8"/>
      <value value="0.9"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="terror-range">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intervention-ability-to-media">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media-frequency">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media-numbers">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-communication-frequency">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="links-with-others">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numbers-of-intervation">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="level-of-intervation">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media-public-influence">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="government-credibility">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="terror-severity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media-information-authenticity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intervation-delay">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-residual-fear">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people-network?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="groups">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="residual-decay-rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-fear-index?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people-population">
      <value value="99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-residual-fear?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
