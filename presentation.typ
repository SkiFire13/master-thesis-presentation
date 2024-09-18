#import "@preview/cetz:0.2.2": canvas, draw, vector
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge
#import "@preview/pinit:0.2.0": *
#import "@preview/polylux:0.3.1": *
#import "typst-slides-unipd/unipd.typ": *
#import "common.typ": *

#show: unipd-theme

#title-slide(
  title: [Solving Systems of Fixpoint Equations via Strategy Iteration],
  subtitle: [Master's degree in Computer Science],
  authors: [Candidate: Giacomo Stevanato \ Supervisor: Prof. Paolo Baldan],
  date: [September 20, 2024],
)

#new-section[The problem]
#slide[
  Formal verification of software is increasingly more important.

  // Example: sent message is eventually received
  - *Model checking* for behavioral logics like $mu$-calculus, to prove system properties;

  - *Abstract interpretation* to compute an approximation of the set of possible states in a program;

  - Checking *behavioral equivalences*, like bisimilarity;

  - ...

  Fixpoints are an essential ingredient in all of them.
]

#new-section[Systems of fixpoint equations]
#slide[
  #one-by-one(mode: "transparent")[
    $
      syseq(
        x_1 &feq_eta_1 &f_1 &(x_1, ..., x_n) \
        x_2 &feq_eta_2 &f_2 &(x_1, ..., x_n) \
            &#h(0.3em)dots.v \
        x_n &feq_eta_n &f_n &(x_1, ..., x_n) \
      )
    $
  ][

    - Defined over a complete lattice $L$

    - Monotone functions $f_i$
  ][

    - $eta_i in {mu, nu}$ and can be mixed
  ]
]

#new-section[$mu$-calculus]
#slide[
  - Labelled transition system $(bb(S), ->)$

  #align(center, diagram(
    node-stroke: 1pt,
    spacing: 4em,
    label-sep: 3pt,

    node((0, 0), "1", radius: 1em),
    node((1, 0), "2", radius: 1em),
    node((2, 0), "3", radius: 1em),

    edge((0, 0), (1, 0), "-|>", label: "y", bend: 30deg),
    edge((2, 0), (1, 0), "-|>", label: "y", bend: -30deg),

    edge((1, 0), (0, 0), "-|>", label: "a", bend: 30deg),
    edge((1, 0), (2, 0), "-|>", label: "b", bend: -30deg),
    
    edge((0, 0), (0, 0), "-|>", label: "a", bend: 130deg),
    edge((2, 0), (2, 0), "-|>", label: "b", bend: 130deg),
    edge((1, 0), (1, 0), "-|>", label: "x", bend: 130deg),
  ))
  
  - Modal logic equipped with fixpoint operators

  $
    phi, psi := p | x | phi or psi | phi and psi | underbrace(boxx(A) phi | diam(A) phi, "modal operators") | underbrace(eta x. phi, "fixpoint")
  $

  #align(right, text(font: "New Computer Modern", size: 19pt)[ \[De Bakker, Kozen\] ])
]

#slide[
  #one-by-one(mode: "transparent")[
    - System of fixpoint equations over $2^bb(S)$
  ][

    - $phi = nu x.#h(5pt) (mu y.#h(5pt) P or diam(A) y) and boxx(A) x #pin("phi")$
  ][
    #context pinit-point-from(
      pin-dy: 0pt,
      offset-dx: 90pt, offset-dy: -20pt,
      body-dy: -20pt,
      fill: text.fill,
      "phi", rect(inset: 0.5em, stroke: text.fill)[$Inv(Even(P))$]
    )
  ][
    $
      syseq(
        y &feq_mu P or diam(A) y \
        x &feq_nu y and boxx(A) x
      )
    $
  ][
    - *Solution*: all states satisfying the formulas

    - If the solution is $(S_y, S_x)$ then $s tack.r.double phi <=> s in S_x$
  ]
]

