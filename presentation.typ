#import "@preview/fletcher:0.5.1" as fletcher: node, edge
#import "@preview/pinit:0.2.0": *
#import "@preview/touying:0.3.1": *
#import "typst-touying-unipd/unipd.typ": *
#import "common.typ": *
#import "touying-diagrams.typ": diagram

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
  $
    syseq(
      x_1 &feq_eta_1 &f_1 &(x_1, ..., x_n) \
      x_2 &feq_eta_2 &f_2 &(x_1, ..., x_n) \
          &#h(0.3em)dots.v \
      x_n &feq_eta_n &f_n &(x_1, ..., x_n) \
    )
  $

  #pause

  - Defined over a complete lattice $L$

  - Monotone functions $f_i$

  #pause

  - $eta_i in {mu, nu}$ and can be mixed
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

  #meanwhile

  #place(bottom + right, dx: 1em, text(font: "New Computer Modern", size: 19pt)[ \[De Bakker, Kozen\] ])
]

#slide[
  - System of fixpoint equations over $2^bb(S)$

  #pause

  - $phi = nu x.#h(5pt) (mu y.#h(5pt) P or diam(A) y) and boxx(A) x #pin("phi")$

  #pause

  #context pinit-point-from(
    pin-dy: 0pt,
    offset-dx: 90pt, offset-dy: -20pt,
    body-dy: -20pt,
    fill: text.fill,
    "phi", rect(inset: 0.5em, stroke: text.fill)[$Inv(Even(P))$]
  )

  #pause

  $
    syseq(
      y &feq_mu P or diam(A) y \
      x &feq_nu y and boxx(A) x
    )
  $

  #pause

  - *Solution*: all states satisfying the formulas

  - If the solution is $(S_y, S_x)$ then $s tack.r.double phi <=> s in S_x$
]

#new-section[Powerset game]
#slide[
  #v(2em)
  - Given basis $B_L$, determine whether $b sub s_i$ for $b in B_L$

  #pause

  #let n0 = (n, p, c) => node(name: n, p, c, radius: 1.5em)
  #let n1 = (n, p, c) => node(name: n, p, c, inset: 1em, shape: fletcher.shapes.rect)
  #let e = (f, t) => edge(f, t, "-|>")
  #let priority = (pos, pr) => node((rel: (0, 0.18), to: pos), text(fill: blue, size: 19pt, pr), stroke: none)
  #let note = (pos, c, to) => (node(pos, text(fill: blue, c), inset: 11pt, stroke: blue, shape: fletcher.shapes.pill), edge(to, "..>", stroke: blue))
  #align(center, diagram(
    node-stroke: 1pt,
    label-sep: 3pt,

    n0(<bi>, (0, 0), $[b, i]$),
    ..note((0, 0.8), $b sub s_i$, <bi>),

    pause,

    n1(<X>, (1.2, -0.4), $tup(X)$),
    n1(<Y>, (1.2, 0.4), $tup(Y)$),
    e(<bi>, <X>),
    e(<bi>, <Y>),
    ..note((0.3, -0.7), [s.t. $b sub f_i (join X)$], (0.5, -0.2)),
    ..note((1.6, -1.1), $tup(X) = (X_1, .., X_n)$, <X>),

    pause,

    n0(<cj>, (2.4, -0.4), $[c, j]$),
    n0(<di>, (2.4, 0.4), $[d, i]$),
    e(<X>, <cj>),
    e(<X>, <di>),
    e(<Y>, <di>),
    ..note((2.8, -1.1), [s.t. $c in X_j$], (1.8, -0.42)),

    pause,

    ..note((3.2, -0.4), text(size: 19pt)[No successor: \ opponent wins], <cj>),

    pause,

    n1(<Z>, (3.4, 0.4), $tup(Z)$),
    e(<di>, <Z>),
    edge(<Z>, (3.4, 0.8), (0.5, 0.8), <bi>, "-|>", corner-radius: 15pt),

    pause,

    node(name: <b0>, (1, 0.05), stroke: none),
    node(name: <b1>, (3.72, 0.05), stroke: none),
    node(name: <b2>, (3.72, 0.9), stroke: none),
    node(name: <b3>, (0.5, 0.9), stroke: none),
    node(name: <b4>, (-0.3, 0.2), stroke: none),
    node(name: <b5>, (-0.3, -0.325), stroke: none),
    node(name: <b6>, (0.13, -0.325), stroke: none),
    node(name: <b7>, (0.55, 0.05), stroke: none),

    edge(<b0>, <b1>, <b2>, <b3>, <b4>, <b5>, <b6>, <b7>, <b0>, "--", corner-radius: 20pt, stroke: blue),

    pause,

    priority(<bi>, $2$),
    priority(<cj>, $5$),
    priority(<di>, $2$),
    priority(<X>, $0$),
    priority(<Y>, $0$),
    priority(<Z>, $0$),
    ..note((22em, -2.5em), text(size: 19pt)[Highest recurring priority wins: \ even $->$ player 0, odd $->$ player 1], (0.7, 0.91)),
  ))

  #meanwhile

  #place(bottom + right, dx: 1em, text(font: "New Computer Modern", size: 19pt)[ \[Baldan, König, Mika-Michalski, Padoan\] ])
]

