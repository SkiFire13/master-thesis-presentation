#let syseq(x) = math.lr(sym.brace.l + block(math.equation(x, block: true, numbering: none)))
#let feq = math.scripts("=")

#let mathstr(s) = s.clusters().map(s => $#s$).join()
#let tt = mathstr("true")
#let ff = mathstr("false")

#let boxx(f) = $class("unary", [ #f ])$
#let diam(f) = $class("unary", angle.l #f angle.r)$

#let tup(a) = math.bold(a)
#let varempty = text(font: "", sym.emptyset)
#let sub = math.class("relation", sym.subset.eq.sq)
#let join = math.class("vary", sym.union.sq)