#new-section[Powerset game]
#slide[
  #place(bottom + right, text(font: "New Computer Modern", size: 19pt)[ \[Baldan, König, Mika-Michalski, Padoan\] ])
  #one-by-one(mode: "transparent")[
    - Given basis $B_L$, determine whether $b sub s_i$ for $b in B_L$
  ][
      #align(center, alternatives-fn(count: 8, i => {
        let color = k => if i < k { gray.lighten(50%) } else { black }

        let b_color = k => if i < k { gray.lighten(50%) } else { blue }

        let n0 = (n, p, c, k) => node(name: n, p, text(fill: color(k), c), radius: 1.5em, stroke: color(k))
        let n1 = (n, p, c, k) => node(name: n, p, text(fill: color(k), c), inset: 1em, stroke: color(k), shape: fletcher.shapes.rect)

        let e = (f, t, k) => edge(f, t, "-|>", stroke: color(k))

        diagram(
          node-stroke: 1pt,
          label-sep: 3pt,

          n0(<bi>, (0, 0), $[b, i]$, 2),
          n1(<X>, (1.2, -0.4), $tup(X)$, 3),
          n1(<Y>, (1.2, 0.4), $tup(Y)$, 3),
          n0(<cj>, (2.4, -0.4), $[c, j]$, 4),
          n0(<di>, (2.4, 0.4), $[d, i]$, 4),
          n1(<Z>, (3.4, 0.4), $tup(Z)$, 6),

          e(<bi>, <X>, 3),
          e(<bi>, <Y>, 3),
          e(<X>, <cj>, 4),
          e(<X>, <di>, 4),
          e(<Y>, <di>, 4),
          e(<di>, <Z>, 6),
          edge(<Z>, (3.4, 0.8), (0.5, 0.8), <bi>, "-|>", stroke: color(6)),

          node((0, 0.8), text(fill: color(2))[$b sub s_i$], inset: 11pt, stroke: color(2), shape: fletcher.shapes.pill),
          edge(<bi>, "..>", stroke: color(2)),

          node((0.3, -0.7), text(fill: color(3))[s.t. $b sub f_i (join X)$], inset: 11pt, stroke: color(3), shape: fletcher.shapes.pill),
          edge((0.5, -0.2), "..>", stroke: color(3)),

          node((1.6, -1.1), text(fill: color(3))[$tup(X) = (X_1, .., X_n)$], inset: 11pt, stroke: color(3), shape: fletcher.shapes.pill),
          edge(<X>, "..>", stroke: color(3)),

          node((2.8, -1.1), text(fill: color(4))[s.t. $c in X_j$], inset: 11pt, stroke: color(4), shape: fletcher.shapes.pill),
          edge((1.8, -0.42), "..>", stroke: color(4)),

          node((3.2, -0.4), text(fill: color(5), size: 19pt)[No successor: \ opponent wins], inset: 11pt, shape: fletcher.shapes.pill, stroke: color(5)),
          edge(<cj>, "..>", stroke: color(5)),

          node(name: <b0>, (0.4, 0.05), stroke: none),
          node(name: <b1>, (3.72, 0.05), stroke: none),
          node(name: <b2>, (3.72, 0.9), stroke: none),
          node(name: <b3>, (0.5, 0.9), stroke: none),
          node(name: <b4>, (-0.3, 0.2), stroke: none),
          node(name: <b5>, (-0.3, -0.325), stroke: none),
          node(name: <b6>, (0.13, -0.325), stroke: none),
          node(name: <b7>, (0.3, 0.05), stroke: none),

          edge(<b0>, <b1>, <b2>, <b3>, <b4>, <b5>, <b6>, <b7>, <b0>, "--", corner-radius: 20pt, stroke: if i < 7 { gray.lighten(100%) } else { blue }),

          ..(if i < 8 { () } else {
            let priority = (pos, pr) => node(pos, text(fill: blue, size: 19pt, pr), stroke: none)
            (
              priority((rel: (0, 0.18), to: <bi>), $2$),
              priority((rel: (0, 0.18), to: <cj>), $5$),
              priority((rel: (0, 0.18), to: <di>), $2$),
              priority((rel: (0, 0.18), to: <X>), $0$),
              priority((rel: (0, 0.18), to: <Y>), $0$),
              priority((rel: (0, 0.18), to: <Z>), $0$),
            )
          }),

          node((22em, -2.5em), text(fill: color(8), size: 19pt)[Highest recurring priority wins: \ even $->$ player 0, odd $->$ player 1], inset: 11pt, shape: fletcher.shapes.pill, stroke: color(8)),
          edge((0.7, 0.91), "..>", stroke: color(8)),
        )
      }))
  ]
]

#new-section[Selections and symbolic moves]
#slide[
  #one-by-one(mode: "transparent")[
    
    - Problem: player 0 has lot of moves
  ][

    - *Selections*: subset of moves equivalent to the full set
  ][

    - *Symbolic moves*:
      
      #one-by-one(mode: "transparent", start: 4)[

        - compact representation using logic formulas

          #text(size: 19pt, h(-20pt) + box($
            ({a, b}, {c}), ({a, b}, varempty), ({a}, {c}), ({b}, {c}), ({a}, varempty), ({b}, varempty), (varempty, {c}) \
            arrow.b.double \
            [a, 1] or [b, 1] or [c, 2]
          $))
      ][

        - generate a small selection

          #text(size: 19pt, box(width: 100%, inset: (right: 40pt), $
            ({a}, varempty), ({b}, varempty), (varempty, {c})
          $))
      ][

        - allows for simplifications
      ]
  ]
]