#slide[
  $
    X feq_mu {0} union X union {x + 2 | x in X}
  $

  #pause

  #let n0 = (n, p, c, ..args) => node(name: n, p, move(dy: -0.4em, c), radius: 1.3em, ..args)
  #let n1 = (n, p, c, ..args) => node(name: n, p, move(dy: -0.4em, c), width: 3em, height: 2.6em, shape: fletcher.shapes.rect, ..args)
  #let e = (f, t, ..args) => edge(f, t, "-|>", ..args)
  #let priority = (pos, pr) => node((rel: (0em, -1.5em), to: pos), text(fill: blue, size: 19pt, [#pr]), stroke: none)
  #align(center, diagram(
    node-stroke: 1pt,
    label-sep: 3pt,

    n0(<3>, (1, 0), $3$),
    priority(<3>, 1),

    pause,

    n1(<s1>, (2, 0), ${1}$),
    priority(<s1>, 0),
    e(<3>, <s1>, bend: 15deg),

    n1(<s3>, (2, 0.75), ${3}$),
    priority(<s3>, 0),
    e(<3>, <s3>, bend: 15deg),
    e(<s3>, <3>, bend: 15deg),

    node(name: <d3>, (1, 0.75), $...$, stroke: none),
    e(<3>, <d3>),

    pause,

    n0(<1>, (3, 0), $1$),
    priority(<1>, 1),
    e(<s1>, <1>, bend: 15deg),
    e(<1>, <s1>, bend: 15deg),

    pause,

    node(name: <d1>, (3, 0.75), $...$, stroke: none),
    e(<1>, <d1>),

    pause,

    n1(<s12>, (4, 0), ${1, 2}$),
    priority(<s12>, 0),
    e(<1>, <s12>, bend: 15deg),
    e(<s12>, <1>, bend: 15deg),
    
    pause,

    n0(<2>, (4, 1.5), $2$),
    priority(<2>, 1),
    e(<s12>, <2>, bend: 15deg),
    e(<2>, <s12>, bend: 15deg),

    pause,

    n1(<s0>, (3, 1.5), ${0}$),
    priority(<s0>, 0),
    e(<2>, <s0>, bend: -15deg),

    n1(<s2>, (3, 2.25), ${2}$),
    priority(<s2>, 0),
    e(<2>, <s2>, bend: 15deg),
    e(<s2>, <2>, bend: 15deg),

    node(name: <d2>, (4, 2.25), $...$, stroke: none),
    e(<2>, <d2>),

    pause,

    n0(<0>, (2, 1.5), $0$),
    priority(<0>, 1),
    e(<s0>, <0>, bend: -15deg),
    e(<0>, <s0>, bend: -15deg),

    node(name: <d0>, (2, 2.25), $...$, stroke: none),
    e(<0>, <d0>),

    pause,

    n1(<e>, (1, 1.5), $varempty$),
    priority(<e>, 0),
    e(<0>, <e>),
  ))
]

#new-section[Selections and symbolic moves]
#slide[
  - Problem: player 0 has lot of moves

  #pause

  - *Selections*: subset of moves equivalent to the full set

  #pause

  - *Symbolic moves*:

    #pause

    - compact representation using logic formulas

      #text(size: 19pt, h(-20pt) + box($
        ({a, b}, {c}), ({a, b}, varempty), ({a}, {c}), ({b}, {c}), ({a}, varempty), ({b}, varempty), (varempty, {c}) \
        arrow.b.double \
        [a, 1] or [b, 1] or [c, 2]
      $))

    #pause

    - generate a small selection

      #text(size: 19pt, box(width: 100%, inset: (right: 40pt), $
        ({a}, varempty), ({b}, varempty), (varempty, {c})
      $))

    #pause

    - allows for simplifications
]

#new-section[Parity game algorithms]
#slide[

  - Two approaches:

    #pause

    - *Global* algorithms: solve for every positions

    #pause

    - *Local* algorithms: solve for some positions

  #pause

  #v(1.3em)

  - Predecessor: LCSFE, based on a local algorithm by Stevens and Stirling
]

