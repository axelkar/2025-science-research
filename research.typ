#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "datetime.typ": format_unix_to_time, parse_datetime_to_unix

#import "@preview/touying:0.6.1": *
#import themes.university: *

#let process_data(filename) = {
  let raw = csv(filename);
  let header_line = raw.remove(0)
  let data = raw.map(((ts, val)) => {
    (parse_datetime_to_unix(ts), float(val))
  })

  (
    header_line: header_line,
    data: data,
    measurements_only: data.map(((ts, val)) => { val }),
    timestamps_only: data.map(((ts, val)) => { ts }),
  )
}

/*#set page(header: [
  _Axel Karjalainen_
  #h(1fr)
  #link("https://axka.fi")
], numbering: "1/1")

#set heading(numbering: "1.")*/

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Enthalpy of fusion for water],
    subtitle: [Science elective research project],
    author: [Axel Karjalainen],
    date: "2025-05",
  ),
  //config-common(show-notes-on-second-screen: right),
)

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#speaker-note[
  Eh water $approx$ ice

  Enthaply of fusion is also known as the latent heat of fusion
]

#title-slide()

#speaker-note[
  COOL (pun intended) experiment
]

== Introduction

Researchable question: How much energy is required to melt water/ice without changing its temperature? In other words, what is the enthalpy of fusion for water?

Hypothesis: The enthalpy of fusion is nonzero and proportional to the amount of water/ice.

#speaker-note[
  Research plan
]

#pagebreak()

Variables which can be controlled:
- Mass of ice ($m$ in grams)

Responding variables:
- Temperature of the ice/water ($T$ in celsius (C))
- Time when the ice melts ($t$ in seconds)

Background influences:
- Ambient temperature

#speaker-note[
  Kelvin can be substituted with celsius, since we're only using differences. More on the next slides.
]

== Necessary materials

- Calorimeter (basically a cup insulated with styrofoam)
- 100ml of water
- Digital thermometer connected to computer

#speaker-note[
  The calorimeter's function is based on the change in temperature caused by the release of heat.
]

== Procedure

1. Measure ambient temperature.
2. Prepare the calorimeter with the thermometer and 100ml of water inside.
3. Start measuring the temperature at an interval.
4. Put the calorimeter in a freezer.
5. Wait until the temperature is nearly 0°C.
6. Wait until the temperature is at 0°C / the curve flattens.
7. Wait until the temperature starts to rise / the curve rises.
8. Graph the results.

#pagebreak()
=== Estimating the thermal conductance of the calorimeter

9. Calculate the thermal conductance in the unit W/K using the following formula:
  1. Pick two points on the curve after melting (Remember $Delta T$ (in °C) and $Delta t$ (in seconds))
  2. Assume $m = 100" g", c=4.181" J/g"*"K"$ @wiki:Table_of_specific_heat_capacities

#speaker-note[
  Thermal conductance is not to be confused with thermal conductivity!

  I measured the mass so this is not just a broad assumption.
]

#pagebreak()

3. Approximate the heat energy transferred using the Rienmann sum.
   $ Q_"melting" = integral accent(Q, dot) dif t  = integral_(t_1)^(t_2) G dot (T_"ambient" - T(t)) dif t $
   $ Q_"melting" approx sum_i G dot (T_"ambient" - T_i) dot Delta t_i $

#speaker-note[
  $accent(Q, dot)$ means power and is similar to $P$ but more precise.

  I made a Python script for this.

  Using integrals is more precise than simply using a short window for $Delta t$.
]

#pagebreak()
5. Estimate average thermal conductance $accent(G, macron)$ using integral: $ accent(G, macron) approx 1/N sum_(i=0)^N (m c dot (Delta T_i)/(Delta t_i))/(T_"ambient" - T_i) $

6. Get the latent heat of fusion: $ L_f = Q / m $

= 1st attempt

#speaker-note[
  In a moment you'll understand why this wasn't the only experiment.
]

== Log

- 15:53 21.3. Weight of cup 32g
- 20:59 21.3. Weight of cup + water 66g
- 21:07 21.3. In the freezer
- 22:33 21.3. Lämpömittarin ensimmäinen mittaus, -0.5°C.
- 22:47 21.3. Folio päälle
- 22:49 21.3. Luulen, että vettä (eli lämpökapasiteettia) ei ole riittävästi. Mittari vaihdettu mittaamaan 1min välein. Ehkä ensi kerralla siirrän jään ja lämpömittarin valmiiksi pakastettuun termokseen, ja en ota lämpömittaria missään kohtaa pois jäästä.

#speaker-note[
  Here's the log I wrote when performing the experiment.
]

== Data

#let processed_1st = process_data("measurements-1st-attempt.csv")

#let max_timestamp = calc.max(..processed_1st.timestamps_only)
#let max_timestamp_measurement = processed_1st.data.find(((ts, _)) => ts == max_timestamp).at(1)

