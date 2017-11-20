-- PURPOSE : Computing the cyclic polytope of n points in QQ^d
--   INPUT : '(d,n)',  two positive integers
--  OUTPUT : A polyhedron, the convex hull of 'n' points on the moment curve in 'd' space 
-- COMMENT : The moment curve is defined by t -> (t,t^2,...,t^d) in QQ^d, if we say we take 'n' points 
--            on the moment curve, we mean the images of 0,...,n-1
cyclicPolytope = method(TypicalValue => Polyhedron)
cyclicPolytope(ZZ,ZZ) := (d,n) -> (
     -- Checking for input errors
     if d < 1 then error("The dimension must be positive");
     if n < 1 then error("There must be a positive number of points");
     convexHull map(ZZ^d, ZZ^n, (i,j) -> j^(i+1)))


-- PURPOSE : Computing the cone of the Hirzebruch surface H_r
--   INPUT : 'r'  a positive integer
--  OUTPUT : The Hirzebruch surface H_r
hirzebruch = method(TypicalValue => Fan)
hirzebruch ZZ := r -> (
   -- Checking for input errors
   if r < 0 then error ("Input must be a positive integer");
   normalFan convexHull matrix {{0, 1, 0, r+1},{0, 0, 1, 1}}
)


-- PURPOSE : Generating the 'd'-dimensional hypercube with edge length 2*'s'
hypercube = method(TypicalValue => Polyhedron)

--   INPUT : '(d,s)',  where 'd' is a strictly positive integer, the dimension of the polytope, and
--     	    	       's' is a positive rational number, half of the edge length
--  OUTPUT : The 'd'-dimensional hypercube with edge length 2*'s' as a polyhedron
hypercube(ZZ,QQ) := (d,s) -> (
     -- Checking for input errors
     if d < 1 then error("dimension must at least be 1");
     if s <= 0 then error("size of the hypercube must be positive");
     -- Generating half-spaces matrix and vector
     polyhedronFromHData(map(QQ^d,QQ^d,1) || -map(QQ^d,QQ^d,1),matrix toList(2*d:{s})))



--   INPUT : '(d,s)',  where 'd' is a strictly positive integer, the dimension of the polytope, and
--     	    	       's' is a positive integer, half of the edge length
hypercube(ZZ,ZZ) := (d,s) -> hypercube(d,promote(s,QQ))

     
--   INPUT : 'd',  is a strictly positive integer, the dimension of the polytope 
hypercube ZZ := d -> hypercube(d,1_QQ)


-- PURPOSE : Computing the Newton polytope for a given polynomial
--   INPUT : 'p',  a RingElement
--  OUTPUT : The polyhedron that has the exponent vectors of the monomials of 'p' as vertices
newtonPolytope = method(TypicalValue => Polyhedron)
newtonPolytope RingElement := p -> convexHull transpose matrix exponents p


