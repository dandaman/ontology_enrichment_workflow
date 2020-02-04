import pandas as pd
import os

O = ["GO","PO","TO"] # which ontologies should be tested
G = ["wheat"] # multiple groups of gene sets can be compared indepently within each group i.e. each has its own pop file
gaf_pattern="annotation/Triticum_aestivum_V1.1_PGSB_%sA_by_orthology.gaf" # pattern to hold the ontology pattern to associate obo with gaf2 file

rule all: 
	input: 
		expand("analysis/{group}/{O}/DONE",group=G,O=O),
		"analysis/significantly_enriched_terms.Bonferroni-Holm.txt",
		"analysis/significantly_enriched_terms.Benjamini-Hochberg.txt"

rule prepare_set:
	input:	
		"input/{group}_sets/"
	output:
		"analysis/{group}/{O}",
		"analysis/{group}/{O}/Snakefile"
	shell:
		"./prepare_sets.R {input} {output[0]} {gaf_pattern}"

rule make_subset:
	input: 
		"analysis/{group}/{O}",
	output:
		"analysis/{group}/{O}/DONE"
	shell:
		"cd {input}; snakemake ; cd -;"

rule compile_results:
	input:
		expand("analysis/{group}/{O}/DONE",group=G,O=O)
	output:
		BH="analysis/significantly_enriched_terms.Benjamini-Hochberg.txt",
		BF="analysis/significantly_enriched_terms.Bonferroni-Holm.txt"
	shell:
		"./compile_significant.R analysis Benjamini-Hochberg 0.1 {output.BH}; ./compile_significant.R analysis Bonferroni-Holm 0.1 {output.BF}" # adjust the cutoff to more stringent levels i.e. 0.01 or 0.05 if your getting too many genes

rule clean:
	input:
		expand("analysis/{group}",group=G)
	shell:
		"rm -r {input}"

rule clean_all:
	input:
		expand("Annotation/{O}.RData",O=O),
		expand("analysis/{group}",group=G)
	shell:
		"rm -r {input}"
