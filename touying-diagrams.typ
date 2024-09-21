#import "@preview/cetz:0.2.2"
#import "@preview/fletcher:0.5.1" as fletcher
#import "@preview/touying:0.3.1": touying-reducer

#let _canvas-reducer(..args) = cetz.canvas({
  cetz.draw.group(name: "inner", ..args)
  cetz.draw.on-layer(-99, cetz.draw.rect((rel: (-1pt, -1pt), to: "inner.south-west"), (rel: (1pt, 1pt), to: "inner.north-east"), fill: white.transparentize(10%), stroke: none))
})

#let _cetz-cover(object) = cetz.draw.on-layer(-100, object)

#let _diagram-reducer(..args) = text(fill: black, fletcher.diagram(
  ..args,
  render: (grid, nodes, edges, options) => {
    _canvas-reducer(fletcher.draw-diagram(grid, nodes, edges, debug: options.debug))
  }
))

#let _fletcher-cover(objects) = {
  if type(objects) == array { objects = objects.join() }
	let seq = objects + []
	seq.children.map(child => {
		if child.func() == metadata {
			let value = child.value
			value.post = _cetz-cover
			metadata(value)
		} else {
			child
		}
	}).join()
}

#let diagram = touying-reducer.with(reduce: _diagram-reducer, cover: _fletcher-cover)
