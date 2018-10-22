import pandas as pd
import os

O = ["GO","PO","TO"]
G = ["phosphorylation_capacity"]
gaf_pattern="annotation/Arabidopsis.%s.gaf"

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
		"./compile_significant.R analysis Benjamini-Hochberg 0.05 {output.BH}; ./compile_significant.R analysis Bonferroni-Holm 0.05 {output.BF}"

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