#new-section[Parity game algorithms]
#slide[
  #one-by-one(mode: "transparent")[
    
    - Two approaches:

      #one-by-one(mode: "transparent")[][

        - *Global* algorithms: solve for every position
      ][

        - *Local* algorithms: solve for some positions
      ]
  ][][][
    #v(1.3em)

    - Predecessor: LCSFE, based on a local algorithm by Stevens and Stirling
  ]
]

#new-section[Strategy iteration]
#slide[
  #one-by-one(mode: "transparent")[
  
    - Idea: *improve* strategy for player 0 until optimal
  ][
  
    - Criteria: *play profiles* $(w, P, e)$

      - $w$, the most relevant vertex of the cycle
      
      - $P$, the visited vertices more relevant than $w$
      
      - $e$, the number of vertices visited before $w$
  ][

    - Play profiles are *ordered*
  ][
    #v(1.3em)

    - Issue: global algorithm
  ]
]

#new-section[Local strategy iteration]
#slide[
  #v(2em)
  - *Local* algorithm

  #alternatives-fn(count: 4, i => [
    #let fill = k => if i >= k { black } else { gray.lighten(50%) }

    #context place(top + right, dx: 1em, dy: -5em, diagram(
      node-stroke: 1pt,
      label-sep: 3pt,

      node((0, 0), width: 10em, height: 8em, shape: fletcher.shapes.ellipse, stroke: fill(2)),
      node((-0.2, 0.2), radius: 2em, stroke: fill(2), fill: none),
      node((-0.25, 0.3), text(fill: fill(2), $s$), stroke: none),
      node((-0.31, 0.34), name: <p1>, radius: 2.5pt, fill: fill(2), stroke: none),
      node((-0.25, 0.05), name: <p2>, radius: 2.5pt, fill: fill(2), stroke: none),
      edge(<p1>, <p2>, "->", stroke: fill(2) + 1pt, bend: 30deg),

      node((-0.2, -0.15), name: <p3>, radius: 2.5pt, fill: if i >= 3 { black }, stroke: none),
      edge(<p2>, <p3>, "..>", stroke: if i >= 3 { (dash: "dashed") }, bend: 30deg),
      
      node((-0.17, 0.125), radius: 2.7em, stroke: if i >= 4 { (dash: "dashed") }, fill: none),
    ))

    #set text(fill: fill(2))

    - Find optimal strategy on a *subgame*

      - game on a subset of vertices

    #set text(fill: fill(3))

      - Check if one player can force winning plays in the subgame

    #set text(fill: fill(4))

      - Otherwise *expand* the subgame

        - according to an expansion strategy
  ])
]

#new-section[Adapting the algorithm]
#slide[
  - *Goal*: solve the powerset game using *local strategy iteration*

  - Challenges caused by the different assumptions

  - Some improvements
]

#slide(title: [#h(1em)Challenges])[
  - Prevent finite plays
  
  #v(1em)

  #let a = (0, 0)
  #let b = (1, 0)
  #let c = (1, 0.9)
  #let d = (0, 0.9)
  #let e = (2, 0.45)
  #let f = (3, 0)
  #let g = (3, 0.9)
  #let w = (s, n) => if s { n } else { fletcher.hide(n) }
  #let diag = s => diagram(
    node-stroke: 1pt,
    spacing: 4em,
    label-sep: 3pt,

    node(a, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node(b, "", radius: 0.7em),
    node(c, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node(d, "", radius: 0.7em),
    node(e, "", radius: 0.7em, shape: fletcher.shapes.rect),
    w(s, node(f, "", radius: 0.7em, stroke: blue)),
    w(s, node(g, "", radius: 0.7em, stroke: blue, shape: fletcher.shapes.rect)),

    edge(a, b, "-|>"),
    edge(b, c, "-|>"),
    edge(c, d, "-|>"),
    edge(d, a, "-|>"),
    edge(b, e, "-|>"),
    w(s, edge(e, f, "-|>", stroke: blue)),
    w(s, edge(f, g, "-|>", bend: 30deg, stroke: blue)),
    w(s, edge(g, f, "-|>", bend: 30deg, stroke: blue)),
  )
  
  #only(1)[#align(center, diag(false))]
  #only(2)[#align(center, diag(true))]
]

