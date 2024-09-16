#import "@preview/cetz:0.2.2": canvas, draw, vector
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge
#import "@preview/polylux:0.3.1": *
#import "typst-slides-unipd/unipd.typ": *
#import "common.typ": *

#show: unipd-theme

#title-slide(
  title: [Solving Systems of Fixpoint Equations via Strategy Iteration],
  subtitle: [Master degree in Computer Science],
  authors: [Candidate: Giacomo Stevanato \ Supervisor: Prof. Paolo Baldan],
  date: [September 20, 2024],
)

#new-section[The problem]
#slide[
  Formal verification of software is increasingly more important.

  - *Model checking* for logics like $mu$-calculus, to prove properties of labelled transition systems;

  - *Abstract interpretation* to compute an approximation of the set of possible states in a program;

  - Checking *behavioral equivalences*, like bisimilarity;

  - ...

  Fixpoints are present in all of them.
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
]

#slide[
  - System of fixpoint equations over $2^bb(S)$

  - $phi = nu x.#h(5pt) (mu y.#h(5pt) P or diam(A) y) and boxx(A) x = Inv(Even(P))$

    $
      syseq(
        y &feq_mu P or diam(A) y \
        x &feq_nu y and boxx(A) x
      )
    $

  - Solution: all states satisfying the formulas

  - If the solution is $(y, x)$ then $s tack.r.double phi <=> s in x$
]

#new-section[Game characterization]
#slide[
  - Given basis $B_L$, determine whether $b sub x_i$ for $b in B_L$

  - *Powerset Game*

    #table(
      columns: 3,
      inset: (x: 16pt, y: 10pt),
      stroke: none,
      table.header([Player], table.vline(), [Positions], table.vline(),[Moves]),
      table.hline(),
      [0], $[b, i]$, [$tup(X)$ s.t. $b sub f_i (join tup(X))$],
      [1], $tup(X) = (X_1, ..., X_n)$, [$[b, i]$ s.t. $b in X_i$]
    )

    // TODO: how to determine winner?
    // TODO: idea goes well with local approach
]

#slide[
  // TODO: Explain better what is this system?
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

  - *Symbolic moves*:
    
    - compact representation using logic formulas

    - generate a small selection

    - allows for simplifications
]

#new-section[Strategy iteration]
#slide[
  - Idea: improve strategy for player 0 until optimal

  - Criteria: *play profiles*, estimating how "good" a play is

    - $w$, the most relevant vertex of the cycle
    
    - $P$, the visited vertices more relevant than $w$
    
    - $e$, the number of vertices visited before $w$

  - Global algorithm
]

#new-section[Local strategy iteration]
#slide[
  - Local algorithm

  - Find optimal strategy on a *subgame*

    - subset of vertices

  - Check if one player can force winning plays in the subgame

  - Otherwise *expand* the game

    - according to an expansion strategy
]

#new-section[Adapting the algorithm]
#slide[
  - Goal: solve the powerset game using local strategy iteration

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
    w(s, node(f, "", radius: 0.7em)),
    w(s, node(g, "", radius: 0.7em, shape: fletcher.shapes.rect)),

    edge(a, b, "-|>"),
    edge(b, c, "-|>"),
    edge(c, d, "-|>"),
    edge(d, a, "-|>"),
    edge(b, e, "-|>"),
    w(s, edge(e, f, "-|>")),
    w(s, edge(f, g, "-|>", bend: 30deg)),
    w(s, edge(g, f, "-|>", bend: 30deg)),
  )
  
  #only(1)[#align(center, diag(false))]
  #only(2)[#align(center, diag(true))]
]

#slide(title: [#h(1em)Challenges])[
  - Generalizing subgames to subsets of edges
  
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
    edge(c, a, "-->", bend: -20deg),
    edge(d, b, "-->", bend: -20deg),
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
  - Making the symbolic moves generator lazy

  - Simplification while iterating moves

  $
    tup(X)_1, tup(X)_2, ..., overbrace(tup(X)_k, "current"), tup(X)_(k+1), ... tup(X)_m \
    arrow.b.double \
    tup(X)_2, tup(X)_5, ..., tup(X)_(k-1), underbrace(tup(X)_(k+1), "current"), ..., tup(X)_(m-1)
  $
]

#slide(title: [#h(1em)Improvements])[
  - Computing play profiles when expanding vertices

  - Expansion scheme with upper bound on number of iterations

  - Graph simplification to remove vertices with determined winner
]

#new-section[Implementation]
#slide[
  - Final product: an implementation in *Rust*

    - Solver for the powerset game

    - Translation for $mu$-calculus, bisimilarity and parity games

  - Improves over the predecessor by an order of magnitude in some test cases

  #align(center, table(
    columns: (auto,) * 3,
    align: horizon,
    inset: (x: 1em),
    stroke: none,
    table.header([$n$], [*Our solver*], [*LCSFE*]),
    table.hline(),
    [2], [132 #us], [65.5 #us],
    [3], [212 #us], [195 #us],
    [4], [2.30 ms], [4.38 ms],
    [5], [202 ms],  [5.90 s],
  ))
]

#new-section[Future work]
#slide[
  - Other parity game algorithms

  - Translate other problems

  - Better expansion strategy

  - Alternative data structures for symbolic moves (BDDs)

  - Integrate up-to techniques and abstractions
]

#filled-slide[
  Thank you for your attention
]
