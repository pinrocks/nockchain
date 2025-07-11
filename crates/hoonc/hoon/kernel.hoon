/+  *wrapper
=>
|%
+$  state-0  [%0 *]
+$  state-1  [%1 *]
+$  state-2  [%2 cached-hoon=(unit (trap vase)) bc=build-cache pc=parse-cache]
::
++  empty-trap-vase
  ^-  (trap vase)
  =>  vaz=!>(~)
  |.(vaz)
::
+$  versioned-state
  $%  state-0
      state-1
      state-2
  ==
+$  choo-state  state-2
::
++  moat  (keep choo-state)
+$  cause
  $%  $:  %build
          pat=cord
          tex=cord
          directory=(list [cord cord])
          arbitrary=?
          out=cord
      ==
      [%file %write path=@t contents=@ success=?]
      [%boot hoon-txt=cord]
  ==
+$  effect
  $%  [%file %write path=@t contents=@]
      [%exit id=@]
  ==
::
::  $entry: path of a file along with unit of its contents.
::
::    If unit is null, the path must exist inside of the dir map.
::
+$  entry  [pat=path tex=(unit cord)]
::
+$  hash  @
::
::  $build-cache: holds up to date cached build artifacts, keyed by merkle hash
+$  build-cache  (map hash (trap vase))
::
::  $build-result: result of a build
::
::    either a (trap vase) or an error trace.
::
+$  build-result  (each (trap vase) tang)
::
::  $taut: file import from /lib or /sur
::
+$  taut  [face=(unit term) pax=term]
::
::  $pile:  preprocessed hoon file
::
+$  pile
  $:  sur=(list taut)  ::  /-
      lib=(list taut)  ::  /+
      raw=(list [face=(unit term) pax=path])  ::  /=
      bar=(list [face=term mark=@tas =path])  ::  /*
      hax=(list taut)                         ::  /#
      =hoon
  ==
::
::
::  $parse-cache: content addressed cache of preprocessed hoon files.
::
+$  parse-cache  (map hash pile)
--
::
=<
~&  >>  %choo-choo
%-  (moat &)
^-  fort:moat
|_  k=choo-state
+*  builder  +>
::
::  +load: upgrade from previous state
::
::
++  load
  |=  old=versioned-state
  ^-  choo-state
  ::
  ::  We do not use the result of the soft because
  ::  clamming (trap vase) overwrites the contents
  ::  with the bunt resulting in the honc and the build
  ::  artifacts being replaced with empty-trap-vase.
  ::
  ?~  ((soft versioned-state) old)
    ~>  %slog.[0 leaf+"choo: +load old state does not nest under versioned-state. Try booting with --new to start from scratch."]
    !!
  ?-    -.old
      %0
    ~>  %slog.[0 leaf+"update 0-to-2, starting from scratch"]
    *choo-state
  ::
      %1
    ~>  %slog.[0 leaf+"update 1-to-2, starting from scratch"]
    *choo-state
  ::
      %2
    ~>  %slog.[0 leaf+"no update"]
    old
  ::
  ==
::
::  +peek: external inspect
::
++  peek
  |=  =path
  ^-  (unit (unit *))
  ?+  path  ~
      [%booted ~]
    ``?=(^ cached-hoon.k)
  ==
::
::  +poke: external apply
::
++  poke
  |=  [=wire eny=@ our=@ux now=@da dat=*]
  ^-  [(list effect) choo-state]
  =/  cause=(unit cause)  ((soft cause) dat)
  ?~  cause
    ~&  "input is not a proper cause"
    !!
  =/  cause  u.cause
  ~&  -.cause
  ?-    -.cause
      %file
    ?:  success.cause
      ~&  >  "choo: output written successfully to {<path.cause>}"
      [[%exit 0]~ k]
    ~&  >  "choo: failed to write output to {<path.cause>}"
    [[%exit 1]~ k]
  ::
      %boot
    ~&  >>  hoon-version+hoon-version
    ?:  ?=(^ cached-hoon.k)
      [~ k]
    ~&  "Please be patient. This will take a few minutes."
    [~ k(cached-hoon `(build-honc hoon-txt.cause))]
  ::
      %build
    ~&  >>  "building path: {<pat.cause>}"
    =/  =entry
      ~|  "path did not parse: {<pat.cause>}"
      [(parse-file-path pat.cause) `tex.cause]
    =/  dir
      %-  ~(gas by *(map path cord))
      (turn directory.cause |=((pair @t @t) [(stab p) q]))
    ?>  ?=(^ cached-hoon.k)
    =/  [compiled=* new-bc=build-cache new-pc=parse-cache]
      ?:  arbitrary.cause
        %-  ~(create-arbitrary builder u.cached-hoon.k bc.k pc.k)
        [entry dir]
      %-  ~(create builder u.cached-hoon.k bc.k pc.k)
      [entry dir]
    :_  k(bc new-bc, pc new-pc)
    =/  write-effect
      :*  %file
          %write
          path=out.cause
          contents=(jam compiled)
      ==
    =/  success  !=(compiled empty-trap-vase)
    ?:  success
      ~&  >>>  "choo: build succeeded, sending out write effect"
      [write-effect]~
    ~&  >>>  "choo: build failed, skipping write and exiting"
    [%exit 1]~
  ==
--
::
::  build system
::
=>
::
::  dependency system
::
|%
+$  raut
  ::  resolved taut - pax contains real path to file after running taut through +get-fit
  [face=(unit @tas) pax=path]
++  rile
  ::  resolved pile
  $:  sur=(list raut)
      lib=(list raut)
      raw=(list raut)
      bar=(list raut)
      hax=(list raut)
      =hoon
  ==
::
::  +parse-file-path: parse cord of earth file path to path
++  parse-file-path
  |=  pat=cord
  (rash pat gawp)
::
::  +gawp: parse an absolute earth file path
++  gawp
  %+  sear
    |=  p=path
    ^-  (unit path)
    ?:  ?=([~ ~] p)  `~
    ?.  =(~ (rear p))  `p
    ~
  ;~(pfix fas (most fas bic))
::
::  +bic: parse file/dir name in earth file path
++  bic
  %+  cook
  |=(a=tape (rap 3 ^-((list @) a)))
  (star ;~(pose nud low hig hep dot sig cab))
::
++  to-wain                                           ::  cord to line list
  |=  txt=cord
  ^-  wain
  ?~  txt  ~
  =/  len=@  (met 3 txt)
  =/  cut  =+(cut -(a 3, c 1, d txt))
  =/  sub  sub
  =|  [i=@ out=wain]
  |-  ^+  out
  =+  |-  ^-  j=@
      ?:  ?|  =(i len)
              =(10 (cut(b i)))
          ==
        i
      $(i +(i))
    =.  out  :_  out
    (cut(b i, c (sub j i)))
  ?:  =(j len)
    (flop out)
  $(i +(j))
::
++  parse-pile
  |=  [pax=path tex=tape]
  ^-  pile
  =/  [=hair res=(unit [=pile =nail])]
    %-  road  |.
    ((pile-rule pax) [1 1] tex)
  ?^  res  pile.u.res
  %-  mean
  =/  lyn  p.hair
  =/  col  q.hair
  ^-  (list tank)
  :~  leaf+"syntax error at [{<lyn>} {<col>}] in {<pax>}"
    ::
      =/  =wain  (to-wain (crip tex))
      ?:  (gth lyn (lent wain))
        '<<end of file>>'
      (snag (dec lyn) wain)
    ::
      leaf+(runt [(dec col) '-'] "^")
  ==
::
++  pile-rule
  |=  pax=path
  %-  full
  %+  ifix
    :_  gay
    ::  parse optional /? and ignore
    ::
    ;~(plug gay (punt ;~(plug fas wut gap dem gap)))
  |^
  ;~  plug
    %+  cook  (bake zing (list (list taut)))
    %+  rune  hep
    (most ;~(plug com gaw) taut-rule)
  ::
    %+  cook  (bake zing (list (list taut)))
    %+  rune  lus
    (most ;~(plug com gaw) taut-rule)
  ::
    %+  rune  tis
    ;~(plug ;~(pose (cold ~ tar) (stag ~ sym)) ;~(pfix gap stap))
  ::
    %+  rune  tar
    ;~  (glue gap)
      sym
      ;~(pfix cen sym)
      ;~(pfix stap)
    ==
  ::
    %+  cook  (bake zing (list (list taut)))
    %+  rune  hax
    (most ;~(plug com gaw) taut-rule)
  ::
    %+  stag  %tssg
    (most gap tall:(vang & pax))
  ==
  ::
  ++  pant
    |*  fel=rule
    ;~(pose fel (easy ~))
  ::
  ++  mast
    |*  [bus=rule fel=rule]
    ;~(sfix (more bus fel) bus)
  ::
  ++  rune
    |*  [bus=rule fel=rule]
    %-  pant
    %+  mast  gap
    ;~(pfix fas bus gap fel)
  --
::
++  taut-rule
  %+  cook  |=(taut +<)
  ;~  pose
    (stag ~ ;~(pfix tar sym))               ::  *foo -> [~ %foo]
    ;~(plug (stag ~ sym) ;~(pfix tis sym))  ::  bar=foo -> [[~ %bar] %foo]
    (cook |=(a=term [`a a]) sym)            ::  foo    -> [[~ %foo] %foo]
  ==
::
++  segments
  |=  suffix=@tas
  ^-  (list path)
  =/  parser
    (most hep (cook crip ;~(plug ;~(pose low nud) (star ;~(pose low nud)))))
  =/  torn=(list @tas)  (fall (rush suffix parser) ~[suffix])
  %-  flop
  |-  ^-  (list (list @tas))
  ?<  ?=(~ torn)
  ?:  ?=([@ ~] torn)
    ~[torn]
  %-  zing
  %+  turn  $(torn t.torn)
  |=  s=(list @tas)
  ^-  (list (list @tas))
  ?>  ?=(^ s)
  ~[[i.torn s] [(crip "{(trip i.torn)}-{(trip i.s)}") t.s]]
::
++  get-fit
  |=  [pre=@ta pax=@tas dir=(map path cord)]
  ^-  (unit path)
  =/  paz=(list path)  (segments pax)
  |-
  ?~  paz
    ~&  >>  "{<pax>}-not-found"  ~
  =/  last=term  (rear i.paz)
  =.  i.paz   `path`(snip i.paz)
  =/  puz
    ^-  path
    %+  snoc
      `path`[pre i.paz]
    `@ta`(rap 3 ~[last %'.' %hoon])
  ?^  (~(get by dir) puz)
    `puz
  $(paz t.paz)
::
++  resolve-pile
  ::  turn fits into resolved path suffixes
  |=  [=pile dir=(map path cord)]
  ^-  (list raut)
  ;:  weld
    (turn sur.pile |=(taut ^-(raut [face (need (get-fit %sur pax dir))])))
    (turn lib.pile |=(taut ^-(raut [face (need (get-fit %lib pax dir))])))
  ::
    %+  turn  raw.pile
    |=  [face=(unit term) pax=path]
    =/  pax-snip  (snip pax)
    =/  pax-rear  (rear pax)
    ^-  raut
    [face `path`(snoc pax-snip `@ta`(rap 3 ~[pax-rear %'.' %hoon]))]
  ::
    %+  turn  bar.pile
    |=  [face=term mark=@tas pax=path]
    =/  pax-snip  (snip pax)
    =/  pax-hind  (rear pax-snip)
    =/  pax-rear  (rear pax)
    ^-  raut
    [`face `path`(snoc (snip pax-snip) `@ta`(rap 3 ~[pax-hind %'.' pax-rear]))]
  ::
    (turn hax.pile |=(taut ^-(raut [face (need (get-fit %dat pax dir))])))
  ==
--
::
::  builder core
::
|_  [honc=(trap vase) bc=build-cache pc=parse-cache]
::
++  build-honc
  |=  hoon-txt=cord
  ^-  (trap vase)
  (swet empty-trap-vase (ream hoon-txt))
::
+$  octs  [p=@ud q=@]
::
::  $node: entry of adjacency matrix with metadata
::
+$  node
  $:  =path
      hash=@
      ::  holds only outgoing edges
      deps=(list raut)
      leaf=graph-leaf
      eval=?  :: whether or not to kick it
  ==
::
+$  graph-leaf
  $%  [%hoon =hoon]
      [%octs =octs]
  ==
::
::  $create: build a trap from a hoon/jock file with dependencies
::
::    .entry: the entry to build
::    .dir: the directory to get dependencies from
::
::    this is meant to build a kernel gate that takes a hash of a the
::    dependency directory.
::
::    returns a trap, a build-cache, and a parse-cache
++  create
  |=  [=entry dir=(map path cord)]
  ^-  [* build-cache parse-cache]
  =/  dir-hash  `@uvI`(mug dir)
  ~&  >>  dir-hash+dir-hash
  =/  compile
    (create-target entry dir)
  =/  ker-gen  (head compile)
  =/  [=build-cache =parse-cache]  (tail compile)
  ::  +shot calls the kernel gate to tell it the hash of the dependency directory
  :_  [build-cache parse-cache]
  ::  build failure, just return the bunted trap
  ?:  =(ker-gen empty-trap-vase)  ker-gen
  =>  %+  shot  ker-gen
    =>  d=!>(dir-hash)
    |.(d)
  |.(+:^$)
::
::  $create-arbitrary: builds a hoon/jock file with dependencies without file hash injection
::
::    .entry: the entry to build
::    .dir: the directory to get dependencies from
::    returns a trap, a build-cache, and a parse-cache
++  create-arbitrary
   |=  [=entry dir=(map path cord)]
   ^-  [* build-cache parse-cache]
   =/  [tase=(trap) =build-cache =parse-cache]
     (create-target entry dir)
   :_  [build-cache parse-cache]
   ?:  =(tase empty-trap-vase)
     tase
   =>  tase
   |.(+:^$)
::
::  $create-target: builds a hoon/jock file with dependencies
::
::    .entry: the entry to build
::    .dir: the directory to get dependencies from
::
::    returns a trap with the compiled hoon/jock file and the updated caches
++  create-target
  |=  [=entry dir=(map path cord)]
  ^-  [(trap vase) build-cache parse-cache]
  =^  parsed-dir=(map path node)  pc
    (parse-dir entry dir)
  =/  all-nodes=(map path node)  parsed-dir
  =/  [dep-dag=merk-dag =path-dag]  (build-merk-dag all-nodes)
  ::
  ::  delete invalid cache entries in bc
  =.  bc
    %+  roll
      ~(tap by bc)
    |=  [[hash=@ *] bc=_bc]
    ?:  (~(has by dep-dag) hash)
      bc
    (~(del by bc) hash)
  ::
  =/  compile
    %:  compile-target
      pat.entry
      path-dag
      all-nodes
      bc
    ==
  ::
  [(head compile) (tail compile) pc]
::
::  $parse-dir: parse $entry and get dependencies from $dir
::
::    .entry: entry to parse
::    .dir: directory to get dependencies from
::
::    returns a map of nodes and a parse cache
++  parse-dir
  |=  [suf=entry dir=(map path cord)]
  ^-  [(map path node) parse-cache]
  =|  new-pc=parse-cache
  ~&  >  parsing+pat.suf
  |^
  =/  file=cord  (get-file suf dir)                   ::  get target file
  =/  hash=@  (shax file)                             ::  hash target file
  =^  target=node  new-pc
    ?.  (is-hoon pat.suf)
      :_  new-pc
      :*  pat.suf                                       ::  path
          hash                                          ::  hash
          ~                                             ::  deps
          [%octs [(met 3 file) file]]                   ::  octs
          %.n                                           ::  eval
      ==
    =/  =pile
      ?:  (~(has by pc) hash)
        ~&  parse-cache-hit+pat.suf
        (~(got by pc) hash)
      ~&  parse-cache-miss+pat.suf
      (parse-pile pat.suf (trip file))         ::  parse target file
    =/  deps=(list raut)  (resolve-pile pile dir)       ::  resolve deps
    :_  (~(put by new-pc) hash pile)
    :*  pat.suf                                         ::  path
        hash                                            ::  hash
        deps                                            ::  deps
        [%hoon hoon.pile]                               ::  hoon
        (is-dat pat.suf)                                ::  eval
    ==
  =|  nodes=(map path node)                             ::  init empty node map
  =.  nodes  (~(put by nodes) pat.suf target)           ::  add target node
  =/  seen=(set path)  (~(put in *(set path)) pat.suf)
  (resolve-all nodes seen deps.target new-pc)
  ::
  ++  resolve-all
    |=  [nodes=(map path node) seen=(set path) deps=(list raut) new-pc=parse-cache]
    ^-  [(map path node) parse-cache]
    ?~  deps  [nodes new-pc]                            ::  done if no deps
    ?.  (~(has in seen) pax.i.deps)                     ::  skip if seen
      ~&  >>  parsing+pax.i.deps
      =/  dep-file  (get-file [pax.i.deps ~] dir)       ::  get dep file
      =/  dep-hash  (shax dep-file)                     ::  hash dep file
      =^  dep-node=node  new-pc
        ?.  (is-hoon pax.i.deps)
          :_  new-pc
          :*  pax.i.deps                                  ::  path
              dep-hash                                    ::  hash
              ~                                           ::  deps
              [%octs [(met 3 dep-file) dep-file]]         ::  octs
              %.n
          ==
        =/  dep-pile
          ?:  (~(has by pc) dep-hash)                     ::  check cache
            ~&  parse-cache-hit+pax.i.deps
            (~(got by pc) dep-hash)
          ~&  parse-cache-miss+pax.i.deps
          (parse-pile pax.i.deps (trip dep-file))         ::  parse dep file
        ~&  >>  parsed+pax.i.deps
        =/  dep-deps  (resolve-pile dep-pile dir)         ::  resolve dep deps
        ~&  >>  resolved+pax.i.deps
        :_  (~(put by new-pc) dep-hash dep-pile)              ::  cache parse
        :*  pax.i.deps
            dep-hash
            dep-deps
            [%hoon hoon.dep-pile]
            (is-dat pax.i.deps)                             ::  eval
        ==
      =.  nodes  (~(put by nodes) pax.i.deps dep-node)  ::  add dep node
      =.  seen  (~(put in seen) pax.i.deps)             ::  mark as seen
      %=  $
        nodes  nodes
        seen   seen
        deps   (weld t.deps deps.dep-node)                   ::  add new deps
        new-pc  new-pc
      ==
    $(deps t.deps)                                      ::  next dep
  ::
  --
::
::  $merk-dag: content-addressed map of nodes
::
::    maps content hashes to nodes. each hash is computed from the node's
::    content and the hashes of its dependencies, forming a merkle tree.
::    used to detect changes in the dependency graph and enable caching.
::
+$  merk-dag  (map @ node)
::
::  $path-dag: path-addressed map of nodes with their content hashes
::
::    maps file paths to [hash node] pairs. provides a way to look up nodes
::    by path while maintaining the connection to their content hash in the
::    merk-dag. used during traversal to find dependencies by path.
::
+$  path-dag  (map path [@ node])
::
::  $graph-view: adjacency matrix with easier access to neighbors
::
::    used to keep track of traversal when building the merkle DAG
::
+$  graph-view  (map path (set path))
::
::  $build-merk-dag: builds a merkle DAG out of the dependency folder
::
::    .nodes: the nodes of the dependency graph
::
::    returns a merkle DAG and a path-dag
++  build-merk-dag
  |^
  ::
  ::  node set of entire dir + target
  |=  nodes=(map path node)
  ^-  [merk-dag path-dag]
  ~&  >>  building-merk-dag-for+~(key by nodes)
  ::
  ::  need a way to uniquely identify dep directories
  =|  dep-dag=merk-dag
  =|  =path-dag
  =/  graph  (build-graph-view nodes)
  =/  next=(map path node)  (update-next nodes graph)
  ::
  ::  traverse via a topological sorting of the DAG using Kahn's algorithm
  |-
  ?:  .=(~ next)
    ?.  .=(~ graph)
      ~|(cycle-detected+~(key by graph) !!)
    [dep-dag path-dag]
  =-
    %=  $
      next   (update-next nodes graph)
      graph  graph
      dep-dag  dd
      path-dag  pd
    ==
  ^-  [graph=(map path (set path)) dd=(map @ node) pd=^path-dag]
  ::
  ::  every node in next is put into path-dag and dep-dag along with
  ::  its hash
  %+  roll
    ~(tap by next)
  |=  [[p=path n=node] graph=_graph dep-dag=_dep-dag path-dag=_path-dag]
  =/  hash  (calculate-hash n dep-dag path-dag)
  :+  (update-graph-view graph p)
    (~(put by dep-dag) hash n)
  (~(put by path-dag) p [hash n])
  ::
  ::  $calculate-hash: calculate the hash of a node
  ::
  ::    .n: the node to calculate the hash of
  ::    .dep-dag: the merkle DAG of the dependency graph
  ::    .path-dag: the path-dag of the dependency graph
  ::
  ::    returns the hash of the node
  ++  calculate-hash
    |=  [n=node dep-dag=merk-dag =path-dag]
    ^-  @
    %+  roll
      deps.n
    |=  [raut hash=_hash.n]
    ?.  (~(has by path-dag) pax)
      ~&  >>>  "calculate-hash: Missing {<pax>}"  !!
    =/  [dep-hash=@ *]
      (~(got by path-dag) pax)
    (shax (rep 8 ~[hash dep-hash]))
  --
::
::  $compile-target: compile a target hoon file
::
::    .pat: path to the target hoon file
::    .path-dag: the path-dag of the dependency graph
::    .nodes: the nodes of the dependency graph
::    .bc: the build cache
::
::    returns a trap vase with the compiled hoon file and the updated build
::    cache. if a build failure is detected, a bunted (trap vase) is returned
::    instead.
++  compile-target
  |^
  |=  [pat=path =path-dag nodes=(map path node) bc=build-cache]
  ^-  [(trap vase) build-cache]
  ~&  >>  compiling-target+pat
  =/  n=node
    ~|  """
        couldn't find node {<pat>} in path-dag.
        nodes: {<~(key by nodes)>}
        path-dag: {<~(key by path-dag)>}
        """
    +:(~(got by path-dag) pat)
  =/  graph  (build-graph-view nodes)
  =/  next=(map path node)  (update-next nodes graph)
  =|  failed=_|
  |-  ^-  [(trap vase) build-cache]
  ?:  failed  [empty-trap-vase bc]
  ?:  .=(~ next)
    =/  [=build-result new-bc=build-cache]
      (compile-node n path-dag bc)
    ?-  -.build-result
      ::
      %|  ~&  >>>  "compile-target: failed: {<pat>}"
          [empty-trap-vase new-bc]
      ::
      %&  [p.build-result new-bc]
    ==
  =/  [err=? bc=build-cache]
    %+  roll  ~(tap by next)
    |=  [[p=path n=node] [err=_| bc=_bc]]
    =/  [=build-result new-bc=build-cache]
      (compile-node n path-dag bc)
    ?-  -.build-result
      ::
      %|  ~&  >>>  "compile-target: failed: {<p>}"
          [& new-bc]
      ::
      %&  [err new-bc]
    ==
  =.  graph
    (roll ~(tap by next) |=([[p=path *] g=_graph] (update-graph-view g p)))
  %=  $
    next       (update-next nodes graph)
    graph      graph
    bc         bc
    failed     err
  ==
  ::
  ::  $compile-node: compile a single node
  ::
  ::    .n: the node to compile
  ::    .path-dag: the path-dag of the dependency graph
  ::    .bc: the build cache
  ::
  ::    looks up the node in the build cache and compiles it if it's not already
  ::    cached.
  ::
  ::    returns a $build-result and the updated build cache
  ++  compile-node
    |=  [n=node =path-dag bc=build-cache]
    ^-  [build-result build-cache]
    =/  [dep-hash=@ *]  (~(got by path-dag) path.n)
    ?:  (~(has by bc) dep-hash)
      ~&  >  build-cache-hit+path.n
      :_  bc
      [%.y (~(got by bc) dep-hash)]
    ~&  >  build-cache-miss+path.n
    =/  =build-result  (mule |.((build-node n path-dag bc)))
    =?  bc  ?=(%& -.build-result)
      (~(put by bc) dep-hash p.build-result)
    =-  ?.  ?=(%| -.build-result)  -
        ((slog p.build-result) -)
    [build-result bc]
  ::
  ::  $build-node: build a single node and its dependencies
  ::
  ::    .n: the node to compile
  ::    .path-dag: the path-dag of the dependency graph
  ::    .bc: the build cache
  ::
  ::    returns a trap vase with the compiled hoon
  ++  build-node
    |=  [n=node =path-dag bc=build-cache]
    ^-  (trap vase)
    ~>  %bout
    =;  dep-vaz=(trap vase)
      ?:  ?=(%hoon -.leaf.n)
        ::
        ::  Faces are resolved via depth-first search into the subject.
        ::  We append the honc (hoon.hoon) to the end of the vase
        ::  because imports have higher precedence when resolving faces.
        ::  To avoid shadowing issues with hoon.hoon, attach faces to your
        ::  imports or avoid shadowed names altogether.
        =/  swetted=(trap vase)  (swet (slat dep-vaz honc) hoon.leaf.n)
        ?.  eval.n
          swetted
        ~&  "node {<path.n>} is eval, kicking"
        =>  [swetted=swetted vase=vase]
        =/  vaz=vase  $:swetted
        =>  vaz=vaz
        |.(vaz)
      =>  octs=!>(octs.leaf.n)
      |.(octs)
    %+  roll  deps.n
    |:  [r=`raut`*raut vaz=empty-trap-vase]
    ~&  >  grabbing-dep+pax.r
    =/  [dep-hash=@ dep-node=node]
      ~|  "couldn't find dep hash for {<pax.r>}"
      (~(got by path-dag) pax.r)
    =/  dep-vaz=(trap vase)
      ~|  "couldn't find artifact for {<pax.r>} in build cache"
      (~(got by bc) dep-hash)
    ~&  >  attaching-face+face.r
    ::
    ::  Ford imports are included in the order that they appear in the deps.
    (slat vaz (label-vase dep-vaz face.r))
  ::
  ::  $label-vase: label a (trap vase) with a face
  ::
  ::    .vaz: the (trap vase) to label
  ::    .face: the face to label the (trap vase) with
  ::
  ::    returns a (trap vase) labeled with the given face
  ++  label-vase
    |=  [vaz=(trap vase) face=(unit @tas)]
    ^-  (trap vase)
    ?~  face  vaz
    =>  [vaz=vaz face=u.face]
    |.
    =/  vas  $:vaz
    [[%face face p.vas] q.vas]
  --
::
::  $update-next: returns nodes from a $graph-view that have no outgoing edges
::
::    .nodes: the nodes of the dependency graph
::    .gv: the graph-view of the dependency graph
::
::    assumes that entries in $nodes that are not in the $graph-view have
::    already been visited.
::
++  update-next
  |=  [nodes=(map path node) gv=graph-view]
  ^-  (map path node)
  ::
  ::  if we don't have the entry in gv, already visited
  %+  roll
    ~(tap by gv)
  |=  [[pax=path edges=(set path)] next=(map path node)]
  ::
  :: if a node has no out edges, add it to next
  ?.  =(*(set path) edges)
    next
  %+  ~(put by next)
    pax
  (~(got by nodes) pax)
::
::  $update-graph-view: updates a $graph-view by removing a $path
::
::    .gv: the graph-view to update
::    .p: the path to remove from the graph-view
::
::    deletes the $path from the $graph-view and removes it from all edge sets
::
++  update-graph-view
  |=  [gv=graph-view p=path]
  ^-  graph-view
  =.  gv  (~(del by gv) p)
  %-  ~(urn by gv)
  |=  [pax=path edges=(set path)]
  (~(del in edges) p)
::
::  $build-graph-view: build a graph-view from a node map
::
::    .nodes: the nodes of the dependency graph
::
::    returns a graph-view of the dependency graph
::
++  build-graph-view
  |=  nodes=(map path node)
  ^-  graph-view
  %-  ~(urn by nodes)
  |=  [* n=node]
  %-  silt
  (turn deps.n |=(raut pax))
::
::  $slat: merge two (trap vase)s
::
::    .hed: the first (trap vase)
::    .tal: the second (trap vase)
::
::    returns a merged (trap vase)
++  slat
  |=  [hed=(trap vase) tal=(trap vase)]
  ^-  (trap vase)
  =>  +<
  |.
  =+  [bed bal]=[$:hed $:tal]
  [[%cell p:bed p:bal] [q:bed q:bal]]
::  +shot: deferred slam
::
::    .gat: the gate to slam with the sample as a (trap vase)
::    .sam: the sample to slam with the gate
::
::    NOTE: this should never run inside of a trap. if it does, the builder
::    dependencies will leak into the result.
::
++  shot
  |=  [gat=(trap vase) sam=(trap vase)]
  ^-  (trap vase)
  =/  [typ=type gen=hoon]
    :-  [%cell p:$:gat p:$:sam]
    [%cnsg [%$ ~] [%$ 2] [%$ 3] ~]
  =+  gun=(~(mint ut typ) %noun gen)
  =>  [typ=p.gun +<.$]
  |.
  [typ .*([q:$:gat q:$:sam] [%9 2 %10 [6 %0 3] %0 2])]
::
::  +swet: deferred +slap
::
::  NOTE: this is +swat but with a bug fixed that caused a space leak in
::  the resulting trap vases.
::
++  swet
  |=  [tap=(trap vase) gen=hoon]
  ^-  (trap vase)
  =/  gun  (~(mint ut p:$:tap) %noun gen)
  =>  [gun=gun tap=tap]
  |.  ~+
  [p.gun .*(q:$:tap q.gun)]
::
++  get-file                                          ::  get file contents
  |=  [suf=entry dir=(map path cord)]
  ^-  cord
  ?~  tex.suf
    ~|  "file not found: {<pat.suf>}"
    (~(got by dir) pat.suf)
  u.tex.suf
::
++  is-hoon
  |=  pax=path
  ^-  ?
  =/  end  (rear pax)
  !=(~ (find ".hoon" (trip end)))
::
++  is-dat
  |=  pax=path
  ^-  ?
  =('dat' (head pax))
--
