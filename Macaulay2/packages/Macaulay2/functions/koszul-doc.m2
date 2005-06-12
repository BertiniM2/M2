--- status: DRAFT
--- author(s): Caviglia, Kummini
--- notes: 

document { 
     Key => {koszul,(koszul,ZZ,Matrix)},
     Headline => "a differential in a Koszul complex",
     Usage => "g = koszul(i,f)",
     Inputs => {
             "i" => "",
             "f" => {"a ", TT "1", " by ", TT "n", " matrix"},
     },
     Outputs => {
          "g" => { "the ", TT "i", "-th differential in the Koszul complex of the matrix ", TT "f"}
     },

     EXAMPLE {
          "R = QQ[x_1..x_4];",
          "f = matrix{{x_1..x_4}}"
     },
     "To see the second differential in the Koszul complex of the matrix ", TT "f", " look at:",
     EXAMPLE {
     "koszul(2,f)",
     },
     SeeAlso => {}
     }
///
document { 
     Key => (koszul,Matrix,Matrix),
     Headline => "a differential in a Koszul complex",
     Usage => "koszul(M,N)",
     Inputs => {
             "M" => {"a ", TT "1", " by ", TT "m", " matrix"},
             "N" => {"a ", TT "1", " by ", TT "n", " matrix"},
     },
     Outputs => {
	  Matrix => { "the ", TT "i", "-th differential in the 
	       Koszul complex of the matrix ", TT "f"}
     },
     EXAMPLE {
	  R = QQ[a..d]
          M = matrix{{a*b, a*c, b*d, b^2}}
	  N = matrix{{a,b,c,d}}
	  koszul(N,M)
     },
     "To see the second differential in the Koszul complex of the matrix ", TT "f", " look at:",
     EXAMPLE {
     "koszul(2,f)",
     },
     SeeAlso => {}
     }
///
