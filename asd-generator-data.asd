;;;; asd-generator-data.asd

((#:package)
 (#:helper (#:lib (#:safe-reader (#:utils)
				 (:rest)))
	   (:rest))
 (#:protocol)
 (#:constants) 
 (#:data (:rest)) 
 (#:impl (:rest)
	 (#:shard (#:message)
		  (#:password)
		  (#:persona)
		  (:rest))
	 (#:server (:rest)
		   (#:get-sexp)))
 (#:gateway))
