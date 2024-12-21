#import "@preview/i-figured:0.2.4"

// chp => chapter
// fig => figure
// spc => spacing
// mjr => major

#let prof_indent = state("ut_prof_indent", 1cm)
#let otln_new_chp_spc = state("ut_otln_new_chp_spc", 1em)

#let otln_chp_primary_spc = state("ut_otln_chp_primary_spc", 6em)
#let otln_chp_secondary_spc = state("ut_otln_chp_secondary_spc", 3em)

#let toc_mjr_spc = state("ut_toc_mjr_spc", 2em)

#let otln_leading_spc = state("ut_otln_leading_spc", 1em)

#let abbrv_columns = state("ut_abbrv_columns", (0.25fr, 1fr))

#let CommitteeProf(person, indent: true) = context {
  if indent {
    h(prof_indent.get())
  }
  
  if person.title != none {
    person.title + [ ]
  }
  person.name
  if person.chair {
    [, Chair]
  }
  linebreak()
} 


#let PreambleChapter(title) = context {
  heading(numbering: none)[#upper(title)]
}

#let ucsd_thesis(
  subject: "Computer Science",
  author: "John/Jane Doe",
  title: "My Little Thesis",
  degree: "Doctor of Philosophy",
  committee: (
    (title: "Professor", name: "Jane Doe", chair: true),
    (title: "Professor", name: "John Doe", chair: false)
  ),
  abstract: none,
  dedication: none,
  acknowledgement: none,
  epigraph: none,
  abbrv: none,
  vita: none,
  publications: none,
  introduction: none,
  doc,
) = {
  set page(
    paper: "us-letter",
    number-align: center,
    numbering: none,
  )
  
  show table.cell: it => text(weight: "regular")[#it]
  
  show heading: it => [
    #set align(center)
    #set text(13pt, weight: "regular")
    #block(upper(it.body))
    #v(1em)
  ]

  // show figure: i-figured.show-figure

  
  show figure: it => block(width: 100%)[#align(center)[
     #par(leading: 1em)[
       #it.body
       #if it.has("caption") {
         if it.caption != none and it.caption.has("body") {
           it.supplement
           " "
           str(counter(heading).get().first())
           "."
           str(counter(figure.where(kind: it.kind)).get().first())
           ": "
           it.caption.body
         }
       }
     ]
   ]
  ]
  
  set outline(fill: align(right, repeat(gap: 5pt)[.]))
  
  show outline.entry : it => context {
    if it.element.func() == heading { // Table of contents outline
      let element = it.element
      let body = it.body
  
      if body.has("text") { // Preamble Chapters
        v(toc_mjr_spc.get())
        body.text + " "
        box(width: 1fr, it.fill)
        " " + it.page
      } else if it.has("level") { // Normal Chapters
  
        if element.body.has("text") and element.body.text == "Acknowledgement" {
          // Skip it
        } else {
          
          let num = numbering("1.1.1", ..counter(heading).at(it.element.location()))
          let grid_data = ()
          let lvl = it.level

          let prim_spc = otln_chp_primary_spc.get()
          let sec_spc = otln_chp_secondary_spc.get()
          
          let columns = (
            "1": (prim_spc, 1fr),
            "2": (prim_spc, sec_spc, 1fr),
            "3": (prim_spc, sec_spc, sec_spc, 1fr),
            "4": (prim_spc, sec_spc, sec_spc, sec_spc, 1fr),        
            "5": (prim_spc, sec_spc, sec_spc, sec_spc, sec_spc, 1fr),
          )
    
          if lvl == 1 {
            v(toc_mjr_spc.get())
            grid_data.push("Chapter " + num)
          } else {
            for i in range(lvl - 1) {
              grid_data.push("")
            }
            
            grid_data.push(num)
          }        
          grid_data.push(element.body + box(width: 1fr, it.fill) + " " + it.page)
    
          grid(
            columns: columns.at(str(lvl)),
            ..for data in grid_data {
              (data,)
            }
          )
        }
      }
    } else { // Other outlines
      let kind = it.element.kind
      let heading_num = counter(heading).at(it.element.location()).first()
      let figure_num = counter(figure.where(kind: kind)).at(it.element.location()).first()
      
      let elem_num = numbering("1.1", heading_num, figure_num)
      let elem_typ = it.element.caption.supplement.text
      let caption = it.element.caption.body
      let dots = box(width: 1fr, align(right, repeat(gap: 5pt)[.]))
  
      let columns = (otln_chp_primary_spc.get(), 1fr)

      if kind == table {
        let fmj = it.element.location()
        let laksdf = counter(figure.where(kind: table)).display()
        let fmja = it.element.caption.counter.at(it.element.location())
      } else if kind != image {
        panic("Only tables and images are supported! This may be a bug.")
      }


      if figure_num == 1 {
        v(otln_new_chp_spc.get())
      }
      
      grid(
        columns: columns,
        elem_typ + " " + elem_num + ":",
        par(leading: 0.5em, spacing: 0.4em)[#context {
          caption + " " + dots + " " + it.page
        }]
      )
    }
  }

  
  align(center)[
    #v(1fr)
    UNIVERSITY OF CALIFORNIA SAN DIEGO
    #v(1fr)
    *#title*
    #v(1fr) A Dissertation submitted in partial satisfaction of the requirements \
    for the degree #degree 
    #v(1fr)  
    in
    #v(1fr)
    #subject
    #v(1fr)
    by
    #v(1fr)
    #author
    #v(1fr)
  ]

    
  [Committee in charge:] + linebreak()


  for person in committee {
    CommitteeProf(person)
  }

  
  v(1fr)
  let today = datetime.today()
  
  align(center)[
    #today.display("[year]") 
  ]
  v(1fr)
  
  pagebreak()
  v(1fr)
  align(center)[
    Copyright #emoji.copyright #author, #today.display("[year]")
    
    All rights reserved.
  ]
  
  pagebreak()
  set page(numbering: "i")
  
  align(center)[
    The Dissertation of #author is approved, and it is acceptable \
    in quality and form for publication on microfilm and electronically.
    
    #v(1fr)
    
    University of California San Diego
    
    #today.display("[year]")
    
    #v(1fr)
  ]
  
  pagebreak()
  
  set par(
    leading: 2em,  
    spacing: 2em,
    first-line-indent: 4em,
  ) 
  show list: set block(spacing: 2em)
    
  pagebreak()
  
  set par(
    leading: 2em,  
    spacing: 2em,
    first-line-indent: 4em,
  ) 
  show list: set block(spacing: 2em)
  
  
  if dedication != none {
    PreambleChapter("Dedication")
    align(center, dedication)  
    pagebreak()
  }

  if epigraph != none {
    PreambleChapter("Epigraph")
    epigraph
    pagebreak()
  }
  
  context {
    par(leading: otln_leading_spc.get(), spacing: 0em)[
      #outline(title: [TABLE OF CONTENTS])
    ]
  }
  pagebreak()

  context {
    par(leading: otln_leading_spc.get(), spacing: 0em)[
      #outline(
        title: [LIST OF FIGURES],
        target: figure.where(kind: image),
      )
    ]
  }
  pagebreak()

  context {
    par(leading: otln_leading_spc.get(), spacing: 0em)[
      #outline(
        title: [LIST OF TABLES],
        target: figure.where(kind: table),
      )
    ]
  }
  
  pagebreak()

  if abbrv != none {
    PreambleChapter("LIST OF ABBREVIATIONS")
    
    let abbrv_sorted = abbrv.pairs().sorted(key: k => k.at(0))
    
    set par(justify: true)

    context {
      table(
        stroke: none,
        columns: abbrv_columns.get(),
        ..for (k, v) in abbrv_sorted {
          (k, v)
        }
      )
    }
    
    pagebreak()
  }

  if acknowledgement != none {
    PreambleChapter("ACKNOWLEDGEMENTS")
    acknowledgement
    pagebreak()
  }

  if vita != none {
    PreambleChapter("Vita")
    vita
  }

  if publications != none {
    PreambleChapter("Publications")
    publications
  }

  
  PreambleChapter("Field of Study")
  
  par(
      leading: 0.5em,  
      spacing: 0.5em,
      first-line-indent: 0em,
    )[
      Major Field: #subject

      #context [
        #h(prof_indent.get()) Studies in Research topic
      ]

      #for person in committee {
        if person.chair {
          CommitteeProf(person)
        }
      }
  ]

  pagebreak()
  
  if abstract != none {
    
    v(2.5in)
    PreambleChapter("Abstract of Dissertation")
    
    align(center)[
      #title
      #v(1em)  
      by
      #v(1em)  
      #author
      #v(1em)
      #degree in #subject
      
      University of California San Diego, #today.display("[year]")
  
      #for person in committee {
        if person.chair {
          CommitteeProf(person, indent: false)
        }
      }
      
      #v(1em)

      #abstract
    ]
  }
  
  set page(numbering: "1")
  counter(page).update(1)

  if introduction != none {
    PreambleChapter("Introduction")
    introduction
  }
  
  set heading(
      numbering: (..) => "Chapter " + counter(heading).display("1"),
      supplement: ""
  )
  show heading: it => context {
    if it.level == 1 {
      // i-figured.reset-counters(it)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      pagebreak()
      text(1.8em, style: "normal", weight: "bold")[
        #par(leading: 0.5em, justify: false)[
          #{
            "Chapter "
            counter(heading).display("1.1.1")
          } #v(-1.8em)
          #linebreak()
          #it.body
        ]
      ]
    } else {
      if it.body.has("text") and it.body.text == "Acknowledgement" {    
        h(-4em) + text(1.5em, style: "normal", weight: "regular")[#it.body #linebreak()]      
      } else {
        h(-4em) + text(1.5em, style: "normal", weight: "regular")[#counter(heading).display("1.1.1") #it.body #linebreak()]
      }
    }
  }

  doc
}