#new-section[Strategy iteration]

#slide[
  - *Strategy*: function from vertex to the move to perform

    - note: it assumes all vertices have at least one succ.

  #pause

  - A vertex is winning iff the player has a *winning strategy*
  
  #pause
  #v(1em)

  - Idea:

    - *Fix* a strategy $phi$ for player 0

    #pause

    - Compute an optimal strategy for player 1 *against* $phi$

    #pause

    - Improve $phi$ based on the induced plays

  #meanwhile

  #place(bottom + right, dx: 1em, text(font: "New Computer Modern", size: 19pt)[ \[Vöge, Jurdziński\] ])
]

#slide[
  - Criteria: *play profiles* $(w, P, e)$

    - $w$, the most relevant vertex of the cycle

    - $P$, the visited vertices more relevant than $w$

    - $e$, the number of vertices visited before $w$

  #pause

  - Ordered based on how much they favor to player 0

  #pause

  - Optimal strategy picks the succ. with the best play profile

  #pause
  #v(1.5em)

  - Issue: global algorithm

  #meanwhile

  #place(bottom + right, dx: 1em, text(font: "New Computer Modern", size: 19pt)[ \[Vöge, Jurdziński\] ])
]

#new-section[Local strategy iteration]
#slide[
  #v(2em)
  - *Local* algorithm

  #pause

  - Find optimal strategy on a *subgame*

    - game on a subset of vertices

  #pause

  - Check if one player can force winning plays in the subgame

  #pause

  - Otherwise *expand* the subgame

    - according to an expansion strategy

  #meanwhile

  #place(top + right, dx: 1em, dy: 2em, diagram(
    node-stroke: 1pt,
    label-sep: 3pt,

    pause,

    node((0, 0), width: 10em, height: 8em, shape: fletcher.shapes.ellipse),
    node((-0.2, 0.2), radius: 2em, fill: none),
    node((-0.25, 0.3), $s$, stroke: none),
    node((-0.31, 0.34), name: <p1>, radius: 2.5pt, fill: black, stroke: none),
    node((-0.25, 0.05), name: <p2>, radius: 2.5pt, fill: black, stroke: none),
    edge(<p1>, <p2>, "->", stroke: 1pt, bend: 30deg),

    pause,

    node((-0.2, -0.15), name: <p3>, radius: 2.5pt, fill: black, stroke: none),
    edge(<p2>, <p3>, "..>", stroke: (dash: "dashed"), bend: 30deg),

    pause,

    node((-0.17, 0.125), radius: 2.7em, stroke: (dash: "dashed"), fill: none),
  ))

  #meanwhile

  #place(bottom + right, dx: 1em, text(font: "New Computer Modern", size: 19pt)[ \[Friedmann, Lange\] ])
]

#new-section[Adapting the algorithm]
#slide[
  - *Goal*: solve the powerset game using *local strategy iteration*

  - Challenges caused by the different assumptions

  - Some improvements
]

#slide(title: [#h(1em)Challenges])[
  - Prevent finite plays (easy)

  #v(1em)

  #align(center, diagram(
    node-stroke: 1pt,
    spacing: 4em,
    label-sep: 3pt,

    node((0, 0), name: <a>, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node((1, 0), name: <b>, "", radius: 0.7em),
    node((1, 0.9), name: <c>, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node((0, 0.9), name: <d>, "", radius: 0.7em),
    node((2, 0.45), name: <e>, "", radius: 0.7em, shape: fletcher.shapes.rect),

    edge(<a>, <b>, "-|>"),
    edge(<b>, <c>, "-|>"),
    edge(<c>, <d>, "-|>"),
    edge(<d>, <a>, "-|>"),
    edge(<b>, <e>, "-|>"),

    pause,

    node((3, 0), name: <f>, "", radius: 0.7em, stroke: blue),
    node((3, 0.9), name: <g>, "", radius: 0.7em, stroke: blue, shape: fletcher.shapes.rect),

    edge(<e>, <f>, "-|>", stroke: blue),
    edge(<f>, <g>, "-|>", bend: 30deg, stroke: blue),
    edge(<g>, <f>, "-|>", bend: 30deg, stroke: blue),
  ))
]

