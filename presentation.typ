#import "@preview/cetz:0.2.2": canvas, draw, vector
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge
#import "@preview/polylux:0.3.1": *
#import "typst-slides-unipd/unipd.typ": *
#import "common.typ": *

#show: unipd-theme

#title-slide(
  title: [Solving Systems of Fixpoint Equations via Strategy Iteration],
  authors: [Candidate: Giacomo Stevanato \ Supervisor: Prof. Paolo Baldan],
  date: [September 20, 2024],
)

#new-section[The problem]
#slide[
  Formal verification of software is increasingly more important.

  - *Model checking* for logics like $mu$-calculus, to prove properties of labelled transition systems;

  - *Abstract interpretation* to compute an approximation of the set of possible values in a program;

  - *Behavioral equivalences*, like bisimilarity;

  - ...

  All depend on fixpoints in some way.
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

  - Defined over a complete lattice $L$

  - Monotone functions $f_i$

  - $eta_i in {mu, nu}$ and can be mixed
]

#new-section[$mu$-calculus]
#slide[
  - Labelled transition system

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
]

// #slide[
//   TODO: $mu$-calculus example
// ]

#slide[
  - System of fixpoint equations over $2^bb(S)$

  // TODO: Rework example
  - Example: $phi = nu x.#h(5pt) mu y.#h(5pt) (P and diam(A) x) or diam(A) y$

    $
      syseq(
        y &feq_mu (P and diam(A) x) or diam(A) y \
        x &feq_nu y
      )
    $

  - If the solution is $(s_1, s_2)$ then $s tack.r.double phi <=> s in s_2$
]

#new-section[Game characterization]
#slide[
  - Given basis $B_L$, determine whether $b sub s_i$ for $b in B_L$

  - Can be done with a *Parity Game*, the *Powerset Game*

    #table(
      columns: 3,
      inset: (x: 16pt, y: 10pt),
      stroke: none,
      table.header([Player], table.vline(), [Positions], table.vline(),[Moves]),
      table.hline(),
      [0], $[b, i]$, [$tup(X)$ s.t. $b sub f_i (join tup(X))$],
      [1], $tup(X) = (X_1, ..., X_n)$, [$[b, i]$ s.t. $b in X_i$]
    )

    // Note: how to determine winner?
    // Note: idea goes well with local approach
]

#slide[
  $
    syseq(
      x_1 &feq_mu x_1 or x_2 \
      x_2 &feq_nu x_1 and x_2 \ 
    )
  $

  #v(1em)

  #align(center, canvas({
    import draw: *

    set-style(content: (padding: .2), stroke: black)

    let node(pos, name, p, label, pr) = {
      let cname = name + "content"
      content(pos, label, name: cname, padding: 0.6em)
      if p == 0 {
        circle(pos, name: name, radius: (2, 1), stroke: black)
        content((v => vector.add(v, (0, .15)), cname + ".south"), text(size: 18pt, str(pr)))
      } else {
        let (x, y) = pos
        rect(cname + ".north-west", cname + ".south-east", name: name, radius: 0.05)
        content((v => vector.add(v, (-.3, .3)), cname + ".south-east"), text(size: 18pt, str(pr)))
      }
    }

    node((6.5, 0), "t1", 0, $[tt, 1]$, 1)
    node((6.5, -3), "t2", 0, $[tt, 2]$, 2)
    
    node((0, 0), "tt_e", 1, $({tt}, varempty)$, 0)
    node((0, -3), "e_tt", 1, $(varempty, {tt})$, 0)
    node((13.5, -1.5), "tt_tt", 1, $({tt}, {tt})$, 0)

    let edge(ni, ai, nf, af, a, w) = {
      let pi = (name: ni, anchor: ai)
      let pf = (name: nf, anchor: af)
      let c = if true and not w { (dash: "dotted") } else { black }
      bezier(pi, pf, (pi, 50%, a, pf), fill: none, stroke: c, mark: (end: ">"))
    }

    edge("t1", 160deg, "tt_e", 20deg, -20deg, false)
    edge("t1", 240deg, "e_tt", 20deg, 20deg, true)
    edge("t1", 20deg, "tt_tt", 130deg, 20deg, false)

    edge("t2", -20deg, "tt_tt", -130deg, -20deg, true)

    edge("tt_e", -20deg, "t1", 200deg, -20deg, false)
    edge("e_tt", -20deg, "t2", 200deg, -20deg, false)
    edge("tt_tt", 160deg, "t1", -20deg, 20deg, false)
    edge("tt_tt", 200deg, "t2", 20deg, -20deg, false)
  }))
]

#new-section[Selections and symbolic moves]
#slide[
  - Problem: player 0 has lot of moves

  - *Selections*: subset of moves equivalent to the full set

  - *Symbolic moves*: represent moves using logic formulas
    
    - compact representation

    - allows for simplifications
]

#new-section[Strategy iteration]
#slide[
  - Global algorithm

  - Idea: improve strategy for player 0 until optimal

  - Criteria: *play profiles*

    - observation of how "good" a play is

    - computation can be expensive

  // TODO: Example in two steps?
]

#new-section[Local strategy iteration]
#slide[
  - Local algorithm

  #v(1em)

  - Find optimal strategy on a *subgame*

  - Check if one player can force winning plays in the subgame

  - Otherwise *expand* the game
]

#new-section[Adapting the algorithm]
#slide[
  - Goal: solve the powerset game using local strategy iteration

  - Challenges derived by the different assumptions

    - Preventing finite plays

    - Generalizing subgames to subsets of edges

    - Making the symbolic moves generator lazy

      - Simplification while iterating moves

  - Improvement: computing play profiles when expanding vertices
]

#new-section[Implementation]
#slide[
  - Final product: an implementation in *Rust*

    - Solver for the powerset game

    - Translation for $mu$-calculus, bisimilarity and parity games

  - Supports extensions for other instances of systems of fixpoint equations

  - Improves over the predecessor by an order of magnitude in some test cases
]

#new-section[Conclusions]
#slide[
  
]