#slide(title: [#h(1em)Challenges])[
  - Generalizing subgames to subsets of *edges*
  
  #v(1em)

  #let a = (0, 0.5)
  #let b = (0.9, 0)
  #let c = (0.9, 1)
  #let d = (1.8, 0.5)
  #align(center, diagram(
    node-stroke: 1pt,
    spacing: 4em,
    label-sep: 3pt,

    node(a, "", radius: 0.7em),
    node(b, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node(c, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node(d, "", radius: 0.7em),

    edge(a, b, "-|>", bend: 20deg),
    edge(b, a, "-|>", bend: 20deg),
    edge(a, c, "-|>", bend: -20deg),
    edge(c, a, "-->", bend: -20deg, stroke: blue + 2.5pt),
    edge(d, b, "-->", bend: -20deg, stroke: blue + 2.5pt),
    edge(c, d, "-|>", bend: -20deg),
    edge(d, c, "-|>", bend: -20deg),

    edge(a, (-0.7, 0.7), "-->"),
    edge(a, (-0.7, 0.3), "-->"),
    edge(b, (0.2, -0.2), "-->"),
    edge(b, (1.6, -0.2), "-->"),
    edge(c, (0.2, 1.2), "-->"),
    edge(c, (1.6, 1.2), "-->"),
    edge(d, (2.5, 0.7), "-->"),
    edge(d, (2.5, 0.3), "-->"),
  ))
]

#slide(title: [#h(1em)Challenges])[
  - Making the symbolic moves generator *lazy*

  - *Simplification* while iterating moves

  #align(center, alternatives-fn(count: 3, i => {
    let fill = if i >= 2 { black } else { gray.lighten(50%) }
    let red_fill = if i >= 3 { red } else { black.lighten(100%) }
    set text(fill: fill)
    diagram(
      node-stroke: 1pt,
      spacing: 1.5em,
      label-sep: 3pt,

      node((0, 0), name: <or>, $or$, stroke: none),

      node((-3, 1), $phi_1$, stroke: none),
      edge(<or>, stroke: fill),
      node((-3, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle, stroke: fill),

      node((-0.9, 1), $phi_2$, stroke: none),
      edge(<or>, stroke: fill),
      node((-0.9, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle, stroke: fill),

      node((0.9, 1), $phi_3$, stroke: none),
      edge(<or>, stroke: fill),
      node((0.9, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle, stroke: fill),

      node((3, 1), $phi_4$, stroke: none),
      edge(<or>, stroke: fill),
      node((3, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle, stroke: fill),

      node((-1.45, 1.5), name: <tl>, stroke: none),
      node((-0.45, 1.5), name: <tr>, stroke: none),
      node((-1.45, 2.5), name: <bl>, stroke: none),
      node((-0.45, 2.5), name: <br>, stroke: none),

      edge(<tl>, <br>, stroke: red_fill + 2pt),
      edge(<tr>, <bl>, stroke: red_fill + 2pt),
    )
  }))
]

#slide(title: [#h(1em)Improvements])[
  - Computing *play profiles* when expanding vertices

  - *Expansion scheme* with upper bound on number of expansions

  - *Graph simplification* to remove vertices with determined winner
]

#new-section[Implementation]
#slide[
  - Final product: an implementation in *Rust*

    - Solver for the powerset game

    - Translation for $mu$-calculus, bisimilarity and parity games

  - Improves over the predecessor by an order of magnitude in some test cases

  #align(center, text(size: 19pt, table(
    columns: (auto,) * 5,
    align: horizon,
    inset: (x: 1em),
    stroke: none,
    table.header([\# trans.], [*mCRL2*], [*AUT generation*], [*Our solver*], [*LCSFE*]),
    table.hline(),
    [4], [67.8 ms], [54.7 ms], [132 #us], [65.5 #us],
    [66], [68.5 ms], [59.2 ms], [212 #us], [195 #us],
    [2268], [72.0 ms], [117 ms],  [2.30 ms], [4.38 ms],
    [183041], [1.47 s],  [2.05 s],  [202 ms],  [5.90 s],
  )))
]

#new-section[Future work]
#slide[
  - Other parity game algorithms

  - Translating other problems

  - Better expansion strategy

  - Alternative data structures for symbolic moves (BDDs)

  - Integrating abstractions techniques
]

#filled-slide[
  Thank you for your attention
]