#slide(title: [#h(1em)Challenges])[
  - Generalizing subgames to subsets of *edges*

  #v(1em)

  #align(center, diagram(
    node-stroke: 1pt,
    spacing: 4em,
    label-sep: 3pt,

    node((0, 0.5), name: <a>, "", radius: 0.7em),
    node((0.9, 0), name: <b>, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node((0.9, 1), name: <c>, "", radius: 0.7em, shape: fletcher.shapes.rect),
    node((1.8, 0.5), name: <d>, "", radius: 0.7em),

    edge(<a>, <b>, "-|>", bend: 20deg),
    edge(<b>, <a>, "-|>", bend: 20deg),
    edge(<a>, <c>, "-|>", bend: -20deg),
    edge(<c>, <a>, "-->", bend: -20deg, stroke: blue + 2.5pt),
    edge(<d>, <b>, "-->", bend: -20deg, stroke: blue + 2.5pt),
    edge(<c>, <d>, "-|>", bend: -20deg),
    edge(<d>, <c>, "-|>", bend: -20deg),

    edge(<a>, (-0.7, 0.7), "-->"),
    edge(<a>, (-0.7, 0.3), "-->"),
    edge(<b>, (0.2, -0.2), "-->"),
    edge(<b>, (1.6, -0.2), "-->"),
    edge(<c>, (0.2, 1.2), "-->"),
    edge(<c>, (1.6, 1.2), "-->"),
    edge(<d>, (2.5, 0.7), "-->"),
    edge(<d>, (2.5, 0.3), "-->"),
  ))
]

#slide(title: [#h(1em)Challenges])[
  - Making the symbolic moves generator *lazy*

  - *Simplification* while iterating moves

  #align(center, diagram(
    node-stroke: 1pt,
    spacing: 1.5em,
    label-sep: 3pt,

    pause,

    node((0, 0), name: <or>, $or$, stroke: none),

    node((-3, 1), $phi_1$, stroke: none),
    edge(<or>),
    node((-3, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle),

    node((-0.9, 1), $phi_2$, stroke: none),
    edge(<or>),
    node((-0.9, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle),

    node((0.9, 1), $phi_3$, stroke: none),
    edge(<or>),
    node((0.9, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle),

    node((3, 1), $phi_4$, stroke: none),
    edge(<or>),
    node((3, 2), width: 1.7em, height: 1.7em, shape: fletcher.shapes.triangle),

    pause,

    node((-1.45, 1.5), name: <tl>, stroke: none),
    node((-0.45, 1.5), name: <tr>, stroke: none),
    node((-1.45, 2.5), name: <bl>, stroke: none),
    node((-0.45, 2.5), name: <br>, stroke: none),

    edge(<tl>, <br>, stroke: red + 2pt),
    edge(<tr>, <bl>, stroke: red + 2pt),
  ))
]

#slide(title: [#h(1em)Improvements])[
  Compute *play profiles* when expanding vertices

  #pause

  - recomputing them for all vertices is relatively slow

  #pause

  - idea:

    - the strategy is fixed for all newly expanded vertices

    // TODO: Reword better
    - the path starting from newly expanded vertices is unique

    - thus compute the play profile for that play
]

#slide(title: [#h(1em)Improvements])[
  // TODO: Reword better
  *Expansion scheme* with upper bound on number of expansions

  #pause

  - we want to avoid expanding too many vertices too soon

  #pause

  - we want to avoid performing too many expansions

  #pause

  - heuristic for how many new vertices in each expansion

    - increase the number of new vertices exponentially

    - logarithmic bound on the number of expansions
]

#slide(title: [#h(1em)Improvements])[
  *Graph simplification* to remove vertices with determined winner

  // TODO: Drawing
]

#new-section[Implementation]
#slide[
  - Final product: an implementation in *Rust*

    - Solver for the powerset game

    - Translation for $mu$-calculus, bisimilarity and parity games

  - Improves over the predecessor by an order of magnitude in some test cases and is comparable to the state of the art

  #align(center, text(size: 19pt, table(
    columns: (auto,) * 5,
    align: horizon,
    inset: (x: 1em),
    stroke: none,
    table.header([*\# trans.*], [*mCRL2*], [*AUT generation*], [*Our solver*], [*LCSFE*]),
    table.hline(),
    [4], [67.8 ms], [54.7 ms], [132 #us], [65.5 #us],
    [66], [68.5 ms], [59.2 ms], [212 #us], [195 #us],
    [2268], [72.0 ms], [117 ms],  [2.30 ms], [4.38 ms],
    [183041], [1.47 s],  [2.05 s],  [202 ms],  [5.90 s],
  )))
]

#new-section[Future work]
#slide[
  - Other parity game algorithms (e.g. Parys's quasi-polynomial algorithm)

  - Translating other problems (e.g. quantitative $mu$-calculus)

  - Better expansion strategy

  - Alternative data structures for symbolic moves (BDDs)

  - Integrating abstractions techniques

    - up-to techniques

    - approximating infinite domains
]

#filled-slide[
  Thank you for your attention
]
