#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)


D=args[1]
O=basename(args[2])
gaf_pattern=args[3]

d=gsub("^input/","",D)
d=gsub("_sets/?","",d)
if (! file.exists(sprintf("analysis/%s",d)))
	dir.create(sprintf("analysis/%s",d))
print(sprintf("Processing %s %s",D,O))
a=NULL
if (! file.exists(sprintf("analysis/%s/%s",d,O)))
	dir.create(sprintf("analysis/%s/%s",d,O))
if (! file.exists(sprintf("analysis/%s/%s/sets",d,O)))
	dir.create(sprintf("analysis/%s/%s/sets",d,O))
if (! file.exists(sprintf("analysis/%s/%s/out",d,O)))
	dir.create(sprintf("analysis/%s/%s/out",d,O))

file.symlink(sprintf(paste("../../../",gaf_pattern,sep=""),O), sprintf("analysis/%s/%s/input.gaf",d,O))
file.symlink(sprintf("../../../Ontologies/%s.obo",O), sprintf("analysis/%s/%s/ontology.obo",d,O))
file.symlink(sprintf("../../../Snakefile.sub",O), sprintf("analysis/%s/%s/Snakefile",d,O))

if (file.exists(sprintf("./Annotation/%s.RData",O))) {
	load(sprintf("./Annotation/%s.RData",O))
} else {
	print(sprintf(gaf_pattern,O))
	a<-read.delim(sprintf(gaf_pattern,O),sep="\t",stringsAsFactors=FALSE,header=FALSE, comment.char="",skip=1)
	a<-unique(a[,2]) # depends on which column the IDs in the sets are in
	save(a,file=sprintf("./Annotation/%s.RData",O))
}

FF=unique(unlist(sapply(list.files(D,pattern="*.set"),function(f) {
						F=sprintf("%s/%s",D,f)
						G=unique(read.table(F,sep="\t",stringsAsFactors=FALSE,header=FALSE)[,1])

						dname=sprintf("analysis/%s/%s/sets",d,O)
						oname=sprintf("analysis/%s/%s/out",d,O)

						y=G[G %in% a] 
						if (length(y)>0) {
							x=gsub("\\.set","",f)
							write.table(y,file=paste(dname,paste(x,"set",sep="."),sep="/"),sep="\t", row.names=FALSE,col.names=FALSE,quote=FALSE)
							return(y)
						}
})))
#compare among sets
#write.table(unlist(FF),file=sprintf("analysis/%s/%s/pop",d,O), row.names=FALSE,col.names=FALSE,quote=FALSE)

#compare against entire population
write.table(a,file=sprintf("analysis/%s/%s/pop",d,O), row.names=FALSE,col.names=FALSE,quote=FALSE)