-- PURPOSE : Generating the positive orthant in n-space as a cone
--   INPUT : 'n",  a strictly positive integer
--  OUTPUT : The cone that is the positive orthant in n-space
posOrthant = method(TypicalValue => Cone)
posOrthant ZZ := n -> coneFromVData map(QQ^n,QQ^n,1)


	  
-- PURPOSE : Computing the secondary Polytope of a Polyhedron
--   INPUT : 'P',  a Polyhedron which must be compact
--  OUTPUT : a polytope, the secondary polytope
secondaryPolytope = method(TypicalValue => Polyhedron)
secondaryPolytope Polyhedron := P -> (
     -- Checking for input errors
     if not isCompact P then error("The polyhedron must be compact.");
     -- Extracting necessary data
     V := vertices P;
     n := dim P;
     m := numColumns V;
     -- Computing the cell decomposition of P induced by the projection of the m-1 simplex onto P
     nCells := apply(subsets(m,n+1), e -> convexHull V_e);
     nCellsfd := select(nCells, C -> dim C == n);
     nCellsfd = inclMinCones nCellsfd;
     refCells := {};
     while nCellsfd != {} do (
	  newCells := {};
	  -- scan through the 'n' dimensional cells and check for each of the cells generated by
	  -- 'n+1' vertices if their intersection is 'n' dimensional and if the first one is not contained 
	  -- in the latter. If true, then their intersection will be saved in the list 'newCells'.
	  -- If false for every cone generated by 'n+1' vertices, then the 'n' dimensional cell will be 
	  -- appended to the list 'refCells'
	  refCells = refCells | (flatten apply(nCellsfd, C1 -> (
			 toBeAdded := flatten apply(nCells, C2 -> (
				   C := intersection(C2,C1);
				   if dim C == n and (not contains(C2,C1)) then C
				   else {}));
			 if toBeAdded == {} then C1
			 else (
			      newCells = newCells | toBeAdded;
			      {}))));
	  -- now, the new intersections will be the 'n' dimensional cones and the same procedure 
	  -- starts over again if this list is not empty
	  nCellsfd = unique newCells);
     refCells = if n != ambDim P then (
	  A := substitute((hyperplanes P)#0,ZZ);
	  A = inverse (smithNormalForm A)#2;
	  d := ambDim P;
	  A = A^{d-n..d-1};
	  apply(refCells, P -> (volume affineImage(A,P),interiorPoint P)))
     else apply(refCells, P -> (volume P,interiorPoint P));
     volP := sum apply(refCells,first);
     Id := -map(QQ^m,QQ^m,1);
     v := map(QQ^m,QQ^1,0);
     N := matrix{toList(m:1_QQ)} || V;
     w := matrix {{1_QQ}};
     sum apply(refCells, e -> (e#0/volP) * intersection(Id,v,N,w||e#1)))
     




-- PURPOSE : Computing the bipyramid over the polyhedron 'P'
--   INPUT : 'P',  a polyhedron 
--  OUTPUT : A polyhedron, the convex hull of 'P', embedded into ambientdim+1 space and the 
--     	         points (barycenter of 'P',+-1)
bipyramid = method(TypicalValue => Polyhedron)
bipyramid Polyhedron := P -> (
   -- Saving the vertices
   V := vertices P;
   n := numColumns V;
   if n == 0 then error("P must not be empty");
   -- Computing the barycenter of P
   << "Compute barycenter." << endl;
   v := matrix toList(n:{1_QQ,1_QQ});
   v = (1/n)*V*v;
   << "Compute barycenter done." << endl;
   C := getProperty(P, underlyingCone);
   M := promote(rays C, QQ);
   LS := promote(linealitySpace C, QQ);
   r := ring M;
   -- Embedding into n+1 space and adding the two new vertices
   zerorow := map(r^1,source M,0);
   newvertices := makePrimitiveMatrix(matrix {{1,1}} || v || matrix {{1,-1}});
   M = (M || zerorow) | newvertices;
   LS = LS || map(r^1,source LS,0);
   newC := coneFromVData(M, LS);
   result := new HashTable from {
      underlyingCone => newC
   };
   polyhedron result
)



-- PURPOSE : Computing the pyramid over the polyhedron 'P'
--   INPUT : 'P',  a polyhedron 
--  OUTPUT : A polyhedron, the convex hull of 'P', embedded into ambientdim+1 space, and the 
--     	         point (0,...,0,1)
pyramid = method(TypicalValue => Polyhedron)
pyramid Polyhedron := P -> (
   C := getProperty(P, underlyingCone);
   M := rays C;
   LS := linealitySpace C;
   -- Embedding into n+1 space and adding the new vertex
   zerorow := map(ZZ^1,source M,0);
   newvertex := 1 || map(ZZ^((numRows M)-1),ZZ^1,0) || 1;
   M = (M || zerorow) | newvertex;
   LS = LS || map(ZZ^1,source LS,0);
   newC := coneFromVData(M, LS);
   result := new HashTable from {
      underlyingCone => newC
   };
   polyhedron result
)


-- PURPOSE : Generating the 'd'-dimensional crosspolytope with edge length 2*'s'
crossPolytope = method(TypicalValue => Polyhedron)

--   INPUT : '(d,s)',  where 'd' is a strictly positive integer, the dimension of the polytope, and 's' is
--     	    	       a strictly positive rational number, the distance of the vertices to the origin
--  OUTPUT : The 'd'-dimensional crosspolytope with vertex-origin distance 's'
crossPolytope(ZZ,QQ) := (d,s) -> (
   -- Checking for input errors
   if d < 1 then error("dimension must at least be 1");
   if s <= 0 then error("size of the crosspolytope must be positive");
   constructMatrix := (d,v) -> (
   if d != 0 then flatten {constructMatrix(d-1,v|{-1}),constructMatrix(d-1,v|{1})}
   else {v});
   homHalf := ( sort makePrimitiveMatrix transpose( matrix toList(2^d:{-s}) | promote(matrix constructMatrix(d,{}),QQ)),map(ZZ^(d+1),ZZ^0,0));
   homVert := (sort makePrimitiveMatrix (matrix {toList(2*d:1_QQ)} || (map(QQ^d,QQ^d,s) | map(QQ^d,QQ^d,-s))),map(ZZ^(d+1),ZZ^0,0));
   C := new HashTable from {
      rays => homVert#0,
      computedLinealityBasis => homVert#1,
      facets => transpose(-homHalf#0),
      computedHyperplanes => transpose(homHalf#1)
   };
   C = cone C;
   result := new HashTable from {
      underlyingCone => C
   };
   polyhedron result
)


--   INPUT : '(d,s)',  where 'd' is a strictly positive integer, the dimension of the polytope, and 's' is a
--     	    	        strictly positive integer, the distance of the vertices to the origin
crossPolytope(ZZ,ZZ) := (d,s) -> crossPolytope(d,promote(s,QQ))


--   INPUT :  'd',  where 'd' is a strictly positive integer, the dimension of the polytope
crossPolytope ZZ := d -> crossPolytope(d,1_QQ)



-- PURPOSE : Generating the empty polyhedron in n space
--   INPUT : 'n',  a strictly positive integer
--  OUTPUT : The empty polyhedron in 'n'-space
emptyPolyhedron = method(TypicalValue => Polyhedron)
emptyPolyhedron ZZ := n -> (
   -- Checking for input errors
   if n < 1 then error("The ambient dimension must be positive");
   C := coneFromVData map(ZZ^(n+1), ZZ^0,0);
   result := new HashTable from {
      underlyingCone => C
   };
   polyhedron result
);
	  
-- PURPOSE : Generating the 'd'-dimensional standard simplex in QQ^(d+1)
--   INPUT : 'd',  a positive integer
--  OUTPUT : The 'd'-dimensional standard simplex as a polyhedron
stdSimplex = method(TypicalValue => Polyhedron)
stdSimplex ZZ := d -> (
     -- Checking for input errors
     if d < 0 then error("dimension must not be negative");
     -- Generating the standard basis
     convexHull map(QQ^(d+1),QQ^(d+1),1))