#{
  let min_measurement = calc.min(..processed_1st.measurements_only)
  let max_measurement = calc.max(..processed_1st.measurements_only)
  let min_timestamp = calc.min(..processed_1st.timestamps_only)

  let plateau_end_timestamp = parse_datetime_to_unix("2025-03-22 01:40:08.0")

  slide(self => [
    #let (only, uncover) = utils.methods(self)
    #cetz-canvas({
      import cetz.draw: *

      plot.plot(size: (24, 12),
        legend: "inner-north-east",
        x-tick-step: 2 * 60 * 60, // Add ticks for every 2 hours
        x-format: format_unix_to_time,
        x-label: "Time (s)",
        y-label: "Temperature (°C)",
        {
          plot.add(processed_1st.data)

          only("2", plot.annotate({
            rect(
              (min_timestamp, min_measurement),
              (plateau_end_timestamp, max_measurement),
              fill: rgb(50,50,200,50),
              stroke: none
            )
          }))
        })
      (pause,)
    })

    #speaker-note[
      1. Graph of the data from the 1st attempt
      2. Measurement started after taking the experiment out of the freezer.
         The ice has already warmed up to the melting point.

         The relatively flat line tells us that heat energy is used to change the state without changing the temperature.

         The issue and the reason for another attempt: We aren't getting the full picture.
      #max_timestamp_measurement
    ]
  ])
}

= 2nd attempt

== Log

- 18:03 22.3. Weight of cup 32g
- 18:04 22.3. Weight of water 100g (cup+water = 132g)
- 18:15 22.3. Sample + thermometer is in the freezer, which is set to -18°C
- 18:19 22.3. Temperature in the thermometer 13.1°C
- 18:46 22.3. Hit under 0°C for the first time
- 21:29 22.3. Around -0.84°C
- 00:30 23.3. Taken out of the freezer
- 00:32 23.3. Temperature sharply rising
//, measurement interval set to 10s and foil added to slow down rate of heat transfer
//- 00:46 23.3. Measurement interval set to 30s
//- 10:29 23.3. Measurement interval set to 1min
//- 17:04 23.3. Ambient temperature is around 19.9°C

#speaker-note[
  Here's the log I wrote when performing the experiment.
]

== Data

#let processed_2nd = process_data("measurements-2nd-attempt.csv")
#let curve_begin_timestamp = parse_datetime_to_unix("2025-03-23 11:50:08.0")
#let curve_begin_index = processed_2nd.timestamps_only.position(ts => ts >= curve_begin_timestamp)

#{
  let min_measurement = calc.min(..processed_2nd.measurements_only)
  let max_measurement = calc.max(..processed_2nd.measurements_only)
  let max_timestamp = calc.max(..processed_2nd.timestamps_only)

  let rise_begin_timestamp = parse_datetime_to_unix("2025-03-23 00:30:08.0")
  let rise_end_timestamp = parse_datetime_to_unix("2025-03-23 01:15:08.0")

  let plateau_begin_timestamp = parse_datetime_to_unix("2025-03-23 01:15:08.0")
  let plateau_end_timestamp = parse_datetime_to_unix("2025-03-23 10:00:08.0")

  slide(self => [
    #let (only, uncover) = utils.methods(self)
    #cetz-canvas({
      import cetz.draw: *

      plot.plot(size: (21, 12),
        legend: "inner-north-east",
        x-tick-step: 2.5 * 60 * 60, // Add ticks for every 2.5 hours
        x-format: format_unix_to_time,
        x-label: "Time (s)",
        y-label: "Temperature (°C)",
        y2-label: "Temperature difference (°C/s)",
        {
          plot.add(processed_2nd.data, label: [Temp vs time])
          plot.add(processed_2nd.data.enumerate().map(((i, (ts, measurement))) => {
            let row_after = processed_2nd.data.at(i + 1, default: none)
            if row_after == none { return none }
            (ts, (row_after.at(1) - measurement) / (row_after.at(0) - ts))
          }).filter((point) => point != none), label: [$(Delta T) \/ (Delta t)$], axes: ("x", "y2"))

          only("2", plot.annotate({
            rect(
              (rise_begin_timestamp, min_measurement),
              (rise_end_timestamp, max_measurement),
              fill: rgb(50,50,200,50),
              stroke: none
            )
          }))

          only("3", plot.annotate({
            rect(
              (plateau_begin_timestamp, min_measurement),
              (plateau_end_timestamp, max_measurement),
              fill: rgb(50,50,200,50),
              stroke: none
            )
          }))

          only("4", {
            plot.annotate({
              rect(
                (curve_begin_timestamp, min_measurement),
                (max_timestamp, max_measurement),
                fill: rgb(50,50,200,50),
                stroke: none
              )
            })
          })
        })
        ((pause,) * 3)
    })

    #speaker-note[
      1. Graph of the data from the 2nd attempt
      2. Taken out of the freezer. The ice warms up to the melting point.
      3. Flat line. Notice anything? This is when energy is used to change the state without changing the temperature. *This is where the melting enthalpy is used*

         Part where I estimated the energy using the Rienmann sum.
      4. Part where I estimated G using the Rienmann sum.
    ]
  ])
}

== Results

The melting enthalpy for water is commonly known to be 333.55 J/g.
// kalorimetriin mahtuu 195 g / hieman alle 200ml

By computing the formulas written in the Procedure section, I calculated the results to be such:

Estimated thermal conductance G: 0.00010700892360287527 W/K

Total heat transferred during melting: 34721.48035185887 J

Latent heat of fusion: 347.21480351858867 J/g

#speaker-note[
  Ambient temperature taken from last measurement of 1st attempt.
]

$
T_"ambient" = 20.96 "C"
$

== Usage

Phase change materials (PCMs) utilize the melting enthalpy to store thermal energy. @pcms

The melting enthalpy in finely divided water with silica is much lower (between 130 J/g and 180 J/g), and also happens at a lower temperature (between -3 C and -45 C). @fdw

== Bibliography

#bibliography("sources.bib", style: "american-physics-society", title: none)
